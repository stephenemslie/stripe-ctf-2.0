#!/bin/sh

if [ ! -f ./mnt/level/password.txt ]; then
    base64 /dev/urandom | head -c 10 > /mnt/level/password.txt
    node ctf-install.js `cat /mnt/level/password.txt`
fi

if [ "$1" = 'serve' ]; then
    exec node level00.js
fi

exec "$@"
