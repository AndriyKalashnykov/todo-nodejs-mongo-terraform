# CLAUDE.md

## Project Overview

Full-stack Todo application with Node.js/Express API, React frontend, and Azure infrastructure managed by Terraform.

## Tech Stack

- **API:** Node.js + Express 5 + TypeScript + Mongoose (MongoDB)
- **Web:** React 19 + Vite + TypeScript + Fluent UI
- **Infrastructure:** Terraform on Azure (Cosmos DB, App Service, Key Vault, APIM)
- **E2E Tests:** Playwright
- **CI/CD:** GitHub Actions (lint -> build + test -> deploy) + Azure Developer CLI (azd)

## Project Structure

```
src/api/       # Express API (port 3100)
src/web/       # React frontend (port 3000)
infra/         # Terraform modules
tests/         # Playwright E2E tests
.github/       # GitHub Actions workflows
```

## Build & Run

```bash
make deps      # Install required tools (idempotent)
make lint      # Lint API, Web, and Dockerfiles
make build     # Build API and Web
make test      # Run API unit tests
make run       # Start API and Web locally
make ci        # Full local CI pipeline
```

## Key Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `NVM_VERSION` | 0.40.4 | nvm version for Node management |
| `NODE_VERSION` | 24 | Node.js major version |
| `ACT_VERSION` | 0.2.87 | act for local CI runs |
| `HADOLINT_VERSION` | 2.14.0 | Dockerfile linter |

## Environment Variables

**API** (`.env`): `AZURE_COSMOS_CONNECTION_STRING`, `AZURE_COSMOS_DATABASE_NAME`, `APPLICATIONINSIGHTS_CONNECTION_STRING`

**Web** (`.env.local`): `VITE_API_BASE_URL`, `VITE_APPLICATIONINSIGHTS_CONNECTION_STRING`

## Notes

- API tests require a running MongoDB instance (integration tests, not unit tests)
- Web uses `legacy-peer-deps=true` in `.npmrc` until `eslint-plugin-react-hooks` supports ESLint 10
- ESLint uses flat config format (`eslint.config.mjs` / `eslint.config.js`)

## Upgrade Backlog

Last reviewed: 2026-04-03

- [ ] Replace `yamljs` with `js-yaml` (abandoned 5+ years)
- [ ] Upgrade `@playwright/test` from ^1.22.2 to latest (37 minor versions behind)
- [ ] Update devcontainer from Bullseye (EOL) to Bookworm: `24-bookworm`
- [ ] Remove `@babel/plugin-proposal-private-property-in-object` (deprecated, unused with Vite)
- [ ] Remove `history` package (unnecessary with React Router v7)
- [ ] Upgrade `uuid` in tests from v8 to v9+ and drop `@types/uuid`
- [ ] Add `.nvmrc` and `engines` field to enforce Node.js version
- [ ] Switch CI from `npm install` to `npm ci`
- [ ] Upgrade API tsconfig target from `es2020` to `es2022`
- [ ] Evaluate TypeScript 6.0 migration when ecosystem is ready
- [ ] Consider upgrading OpenAPI spec from 3.0.0 to 3.1.0

## Skills

Use the following skills when working on related files:

| File(s) | Skill |
|---------|-------|
| `Makefile` | `/makefile` |
| `renovate.json` | `/renovate` |
| `README.md` | `/readme` |
| `.github/workflows/*.yml` | `/ci-workflow` |

When spawning subagents, always pass conventions from the respective skill into the agent's prompt.
