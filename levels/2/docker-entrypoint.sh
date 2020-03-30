#!/bin/sh

mkdir -p /usr/src/app/uploads
ln -s $PW_FILE password.txt

if [ ! -f $PW_FILE ]; then
  base64 /dev/urandom | head -c 10 > $PW_FILE
fi

if [ "$1" == 'serve' ]; then
  /usr/sbin/sshd
  exec php -t . -S 0.0.0.0:8000 routing.php
fi

exec "$@"
