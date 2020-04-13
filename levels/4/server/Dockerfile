FROM ruby:2.7.0-alpine
WORKDIR /usr/src/app
RUN apk add --no-cache build-base sqlite sqlite-dev sqlite-libs
RUN apk add inotify-tools --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
RUN gem install sinatra sequel sqlite3
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 4567
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
