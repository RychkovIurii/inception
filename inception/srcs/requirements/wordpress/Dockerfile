# Use Alpine Linux 3.18 as the base image for a lightweight container
FROM alpine:3.18

# Update package index and install PHP 8.1 with required extensions for WordPress
# Core PHP packages:
# - php81: PHP 8.1 interpreter
# - php81-fpm: FastCGI Process Manager for handling PHP requests
# WordPress required extensions:
# - php81-mysqli: MySQL/MariaDB database connectivity
# - php81-mbstring: Multi-byte string handling for internationalization
# - php81-json: JSON data processing
# - php81-session: Session management
# - php81-curl: HTTP client for external API calls
# - php81-dom: XML/HTML document manipulation
# - php81-opcache: PHP opcode caching for performance
# - php81-exif: Image metadata extraction
# - php81-fileinfo: File type detection
# - php81-pecl-redis: Redis caching support
# Utilities:
# - curl: Command-line tool for downloading files
# - mariadb-client: MySQL client for database operations
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

# Set the working directory to the web root where WordPress files will be placed
WORKDIR /var/www/html

# Download and extract the latest WordPress release
# 1. Download the latest WordPress archive from the official source
# 2. Extract the tar.gz file
# 3. Move all WordPress files to the current directory (/var/www/html)
# 4. Clean up by removing the temporary archive and extracted directory
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress latest.tar.gz

# Copy the WordPress initialization and configuration script
COPY tools/init.sh /init.sh
# Make the initialization script executable
RUN chmod +x /init.sh

# Set the initialization script as the container's entry point
# This script will configure WordPress, connect to the database, and start PHP-FPM
ENTRYPOINT ["/init.sh"]