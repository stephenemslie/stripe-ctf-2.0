#!/bin/sh

if [ -n "$GSM_PASSWORD_KEY" ]; then
    export LEVEL7_PW=`python get_secret.py $GSM_PASSWORD_KEY`
fi

if [ ! -f ./wafflecopter.db ]; then
    python initialize_db.py $LEVEL7_PW
fi

if [ "$1" = 'serve' ]; then
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf python wafflecopter.py
fi

exec "$@"
