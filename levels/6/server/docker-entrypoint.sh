#!/bin/sh

if [ "$1" = 'serve' ]; then
    if [ ! -f /mnt/passwords/password6.txt ]; then
        base64 /dev/urandom | head -c 10 > /mnt/passwords/password6.txt
    fi
    exec ruby srv.rb
fi

exec "$@"
