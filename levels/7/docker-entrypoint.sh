#!/bin/sh

if [ "$1" = 'serve' ]; then
    if [ ! -f ./wafflecopter.db ]; then
        python initialize_db.py `base64 /dev/urandom | head -c 10`
    fi
    exec python wafflecopter.py
fi

exec "$@"
