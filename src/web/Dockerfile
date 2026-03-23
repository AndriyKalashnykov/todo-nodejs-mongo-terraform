FROM node:22-alpine@sha256:8094c002d08262dba12645a3b4a15cd6cd627d30bc782f53229a2ec13ee22a00 AS build

# make the 'app' folder the current working directory
WORKDIR /app

COPY . .

# install project dependencies
RUN npm ci
RUN npm run build

FROM nginx:alpine@sha256:f46cb72c7df02710e693e863a983ac42f6a9579058a59a35f1ae36c9958e4ce0

WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist .
COPY --from=build /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["/bin/sh", "-c", "nginx -g \"daemon off;\""]
