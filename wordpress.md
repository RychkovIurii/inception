
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
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-mbstring \
    php81-json \
    php81-session \
    php81-curl \
    php81-dom \
    php81-opcache \
    php81-exif \
    php81-fileinfo \
    php81-pecl-redis \
    curl \
    mariadb-client

WORKDIR /var/www/html

RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress latest.tar.gz

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]
```

---

## 🛠️ 2. Create `init.sh`

File: `~/inception/srcs/requirements/wordpress/tools/init.sh`

```bash
#!/bin/sh

WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")

until mariadb -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e ";" ; do
  echo "Waiting for MariaDB..."
  sleep 2
done

if [ ! -f wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" wp-config.php
fi

if ! wp core is-installed --allow-root; then
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
fi

exec php-fpm81 -F
```

Make it executable:

```bash
chmod +x ~/inception/srcs/requirements/wordpress/tools/init.sh
```

---

## 🧾 Required in `.env`

```env
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD_FILE=/run/secrets/db_password
WORDPRESS_DB_HOST=mariadb:3306

WP_ADMIN_USER=main_user
WP_ADMIN_PASSWORD_FILE=/run/secrets/credentials.txt
WP_ADMIN_EMAIL=admin@irychkov.42.fr
WP_SITE_TITLE=Inception42
DOMAIN_NAME=irychkov.42.fr
```

---

## ✅ Run it

```bash
cd ~/inception
make
```

Visit: [https://irychkov.42.fr](https://irychkov.42.fr)



