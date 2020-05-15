FROM node:13.14-buster-slim as node
WORKDIR /usr/src/app
COPY package.json package.json
RUN npm install
COPY *.config.js ./
COPY templates /usr/src/app/templates/
COPY docker-entrypoint.sh .
COPY assets ./assets/
RUN npm run build
RUN touch static/index.html
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["npmwatch"]

FROM golang:1.14-buster as go
RUN set -eux; \
    apt-get update; \
    apt-get install -y git
WORKDIR /usr/src/app
COPY go.mod /usr/src/app/go.mod
RUN go mod download
RUN go get github.com/githubnemo/CompileDaemon
COPY . /usr/src/app
COPY --from=node /usr/src/app/static/ /usr/src/app/static/
RUN mkdir -p /usr/src/bin
run go build -o /usr/src/app/bin/ctfproxy /usr/src/app/main.go
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["gowatch"]

FROM debian:buster-slim as deploy
RUN set -eux; \
    apt-get update; \
    apt-get install -y gosu; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
WORKDIR /usr/src/app
COPY . /usr/src/app
COPY --from=node /usr/src/app/static/ /usr/src/app/static/
COPY --from=go /usr/src/app/bin /usr/src/app/bin/
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
