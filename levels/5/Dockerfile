FROM ruby:2.7.0-alpine
WORKDIR /usr/src/app
RUN apk add --no-cache build-base
RUN gem install sinatra rest-client
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 4568
ENTRYPOINT ["./docker-entrypoint.sh"]
