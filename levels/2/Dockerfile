FROM php:7.4-alpine
WORKDIR /usr/src/app
RUN mkdir uploads
COPY *.php ./
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
