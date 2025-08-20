#!/bin/sh

# Read sensitive passwords from Docker secrets files
# These files are mounted as volumes and contain the actual password values
if [ ! -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
  echo "❌ DB password file missing"
  exit 1
fi
WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")

if [ ! -f "$WP_ADMIN_PASSWORD_FILE" ]; then
  echo "❌ Admin password file missing"
  exit 1
fi
WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")

# Wait for MariaDB to be ready before proceeding
# This loop continuously tries to connect to the database until it succeeds
# This ensures WordPress doesn't try to connect before the database is available
until mariadb -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e ";" ; do
  echo "Waiting for MariaDB..."
  sleep 2
done
echo "✅ MariaDB is ready!"

# Configure WordPress database connection if wp-config.php doesn't exist
# Create wp-config.php
if [ ! -f wp-config.php ]; then
  echo "⚙️ Creating wp-config.php..."
  wp config create \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbprefix="wp_" \
    --allow-root
  echo "✅ wp-config.php created"
else
  echo "✅ wp-config.php already exists"
fi

# Install WordPress if it hasn't been installed yet
# This creates the initial database tables and sets up the admin user
if ! wp core is-installed --allow-root; then
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
  echo "✅ WordPress installed"
else
  echo "✅ WordPress already installed"
fi

# Start PHP-FPM in the foreground
# The -F flag keeps the process running in the foreground so the container doesn't exit
exec php-fpm81 -F