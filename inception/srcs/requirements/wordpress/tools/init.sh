#!/bin/sh
set -eu

WP_PATH="/var/www/html"
WP="wp --path=${WP_PATH}"

# ---------- helpers ----------
need() { eval "v=\${$1:-}"; [ -n "$v" ] || { echo "❌ Missing env: $1" >&2; exit 1; }; }
trim_file() { tr -d '\r\n' < "$1"; }

# ---------- required env ----------
need WORDPRESS_DB_HOST
need WORDPRESS_DB_USER
need WORDPRESS_DB_NAME
need WP_ADMIN_USER
need WP_ADMIN_EMAIL
need DOMAIN_NAME
need WORDPRESS_DB_PASSWORD_FILE
need WP_ADMIN_PASSWORD_FILE

# ---------- secrets (trim trailing newlines) ----------
WORDPRESS_DB_PASSWORD="$(trim_file "$WORDPRESS_DB_PASSWORD_FILE")"
WP_ADMIN_PASSWORD="$(trim_file "$WP_ADMIN_PASSWORD_FILE")"

# optional second user secrets
if [ -n "${WP_SECOND_PASSWORD_FILE:-}" ] && [ -f "${WP_SECOND_PASSWORD_FILE:-}" ]; then
  WP_SECOND_PASSWORD="$(trim_file "$WP_SECOND_PASSWORD_FILE")"
fi

# ---------- ensure runtime dirs (in case) ----------
mkdir -p /run/php
# /var/www/html ownership is already set in Dockerfile; keep tolerant here:
chown -R www-data:www-data "$WP_PATH" /run/php 2>/dev/null || true

# ---------- wait for MariaDB ----------
echo "⏳ Waiting for MariaDB at ${WORDPRESS_DB_HOST}..."
until mariadb -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e ";" >/dev/null 2>&1; do
  sleep 2
done
echo "✅ MariaDB is ready!"

# ---------- sanity: wp-cli ----------
if ! command -v wp >/dev/null 2>&1; then
  echo "❌ wp-cli not found on PATH" >&2
  exit 1
fi

# ---------- create wp-config.php if missing ----------
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  echo "⚙️ Creating wp-config.php..."
  $WP config create \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbprefix="wp_" \
    --skip-check

  # salts/keys
  $WP config shuffle-salts || $WP config generate

  # force admin over https & handle reverse proxy
  $WP config set FORCE_SSL_ADMIN true --raw
  if ! grep -q "HTTP_X_FORWARDED_PROTO" "${WP_PATH}/wp-config.php"; then
    printf "\nif (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') { \$_SERVER['HTTPS'] = 'on'; }\n" >> "${WP_PATH}/wp-config.php"
  fi

  echo "✅ wp-config.php created."
else
  echo "✅ wp-config.php already exists."
fi

# ---------- install core (idempotent + small retry) ----------
if ! $WP core is-installed >/dev/null 2>&1; then
  echo "⚙️ Installing WordPress core..."
  i=0
  until $WP core install \
      --url="https://${DOMAIN_NAME}" \
      --title="${WP_SITE_TITLE:-WordPress}" \
      --admin_user="${WP_ADMIN_USER}" \
      --admin_password="${WP_ADMIN_PASSWORD}" \
      --admin_email="${WP_ADMIN_EMAIL}" \
      --skip-email; do
    i=$((i+1))
    [ $i -ge 5 ] && { echo "❌ WP install failed after retries" >&2; exit 1; }
    echo "…retrying WP install ($i/5)…"
    sleep 2
  done
  echo "✅ WordPress installed."
else
  echo "✅ WordPress already installed."
fi

# ---------- optional second user ----------
if [ -n "${WP_SECOND_USER:-}" ] && [ -n "${WP_SECOND_EMAIL:-}" ] && [ -n "${WP_SECOND_PASSWORD:-}" ]; then
  if ! $WP user exists "$WP_SECOND_USER" --quiet; then
    $WP user create "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
      --role="${WP_SECOND_ROLE:-author}" \
      --user_pass="$WP_SECOND_PASSWORD"
    echo "👤 Created secondary user '${WP_SECOND_USER}'."
  else
    echo "👤 Secondary user '${WP_SECOND_USER}' already exists."
  fi
fi

# ---------- hand off to CMD ----------
exec "$@"
