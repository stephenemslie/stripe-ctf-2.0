#!/bin/sh

if [ "$1" = 'serve' ]; then
    exec go run main.go
fi

if [ "$1" = 'gowatch' ]; then
    exec CompileDaemon --build="go build" --include="*.html" --command=./ctfproxy
fi

if [ "$1" = 'npmwatch' ]; then
    exec npm run watch
fi

exec "$@"
