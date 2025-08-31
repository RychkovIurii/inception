
# Step: MariaDB Service — Dockerfile and Initialization

This step guides you through setting up the `mariadb` container from scratch using Alpine. It will read secrets, configure the DB, and run safely.

Alpine is lightweight (~5MB), fast, and more secure with a minimal surface, making it ideal for custom, efficient containers. However, it may require extra setup and has compatibility issues with some software compared to Debian, which is larger but easier and more compatible out of the box.

---

## 📁 Directory Structure

You should be inside:
```
~/inception/srcs/requirements/mariadb/
├── Dockerfile
├── conf/
└── tools/
```

---

## 🛠️ 1. Create the `Dockerfile`

File: `~/inception/srcs/requirements/mariadb/Dockerfile`

```Dockerfile
FROM alpine:3.21

RUN apk update && apk add --no-cache \
    mariadb mariadb-client \
 && rm -rf /var/cache/apk/*

RUN mkdir -p /run/mariadbd /var/lib/mysql /var/log/mysql \
 && chown -R mysql:mysql /run/mariadbd /var/lib/mysql /var/log/mysql

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306
ENTRYPOINT ["/init.sh"]
```

---

## 🛠️ 2. Create the `init.sh` script

File: `~/inception/srcs/requirements/mariadb/tools/init.sh`

```bash
#!/bin/sh
set -eu

trim_file() { tr -d '\r\n' < "$1"; }
need() { eval "v=\${$1:-}"; [ -n "$v" ] || { echo "❌ Missing env: $1" >&2; exit 1; }; }

need MYSQL_DATABASE
need MYSQL_USER
need MYSQL_ROOT_PASSWORD_FILE
need MYSQL_PASSWORD_FILE

MYSQL_ROOT_PASSWORD="$(trim_file "$MYSQL_ROOT_PASSWORD_FILE")"
MYSQL_PASSWORD="$(trim_file "$MYSQL_PASSWORD_FILE")"
DATADIR="/var/lib/mysql"

if [ ! -d "${DATADIR}/mysql" ]; then
  mariadb-install-db --user=mysql --basedir=/usr --datadir="$DATADIR" >/dev/null
  mariadbd --user=mysql --bootstrap --datadir="$DATADIR" <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
DELETE FROM mysql.user WHERE user='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF
fi

exec mariadbd-safe
```

Then make it executable:

```bash
chmod +x ~/inception/srcs/requirements/mariadb/tools/init.sh
```

---

## 🟩 3. Make sure `.env` and secrets are ready

Required variables in `.env` (note: secrets mount to `/run/secrets/<name>`, no `.txt`):
```
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD_FILE=/run/secrets/db_password
```

Secrets needed in `secrets/` (outside `srcs/`):
- `db_root_password.txt`
- `db_password.txt`

---

## ✅ Test it

From your main project folder:

```bash
cd ~/inception
make
```

Then test DB connection:

```bash
docker exec -it mariadb mariadb -u wp_user -p
# Enter the password from db_password.txt
```

You should be inside MySQL shell.

---
