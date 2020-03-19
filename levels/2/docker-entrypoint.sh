#!/bin/sh

mkdir -p /usr/src/app/uploads
ln -s $PWPATH password.txt

if [ ! -f $PWPATH ]; then
  base64 /dev/urandom | head -c 10 > $PWPATH
fi

if [ "$1" == 'serve' ]; then
  /usr/sbin/sshd
  exec php -t . -S 0.0.0.0:8000 routing.php
fi

exec "$@"
