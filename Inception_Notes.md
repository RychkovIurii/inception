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

💡 `make` runs `docker compose` using your `.env` file.

---

### ✅ What’s next?

Once you’ve created the structure and `Makefile`, we’ll proceed to:

1. Create the `.env` file with variables.
2. Write `docker-compose.yml`.
3. Set up services: **nginx → mariadb → wordpress** (in that order).
