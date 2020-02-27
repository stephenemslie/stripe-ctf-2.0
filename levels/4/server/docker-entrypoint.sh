#!/bin/sh

if [ "$1" = 'serve' ]; then
    if [ ! -f /mnt/passwords/password4.txt ]; then
        base64 /dev/urandom | head -c 10 > /mnt/passwords/password4.txt
    fi
    exec ruby srv.rb
fi

exec "$@"
