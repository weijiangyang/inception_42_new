## 1. Environment Setup

### Prerequisites
Ensure your local system (VM or host) has the following installed:
* **Docker Engine** (v20.10+)
* **Docker Compose** (v2.0+)
* **GNU Make**

### Configuration & Secrets
To maintain zero-trust security, all sensitive environment variables are completely decoupled from the code and injected dynamically via Docker Secrets.

1. **Local DNS Setup:** Add `weiyang.42.fr` to your local `/etc/hosts` file:
   ```bash
   echo "127.0.0.1 weiyang.42.fr" | sudo tee -a /etc/hosts



2. **Secrets & Environment Provisioning:** Create the configurations before building:
   * **Docker Secrets (`srcs/secrets/`):** Create this folder and populate it with raw text files:
     * `srcs/secrets/db_root_password` (MariaDB root password)
     * `srcs/secrets/db_password` (WordPress database user password)
     * `srcs/secrets/ftp_password` (Secure FTP user password)
     * `srcs/secrets/wp_admin_password` (WordPress admin password)
     * `srcs/secrets/wp_user_password` (WordPress user password)
     
   * **Environment File (`srcs/.env`):** Create a `.env` file to store non-sensitive configuration keys (e.g., database names, user names, host configurations, domain settings).


---

## 2. Build and Launch the Project

The infrastructure lifecycle is entirely managed using the `Makefile` located at the root of the project.

* **Build & Run Core Services Only:** Builds images and starts Nginx, WordPress, and MariaDB.
```bash
make

```


* **Build & Run Everything (Core + Bonuses):** Launches the entire stack, including Redis, FTP, Adminer, Static Host, and Uptime Kuma.
```bash
make bonus

```


* **Stop the Stack:** Gracefully stops and removes running containers and virtual networks without deleting data.
```bash
make clean

```


* **Full Hard Reset (Wipe Everything):** Stops containers, deletes networks, and completely wipes out all persistent physical volumes.
```bash
make fclean

```



---

## 3. Container & Volume Management Commands

Use these standard Docker commands within the environment to debug and audit the system:

* **Inspect Active Processes:** Check container resource allocation, IDs, and uptime.
```bash
docker ps

```


* **Stream Real-time Logs:** Monitor application runtime behaviors and errors.
```bash
docker logs -f <container_name>

```


* **Execute Terminal Inside a Container:** Pop a shell into an active runtime container for manual debugging.
```bash
docker exec -it <container_name> sh

```


* **Inspect Virtual Storage Volumes:** View all volumes managed by the Docker engine.
```bash
docker volume ls

```



---

## 4. Data Storage and Persistence Strategy

The architecture enforces a strict decoupling of stateless compute layers from stateful storage layers.

### Where Data Lives

All critical runtime data is bound to local-driver Named Volumes configured with `driver_opts`. This forces Docker to map container filesystems directly back down to visible, absolute paths on your VM/host:

* **WordPress Core & Uploads:** Persistent on the host at `/home/weiyang/data/wordpress/`
* **MariaDB Database Shards:** Persistent on the host at `/home/weiyang/data/mariadb/`

### How Persistence Survives Destruction

Because the storage is tied to explicit physical paths on the host machine via `driver_opts`, running commands like `make clean` or forcing container deletion will only destroy the stateless execution environments.

The next time you run `make` or `make bonus`, the newly spawned containers will automatically remount these paths, guaranteeing **100% data survival across aggressive destruction cycles**.

