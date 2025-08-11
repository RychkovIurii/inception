FROM alpine:3.18

RUN apk update && apk add --no-cache mariadb mariadb-client su-exec openrc

# Create necessary directories
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Copy initialization script
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# Use mariadb user and launch the DB properly
USER mysql

ENTRYPOINT ["/init.sh"]