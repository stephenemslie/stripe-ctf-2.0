FROM node:13.8.0
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN node ctf-install.js `base64 /dev/urandom | head -c 10`
EXPOSE 3000
CMD ["node", "level00.js"]
