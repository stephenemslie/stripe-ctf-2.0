FROM php:7.4-alpine
WORKDIR /usr/src/app
RUN base64 /dev/urandom | head -c 10 > password.txt
RUN mkdir uploads
COPY *.php ./
EXPOSE 8000
CMD php -t . -S 0.0.0.0:8000 routing.php
