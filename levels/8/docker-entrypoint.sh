#!/bin/sh

if [ ! -f $PW_FILE ]; then
    python -c "import random; import sys; sys.stdout.write(''.join([str(random.SystemRandom().randint(0, 9)) for i in range(12)]))" > $PW_FILE
fi

if [ "$1" = 'serve' ]; then
    PASSWORD=`cat $PW_FILE`
    exec ./password_db_launcher "$PASSWORD" 0.0.0.0:4000
fi

exec "$@"
