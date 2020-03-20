#!/bin/sh

if [ "$1" = 'serve' ]; then
    exec go run main.go
fi

exec "$@"
