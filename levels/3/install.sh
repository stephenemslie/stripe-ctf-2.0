#! /bin/sh
export PASSWORD=`base64 /dev/urandom | head -c 10`
export PLANS=`uuidgen`
export PROOF=`uuidgen`
sed -i "s/dummy-proof/$PROOF/" ./data/secrets.json
sed -i "s/dummy-proof/$PROOF/" ./secretvault.py
sed -i "s/dummy-plans/$PLANS/" ./data/secrets.json
sed -i "s/dummy-plans/$PLANS/" ./secretvault.py
sed -i "s/dummy-password/$PASSWORD/" ./data/secrets.json
sed -i "s/dummy-password/$PASSWORD/" ./secretvault.py
