#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL8_PW=`python get_secret.py $GSM_PASSWORD_KEY`
fi

if [ "$1" = 'serve' ]; then
    exec ./password_db_launcher $LEVEL8_PW 0.0.0.0:${PORT:-4000}
fi

exec "$@"
