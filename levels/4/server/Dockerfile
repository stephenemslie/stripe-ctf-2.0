FROM ruby:2.6.6-slim-buster
WORKDIR /usr/src/app
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends gosu curl gnupg gnupg2 ca-certificates build-essential libsqlite3-dev inotify-tools; \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add -; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends google-cloud-sdk; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
RUN gem install sinatra sequel sqlite3 google-cloud-secret_manager
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 4567
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
