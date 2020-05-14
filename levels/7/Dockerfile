FROM python:3.8.2-slim-buster
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends gosu; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
RUN pip install bcrypt \
                requests \
                flask \
                google-cloud-secret-manager
WORKDIR /usr/src/app
COPY . .
RUN chmod a+x docker-entrypoint.sh
EXPOSE 9233
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
