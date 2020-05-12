FROM node:13.8-alpine as node
WORKDIR /usr/src/app
COPY package.json package.json
RUN npm install
COPY *.config.js .
COPY docker-entrypoint.sh .
COPY assets ./assets
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
COPY --from=node /usr/src/app/static/bundle.js /usr/src/app/static/bundle.js
RUN mkdir -p /usr/src/bin
run go build -o /usr/src/app/bin/ctfproxy /usr/src/app/main.go
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["gowatch"]

FROM golang:1.13-alpine as deploy
WORKDIR /usr/src/app
COPY --from=gcr.io/stripe-ctf-demo/level0 /usr/src/app/level00.html /usr/src/app/level00.js /usr/src/levels/0/
COPY --from=gcr.io/stripe-ctf-demo/level1 /usr/src/app/index.php /usr/src/app/routing.php /usr/src/levels/1/
COPY --from=gcr.io/stripe-ctf-demo/level2 /usr/src/app/index.php /usr/src/app/routing.php /usr/src/levels/2/
COPY --from=gcr.io/stripe-ctf-demo/level3 /usr/src/app/index.html /usr/src/app/secretvault.py /usr/src/levels/3/
COPY --from=gcr.io/stripe-ctf-demo/level4-server /usr/src/app/srv.rb /usr/src/levels/4/server/
COPY --from=gcr.io/stripe-ctf-demo/level4-server /usr/src/app/views /usr/src/levels/4/server/views/
COPY --from=gcr.io/stripe-ctf-demo/level5 /usr/src/app/srv.rb /usr/src/levels/5/
COPY --from=gcr.io/stripe-ctf-demo/level6-server /usr/src/app/srv.rb /usr/src/levels/6/server/
COPY --from=gcr.io/stripe-ctf-demo/level6-server /usr/src/app/views /usr/src/levels/6/server/views/
COPY --from=gcr.io/stripe-ctf-demo/level7 /usr/src/app/*.py /usr/src/levels/7/
COPY --from=gcr.io/stripe-ctf-demo/level7 /usr/src/app/templates /usr/src/levels/7/templates/
COPY --from=gcr.io/stripe-ctf-demo/level8 /usr/src/app/primary_server /usr/src/app/chunk_server /usr/src/app/password_db_launcher /usr/src/app/common.py /usr/src/levels/8/
COPY . /usr/src/app
COPY --from=node /usr/src/app/static/bundle.js /usr/src/app/static/bundle.js
COPY --from=go /usr/src/app/bin /usr/src/app/bin
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
