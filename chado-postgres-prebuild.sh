#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
	chown -R postgres "$PGDATA"
	
	if [ -z "$(ls -A "$PGDATA")" ]; then
		gosu postgres initdb
		
		sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
		
		# check password first so we can ouptut the warning before postgres
		# messes it up
		if [ "$POSTGRES_PASSWORD" ]; then
			pass="PASSWORD '$POSTGRES_PASSWORD'"
			authMethod=md5
		else
			# The - option  suppresses leading tabs but *not* spaces. :)
			cat >&2 <<-'EOWARN'
				****************************************************
				WARNING: No password has been set for the database.
				         Use "-e POSTGRES_PASSWORD=password" to set
				         it in "docker run".
				****************************************************
			EOWARN
			
			pass=
			authMethod=trust
		fi
		
		: ${POSTGRES_USER:=postgres}
		if [ "$POSTGRES_USER" = 'postgres' ]; then
			op='ALTER'
		else
			op='CREATE'
			gosu postgres postgres --single -E <<-EOSQL
				CREATE DATABASE "$POSTGRES_USER"
			EOSQL
		fi
		
		gosu postgres postgres --single <<-EOSQL
			$op USER "$POSTGRES_USER" WITH SUPERUSER $pass
		EOSQL
		{ echo; echo "host all \"$POSTGRES_USER\" 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf
	fi
fi


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
wget --no-check-certificate --quiet https://cpt.tamu.edu/jenkins/job/Chado-Prebuilt-Schemas/lastSuccessfulBuild/artifact/chado/default/chado-master.sql
gosu postgres psql < chado-master.sql

# Stop the database
gosu postgres pg_ctl -w  stop
