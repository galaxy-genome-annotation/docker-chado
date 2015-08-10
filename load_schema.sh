#!/bin/bash
: ${INSTALL_CHADO_SCHEMA:=1}
CHECK_FOR_CHADO=$(psql -U postgres "$POSTGRES_DB" -c 'select * from chadoprop' >/dev/null 2>&1; echo "$?")
if [[ $CHECK_FOR_CHADO -ne 0 ]]; then
    # Only if set to 1 do we automatically install the schema
    if [[ $INSTALL_CHADO_SCHEMA -eq 1 ]]; then
        psql --username postgres --dbname "$POSTGRES_DB" < /chado.sql
    fi
fi
