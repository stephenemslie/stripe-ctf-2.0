#!/bin/sh

if [ ! -f /mnt/level/password.txt ]; then
  ln -s /mnt/level/password.txt password.txt
  base64 /dev/urandom | head -c 10 > /mnt/level/password.txt
fi

if [ "$1" == 'serve' ]; then
  exec php -t . -S 0.0.0.0:8000 routing.php
fi

exec "$@"
