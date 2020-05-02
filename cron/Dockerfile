FROM node:13-buster-slim
RUN apt-get update -y && \
    apt-get install -y curl cron && \
    apt-get clean
COPY crontab /etc/cron.d/ctf-cron
RUN chmod 0644 /etc/cron.d/ctf-cron
RUN touch /var/log/cron.log
CMD cron && tail -f /var/log/cron.log

