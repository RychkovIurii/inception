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
echo "🔐 [DEBUG]Root password: ${MYSQL_ROOT_PASSWORD:-<empty>}"
MYSQL_PASSWORD="$(trim_file "$MYSQL_PASSWORD_FILE")"
echo "🔐 [DEBUG]User password: ${MYSQL_PASSWORD:-<empty>}"
echo "ℹ️  Database: ${MYSQL_DATABASE}"
echo "ℹ️  User: ${MYSQL_USER}"
DATADIR="/var/lib/mysql"
RUNDIR="/run/mariadbd"


# Initialize database if not already done
if [ ! -d "${DATADIR}/mysql" ]; then
  echo "🔧 Initializing MariaDB datadir..."
  mariadb-install-db --user=mysql --basedir=/usr --datadir="$DATADIR" >/dev/null

  echo "🚀 Running bootstrap SQL…"
  mariadbd --user=mysql --bootstrap --datadir="$DATADIR" <<EOF
-- Secure root and prepare app database
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Hand off to mariadbd in foreground (no hacks)
exec mariadbd --user=mysql --console --bind-address=0.0.0.0 --datadir="$DATADIR" --socket="$RUNDIR/mariadb.sock"