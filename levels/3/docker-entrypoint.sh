#!/bin/sh

if [ ! -f /mnt/level/password.txt ]; then
  base64 /dev/urandom | head -c 10 > /mnt/level/password.txt
fi


export PASSWORD=`cat /mnt/level/password.txt`
export PLANS=`uuidgen`
export PROOF=`uuidgen`
mkdir -p $LEVEL3_DATA_DIR
python generate_data.py $LEVEL3_DATA_DIR $PASSWORD $PROOF $PLANS

if [ "$1" == 'serve' ]; then
  exec python secretvault.py
fi

exec "$@"
