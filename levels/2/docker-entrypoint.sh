#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL2_PW=`php get_secret.php $GSM_PASSWORD_KEY`
fi

mkdir -p /usr/src/app/uploads
echo $LEVEL2_PW > password.txt

if [ "$1" == 'serve' ]; then
  /usr/sbin/sshd
  exec php -t . -S 0.0.0.0:${PORT:-8000} routing.php
fi

exec "$@"
