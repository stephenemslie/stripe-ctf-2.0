#!/bin/sh

if [ ! -f secret-combination.txt ]; then
    uuidgen > secret-combination.txt
fi

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL1_PW=`php get_secret.php $GSM_PASSWORD_KEY`
fi

if [ "$1" = 'serve' ]; then
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf php -t . -S 0.0.0.0:${PORT:-8000} ./routing.php
fi

exec "$@"
