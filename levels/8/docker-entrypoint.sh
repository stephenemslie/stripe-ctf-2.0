#!/bin/sh

if [ -z "$LEVEL8_PW" ]; then
    export LEVEL8_PW=`gcloud secrets versions access latest --secret=level8-password`
fi

if [ "$1" = 'serve' ]; then
    exec ./password_db_launcher $LEVEL8_PW 0.0.0.0:${PORT:-4000}
fi

exec "$@"
