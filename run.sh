#!/bin/bash

set -x

function createPostgresConfig() {
  cp /etc/postgresql/12/main/postgresql.custom.conf.tmpl /etc/postgresql/12/main/conf.d/postgresql.custom.conf
  sudo -u postgres echo "autovacuum = $AUTOVACUUM" >> /etc/postgresql/12/main/conf.d/postgresql.custom.conf
  cat /etc/postgresql/12/main/conf.d/postgresql.custom.conf
}

function setPostgresPassword() {
    sudo -u postgres psql -c "ALTER USER renderer PASSWORD '${PGPASSWORD:-renderer}'"
}

# Clean /tmp
rm -rf /tmp/*

# Fix postgres data privileges
chown postgres:postgres /var/lib/postgresql -R

# Initialize PostgreSQL and Apache
createPostgresConfig
service postgresql start
setPostgresPassword

# Run while handling docker stop's SIGTERM
stop_handler() {
    service postgresql stop
}
trap stop_handler EXIT

tail -f /dev/null