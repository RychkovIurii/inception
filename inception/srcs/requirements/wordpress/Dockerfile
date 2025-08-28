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
# - ca-certificates: SSL certificates for secure connections
# - tar: Archive extraction
# - php81-zip: ZIP file handling
# - php81-gd: Image processing library
# - php81-pdo & php81-pdo_mysql: Database abstraction layer
# - php81-sodium: Modern cryptography library
RUN apk update && apk add --no-cache \
    php81 php81-fpm \
    php81-mysqli php81-pdo php81-pdo_mysql \
    php81-mbstring php81-xml php81-dom \
    php81-gd php81-zip \
    php81-curl php81-opcache php81-exif php81-fileinfo \
    php81-sodium \
    php81-pecl-redis \
    curl tar mariadb-client ca-certificates \
 && rm -rf /var/cache/apk/*

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

# Install WP-CLI
# WP-CLI is a command-line tool for managing WordPress installations
# 1. Download the WP-CLI Phar file
# 2. Move it to /usr/local/bin/wp for global access
# 3. Make it executable
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

# Create a non-root user 'www-data' with UID 82 (standard for web servers)
RUN adduser -D -H -u 82 www-data \
 && mkdir -p /run/php \
 && chown -R www-data:www-data /var/www/html /run/php

# Configure PHP-FPM settings for optimal performance with WordPress
# - Listen on all interfaces at port 9000
# - Set process management to dynamic with specific limits
#   - max_children: Maximum number of child processes
#   - start_servers: Number of child processes created on startup
#   - min_spare_servers: Minimum number of idle child processes
#   - max_spare_servers: Maximum number of idle child processes
RUN sed -ri 's|^listen\s*=\s*.*|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf \
 && sed -ri 's|^;?pm.max_children\s*=.*|pm.max_children = 10|' /etc/php81/php-fpm.d/www.conf \
 && sed -ri 's|^;?pm.start_servers\s*=.*|pm.start_servers = 2|' /etc/php81/php-fpm.d/www.conf \
 && sed -ri 's|^;?pm.min_spare_servers\s*=.*|pm.min_spare_servers = 2|' /etc/php81/php-fpm.d/www.conf \
 && sed -ri 's|^;?pm.max_spare_servers\s*=.*|pm.max_spare_servers = 5|' /etc/php81/php-fpm.d/www.conf

# Enable and configure OPcache for improved PHP performance
# - opcache.enable: Enable OPcache
# - opcache.enable_cli: Enable OPcache for CLI
# - opcache.validate_timestamps: Disable file change validation for better performance
# - opcache.jit: Enable Just-In-Time compilation with optimization level 1255
# - opcache.jit_buffer_size: Allocate 64MB for JIT buffer
RUN { \
      echo "opcache.enable=1"; \
      echo "opcache.enable_cli=1"; \
      echo "opcache.validate_timestamps=0"; \
      echo "opcache.jit=1255"; \
      echo "opcache.jit_buffer_size=64M"; \
    } > /etc/php81/conf.d/00_opcache.ini

# Copy the WordPress initialization and configuration script
COPY tools/init.sh /init.sh
# Make the initialization script executable
RUN chmod +x /init.sh

# Expose the port used by PHP-FPM
EXPOSE 9000

# Switch to the non-root user 'www-data' for security best practices
# Running the web server as a non-root user reduces security risks
USER www-data

# Set the initialization script as the container's entry point
# This script will configure WordPress, connect to the database, and start PHP-FPM
ENTRYPOINT ["/init.sh"]
# Start PHP-FPM in the foreground to keep the container running
CMD [ "php-fpm81", "-F" ]