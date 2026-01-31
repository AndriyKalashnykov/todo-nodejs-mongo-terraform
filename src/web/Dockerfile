FROM node:22-alpine@sha256:e4bf2a82ad0a4037d28035ae71529873c069b13eb0455466ae0bc13363826e34 AS build

# make the 'app' folder the current working directory
WORKDIR /app

COPY . .

# install project dependencies
RUN npm ci
RUN npm run build

FROM nginx:alpine@sha256:4870c12cd2ca986de501a804b4f506ad3875a0b1874940ba0a2c7f763f1855b2

WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist .
COPY --from=build /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["/bin/sh", "-c", "nginx -g \"daemon off;\""]
