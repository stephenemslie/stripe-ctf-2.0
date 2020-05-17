#!/bin/bash

if [ -z "$LEVEL3_PW" ]; then
    export LEVEL3_PW=`gcloud secrets versions access latest --secret=level3-password`
fi

export PLANS=`uuidgen`
export PROOF=`uuidgen`
mkdir -p $DATA_DIR
python generate_data.py $DATA_DIR $LEVEL3_PW $PROOF $PLANS

if [ "$1" == "serve" ]; then
  useradd ctf
  chown -R ctf:ctf /usr/src/app
  exec gosu ctf:ctf python secretvault.py
fi

exec "$@"
