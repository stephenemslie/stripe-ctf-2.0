FROM php:7.4.5-cli-buster
WORKDIR /usr/src/app
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends gosu curl gnupg2 ca-certificates; \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add -; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends google-cloud-sdk; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
RUN mkdir uploads
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN composer require google/cloud-secret-manager
COPY . .
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
