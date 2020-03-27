FROM node:13.8-alpine as node
WORKDIR /usr/src/app
COPY package.json package.json
RUN npm install
COPY assets ./assets
COPY static ./static
RUN npm run build:css
ENTRYPOINT ["./docker-entrypoint.sh"]

FROM golang:1.13-alpine
RUN apk add git
WORKDIR /usr/src/app
COPY go.mod /usr/src/app/go.mod
RUN go mod download
RUN go get github.com/githubnemo/CompileDaemon
COPY . /go/src/app
COPY --from=0 /usr/src/app/static/styles.css /usr/src/app/static/styles.css
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
