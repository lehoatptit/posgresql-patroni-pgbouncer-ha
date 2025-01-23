#!/bin/bash

# Get Docker IP address
DOCKER_IP=$(hostname --ip-address)
PATRONI_SCOPE=${PATRONI_SCOPE:-batman}

# Export environment variables
export PATRONI_NAME="${PATRONI_NAME:-${HOSTNAME}}"
export PATRONI_RESTAPI_CONNECT_ADDRESS="${DOCKER_IP}:8008"
export PATRONI_RESTAPI_LISTEN="0.0.0.0:8008"
export PATRONI_admin_PASSWORD="${PATRONI_admin_PASSWORD:-admin}"
export PATRONI_admin_OPTIONS="${PATRONI_admin_OPTIONS:-createdb, createrole}"
export PATRONI_POSTGRESQL_CONNECT_ADDRESS="${DOCKER_IP}:5432"
export PATRONI_POSTGRESQL_LISTEN="0.0.0.0:5432"
export PATRONI_POSTGRESQL_DATA_DIR="data/${PATRONI_SCOPE}"
export PATRONI_REPLICATION_USERNAME="${PATRONI_REPLICATION_USERNAME:-replicator}"
export PATRONI_REPLICATION_PASSWORD="${PATRONI_REPLICATION_PASSWORD:-abcd}"
export PATRONI_SUPERUSER_USERNAME="${PATRONI_SUPERUSER_USERNAME:-postgres}"
export PATRONI_SUPERUSER_PASSWORD="${PATRONI_SUPERUSER_PASSWORD:-postgres}"
export PATRONI_POSTGRESQL_PGPASS="$HOME/.pgpass"

# Create symbolic link to patronictl configuration
mkdir -p "$HOME/.config/patroni"
[ -h "$HOME/.config/patroni/patronictl.yaml" ] || ln -s /etc/patroni/patroni.yml "$HOME/.config/patroni/patronictl.yaml"

# Ensure permissions on patroni.yml
chown postgres:postgres /etc/patroni/patroni.yml

# Start Patroni if not in cheat mode
[ -z "$CHEAT" ] && exec /opt/venv/bin/patroni /etc/patroni/patroni.yml

# If in cheat mode, simply keep the container running
while true; do
    sleep 60
done
