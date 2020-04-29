FROM python:3.8.2-slim-buster
RUN pip install bcrypt \
                requests \
                flask \
                google-cloud-secret-manager
WORKDIR /usr/src/app
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 9233
ENTRYPOINT ["./docker-entrypoint.sh"]
