FROM python:3.8.1-alpine
RUN apk add --no-cache util-linux
WORKDIR /usr/src/app
COPY *.py ./
COPY install.sh ./
COPY data ./data
RUN sh install.sh
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY index.html ./
EXPOSE 5000
CMD ["python", "secretvault.py"]
