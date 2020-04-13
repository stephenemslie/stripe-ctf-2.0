#!/bin/sh

if [ ! -f $PW_FILE ]; then
    cat /dev/urandom | tr -dc "A-Z0-9\"'" | fold -w 16 | grep "'" | grep "\"" | head -n 1 | tr -d '\n' > $PW_FILE
fi

if [ "$1" = 'serve' ]; then
    exec ruby srv.rb
fi

exec "$@"
