
# 🐳 Docker Compose Cheatsheet with Explanations

This is a reference for writing `docker-compose.yml` files, with explanations for each important key and feature.

---

## 🔹 Basic Service Syntax

```yaml
services:
  servicename:
    build: ./path
    image: custom-image-name
    container_name: name
    ports:
      - "host:container"
    environment:
      - VAR=value
    env_file:
      - .env
    volumes:
      - host_path:container_path
    secrets:
      - my_secret
    networks:
      - my_network
    depends_on:
      - other_service
    restart: unless-stopped
```

---

## 🔍 Key Explanations

### `build`
- Tells Docker how to build an image.
- `context`: path to the directory with the Dockerfile.
- `dockerfile`: optional, name of a custom Dockerfile.

### `image`
- The name/tag of the image to use or build.

### `container_name`
- The custom name for the running container (instead of a generated one).

### `ports`
- Maps ports from host to container: `"443:443"` means host port 443 → container port 443.

### `environment`
- Inline environment variables passed to the container.

### `env_file`
- A `.env` file with key=value pairs. Variables will be available to the container.

---

## 🔸 Volumes

```yaml
volumes:
  volume_name:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /absolute/host/path
```

### `driver`
- Defines the volume backend. `local` is default (local file system).

### `driver_opts`
- Fine-tune how the volume is mounted.
- `type: none`: tells Docker not to use a special FS type.
- `o: bind`: mount the host directory as a bind mount.
- `device`: the absolute path on the host that is mounted into the container.

---

## 🔸 Networks

```yaml
networks:
  my_network:
    driver: bridge
```

### `driver`
- Commonly `bridge` for internal container networking.

---

## 🔸 Secrets

```yaml
secrets:
  my_secret:
    file: ./secrets/secret_file.txt
```

### How it works:
- The content is mounted inside the container at `/run/secrets/my_secret`.
- Use this to store DB passwords or admin credentials.

---

## 🔸 Restart Policies

```yaml
restart: always | no | on-failure | unless-stopped
```

- `always`: always restart
- `no`: never restart
- `on-failure`: restart only on error (non-zero exit code)
- `unless-stopped`: restart unless manually stopped

---

## 🔸 Other keys

### `depends_on`
- Defines startup order (not readiness).

### `command`
- Overrides default `CMD` in Dockerfile.

---

## 🔹 Useful Docker Compose CLI Commands

```bash
docker compose up --build      # Build and run containers
docker compose down            # Stop and remove containers, network, etc.
docker compose ps              # Show running services
docker compose logs -f         # Show logs in real-time
docker compose exec service sh  # Get shell access
docker compose config          # View expanded and validated config
```

---

## 🧠 Tips

- Keep secrets in files and refer via `secrets` not `env`.
- Use volumes for persistent data.
- Keep `docker-compose.yml` clean by offloading configs to `.env`.

---

Inspired by: https://docs.docker.com/compose/compose-file/
