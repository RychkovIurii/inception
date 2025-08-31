
# Inception Project — Virtual Machine Setup Notes

## 🖋️ Step 1: Set up your Virtual Machine

---

### 1️⃣ Choose a virtualization solution

On your host machine (Linux / Windows / macOS), install one of these:

- VirtualBox (free & cross-platform): https://www.virtualbox.org/wiki/Downloads
- Or use VMware if you already have it.
- Or on macOS: UTM (https://mac.getutm.app/) if you prefer.

💡 **Recommendation**: VirtualBox — widely used, easy to set up, and perfect for this project.  
✅ I chose **VirtualBox**.

---

### 2️⃣ Download a Linux ISO

You’ll need a Linux distribution to install inside the VM.

- **Suggested**: Debian 12 (Bookworm) — https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/
- Or: Ubuntu Server 24.04 LTS — https://ubuntu.com/download/server

✅ I chose **Debian**.

---

### 3️⃣ Create a VM in VirtualBox

- Open VirtualBox → New → Name it `inception-vm`
- Set OS type: **Linux / Debian**
- Assign:
  - 2 CPUs
  - 2048 MB RAM (or more)
  - 10–20 GB disk space
- Mount the ISO you downloaded as the optical disk for first boot.

---

### 4️⃣ Install Linux

- Boot the VM, and follow the installation wizard.
- Create a user with your login (e.g., `yourlogin` or `irychkov`)
- Install **OpenSSH server** if prompted (optional, but useful for SSH)

---

### 5️⃣ Install Docker and Docker Compose

Follow the step-by-step instructions in `docker-install.md`.

---
### 6️⃣ Map domain name to hosts on VM

Note: `make` automatically adds `127.0.0.1 irychkov.42.fr` to `/etc/hosts`. You can also do it manually:

```bash
echo "127.0.0.1 irychkov.42.fr" | sudo tee -a /etc/hosts
```

### Static IP and hostname (OPTIONAL if you have root to host)

To access your VM via a browser using a fake domain like `login.42.fr` (e.g. `irychkov.42.fr`), you need to assign your VM a **static IP** that's accessible from your host machine.

---

#### Check current IP:

Open terminal on your VM and run:

```bash
hostname -I
```

Example output:
```
10.0.2.15 172.17.0.1 ...
```

📌 **Problem**: IP like `10.0.2.15` is a NAT address (default VirtualBox mode) — not accessible from the host browser.

---

## ✅ Solution: Add a second network adapter (Host-Only)

### 🔧 1. Shut down the VM

### 🔧 2. Open VM settings → Network

- Adapter 1: keep as NAT  
- Adapter 2:
  - Enable it
  - Choose **Host-only Adapter**
  - Name: `vboxnet0` (or whatever is available)

💡 If no adapter is listed: go to VirtualBox → File → Network Manager → Create

---

### 🔧 3. Start the VM and check IP

Run:
```bash
ip a
```
or
```bash
ip addr show
```

✅ You should now see a new IP like:
```
192.168.56.101
```

📌 This will be your static IP.

---

### 🔧 4. Update `/etc/hosts` on the **host machine** (not in VM)

```bash
sudo nano /etc/hosts
```

Add:
```
192.168.56.101    irychkov.42.fr
```

---

### ✅ Verify (port 443)

Run:
```bash
ping irychkov.42.fr
```

Example output:
```
PING irychkov.42.fr (192.168.56.101) 56(84) bytes of data.
64 bytes from irychkov.42.fr: icmp_seq=1 ttl=64 time=0.5 ms
...
```

📎 If ping works and resolves to your VM's IP — you’re ready to continue.

---

✅ **My result: it works. We move forward.**
