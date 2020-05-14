#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL6_PW=`ruby get_secret.rb $GSM_PASSWORD_KEY`
fi

if [ "$1" = 'serve' ]; then
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf ruby srv.rb
fi

exec "$@"
