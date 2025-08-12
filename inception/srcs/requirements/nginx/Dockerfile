FROM alpine:3.18

RUN apk update && apk add --no-cache \
    nginx \
    openssl

# Create directory for SSL certs
RUN mkdir -p /etc/nginx/ssl

# Copy configuration and init script
COPY conf/default.conf /etc/nginx/http.d/default.conf
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]