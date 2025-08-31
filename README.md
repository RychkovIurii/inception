# Inception

Project scaffold for a WordPress + MariaDB stack behind NGINX over HTTPS using Docker Compose.

Usage
- `make` (or `make all`): Adds `127.0.0.1 irychkov.42.fr` to `/etc/hosts`, ensures data dirs exist, and runs `docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build`.
- `make down`: Stops only this stack (`--remove-orphans`).
- `make fclean`: Project-scoped cleanup: `down --rmi local --volumes --remove-orphans`, removes `/home/irychkov/data/*`, and cleans hosts entry.
- `make re`: Full rebuild (fclean + all).

Notes
- Secrets live in `secrets/` and are referenced by Compose as Docker secrets.
- Volumes bind to `/home/irychkov/data/{mariadb,wordpress}`.
- HTTPS served on `https://irychkov.42.fr:443` (self-signed by default).
