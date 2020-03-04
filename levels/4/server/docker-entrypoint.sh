#!/bin/sh

if [ ! -f $PW_FILE ]; then
    base64 /dev/urandom | head -c 10 > $PW_FILE
fi

if [ "$1" = 'serve' ]; then
    exec ruby srv.rb
fi

exec "$@"
