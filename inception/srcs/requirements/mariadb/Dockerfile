# Use Alpine Linux 3.18 as the base image for a lightweight container
FROM alpine:3.18

# Update package index and install MariaDB server, client, and required utilities
# - mariadb: The main database server
# - mariadb-client: Client tools for connecting to MariaDB
# - su-exec: Alternative to sudo for dropping privileges in containers
# - openrc: Init system for managing services in Alpine
RUN apk update && apk add --no-cache mariadb mariadb-client su-exec openrc

# Create the MariaDB runtime directory and set proper ownership
# /run/mysqld is where MariaDB stores its socket file and PID file
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY tools/healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# Copy the database initialization script from the host to the container
# This script will handle database setup, user creation, and initial configuration
COPY tools/init.sh /init.sh
# Make the initialization script executable
RUN chmod +x /init.sh

# Switch to the mysql user for security best practices
# Running the database as a non-root user reduces security risks
USER mysql

# Set the initialization script as the container's entry point
# This script will be executed when the container starts
ENTRYPOINT ["/init.sh"]