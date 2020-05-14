FROM python:3.8.2-slim-buster
WORKDIR /usr/src/app
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends gosu uuid-runtime; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
