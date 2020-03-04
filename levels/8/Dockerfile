FROM python:3.8.1-alpine
RUN apk add --no-cache build-base
RUN pip install twisted
WORKDIR /usr/src/app
RUN base64 /dev/urandom | head -c 10 > password.txt
COPY . .
EXPOSE 4000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
