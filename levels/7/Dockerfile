FROM python:3.8.1-alpine
RUN apk add --no-cache build-base libffi-dev
RUN pip install bcrypt \
                requests \
                flask \
                google-cloud-secret-manager
WORKDIR /usr/src/app
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 9233
ENTRYPOINT ["./docker-entrypoint.sh"]
