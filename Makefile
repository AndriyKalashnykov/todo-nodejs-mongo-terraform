.DEFAULT_GOAL := help

APP_NAME       := todo-nodejs-mongo-terraform
CURRENTTAG     := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "dev")

API_DIR        := src/api
WEB_DIR        := src/web
TEST_DIR       := tests

# === Tool Versions (pinned) ===
NVM_VERSION      := 0.40.4
NODE_VERSION     := 24
ACT_VERSION      := 0.2.87
HADOLINT_VERSION := 2.14.0

# === pnpm (CI-safe: uses --frozen-lockfile when CI=true) ===
PNPM_INSTALL    := pnpm install $(if $(CI),--frozen-lockfile,)

# === Docker ===
API_IMAGE       := todo-api
WEB_IMAGE       := todo-web
DOCKER_TAG      ?= $(CURRENTTAG)

# Helper: source nvm in a subshell (nvm is a shell function, not a binary)
define nvm-exec
bash -c 'export NVM_DIR="$$HOME/.nvm"; [ -s "$$NVM_DIR/nvm.sh" ] && . "$$NVM_DIR/nvm.sh" && $(1)'
endef

#help: @ List available tasks
help:
	@echo "Usage: make COMMAND"
	@echo "Commands :"
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-22s\033[0m - %s\n", $$1, $$2}'

#deps: @ Install required tools (idempotent)
deps:
	@command -v node >/dev/null 2>&1 || { \
		echo "Installing nvm $(NVM_VERSION) + Node $(NODE_VERSION)..."; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash; \
		$(call nvm-exec,nvm install $(NODE_VERSION)); \
	}
	@command -v pnpm >/dev/null 2>&1 || { \
		echo "Installing pnpm via corepack..."; \
		corepack enable pnpm; \
	}

#deps-check: @ Show installed tool versions
deps-check:
	@printf "  %-16s " "node:"; command -v node >/dev/null 2>&1 && node --version || echo "NOT installed"
	@printf "  %-16s " "pnpm:"; command -v pnpm >/dev/null 2>&1 && pnpm --version || echo "NOT installed"
	@printf "  %-16s " "docker:"; command -v docker >/dev/null 2>&1 && docker --version || echo "NOT installed"
	@printf "  %-16s " "hadolint:"; command -v hadolint >/dev/null 2>&1 && hadolint --version || echo "NOT installed"
	@printf "  %-16s " "act:"; command -v act >/dev/null 2>&1 && act --version || echo "NOT installed"

#deps-act: @ Install act for local CI
deps-act: deps
	@command -v act >/dev/null 2>&1 || { echo "Installing act $(ACT_VERSION)..."; \
		curl -sSfL https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash -s -- -b /usr/local/bin v$(ACT_VERSION); \
	}

#deps-hadolint: @ Install hadolint for Dockerfile linting
deps-hadolint:
	@command -v hadolint >/dev/null 2>&1 || { echo "Installing hadolint $(HADOLINT_VERSION)..."; \
		curl -sSfL -o /tmp/hadolint https://github.com/hadolint/hadolint/releases/download/v$(HADOLINT_VERSION)/hadolint-Linux-x86_64 && \
		install -m 755 /tmp/hadolint /usr/local/bin/hadolint && \
		rm -f /tmp/hadolint; \
	}

#install: @ Install pnpm dependencies for all packages
install: deps
	@cd $(API_DIR) && $(PNPM_INSTALL)
	@cd $(WEB_DIR) && $(PNPM_INSTALL)
	@cd $(TEST_DIR) && $(PNPM_INSTALL)

#clean: @ Remove build artifacts
clean:
	@rm -rf $(API_DIR)/dist $(WEB_DIR)/dist
	@rm -rf $(API_DIR)/node_modules $(WEB_DIR)/node_modules $(TEST_DIR)/node_modules
	@rm -rf $(API_DIR)/coverage

#lint: @ Lint all code and Dockerfiles
lint: deps deps-hadolint
	@echo "=== Lint API ==="
	@cd $(API_DIR) && $(PNPM_INSTALL) && pnpm run lint
	@echo "=== Lint Web ==="
	@cd $(WEB_DIR) && $(PNPM_INSTALL) && pnpm run lint
	@echo "=== Lint Dockerfiles ==="
	@hadolint $(API_DIR)/Dockerfile
	@hadolint $(WEB_DIR)/Dockerfile

#build: @ Build API and Web
build: deps
	@echo "=== Build API ==="
	@cd $(API_DIR) && $(PNPM_INSTALL) && pnpm run build
	@echo "=== Build Web ==="
	@cd $(WEB_DIR) && $(PNPM_INSTALL) && pnpm run build

#test: @ Run API tests (requires MongoDB - use compose-up first)
test: deps
	@cd $(API_DIR) && $(PNPM_INSTALL) && pnpm test

#e2e: @ Run Playwright end-to-end tests
e2e: deps
	@cd $(TEST_DIR) && $(PNPM_INSTALL) && pnpm exec playwright install --with-deps && pnpm exec playwright test

#run: @ Start API and Web locally (API on :3100, Web on :3000)
run: deps
	@echo "Starting API on http://localhost:3100 and Web on http://localhost:3000"
	@cd $(API_DIR) && $(PNPM_INSTALL) && pnpm start &
	@cd $(WEB_DIR) && $(PNPM_INSTALL) && pnpm run dev

#ci: @ Run full local CI pipeline (lint, build)
ci: deps lint build
	@echo "Local CI pipeline passed."

#ci-run: @ Run GitHub Actions workflow locally using act
ci-run: deps-act
	@echo '{"act": true}' > /tmp/act-event.json
	@act push --container-architecture linux/amd64 \
		--artifact-server-path /tmp/act-artifacts \
		--eventpath /tmp/act-event.json
	@rm -f /tmp/act-event.json

#image-build: @ Build Docker images for API and Web
image-build: build
	@echo "=== Build API image ==="
	@docker buildx build --load -t $(API_IMAGE):$(DOCKER_TAG) $(API_DIR)
	@echo "=== Build Web image ==="
	@docker buildx build --load -t $(WEB_IMAGE):$(DOCKER_TAG) $(WEB_DIR)

#image-run: @ Run Docker containers
image-run: image-stop
	@docker run --rm -d -p 3100:3100 --name $(API_IMAGE) $(API_IMAGE):$(DOCKER_TAG)
	@docker run --rm -d -p 3000:80 --name $(WEB_IMAGE) $(WEB_IMAGE):$(DOCKER_TAG)
	@echo "API running on http://localhost:3100"
	@echo "Web running on http://localhost:3000"

#image-stop: @ Stop Docker containers
image-stop:
	@docker stop $(API_IMAGE) 2>/dev/null || true
	@docker stop $(WEB_IMAGE) 2>/dev/null || true

#compose-up: @ Start all services with Docker Compose (API + Web + MongoDB)
compose-up:
	@docker compose up -d --build
	@echo "MongoDB on mongodb://localhost:27017"
	@echo "API running on http://localhost:3100"
	@echo "Web running on http://localhost:3000"

#compose-down: @ Stop and remove all Docker Compose services
compose-down:
	@docker compose down -v

#compose-logs: @ Tail logs from all Docker Compose services
compose-logs:
	@docker compose logs -f

#renovate-validate: @ Validate Renovate configuration
renovate-validate: deps
	@pnpm dlx renovate --platform=local

#release: @ Create and push a new tag
release:
	@bash -c 'read -p "New tag (current: $(CURRENTTAG)): " newtag && \
		echo "$$newtag" | grep -qE "^v[0-9]+\.[0-9]+\.[0-9]+$$" || { echo "Error: Tag must match vN.N.N"; exit 1; } && \
		echo -n "Create and push $$newtag? [y/N] " && read ans && [ "$${ans:-N}" = y ] && \
		git add -A && \
		git commit -a -s -m "Cut $$newtag release" && \
		git tag $$newtag && \
		git push origin $$newtag && \
		git push && \
		echo "Done."'

.PHONY: help deps deps-check deps-act deps-hadolint install clean \
	lint build test e2e run ci ci-run \
	image-build image-run image-stop \
	compose-up compose-down compose-logs \
	renovate-validate release
