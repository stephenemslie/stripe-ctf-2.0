FROM ruby:2.7.0-alpine
WORKDIR /usr/src/app
RUN apk add --no-cache build-base sqlite sqlite-dev sqlite-libs
RUN gem install sinatra sequel sqlite3
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 4567
ENTRYPOINT ["./docker-entrypoint.sh"]
