FROM python:3.8.2-slim-buster
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends gosu curl gnupg2 ca-certificates; \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add -; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends google-cloud-sdk; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
RUN pip install bcrypt requests flask
WORKDIR /usr/src/app
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 9233
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
