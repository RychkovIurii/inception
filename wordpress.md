
# Step: WordPress Service — Dockerfile and Setup

This step explains how to set up the WordPress container using Alpine and PHP-FPM (no nginx inside).

---

## 📁 Directory Structure

You should be in:

```
~/inception/srcs/requirements/wordpress/
├── Dockerfile
├── conf/
└── tools/
```

---

## 🛠️ 1. Create the Dockerfile

File: `~/inception/srcs/requirements/wordpress/Dockerfile`

```Dockerfile
FROM alpine:3.21

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-mbstring \
    php83-dom \
    php83-gd \
    php83-zip \
    php83-curl \
    php83-phar \
    curl \
    tar \
    mariadb-client \
 && rm -rf /var/cache/apk/*

WORKDIR /var/www/wp

RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress latest.tar.gz

# Install WP-CLI
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

# PHP-FPM pool config
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 9000
ENTRYPOINT ["/init.sh"]
CMD ["php-fpm83", "-F"]
```

---

## 🛠️ 2. Create `init.sh`

File: `~/inception/srcs/requirements/wordpress/tools/init.sh`

```bash
#!/bin/sh

# Read secrets from Docker secrets files
if [ ! -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then echo "❌ DB password file missing"; exit 1; fi
WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")

if [ ! -f "$WP_ADMIN_PASSWORD_FILE" ]; then echo "❌ Admin password file missing"; exit 1; fi
WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")

# Optional: second user
if [ -n "${WP_SECOND_PASSWORD_FILE:-}" ] && [ -f "$WP_SECOND_PASSWORD_FILE" ]; then
  WP_SECOND_PASSWORD=$(cat "$WP_SECOND_PASSWORD_FILE")
fi

# Create wp-config.php using WP-CLI
if [ ! -f wp-config.php ]; then
  wp config create \
    --path=/var/www/wp \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbprefix="wp_" \
    --allow-root
fi

# Install WordPress if not installed
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
  if [ -n "${WP_SECOND_USER:-}" ] && [ -n "${WP_SECOND_EMAIL:-}" ] && [ -n "${WP_SECOND_PASSWORD:-}" ]; then
    wp user create "${WP_SECOND_USER}" "${WP_SECOND_EMAIL}" \
      --path=/var/www/wp \
      --user_pass="${WP_SECOND_PASSWORD}" \
      --role="${WP_SECOND_ROLE:-author}" \
      --allow-root
  fi
fi

chown -R www-data:www-data /var/www/wp

exec "$@"
```

Make it executable:

```bash
chmod +x ~/inception/srcs/requirements/wordpress/tools/init.sh
```

---

## 🧾 Required in `.env`

```env
DOMAIN_NAME=irychkov.42.fr

WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD_FILE=/run/secrets/db_password
WORDPRESS_DB_HOST=mariadb:3306

WP_ADMIN_USER=main_user
WP_ADMIN_PASSWORD_FILE=/run/secrets/credentials
WP_ADMIN_EMAIL=admin@irychkov.42.fr
WP_SITE_TITLE=Inception42

# Optional second user
WP_SECOND_USER=editor
WP_SECOND_EMAIL=editor@irychkov.42.fr
WP_SECOND_PASSWORD_FILE=/run/secrets/credentials
WP_SECOND_ROLE=author
```

---

## ✅ Run it

```bash
cd ~/inception
make
```

Visit: https://irychkov.42.fr (port 443)


