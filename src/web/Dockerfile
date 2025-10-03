FROM node:22-alpine@sha256:cb3143549582cc5f74f26f0992cdef4a422b22128cb517f94173a5f910fa4ee7 AS build

# make the 'app' folder the current working directory
WORKDIR /app

COPY . .

# install project dependencies
RUN npm ci
RUN npm run build

FROM nginx:alpine@sha256:42a516af16b852e33b7682d5ef8acbd5d13fe08fecadc7ed98605ba5e3b26ab8

WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist .
COPY --from=build /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["/bin/sh", "-c", "nginx -g \"daemon off;\""]
