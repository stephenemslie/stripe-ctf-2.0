#!/bin/sh

if [ ! -f $PWPATH ]; then
    base64 /dev/urandom | head -c 10 > $PWPATH
fi

if [ ! -f level00.db ]; then
    node ctf-install.js `cat $PWPATH`
fi

if [ "$1" = 'serve' ]; then
    exec node level00.js
fi

exec "$@"
