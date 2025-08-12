
# 📘 docker-compose.yml — Full Explanation

This file defines the three main services (mariadb, wordpress, nginx), how they interact, and how secrets, volumes, and networks are used.

---

## 🔹 services:

### 🔸 mariadb:

```yaml
mariadb:
  container_name: mariadb
```
- Sets the container's name instead of a random one.

```yaml
  build: ./requirements/mariadb
```
- Tells Docker to build an image using the Dockerfile located in `requirements/mariadb`.

```yaml
  env_file: .env
```
- Loads environment variables from `.env` file.

```yaml
  secrets:
    - db_root_password
    - db_password
```
- Injects sensitive data (passwords) from `secrets/` directory into `/run/secrets/...` inside the container.

```yaml
  volumes:
    - mariadb_data:/var/lib/mysql
```
- Maps the named volume `mariadb_data` to store the MySQL database files.

```yaml
  networks:
    - inception
```
- Connects the service to the custom network `inception`.

```yaml
  restart: unless-stopped
```
- Automatically restarts the container unless it was stopped manually.

---

### 🔸 wordpress:

```yaml
wordpress:
  container_name: wordpress
  build: ./requirements/wordpress
  env_file: .env
```
- Same as above: builds custom image and loads env vars.

```yaml
  secrets:
    - db_password
    - credentials
```
- Injects both database user password and WordPress admin credentials securely.

```yaml
  volumes:
    - wordpress_data:/var/www/html
```
- Mounts persistent storage to serve WordPress files.

```yaml
  depends_on:
    - mariadb
```
- Ensures mariadb container starts before wordpress.

```yaml
  networks:
    - inception
  restart: unless-stopped
```
- Same as above.

---

### 🔸 nginx:

```yaml
nginx:
  container_name: nginx
  build: ./requirements/nginx
  env_file: .env
```
- NGINX container with config and TLS setup.

```yaml
  volumes:
    - wordpress_data:/var/www/html
```
- Mounts the same WordPress volume (read-only from nginx).

```yaml
  ports:
    - "443:443"
```
- Maps port 443 on host to port 443 on container (TLS only).

```yaml
  depends_on:
    - wordpress
  networks:
    - inception
  restart: unless-stopped
```
- Waits for WordPress before starting.

---

## 🔹 volumes:

```yaml
volumes:
  mariadb_data:
    driver: local
    name: mariadb_data
    driver_opts:
      type: none
      o: bind
      device: /home/irychkov/data/mariadb
```
- **mariadb_data** volume stores database files persistently on the host machine.
- `type: none` and `o: bind` means it's mounted directly from the host path.
- `device`: absolute path on the host.

Same structure applies for:

```yaml
  wordpress_data:
    ...
    device: /home/irychkov/data/wordpress
```
- Stores all WordPress site files persistently.

---

## 🔹 networks:

```yaml
networks:
  inception:
    driver: bridge
```
- Creates an isolated Docker network for all containers to communicate internally.

---

## 🔹 secrets:

```yaml
secrets:
  db_root_password:
    file: ../secrets/db_root_password.txt
```
- Maps a file on the host into `/run/secrets/db_root_password` in the container.

Other secrets follow the same pattern.

---

✅ With this structure:
- nginx is the only entrypoint (port 443),
- mariadb stores data persistently,
- secrets are securely injected,
- all containers are isolated in a private network.
