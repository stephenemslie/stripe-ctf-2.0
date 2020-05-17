#!/bin/sh

if [ -z "$LEVEL6_PW" ]; then
    export LEVEL6_PW=`gcloud secrets versions access latest --secret=level6-password`
fi

if [ "$1" = 'browser' ]; then
    exec gosu pptruser:pptruser node index.js
fi

exec "$@"
