FROM golang:1.13-alpine
RUN apk add git
WORKDIR /go/src/app
COPY main.go /go/src/app/main.go
RUN go get
COPY . /go/src/app
EXPOSE 8000
