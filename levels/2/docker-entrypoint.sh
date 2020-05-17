#!/bin/bash

if [ -z "$LEVEL2_PW" ]; then
    export LEVEL2_PW=`gcloud secrets versions access latest --secret=level2-password`
fi

mkdir -p /usr/src/app/uploads
echo $LEVEL2_PW > password.txt

if [ "$1" == 'serve' ]; then
  useradd ctf
  chown -R ctf:ctf /usr/src/app
  exec gosu ctf:ctf php -t . -S 0.0.0.0:${PORT:-8000} routing.php
fi

exec "$@"
