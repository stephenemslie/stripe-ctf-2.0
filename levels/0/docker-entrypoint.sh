#!/bin/sh

if [ ! -f $PW_FILE ]; then
    base64 /dev/urandom | head -c 10 > $PW_FILE
fi

if [ ! -f level00.db ]; then
    node ctf-install.js `cat $PW_FILE`
fi

if [ "$1" = 'serve' ]; then
    exec node level00.js
fi

exec "$@"
