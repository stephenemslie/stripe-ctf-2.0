FROM node:13.8-alpine as node
WORKDIR /usr/src/app
COPY package.json package.json
RUN npm install
COPY assets ./assets
COPY static ./static
RUN npm run build:css
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["npmwatch"]

FROM golang:1.13-alpine as go
RUN apk add --no-cache git
WORKDIR /usr/src/app
COPY go.mod /usr/src/app/go.mod
RUN go mod download
RUN go get github.com/githubnemo/CompileDaemon
COPY . /usr/src/app
COPY --from=0 /usr/src/app/static/styles.css /usr/src/app/static/styles.css
RUN mkdir -p /usr/src/bin
run go build -o /usr/src/app/bin/ctfproxy /usr/src/app/main.go
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
