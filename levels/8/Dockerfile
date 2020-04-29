FROM python:2.7.17-slim-buster
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get clean
RUN pip install twisted==11.1.0 google-cloud-secret-manager
WORKDIR /usr/src/app
COPY . .
EXPOSE 4000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
