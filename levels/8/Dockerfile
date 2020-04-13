FROM python:2.7.17-alpine3.11
RUN apk add --no-cache build-base
RUN pip install twisted==11.1.0
WORKDIR /usr/src/app
COPY . .
EXPOSE 4000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
