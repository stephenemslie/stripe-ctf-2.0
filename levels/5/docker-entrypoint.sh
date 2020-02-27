#!/bin/sh

if [ "$1" = 'serve' ]; then
    if [ ! -f password.txt ]; then
        base64 /dev/urandom | head -c 10 > password.txt
    fi
    exec ruby srv.rb
fi

exec "$@"
