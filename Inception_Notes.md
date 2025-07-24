## 🖋️ Step 1: Set up your Virtual Machine

Follow the step-by-step instructions in `vm_setup.md`.

---

## 🖋️ Step 2: Create Project Structure and Makefile

### 📁 Recommended Project Structure

```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── srcs/
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       └── wordpress/
│           ├── Dockerfile
│           ├── conf/
│           └── tools/
```

---

### 📌 Structure Explanation

- `Makefile` — launches `docker compose up --build`.
- `secrets/` — stores credentials (should not be pushed to git!).
- `srcs/` — main project directory.
  - `.env` — environment variables.
  - `docker-compose.yml` — defines all services.
  - `requirements/` — one folder per service:
    - `nginx/`, `wordpress/`, `mariadb/` — each with its own Dockerfile, config, and tools.

---

### 🛠️ What to do now

#### 🔧 1. Create directories and files:

```bash
mkdir -p ~/inception/{secrets,srcs/requirements/{nginx,wordpress,mariadb}}

# inside each service:
mkdir -p ~/inception/srcs/requirements/nginx/{conf,tools}
mkdir -p ~/inception/srcs/requirements/wordpress/{conf,tools}
mkdir -p ~/inception/srcs/requirements/mariadb/{conf,tools}

# base files:
touch ~/inception/srcs/docker-compose.yml
touch ~/inception/srcs/.env
touch ~/inception/Makefile

# secrets:
touch ~/inception/secrets/credentials.txt
touch ~/inception/secrets/db_password.txt
touch ~/inception/secrets/db_root_password.txt
```

✅ After this, you will have a clean structure ready to work with.

---

#### 🔧 2. Create a basic Makefile

Edit `Makefile` and paste:

```makefile
NAME=inception

all:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build

down:
	docker compose -f srcs/docker-compose.yml down

fclean: down
	docker system prune -af --volumes

re: fclean all
```

Install `make` and `tree`:

```bash
sudo apt-get install tree
sudo apt-get install make
```

💡 `make` runs `docker compose` using your `.env` file.

---

### ✅ What’s next?

Once you’ve created the structure and `Makefile`, we’ll proceed to:

1. Create the `.env` file with variables.
2. Write `docker-compose.yml`.
3. Set up services: **nginx → mariadb → wordpress** (in that order).


## 🖋️ Step 3: Create the `.env` File

The `.env` file will contain all environment variables used in your `docker-compose.yml` and Dockerfiles.  
**This is a strict project requirement:** _no passwords or logins should be hardcoded in your code!_

---

### 📋 Example `.env` Content

Create the file:

```bash
nano ~/inception/srcs/.env
```

Paste this example:

```env
# DOMAIN
DOMAIN_NAME=irychkov.42.fr

# MYSQL (MariaDB)
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD_FILE=/run/secrets/db_password

# WORDPRESS
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD_FILE=/run/secrets/db_password
WP_ADMIN_USER=main_user
WP_ADMIN_PASSWORD_FILE=/run/secrets/credentials.txt
WP_ADMIN_EMAIL=admin@irychkov.42.fr
WP_SITE_TITLE=Inception42
```

---

### 📌 Variable Explanations

| Variable                     | Purpose                                               |
|------------------------------|-------------------------------------------------------|
| `DOMAIN_NAME`                | Used by nginx for TLS and domain setup                |
| `MYSQL_ROOT_PASSWORD_FILE`   | Path to MariaDB root password file                    |
| `MYSQL_DATABASE`             | WordPress database name                               |
| `MYSQL_USER`                 | Database user                                         |
| `MYSQL_PASSWORD_FILE`        | Path to password file for `MYSQL_USER`                |
| `WORDPRESS_DB_HOST`          | MariaDB address inside Docker network                 |
| `WORDPRESS_DB_NAME`          | WordPress DB name (same as `MYSQL_DATABASE`)          |
| `WORDPRESS_DB_USER`          | WordPress DB user (same as `MYSQL_USER`)              |
| `WORDPRESS_DB_PASSWORD_FILE` | File with WordPress DB password                       |
| `WP_ADMIN_USER`              | WordPress admin username (should not be 'admin')      |
| `WP_ADMIN_PASSWORD_FILE`     | File with WordPress admin password                    |
| `WP_ADMIN_EMAIL`             | WordPress admin email                                 |
| `WP_SITE_TITLE`              | WordPress site title                                  |

---

**Next:**  
You’ll use these variables in your `docker-compose.yml` and service Dockerfiles to keep credentials secure and configuration flexible.

---

## 🖋️ Step 4: Add Secrets and Environment Variables

### 🔑 1. Add Passwords to `secrets/` Files

Run these commands to add your real passwords to the secrets files:

```bash
echo "supersecret_root" > ~/inception/secrets/db_root_password.txt
echo "userpass123"      > ~/inception/secrets/db_password.txt
echo "secureadminpass"  > ~/inception/secrets/credentials.txt
```

> ⚠️ These files must be specified as Docker secrets in `docker-compose.yml` (we’ll do this in the next step).

---
