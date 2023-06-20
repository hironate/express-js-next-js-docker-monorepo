#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE USER monorepo_user;
ALTER USER monorepo_user WITH PASSWORD 'monorepo-password';
GRANT ALL ON DATABASE "$POSTGRES_DB" TO monorepo_user;
GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_DB" TO monorepo_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO monorepo_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO monorepo_user;
EOSQL