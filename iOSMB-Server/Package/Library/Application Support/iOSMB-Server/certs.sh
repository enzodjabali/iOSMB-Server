#!/bin/bash

cd /Library/Application\ Support/iOSMB-Server

PASSPHRASE=$(openssl rand -base64 16)
echo "$PASSPHRASE" > ./passphrase

openssl req -new -newkey rsa:4096 -nodes -x509 -subj "/C=US/ST=CA/L=/O=/CN=iOSMB-Server" -keyout iosmb.key -out iosmb.pem -outform pem 2>&1 > /dev/null
openssl x509 -in iosmb.pem -inform pem -out iosmb.der -outform der 2>&1 > /dev/null
openssl pkcs12 -export -out iosmb.p12 -inkey iosmb.key -in iosmb.pem -passout pass:$PASSPHRASE 2>&1 > /dev/null
