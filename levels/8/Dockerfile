FROM python:3.8.1-alpine
RUN apk add --no-cache build-base
RUN pip install twisted
WORKDIR /usr/src/app
COPY . .
EXPOSE 4000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
