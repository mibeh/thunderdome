#!/bin/bash

mkdir -p /opt/vectr/user/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /opt/vectr/user/certs/ssl.key -out /opt/vectr/user/certs/ssl.crt -subj "/C=US/ST=NY/L=[]/O=Thunderdome/OU=CyberRange/CN=thunderdome.lab"

sed -i "s/sravectr\.internal/thunderdome\.lab/g" /opt/vectr/.env
sed -i "s/sandbox1/vectr/g" /opt/vectr/.env

#NEW_VECTR_DATA_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
sed -i "s/^\(VECTR_DATA_KEY\s*=\s*\).*\$/\1$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)/" /opt/vectr/.env
#NEW_CAS_ENCRYPT_MONGO_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
sed -i "s/^\(CAS_ENCRYPT_MONGO_KEY\s*=\s*\).*\$/\1$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)/" /opt/vectr/.env
#NEW_MONGO_INITDB_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
sed -i "s/^\(MONGO_INITDB_ROOT_PASSWORD\s*=\s*\).*\$/\1$NEW_MONGO_INITDB_ROOT_PASSWORD/" /opt/vectr/.env

cd /opt/vectr && docker-compose up -d
