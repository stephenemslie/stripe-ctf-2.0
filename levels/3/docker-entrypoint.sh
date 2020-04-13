#!/bin/sh

if [ ! -f $PW_FILE ]; then
  base64 /dev/urandom | head -c 10 > $PW_FILE
fi

export PASSWORD=`cat $PW_FILE`
export PLANS=`uuidgen`
export PROOF=`uuidgen`
mkdir -p $LEVEL3_DATA_DIR
python generate_data.py $LEVEL3_DATA_DIR $PASSWORD $PROOF $PLANS

if [ "$1" == 'serve' ]; then
  exec python secretvault.py
fi

exec "$@"
