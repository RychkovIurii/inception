
# Step: NGINX Setup with TLS — Dockerfile and Configuration

This step explains how to configure NGINX as the only entrypoint to your infrastructure, secured with TLS (HTTPS only).

---

## 📁 Directory Structure

Work in:

```
~/inception/srcs/requirements/nginx/
├── Dockerfile
├── conf/
│   └── default.conf
└── tools/
    └── init.sh
```

---

## 🛠️ 1. Create the Dockerfile

File: `~/inception/srcs/requirements/nginx/Dockerfile`

```Dockerfile
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
```

---

## 🛠️ 2. Create init.sh (generates SSL + starts NGINX)

File: `~/inception/srcs/requirements/nginx/tools/init.sh`

```bash
#!/bin/sh

# Generate self-signed cert if not exists
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=42/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}"
fi

# Start nginx in foreground
exec nginx -g 'daemon off;'
```

Make it executable:

```bash
chmod +x ~/inception/srcs/requirements/nginx/tools/init.sh
```

---

## 🛠️ 3. Create default.conf

File: `~/inception/srcs/requirements/nginx/conf/default.conf`

```nginx
server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

    ssl_certificate     /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    ssl_protocols TLSv1.2 TLSv1.3;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        fastcgi_pass wordpress:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
        fastcgi_index index.php;
    }
}
```

---

## ⚠️ Make sure in `docker-compose.yml`

- The nginx service maps:
```yaml
ports:
  - "443:443"
```

- The service shares the WordPress volume:
```yaml
volumes:
  - wordpress_data:/var/www/html
```

- And reads env vars from `.env`:
```yaml
env_file: .env
```

---

## ✅ Test It

From project root:

```bash
cd ~/inception
make
```

Then open in browser:
```
https://irychkov.42.fr
```

Make sure your browser says “connection secure” (it will be self-signed, so accept the warning).

---

✅ NGINX is now your single TLS-secured entrypoint into your Docker infrastructure.
