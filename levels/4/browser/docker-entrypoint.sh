#!/bin/sh

if [ -z "$LEVEL4_PW" ]; then
    export LEVEL4_PW=`gcloud secrets versions access latest --secret=level4-password`
fi

if [ "$1" = 'browser' ]; then
    exec gosu pptruser:pptruser node index.js
fi

exec "$@"
