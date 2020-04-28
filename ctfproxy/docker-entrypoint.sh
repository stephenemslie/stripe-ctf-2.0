#!/bin/sh

if [ "$1" = 'serve' ]; then
    exec ./bin/ctfproxy
fi

if [ "$1" = 'gowatch' ]; then
    exec CompileDaemon --build="go build" --include="*.html" --command=./ctfproxy
fi

if [ "$1" = 'npmwatch' ]; then
    exec npm run watch
fi

exec "$@"
