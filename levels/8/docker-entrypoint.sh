#!/bin/sh

if [ "$1" = 'serve' ]; then
    if [ ! -f password.txt ]; then
        base64 /dev/urandom | head -c 10 > password.txt
    fi
    PASSWORD=`cat password.txt`
    exec ./password_db_launcher $PASSWORD 0.0.0.0:4000
fi

exec "$@"
