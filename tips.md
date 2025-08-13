### Clean and restart everything
Sometimes Compose caches things. Run:  

```bash
docker compose down -v --remove-orphans
docker system prune -af --volumes
make
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
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      start_period: 30s
      interval: 5s
      timeout: 3s
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
      - wordpress_data:/var/www/html
    depends_on:
      mariadb:
        condition: service_healthy
    networks:
      - inception
    restart: unless-stopped
```