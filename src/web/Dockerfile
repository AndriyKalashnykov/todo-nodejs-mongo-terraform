FROM node:22-alpine@sha256:dbcedd8aeab47fbc0f4dd4bffa55b7c3c729a707875968d467aaaea42d6225af AS build

# make the 'app' folder the current working directory
WORKDIR /app

COPY . .

# install project dependencies
RUN npm ci
RUN npm run build

FROM nginx:alpine@sha256:7c1b9a91514d1eb5288d7cd6e91d9f451707911bfaea9307a3acbc811d4aa82e

WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist .
COPY --from=build /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["/bin/sh", "-c", "nginx -g \"daemon off;\""]
