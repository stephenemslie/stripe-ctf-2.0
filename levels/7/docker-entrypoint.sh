#!/bin/sh

if [ -z "$LEVEL7_PW" ]; then
    export LEVEL7_PW=`gcloud secrets versions access latest --secret=level7-password`
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
