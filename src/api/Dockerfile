FROM node:24-alpine@sha256:4f696fbf39f383c1e486030ba6b289a5d9af541642fc78ab197e584a113b9c03 AS build

WORKDIR /app

COPY . .

RUN npm ci
RUN npm run build

CMD ["npm","run","start"]
