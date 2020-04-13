FROM php:7.4-alpine
WORKDIR /usr/src/app
RUN apk add --no-cache util-linux
COPY docker-entrypoint.sh .
COPY *.php ./
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
