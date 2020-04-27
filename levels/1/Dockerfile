FROM php:7.4-alpine
WORKDIR /usr/src/app
RUN apk add --no-cache util-linux
COPY docker-entrypoint.sh .
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN composer require google/cloud-secret-manager
COPY *.php ./
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
