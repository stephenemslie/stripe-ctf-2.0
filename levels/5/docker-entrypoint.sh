#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL5_PW=`ruby get_secret.rb $GSM_PASSWORD_KEY`
fi

if [ "$1" = 'serve' ]; then
    exec ruby srv.rb
fi

if [ "$1" = 'cloudrun' ]; then
    exec ruby cloud_srv.rb
fi

exec "$@"
