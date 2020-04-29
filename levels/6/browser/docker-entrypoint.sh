#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL6_PW=`node get_secret.js $GSM_PASSWORD_KEY`
fi

if [ "$1" = 'browser' ]; then
    exec node index.js
fi

exec "$@"
