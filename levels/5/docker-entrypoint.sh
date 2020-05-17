#!/bin/bash

if [ -z "$LEVEL5_PW" ]; then
    export LEVEL5_PW=`gcloud secrets versions access latest --secret=level5-password`
fi

if [ "$1" = 'serve' ]; then
    exec ruby srv.rb
fi

if [ "$1" = 'cloudrun' ]; then
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf ruby srv.rb
fi

exec "$@"
