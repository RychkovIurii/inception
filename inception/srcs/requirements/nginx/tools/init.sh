#!/bin/sh

# Generate self-signed cert if not exists
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=42/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}"
fi

# Start nginx in foreground mode (daemon off)
# In Docker containers, the main process must run in the foreground to keep the container alive
# If nginx runs as a daemon (background process), the container would exit immediately
# because Docker needs a running process to maintain the container's lifecycle
# The 'daemon off;' directive ensures nginx stays in the foreground as PID 1
exec nginx -g 'daemon off;'