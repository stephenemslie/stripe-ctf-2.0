FROM php:7.4.5-cli-buster
WORKDIR /usr/src/app
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends gosu uuid-runtime git; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
COPY docker-entrypoint.sh .
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN composer require google/cloud-secret-manager
COPY *.php ./
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
