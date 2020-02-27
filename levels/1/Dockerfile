FROM php:7.4-alpine
WORKDIR /usr/src/app
RUN apk add --no-cache util-linux
RUN uuidgen > secret-combination.txt
RUN base64 /dev/urandom | head -c 10 > level02-password.txt
COPY *.php ./
EXPOSE 8000
CMD php -t . -S 0.0.0.0:8000 ./routing.php
