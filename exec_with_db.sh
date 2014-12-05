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
exec "$@"

# Stop the database
gosu postgres pg_ctl -w  stop
