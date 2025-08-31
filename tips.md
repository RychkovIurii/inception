### Clean and restart everything
Sometimes Compose caches things. Run:  

```bash
docker compose -f srcs/docker-compose.yml down --volumes --remove-orphans
make fclean   # project-scoped cleanup (images/volumes used here)
make          # rebuild and start
```

### Sample with healthcheck
```
  mariadb:
    container_name: mariadb
    build: ./requirements/mariadb
    env_file: .env
    secrets:
      - db_root_password
      - db_password
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-P", "3306"]
      start_period: 90s
      interval: 10s
      timeout: 5s
      retries: 10
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - inception
    restart: unless-stopped

  wordpress:
    container_name: wordpress
    build: ./requirements/wordpress
    env_file: .env
    secrets:
      - db_password
      - credentials
    volumes:
      - wordpress_data:/var/www/wp
    depends_on:
      mariadb:
        condition: service_healthy
    networks:
      - inception
    restart: unless-stopped
```
