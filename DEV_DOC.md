# 1. Prerequisites & Host Environment Alignment

Before bootstrapping the Infrastructure as Code (IaC) layer, the host environment must satisfy the following baseline dependencies to guarantee deterministic multi-container execution:

## 1.1 Physical Dependencies

* **Operating System:** Clean Debian (Bullseye/Bookworm core) or equivalent Linux distribution (e.g., Ubuntu Linux) running natively inside a hypervisor virtual machine.
* **Orchestration Runtimes:**
* `Docker Engine` (v20.10.x or higher)
* `Docker Compose v2` (CLI-plugin standard syntax with dynamic `--profile` support)
* GNU `make` compilation utility



## 1.2 Host Routing Ingress (Domain Redirection)

The web server block intercepts requests targeted at the explicit `weiyang.42.fr` local loopback. You must map this network routing alias inside your host operating system's local hosts files:
alt text
```bash
# Append this entry to /etc/hosts on the host system
127.0.0.1 weiyang.42.fr
alt text
```

---

# 2. Configuration Matrix & Declarative Security

To maintain a secure production posture, configuration scopes are cleanly divided between standard public state variables, declarative orchestrations, and isolated memory-mapped credentials.
![alt text](image.png)
## 2.1 Public Variable Blueprint (`srcs/.env`)

Create a central control configuration file at `srcs/.env` to parameterize non-sensitive system environment values:

```env
# System Path Matrices (Core & Bonus Volumes)
WP_DATA_PATH=/home/weiyang/data/wordpress
DB_DATA_PATH=/home/weiyang/data/mariadb
REDIS_DATA_PATH=/home/weiyang/data/redis

# Domain & General Routing Configurations
WP_URL=weiyang.42.fr
WP_TITLE=Inception_Matrix

# Database Routing Metadata
MYSQL_DATABASE=inception_db
MYSQL_USER=weiyang
WP_USER_EMAIL=weiyang@student.42.fr
WP_ADMIN_EMAIL=admin@42.fr

```

## 2.2 Centralized Composition Engineering (`srcs/docker-compose.yml`)

The `docker-compose.yml` acts as the declarative source of truth for the multi-service architecture, implementing rigid isolation rules:

* **Decoupled Secret Projections:** Rather than injecting plain-text credentials into system environment blocks, passwords are authenticated via a global `secrets:` block. These are projected as temporary, read-only memory files under `/run/secrets/` inside `tmpfs` container filesystems, blocking exposure from `docker inspect` scanning tools.
* **Microservices Profiling Segment:** Extended services are bound under the `bonus` profile namespace. When running `make bonus`, Docker Compose dynamically merges the extended topology (Redis, FTP, Adminer) into the runtime grid.
* **Network Encapsulation:** Services declare custom network scopes under `srcs_inception_network` using a private bridge driver. Container-to-container traffic resolves dynamically via integrated Docker DNS, allowing the application layer to resolve service routes using network aliases.

## 2.3 Security Credentials Blueprint (`srcs/secrets/`)

This framework explicitly bans plain-text hardcoding in `.env` files to prevent global exposure via runtime system inspecting tools. You must populate the following dynamic memory-mapped text files inside `srcs/secrets/` (which are ignored by version control via `.gitignore`):

* **`db_root_password.txt`**: Raw alphanumeric passkey for the administrative MariaDB root accounts.
* **`db_password.txt`**: Dedicated application runtime passkey utilized for internal backend user handshakes.
* **`wp_admin_password.txt`**: Access credential assigned to the primary WordPress root panel identity.
* **`wp_user_password.txt`**: Access credential assigned to the evaluator profile role identity.
* **`ftp_password.txt`**: Access credential allocated to the isolated multi-tenant FTP gateway.

---

# 3. Custom Dockerfile Compilation Blueprints

All microservice layers are compiled completely from scratch using official stable Debian base images. Every `Dockerfile` strips away auxiliary system packages to shrink potential attack surfaces and locks down processes into specific foreground execution scopes.

## 3.1 Nginx Security Hardening Blueprint

The Nginx layer transforms a default web server blueprint into a hardened TLS edge termination gateway:

* **Cryptographic Suite Enforcement:** Custom configurations strictly deprecate legacy cipher suites (SSL v3, TLS v1.0, TLS v1.1), enforcing high-security constraints targeting **TLS v1.2** and **TLS v1.3** via an explicit cipher optimization matrix.
* **Dynamic Bonus Route Branching:** Integrates specific reverse proxy FastCGI blocks routing `/adminer` requests asynchronously to port `9000` on the Adminer node, and handles high-efficiency static content delivery via filesystem `alias` blocks for `/resume`.
* **Foreground Binding Constraint:** The runtime setup explicitly injects the `daemon off;` directive. This process manually locks Nginx’s primary master worker process directly to **PID 1**, preventing the container engine from terminating prematurely when sub-worker processes fork into asynchronous layers.

## 3.2 WordPress & PHP-FPM Application Layer Tuning

The WordPress image bridges the deployment gap between standard web assets and programmatic runtime configurations:

* **Networking Pool Configuration:** Modifies the internal PHP-FPM worker configuration (`www.conf`) to listen on `0.0.0.0:9000` instead of a local Unix socket. This change allows high-efficiency TCP/IP FastCGI network routing loops across isolated container boundaries.
* **Automated WP-CLI Tooling:** Integrates the standalone `wp-cli.phar` utility during image construction. This tool enables the system entrypoint script to dynamically configure, download, and initialize database schemas via programmatic terminal commands, bypassing interactive web setup interfaces completely.
* **Nodaemonize Interception:** The execution block enforces service persistence by launching via `php-fpm7.4 -F` (or `--nodaemonize`), binding the PHP application interpreter directly to **PID 1** to maintain runtime container stability.

## 3.3 MariaDB Data Engine Isolation

The MariaDB container isolates relational data operations from host interfaces:

* **Private Socket Binding:** The compilation replaces default server settings with `bind-address=0.0.0.0` in the `50-server.cnf` configuration file. This restriction ensures that MariaDB accepts queries strictly over the virtual internal bridge sub-network while remaining invisible to external host port scanners.
* **Authentication Layer Stripping:** The initialization sequence strips away the standard high-risk `unix_socket` authentication extension, forcing all local root administrator access controls to use the dynamically mounted runtime credentials.

## 3.4 Redis In-Memory Volatile Acceleration Store (Bonus Layer)

The Redis image sets up the non-relational object caching backend:

* **Protected Standalone Tuning:** Built from a clean Debian image compiling standard `redis-server`. The configuration adjusts memory limit policies to `maxmemory 256mb` and enforces eviction via `maxmemory-policy allkeys-lru` to handle cache drops safely.
* **Interface Binding Constraint:** The runtime strips away local-only bindings, applying `bind 0.0.0.0` to permit secure internal multi-container cluster connectivity while retaining background snapshot persistence (RDB/AOF).

## 3.5 Handcrafted Adminer Container Engine (Bonus Layer)

The Adminer service isolates graphical relational table analytics:

* **Supply-Chain Hardening:** Bypasses heavy third-party configurations by compiling a pristine Debian image embedding a raw, verified `adminer-4.x.x.php` script inside a streamlined, independent `php-fpm` engine running on port `9000`.
* **Zero-Access Security Guard:** Operates with no exposed host-side listening interfaces, making the service entirely dependent on Nginx reverse proxy FastCGI handshakes over the internal LAN.

## 3.6 Chrooted FTP vsftpd Server Jail (Bonus Layer)

The FTP component handles multi-tenant backend asset migration:

* **POSIX Jail Isolation:** Employs a hardened `vsftpd` execution layer configuration. It enforces secure configurations via `chroot_local_user=YES` and `allow_writeable_chroot=YES`.
* **UID/GID Synchronization:** Explicitly overrides standard runtime permissions, locking the FTP data channel target path to `/var/www/html` matching the exact `www-data` ID (`UID 33 / GID 33`). This structure blocks multi-tenant privilege escalation and avoids local write errors.

---

# 4. Infrastructure Architecture & Build Flow

The multi-container cluster is mapped out across an isolated, software-defined private network mesh.

```text
                      [ Developer Ingress via Localhost ]
                                     │
         ┌───────────────────────────┴───────────────────────────┐
         │ (Port 443 | TLS v1.2/v1.3)                            │ (Port 21 | FTP Data Ingress)
         ▼                                                       ▼
┌───────────────────────────────────────────────────┐  ┌───────────────────────────────────┐
│                 nginx-container                   │  │          ftp-container            │
│  (Gateway Interface & Static Content Router)      │  │  (Chrooted POSIX Jail GID: 33)    │
└────────┬─────────────────┬────────────────────────┘  └─────────────────┬─────────────────┘
         │                 │                                             │
         │ (FastCGI)       │ (FastCGI Split Routing)                     │ (Direct File I/O)
         ▼ (Port 9000)     ▼ (Port 9000)                                 │
┌─────────────────┐  ┌──────────────────────────────┐                    │
│  wp-container   │  │       adminer-container      │                    │
│  (PHP-FPM Core) │  │  (Handcrafted SQL Interface) │                    │
└────────┬────────┘  └─────────────┬────────────────┘                    │
         │                         │                                     │
         ├─────────────────────────┴─────────────────────────────────────┤
         │ (MySQL Wire Protocol | Port 3306)                             │ (Shared Host Mount)
         ▼                                                               ▼
┌─────────────────┐                                    ┌───────────────────────────────────┐
│ mariadb-container│                                   │        /home/weiyang/data/        │
│ (Isolated SQL)  │                                    │  (Stateful Physical Volume Disk)  │
└─────────────────┘                                    └─────────────────┬─────────────────┘
         ▲                                                               │
         │ (RESP Cache Protocol | Port 6379)                             │ (Shared Host Mount)
         └───[ redis-container (In-Memory RAM Engine) ]◄─────────────────┘

```

## 4.1 Network Topology Enforcement

The entire stack is placed into a dedicated bridge sub-network layer (`srcs_inception_network`). To **mitigate perimeter vulnerabilities**, only the Nginx gateway maps public HTTPS ports (`443:443`) back out to the host system. When the bonus profile is active, the FTP service opens control port `21` along with passive range bounds (`30000-30009`). The application layers (`php-fpm`, `adminer`), caching arrays (`redis`), and storage matrices (`mariadb`) are bound invisibly inside the internal LAN grid, neutralizing port scanning attacks.

## 4.2 Storage Mapping Mechanics

Persistent state survival is engineered via custom storage driver extensions:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/weiyang/data/mariadb'
  wordpress_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/weiyang/data/wordpress'
  redis_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/weiyang/data/redis'

```

This architectural approach wraps absolute host path mapping under a Named Volume block configuration. Services remain entirely decoupled, but data remains accessible on the local host drive (`/home/weiyang/data/`) for physical compliance auditing and multi-tenant data persistence.

---

# 5. Build, Launch, & Management Lifecycle

Developers control the lifecycle of the environment via automated targets encapsulated within the centralized root `Makefile`.

## 5.1 Orchestration Lifecycles

### A. Core Stack Cold Launch

Compiles custom mandatory service `Dockerfile` recipes (Nginx, WordPress, MariaDB), creates core storage directories, allocates network bridging lanes, and fires up runtime initializations:

```bash
make

```

### B. Extended Complete Stack Launch (👑 Bonus Pipeline)

Compiles and boots the complete infrastructure matrix by integrating the `bonus` profile. This workflow activates the Redis caching engine, Adminer panel, FTP system, and static portfolio routes concurrently:

```bash
make bonus

```

### C. Ephemeral Suspension

Gracefully stops active processing loops and background container runtimes without destroying active state records or network structures:

```bash
make down

```

### D. Active Footprint Takedown

Safely unmaps active container allocations and destroys local virtual local area networks:

```bash
make clean

```

### E. Hard Reset & Data Wipe (Auditing Purge)

Destroys all active container instances, clears cached layer image maps, unmaps virtual networks, and **physically purges all live databases, website data assets, and Redis append-only files from the host drive (`/home/weiyang/data/`)**:

```bash
make fclean

```

### F. Core Chained Redeployment

Triggers an immediate, zero-contamination infrastructure rebuild by executing a clean wipe sequence followed instantly by a fresh mandatory core launch:

```bash
make re

```

### G. Bonus Chained Redeployment (👑 Complete Reset)

Forces a total atomic reset and clean redeployment of the complete advanced portfolio cluster:

```bash
make re_bonus

```

---

# 6. Bootstrapping Scripts & Race-Condition Mitigation

When launching from a cold state, the containers boot concurrently. This creates high-concurrency race conditions where dependent stacks try to communicate with backend engines before daemons finish compiling internal runtime schemas, resulting in system death.

To enforce structural safety, both microservices integrate custom `entrypoint.sh` loops that break execution sequences into distinct tracks:

## 6.1 The MariaDB Bootstrap Track

MariaDB initiates a localized background process bypassing the network interface entirely (`--skip-networking`) to inject secrets securely and populate the core schemas. Once health states pass, the script uses the Bash `exec` instruction to pass control to the main foreground `mysqld` process on **PID 1**.

## 6.2 The WordPress Adaptive Bootloader & Redis Hot-Plugging Matrix

The WordPress container applies a strict **Pre-emptive Topology Probing & Application Injection Sequence**:

```bash
# 1. Clear legacy drop-in transient states from the shared persistent volume
rm -f wp-content/object-cache.php

# 2. Check relational backend availability (Bounded loop targeting MariaDB 3306)
while ! mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASS}" --silent; do
    sleep 2
done

# 3. Asynchronous Non-Blocking Discovery for Bonus Grid Alignment
REDIS_OK=0
if getent hosts redis >/dev/null 2>&1 && ping -c 1 redis >/dev/null 2>&1; then
    if php -r "\$fp=@fsockopen('redis',6379,\$e,\$s,1); if(\$fp){fclose(\$fp);exit(0);} exit(1);"; then
        REDIS_OK=1
    fi
fi

# 4. Aspect-Oriented Configuration Alignment
if [ "$REDIS_OK" -eq 1 ]; then
    # Inject variables strictly BEFORE wp-settings.php execution boundary line
    wp config set WP_REDIS_HOST redis --anchor="require_once ABSPATH . 'wp-settings.php';" --placement="before" --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --anchor="require_once ABSPATH . 'wp-settings.php';" --placement="before" --allow-root
    
    # Download, active, and compile the object-cache.php drop-in router
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
else
    # Safe Mode Fallback: Clear parameters to bypass connection drops
    wp config delete WP_REDIS_HOST --allow-root || true
    wp config delete WP_REDIS_PORT --allow-root || true
fi

# 5. Handover to PID 1
exec /usr/sbin/php-fpm7.4 -F

```

---

# 7. Docker Operational Commands & Status Auditing Guide

## 7.1. Container Management Commands

### Check Active Processes and Security Posture

Run the following command to inspect your running containers and verify that only authorized gateways expose ports to the host system:

```bash
docker ps

```

* **Verification Check (Mandatory Mode):** Ensure that only the Nginx row displays a mapped host port (`0.0.0.0:443->443/tcp`).
* **Verification Check (Bonus Mode):** Ensure that only Nginx (`443`) and FTP (`21`) expose public pathways. The MariaDB (`3306`), WordPress (`9000`), Adminer (`9000`), and Redis (`6379`) containers must show empty host mappings, proving they are completely invisible to external scanners.

### Inspect Container Internals (PID 1 Verification)

To prove to your evaluator that your application processes are running correctly in the foreground as **PID 1**, run:

```bash
docker top <container_name_or_id>

```

* **Example:** `docker top wordpress` or `docker top redis` must explicitly show the primary runtime engine process running at the top of the container's execution tree, confirming that its process lifecycle is bound directly to the container container.

---

## 7.2. Volume & Storage Auditing Commands

### List Active Volumes

To verify that your custom "Local-Persisted Named Volumes" are active and registered within the Docker storage engine, run:

```bash
docker volume ls

```

### Inspect Volume Metapaths

To verify that your volume driver configurations have successfully linked back to your mandatory hardware path (`/home/weiyang/data/`), execute:

```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_redis_data

```

* **Expected Output Matrix:** In the JSON output block, ensure the `Options` mapping displays exactly these parameters:

```json
"device": "/home/weiyang/data/mariadb",
"o": "bind",
"type": "none"

```

### Host-Side Physical Data Auditing

To satisfy the strict 42 evaluation sheet requirement of verifying database, cache chunks, and web asset persistence directly on the host drive without using Docker utilities, run:

```bash
ls -la /home/weiyang/data/mariadb
ls -la /home/weiyang/data/wordpress
ls -la /home/weiyang/data/redis

```

---

## 7.3. Network Topology Commands

### Map Network Attachments

To review the internal sub-network configuration and confirm your containers are properly isolated on the custom bridge grid, run:

```bash
docker network ls

```

### Inspect Private Network Routing

To map container internal IP allocations and verify that no external interfaces can access the internal network pool directly, run:

```bash
docker network inspect srcs_inception_network

```

---

## 7.4. Runtime Observability & Log Auditing

When troubleshooting a `502 Bad Gateway` exception or tracking container cold launches, utilize the following log commands to extract active cluster diagnostics:

### 7.4.1 Whole-Stack Realtime Traffic Tracking

To aggregate all log outputs from Nginx, WordPress, MariaDB, and all active bonus daemons into a single, color-coded live terminal stream, run:

```bash
docker compose -f srcs/docker-compose.yml logs -f

```

### 7.4.2 Targeted Single-Service Diagnostics

If you suspect a single component (like the redis node) failed during its initialization phases, inspect its latest records directly:

```bash
docker compose -f srcs/docker-compose.yml logs --tail 50 redis

```

### 7.4.3 High-Precision Nanosecond Timestamp Auditing

To prove that your setup successfully resolved the concurrent cold launch **Race Condition** and established the Redis cache drop-in link, run:

```bash
docker compose -f srcs/docker-compose.yml logs -t wordpress

```

---

## 7.5. L7 Application Cache Auditing (Bonus Verification)

### Real-Time RESP Protocol Interception

To prove to the evaluator that the Redis engine is actively intercepting and accelerating application data transactions instead of remaining idle, run this command from the host terminal:

```bash
docker exec -it redis redis-cli monitor

```

* **Verification Procedure:** Execute the command, leave the terminal open, and refresh `https://weiyang.42.fr` in your browser. The terminal will instantly output a live transaction stream showing keys being retrieved via the memory cache pipeline:

```text
1465452118.102345 [0 172.25.0.4:54322] "PING"
1465452118.104122 [0 172.25.0.4:54322] "GET" "wp_:options:alloptions"
1465452118.108431 [0 172.25.0.4:54322] "GET" "wp_:posts:last_posts"

```

---

## 7.6. System Cleanup & Purge Commands

### Check Resource Footprints

To analyze physical disk space allocation across images, active container layer states, and local cache systems before executing an infrastructure reset:

```bash
docker system df

```

### Force Infrastructure Purge (Alternative to `make fclean`)

If an unexpected edge case blocks your standard `Makefile` recipes, you can use this native Compose command to force-evict all containers, networks, volumes, and images instantly:

```bash
# Danger: Unconditionally stops and wipes all containers, networks, volumes, and cached imagery
docker compose -f srcs/docker-compose.yml --profile bonus down --rmi all --volumes

```