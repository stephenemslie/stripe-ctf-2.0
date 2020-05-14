FROM php:7.4.5-cli-buster
WORKDIR /usr/src/app
RUN mkdir uploads
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN composer require google/cloud-secret-manager
COPY . .
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
