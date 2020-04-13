#!/bin/sh

if [ ! -f $PW_FILE ]; then
    base64 /dev/urandom | head -c 10 > $PW_FILE
fi

if [ ! -f ./wafflecopter.db ]; then
    python initialize_db.py `echo $PW_FILE`
fi

if [ "$1" = 'serve' ]; then
    exec python wafflecopter.py
fi

exec "$@"
