FROM python:3.8.2-slim-buster
RUN apt-get update && apt-get install uuid-runtime && apt-get clean
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
