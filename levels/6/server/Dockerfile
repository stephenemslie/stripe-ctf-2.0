FROM ruby:2.6.6-slim-buster
WORKDIR /usr/src/app
RUN apt-get update && \
    apt install -y build-essential \
                   libsqlite3-dev \
                   inotify-tools && \
    apt-get clean
COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle install
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 4567
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
