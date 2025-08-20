#!/bin/sh

# Read secrets from mounted secret files

if [ ! -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
  echo "❌ DB password file missing"
  exit 1
fi
MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")

if [ ! -f "$MYSQL_PASSWORD_FILE" ]; then
  echo "❌ DB user password file missing"
  exit 1
fi
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
  mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

  mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

exec mysqld --user=mysql --console --skip-networking=0 --bind-address=0.0.0.0 --port=3306