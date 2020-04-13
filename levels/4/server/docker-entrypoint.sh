#!/bin/sh

if [ ! -f $PW_FILE ]; then
    base64 /dev/urandom | head -c 10 > $PW_FILE
fi

if [ "$1" = 'serve' ]; then
    ruby srv.rb&
    PID=$!
    WATCH_DIR=`dirname $RESET_FILE`
    WATCH_NAME=`basename $RESET_FILE`
    inotifywait -m -e CREATE $WATCH_DIR |
        while read path action file; do
            if [[ "$WATCH_NAME" = "$file" ]]; then
                echo "RESETTING"
                kill $PID
                rm $DB_FILE
                rm $RESET_FILE
                sleep 3
                ruby srv.rb&
                PID=$!
            fi
        done
fi

exec "$@"
