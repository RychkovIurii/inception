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

if [ ! -f "$WP_SECOND_PASSWORD_FILE" ]; then
  echo "❌ Second user password file missing"
  exit 1
fi
WP_SECOND_PASSWORD=$(cat "$WP_SECOND_PASSWORD_FILE")

# Configure WordPress database connection if wp-config.php doesn't exist
# Create wp-config.php
if [ ! -f wp-config.php ]; then
  echo "⚙️ Creating wp-config.php..."
  wp config create \
    --path=/var/www/wp \
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
if ! wp core is-installed --path=/var/www/wp --allow-root; then
  wp core install \
    --path=/var/www/wp \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
  wp user create "${WP_SECOND_USER}" \
    "${WP_SECOND_EMAIL}" \
    --path=/var/www/wp \
    --user_pass="${WP_SECOND_PASSWORD}" \
    --role="${WP_SECOND_ROLE}" \
    --allow-root
  echo "✅ WordPress installed"
else
  echo "✅ WordPress already installed"
fi

chown -R www-data:www-data /var/www/wp

# Execute the command passed to the container (e.g., php-fpm83 -F)
exec "$@"