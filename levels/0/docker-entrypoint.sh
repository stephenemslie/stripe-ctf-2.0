#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL0_PW=`node get_secret.js $GSM_PASSWORD_KEY`
fi

if [ "$1" = 'serve' ]; then
    rm level00.db
    node ctf-install.js $LEVEL0_PW
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf node /usr/src/app/level00.js
fi

exec "$@"
