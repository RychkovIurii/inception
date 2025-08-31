# Inception Project Verification Guide

## Overview
This guide explains how to verify the Inception project on an Ubuntu server, including installation, configuration, and testing procedures.

## Prerequisites Installation

### 1. Update System and Install Required Packages
```bash
sudo apt update
sudo apt install git docker.io docker-compose-plugin make
sudo systemctl enable --now docker
```

### 2. Add User to Docker Group (Optional)
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

## Project Setup

### 1. Clone the Repository
```bash
git clone <REPO_URL>
cd inception/inception
```

### 2. Environment Configuration

#### Create Environment File
Create `srcs/.env` with the following required variables:

```bash
# DOMAIN
DOMAIN_NAME=irychkov.42.fr

# MYSQL (MariaDB)
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD_FILE=/run/secrets/db_password

# WORDPRESS
WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD_FILE=/run/secrets/db_password

# ADMIN USER
WP_ADMIN_USER=main_user
WP_ADMIN_PASSWORD_FILE=/run/secrets/credentials
WP_ADMIN_EMAIL=admin@irychkov.42.fr
WP_SITE_TITLE=Inception42

# SECOND USER
WP_SECOND_USER=irychkov
WP_SECOND_PASSWORD_FILE=/run/secrets/credentials
WP_SECOND_EMAIL=irychkov@42.fr
WP_SECOND_ROLE=author
```

#### Configure Secrets
Place password/credential values into the secrets directory (outside `srcs/`):

```bash
# Create secrets directory if it doesn't exist
mkdir -p secrets/

# Add your passwords to these files:
echo "your_root_password" > secrets/db_root_password.txt
echo "your_db_password" > secrets/db_password.txt
echo "your_wp_admin_password" > secrets/credentials.txt
```

## Deployment

### 1. Build and Start the Stack
```bash
make            # Runs: docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build
```

### 2. Alternative Docker Commands
```bash
# Manual build and start (explicit env-file)
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build

# Start in detached mode
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build -d
```

## Verification Steps

### 1. Check Service Health
```bash
# Check container status and health
docker compose -f srcs/docker-compose.yml ps

# Expected output should show "healthy" status for mariadb
# and "running" status for other services
```

### 2. Monitor Logs
```bash
# Watch real-time logs for all services
docker compose -f srcs/docker-compose.yml logs -f

# Check logs for specific service
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

### 3. Test Application Access

#### Web Browser Access
- Navigate to: `https://irychkov.42.fr` (port 443)
- **Note**: You'll see a security warning due to the self-signed certificate
- Click "Advanced" → "Proceed to site" to continue

#### Command Line Testing
```bash
# Test from the server itself
curl -k https://localhost:443

# Test with verbose output
curl -kv https://localhost:443

# Expected: HTML response from WordPress
```

### 4. Database Connection Test
```bash
# Test MariaDB connectivity
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u root -p

# Test WordPress database
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u wp_user -p wordpress
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Port Conflicts
```bash
# Check what's using port 8443
sudo netstat -tulpn | grep 8443

# Stop conflicting services if needed
sudo systemctl stop apache2  # if Apache is running
```

#### 2. Permission Issues
```bash
# Fix Docker permissions
sudo chown -R $USER:$USER ./srcs/
sudo chmod +x srcs/requirements/*/tools/*.sh
```

#### 3. Container Health Checks
```bash
# Check individual container health
docker inspect <container_name> | grep -A 10 "Health"

# Restart unhealthy containers
docker compose -f srcs/docker-compose.yml restart <service_name>
```

## Cleanup Operations

### 1. Stop Services
```bash
make down     # Stops containers but preserves volumes (removes orphans)
```

### 2. Complete Cleanup (Destructive)
```bash
make fclean   # Project-scoped cleanup: containers, volumes, locally-built images
```

### 3. Manual Cleanup
```bash
# Stop and remove containers
docker compose -f srcs/docker-compose.yml down --remove-orphans

# Remove volumes (data loss!)
docker compose -f srcs/docker-compose.yml down --volumes --remove-orphans

# Remove images built for this project
docker compose -f srcs/docker-compose.yml --env-file srcs/.env down --rmi local --volumes --remove-orphans
```

## Success Criteria

✅ **Containers Running**: All three services (nginx, wordpress, mariadb) are running  
✅ **Health Checks**: MariaDB shows "healthy" status  
✅ **HTTPS Access**: WordPress site accessible via HTTPS  
✅ **SSL Certificate**: Self-signed certificate working  
✅ **Database Connection**: WordPress can connect to MariaDB  
✅ **No Errors**: Clean logs without critical errors  

## Expected Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     nginx       │    │   wordpress     │    │    mariadb      │
│   (reverse      │    │   (php-fpm)     │    │   (database)    │
│    proxy)       │◄──►│                 │◄──►│                 │
│   Port: 443     │    │   Port: 9000    │    │   Port: 3306    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
   HTTPS Traffic
   (Self-signed cert)
```

This verification sequence ensures the repository builds correctly, containers start successfully, health checks pass, and the WordPress site is reachable over HTTPS with proper SSL termination.
