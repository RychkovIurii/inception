FROM alpine:3.21

# Update package index and install Nginx and OpenSSL for serving WordPress over HTTPS
# - nginx: High-performance web server
# - openssl: Tool for generating SSL certificates
# rm -rf /var/cache/apk/* is used to clean up the package cache to reduce image size
RUN apk update && apk add --no-cache \
    nginx \
    openssl \
  && rm -rf /var/cache/apk/*

# Create directory for SSL certs
RUN mkdir -p /etc/nginx/ssl

# Copy configuration and init script
COPY conf/default.conf /etc/nginx/http.d/default.conf
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# Expose HTTPS port
EXPOSE 443

ENTRYPOINT ["/init.sh"]