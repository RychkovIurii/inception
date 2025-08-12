### Clean and restart everything
Sometimes Compose caches things. Run:  

```bash
docker compose down -v --remove-orphans
docker system prune -af --volumes
make
```