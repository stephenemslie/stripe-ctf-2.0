#!/bin/sh

if [ ! -f ./mnt/level/password.txt ]; then
    uuidgen > secret-combination.txt
    base64 /dev/urandom | head -c 10 > $PWPATH
fi

if [ "$1" = 'serve' ]; then
    exec php -t . -S 0.0.0.0:8000 ./routing.php
fi

exec "$@"
