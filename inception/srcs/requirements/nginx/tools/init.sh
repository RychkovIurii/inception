#!/bin/sh
set -eu

# Inputs (optionally via docker secrets)
SSL_CERT_SRC="${SSL_CERT_SRC:-/run/secrets/ssl_cert}"
SSL_KEY_SRC="${SSL_KEY_SRC:-/run/secrets/ssl_key}"
SSL_CERT_DST="/etc/nginx/ssl/tls.crt"
SSL_KEY_DST="/etc/nginx/ssl/tls.key"

DOMAIN="${DOMAIN_NAME:-localhost}"

# If secrets exist, use them; otherwise create a self-signed pair once
if [ -f "$SSL_CERT_SRC" ] && [ -f "$SSL_KEY_SRC" ]; then
  cp "$SSL_CERT_SRC" "$SSL_CERT_DST"
  cp "$SSL_KEY_SRC"  "$SSL_KEY_DST"
  chmod 600 "$SSL_KEY_DST"
  echo "🔐 Using TLS certs from secrets."
else
  if [ ! -f "$SSL_CERT_DST" ] || [ ! -f "$SSL_KEY_DST" ]; then
    echo "🛠  Generating self-signed TLS cert for ${DOMAIN}..."
    openssl req -x509 -nodes -days 365 \
      -newkey rsa:2048 \
      -keyout "$SSL_KEY_DST" \
      -out   "$SSL_CERT_DST" \
      -subj "/CN=${DOMAIN}"
    chmod 600 "$SSL_KEY_DST"
  else
    echo "🔐 Using existing self-signed TLS certs."
  fi
fi

# Ensure webroot exists (mounted from wordpress container volume)
mkdir -p /var/www/wp

# Hand off to Nginx (CMD)
exec nginx -g 'daemon off;'
