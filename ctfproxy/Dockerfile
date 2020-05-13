FROM node:13.8-alpine as node
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

FROM golang:1.13-alpine as go
RUN apk add --no-cache git
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

FROM golang:1.13-alpine as deploy
WORKDIR /usr/src/app
COPY . /usr/src/app
COPY --from=node /usr/src/app/static/ /usr/src/app/static/
COPY --from=go /usr/src/app/bin /usr/src/app/bin/
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
