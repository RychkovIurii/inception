
# Step 10: MariaDB Service — Dockerfile and Initialization

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
```

---

## 🛠️ 2. Create the `init.sh` script

File: `~/inception/srcs/requirements/mariadb/tools/init.sh`

```bash
#!/bin/sh

# Read secrets from mounted secret files
MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
  mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

  mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

exec mysqld --user=mysql --console
```

Then make it executable:

```bash
chmod +x ~/inception/srcs/requirements/mariadb/tools/init.sh
```

---

## 🟩 3. Make sure `.env` and secrets are ready

Required variables in `.env`:
```
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD_FILE=/run/secrets/db_password
```

Secrets needed in `/secrets/`:
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
