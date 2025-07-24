
# Docker Installation Guide for Debian 12 (Bookworm)

This guide follows the **official Docker method** for installing Docker Engine and Docker Compose on Debian-based systems (2023+ format using `.asc` keyrings).

---

## 1️⃣ Update package index and install dependencies
```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
```

---

## 2️⃣ Create the keyrings directory
```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

---

## 3️⃣ Download Docker’s GPG key and set permissions
```bash
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

---

## 4️⃣ Add the Docker repository to apt sources
```bash
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc]   https://download.docker.com/linux/debian   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

If you use a Debian derivative (e.g., Kali), replace:
```bash
$(. /etc/os-release && echo "$VERSION_CODENAME")
```
with the actual codename of your base distribution, e.g. `bookworm`.

---

## 5️⃣ Update the apt package index again
```bash
sudo apt-get update
```

---

## 6️⃣ Install Docker Engine and Compose
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## 7️⃣ Verify the installation
```bash
sudo docker run hello-world
```

✅ If successful, you’ll see: `Hello from Docker!`

---

## 8️⃣ (Optional) Allow running docker without sudo
```bash
sudo usermod -aG docker $USER
```

Then log out and back in (or run `newgrp docker`) to apply group change.

---

## 🔧 Useful Notes

- Docker repo: `/etc/apt/sources.list.d/docker.list`
- Docker key: `/etc/apt/keyrings/docker.asc`
- Test docker version: `docker --version`
- Test compose: `docker compose version`

---

Based on: https://docs.docker.com/engine/install/debian/
