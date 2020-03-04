FROM python:3.8.1-alpine
RUN apk add --no-cache util-linux
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
