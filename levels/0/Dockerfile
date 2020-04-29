FROM node:13-buster-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["serve"]
