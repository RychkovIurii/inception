# Use Alpine Linux 3.21 as the base image for a lightweight container
FROM alpine:3.21

# Update package index and install PHP 8.3 with required extensions for WordPress
# Core PHP packages:
# - php83: The main PHP package
# - php83-fpm: FastCGI Process Manager for handling PHP requests
# PHP extensions:
# - php83-mysqli: MySQL database driver for PHP
# - php83-mbstring: Multibyte string handling
# - php83-dom: Document Object Model extension
# - php83-gd: Image processing and manipulation
# - php83-zip: ZIP file handling
# - php83-curl: Client URL library for making HTTP requests
# Additional tools:
# - curl: Command-line tool for transferring data with URLs
# - tar: Utility for handling tar archives
# - mariadb-client: Client tools for connecting to MariaDB databases
# rm -rf /var/cache/apk/* is used to clean up the package cache to reduce image size
RUN apk update && apk add --no-cache \
    php83 \
	php83-fpm \
    php83-mysqli \
    php83-mbstring \
	php83-dom \
    php83-gd \
	php83-zip \
    php83-curl \
    curl \
	tar \
	mariadb-client \
 && rm -rf /var/cache/apk/*

# Set the working directory to the web root where WordPress files will be placed
WORKDIR /var/www/wp

# Download and extract the latest WordPress release
# 1. Download the latest WordPress archive from the official source
# 2. Extract the tar.gz file
# 3. Move all WordPress files to the current directory (/var/www/wp)
# 4. Clean up by removing the temporary archive and extracted directory
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress latest.tar.gz

# Install WP-CLI
# WP-CLI is a command-line tool for managing WordPress installations
# 1. Download the WP-CLI Phar file
# 2. Move it to /usr/local/bin/wp for global access
# 3. Make it executable
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

# Create a non-root user 'www-data' to run the web server
# -D: Do not create a home directory
# -H: Do not create a home directory
# -s /sbin/nologin: Set the shell to nologin for security
# -g www-data: Set the primary group to www-data
# -G www-data: Add to the www-data group
RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

# Copy the WordPress initialization and configuration script
COPY tools/init.sh /init.sh
# Make the initialization script executable
RUN chmod +x /init.sh

# after installing php83/php83-fpm …
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

# Expose the port used by PHP-FPM
EXPOSE 9000

# Set the initialization script as the container's entry point
# This script will configure WordPress, connect to the database, and start PHP-FPM
ENTRYPOINT ["/init.sh"]
# Start PHP-FPM in the foreground to keep the container running
CMD [ "php-fpm83", "-F" ]