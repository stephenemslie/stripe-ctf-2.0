#!/bin/bash

if [ ! -f secret-combination.txt ]; then
    uuidgen > secret-combination.txt
fi

if [ -z "$LEVEL1_PW" ]; then
    export LEVEL1_PW=`gcloud secrets versions access latest --secret=level1-password`
fi

if [ "$1" = 'serve' ]; then
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf php -t . -S 0.0.0.0:${PORT:-8000} ./routing.php
fi

exec "$@"
