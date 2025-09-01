# Inception - Tips and Commands

### Clean and restart everything
Sometimes Compose caches things. Run:  

```bash
docker compose -f srcs/docker-compose.yml down --volumes --remove-orphans
make fclean   # project-scoped cleanup (images/volumes used here)
make          # rebuild and start
```

### Simple checks (after make)
- Check NGINX on 443: `docker ps` should show `0.0.0.0:443->443/tcp` for `nginx`.
- Verify TLS is served:
  - `curl -I https://localhost --insecure`
  - `openssl s_client -connect localhost:443 -servername irychkov.42.fr </dev/null | head -n 20`
- Confirm HTTP (port 80) is not served:
  - `curl -I http://irychkov.42.fr` (should fail/connection refused)
  - or explicitly: `curl -I http://irychkov.42.fr:80`
  - For a TLS-misuse demo: `curl -vk https://irychkov.42.fr:80` (shows handshake failure)

### What is a Docker network?
- A Docker network lets containers communicate as if on the same LAN.
- Containers resolve each other by service/container name via embedded DNS.
- Useful commands:
  - List networks: `docker network ls`
  - Inspect project net: `docker network inspect inception`
  - Show services: `docker compose -f srcs/docker-compose.yml ps`

### Demonstrate port behavior
- HTTPS works: `curl -I https://irychkov.42.fr --insecure`
- HTTP closed: `curl -I http://irychkov.42.fr` (or `:80`)
- TLS proof: `openssl s_client -connect localhost:443 -servername irychkov.42.fr </dev/null | head -n 20`

### WordPress admin
- URLs:
  - `https://irychkov.42.fr/wp-admin`
  - `https://irychkov.42.fr/wp-login.php`
- After login, create a new post and leave a comment to verify DB writes.

### MariaDB access (root)
- Use the MariaDB client inside the container (no bash needed):
  - `docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u root -p`
  - Enter the root password from `secrets/db_root_password.txt`.
- Useful SQL:
  - `SHOW DATABASES;`
  - `USE wordpress;`
  - `SHOW TABLES;`

---

### Simple setup:

- Ensure NGINX can be accessed by port 443. Check with `docker ps` command.
- Ensure SSL/TLS certificate is used. Check the conf and use command:
  - `curl -I https://localhost --insecure`
  - Or this command shows even more details: `openssl s_client -connect localhost:443`
- Verify that HTTP does not work. For example:
  - `curl -I --insecure http://irychkov.42.fr:443`

### What is Docker network?
- Docker network is a way to enable containers to communicate with each other like they would be in the same network.
- You don’t need to use IP addresses to communicate, you can use the names of the containers.

### Demonstrate that port 80 is not working
```bash
curl -I --insecure https://irychkov.42.fr:80
```

### Demonstrate that TLS is used
```bash
openssl s_client -connect localhost:443
```

### Login to WordPress as admin
- `https://irychkov.42.fr/wp-admin`
- `https://irychkov.42.fr/wp-login.php`
- Create a new post so you can write a comment

### This is how you can login to MariaDB as root
```bash
docker exec -it mariadb-container bash
mysql -u root -p
```

- It will prompt the password

Then to show the databases:

```sql
SHOW DATABASES;
```

Then use the database:

```sql
USE inception;
```

Then show the tables in database:

```sql
SHOW TABLES;
```

### Summary:

- Ensure NGINX can be accessed by port 443. Check with `docker ps` command.
- Ensure SSL/TLS certificate is used. Check the conf and use:
  - `curl -I https://localhost --insecure`
  - Or: `openssl s_client -connect localhost:443`
- Verify that HTTP does not work:
  - `curl -I --insecure http://irychkov.42.fr:443`
- Understand Docker network:
  - A way to enable containers to communicate without using IPs.
- Demonstrate port 80 is not working:
  - `curl -I --insecure https://irychkov.42.fr:80`
- Demonstrate TLS is used:
  - `openssl s_client -connect localhost:443`
- Login to WordPress:
  - Visit `wp-admin` and create a post/comment.
- Login to MariaDB as root and inspect the DB.

### Data transfer using SCP and SSH
scp -P 2222 -r /home/irychkov/Desktop/test irychkov@127.0.0.1:/home/irychkov/
ssh -p 2222 irychkov@127.0.0.1