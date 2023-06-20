#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE USER monorepo;
ALTER USER monorepo WITH PASSWORD 'monorepo';
GRANT ALL ON SCHEMA public TO monorepo;
EOSQL
