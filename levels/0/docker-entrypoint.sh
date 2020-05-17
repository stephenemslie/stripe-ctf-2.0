#!/bin/sh

if [ -z "$LEVEL0_PW" ]; then
    export LEVEL0_PW=`gcloud secrets versions access latest --secret=level0-password`
fi

if [ "$1" = 'serve' ]; then
    rm level00.db
    node ctf-install.js $LEVEL0_PW
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf node /usr/src/app/level00.js
fi

exec "$@"
