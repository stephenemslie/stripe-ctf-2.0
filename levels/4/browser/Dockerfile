FROM zenika/alpine-chrome:77-with-puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 1
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install .
COPY . ./
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["browser"]
