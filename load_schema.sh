#!/bin/bash
# start the service
gosu postgres pg_ctl -w start
# Wait on the service to come up
echo "Stalling for DB"
while true;
do
    nc -q 1 localhost 5432 > /dev/null && sleep 4 && break
    sleep 1
done
# Now the DB is up, we can execute DB dependent actions
wget --no-check-certificate https://gx.hx42.org//job/Docker-Build/lastSuccessfulBuild/artifact/chado/default/chado-4e7f5f3f4a83c48a46bd23f386b75b82ea9681b2.sql -O chado.sql
psql < chado.sql

# Stop the database
gosu postgres pg_ctl -w  stop
