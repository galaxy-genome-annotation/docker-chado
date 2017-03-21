#!/bin/bash
: ${INSTALL_CHADO_SCHEMA:=1}
if [[ $INSTALL_CHADO_SCHEMA -eq 1 ]]; then
    psql --username postgres --dbname "$POSTGRES_DB" < /search.sql
fi
