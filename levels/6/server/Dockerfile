FROM ruby:2.6.6-slim-buster
WORKDIR /usr/src/app
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends gosu build-essential libsqlite3-dev inotify-tools; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle install
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 4567
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
