#!/bin/sh

if [ -z "$LEVEL6_PW" ]; then
    export LEVEL6_PW=`gcloud secrets versions access latest --secret=level6-password`
fi

if [ "$1" = 'serve' ]; then
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf ruby srv.rb
fi

exec "$@"
