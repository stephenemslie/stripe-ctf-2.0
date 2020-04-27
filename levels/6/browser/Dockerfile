FROM zenika/alpine-chrome:77-with-puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 1
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
WORKDIR /usr/src/app
COPY package* ./
RUN npm install .
COPY index.js ./
CMD ["node", "index.js"]
