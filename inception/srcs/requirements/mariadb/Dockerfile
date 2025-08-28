# Use Alpine Linux 3.18 as the base image for a lightweight container
FROM alpine:3.18

# Update package index and install MariaDB server, client, and required utilities
# - mariadb: The main database server
# - mariadb-client: Client tools for connecting to MariaDB
# - bash: For scripting and running bash scripts
# - util-linux: Provides the 'flock' command used in health checks
# rm -rf /var/cache/apk/* is used to clean up the package cache to reduce image size
RUN apk update && apk add --no-cache \
    mariadb mariadb-client \
    bash util-linux \
 && rm -rf /var/cache/apk/*

# Create the MariaDB runtime directory and set proper ownership
# /run/mysqld is where MariaDB stores its socket file and PID file
# /var/lib/mysql is the default data directory for MariaDB databases
# Ensuring these directories exist and have the correct permissions is crucial for MariaDB to run properly
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY tools/healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# Copy the database initialization script from the host to the container
# This script will handle database setup, user creation, and initial configuration
COPY tools/init.sh /init.sh
# Make the initialization script executable
RUN chmod +x /init.sh

# Expose the default MariaDB port
EXPOSE 3306

# Switch to the mysql user for security best practices
# Running the database as a non-root user reduces security risks
USER mysql

# Set the initialization script as the container's entry point
# This script will be executed when the container starts
ENTRYPOINT ["/init.sh"]