FROM node:13.8-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN node ctf-install.js `base64 /dev/urandom | head -c 10`
EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["node", "level00.js"]
