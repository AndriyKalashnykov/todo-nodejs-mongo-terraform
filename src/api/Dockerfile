FROM node:24-alpine@sha256:7e0bd0460b26eb3854ea5b99b887a6a14d665d14cae694b78ae2936d14b2befb AS build

WORKDIR /app

COPY . .

RUN npm ci
RUN npm run build

CMD ["npm","run","start"]
