#!/bin/sh
set -eu

# --- helpers ---
trim_file() { tr -d '\r\n' < "$1"; }
need() { eval "v=\${$1:-}"; [ -n "$v" ] || { echo "❌ Missing env: $1" >&2; exit 1; }; }

# --- required env ---
need MYSQL_DATABASE
need MYSQL_USER
need MYSQL_ROOT_PASSWORD_FILE
need MYSQL_PASSWORD_FILE

# --- secrets (trim newline) ---
MYSQL_ROOT_PASSWORD="$(trim_file "$MYSQL_ROOT_PASSWORD_FILE")"
MYSQL_PASSWORD="$(trim_file "$MYSQL_PASSWORD_FILE")"

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"

# Ensure runtime dirs/ownership (important with bind mounts)
mkdir -p "$RUNDIR" "$DATADIR"
chown -R mysql:mysql "$RUNDIR" "$DATADIR"

# Initialize database if not already done
if [ ! -d "${DATADIR}/mysql" ]; then
  echo "🔧 Initializing MariaDB datadir..."
  mariadb-install-db --user=mysql --basedir=/usr --datadir="$DATADIR" >/dev/null

  echo "🚀 Running bootstrap SQL…"
  mysqld --user=mysql --bootstrap <<EOF
-- Secure root and prepare app database
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Hand off to mysqld in foreground (no hacks)
exec mysqld --user=mysql --console --bind-address=0.0.0.0 --port=3306