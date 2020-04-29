#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL0_PW=`node get_secret.js $GSM_PASSWORD_KEY`
fi

if [ "$1" = 'serve' ]; then
    rm level00.db
    node ctf-install.js $LEVEL0_PW
    exec node level00.js
fi

exec "$@"
