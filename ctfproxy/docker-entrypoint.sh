#!/bin/sh

if [ "$1" = 'serve' ]; then
    useradd ctf
    chown -R ctf:ctf /usr/src/app
    exec gosu ctf:ctf ./bin/ctfproxy
fi

if [ "$1" = 'gowatch' ]; then
    exec CompileDaemon --build="go build -o /usr/src/app/bin/ctfproxy" --include="*.html" --command=./bin/ctfproxy
fi

if [ "$1" = 'npmbuild' ]; then
    exec npm run build
fi

if [ "$1" = 'npmwatch' ]; then
    exec npm run watch
fi

exec "$@"
