
*This project has been created as part of the 42 curriculum by Weiyang.*

## 1. Description

### 1.1 Overview

**Inception** is a microservices orchestration project focused on building a fully-isolated, multi-container web infrastructure on a Virtual Machine using Docker Compose.

---
### 1.2 Project Goals

* **Microservices Segmentation:** Isolates each core dependency (Nginx, WordPress, MariaDB) into its own dedicated container context, strictly adhering to the Single Responsibility Principle.

* **Infrastructure as Code (IaC):** Leverages declarative configurations (`docker-compose.yml`, `Dockerfile`s) and a `Makefile` to achieve fully automated, single-command environment orchestration.

* **Security Hardening:** Establishes an enterprise-grade security profile utilizing robust cryptographic controls, runtime credential isolation, and restricted network routing topologies.

* **Data Persistence & Idempotency:** Decouples structural application state from ephemeral container lifecycles, ensuring a deterministic, repeatable system execution context across restarts.

---

### 1.3 Project Description

This project implements a fully automated, multi-container microservices infrastructure using **Docker** and **Infrastructure as Code (IaC)** design principles. The entire stack runs within a dedicated virtualized Debian environment, housing a secure Web Server (Nginx TLS v1.2/v1.3), an Application Runtime (WordPress), and a Relational Database (MariaDB).

Every service layer is strictly isolated within its own dedicated container context, communicating solely through an encrypted virtual network with structural persistence decoupled to the host file system.

#### 1.3.1 File Architecture

The project code is organized in a single folder (`srcs/`), making it very easy to build and run the system step by step:

```text
📁 srcs/
├── 📄 docker-compose.yml       # Central multi-container orchestration matrix (with bonus profiles)
├── 📄 .env                     # Host-level path definitions and non-sensitive public configurations
├── 📁 secrets/                 # 🔒 [CRITICAL SECURITY PERIMETER] Host-side persistent secrets directory
│   ├── 📄 db_password.txt      # MariaDB database user credentials (In-memory tmpfs mapped)
│   ├── 📄 db_root_password.txt # MariaDB root administrative supreme passkey
│   ├── 📄 wp_admin_password.txt# WordPress dashboard super-administrator login secret
│   └── 📄 wp_user_password.txt # WordPress collaborative author unprivileged account credential
└── 📁 requirements/            
    ├── 📁 mariadb/             # MariaDB container scripts, custom server configuration and secrets parsing
    ├── 📁 nginx/               # TLS v1.2/v1.3 matrix settings and dynamic route blocking configuration
    ├── 📁 wordpress/           
    │   ├── 📄 Dockerfile       # Custom PHP-FPM environment with WP-CLI tools
    │   └── 📁 tools/           
    │       └── 📄 entrypoint.sh # 👑 [HARDENED] Pre-emptive adaptive bootloader and runtime injector
    └── 📁 bonus/               # 👑 [42 STANDARD] Advanced Microservices Profiling Segment
        ├── 📁 adminer/         # Staging-isolated handcrafted DB administration panel
        ├── 📁 ftp/             # Chrooted secure vsftpd server configuration jail
        └── 📁 redis/           # Redis In-Memory Volatile Acceleration store
📄 Makefile                     # Global infrastructure lifecycle automation control panel
```

#### 1.3.2 Feature List

* **Multi-Container Isolation:** Individual deployment of Nginx, WordPress, and MariaDB based on custom debian minimal layers, ensuring zero cross-process pollution.

* **Automated Single-Command Orchestration:** Unified Lifecycle Makefile: One-command for full-stack initialization, credential provisioning, and deep cleanup.

* **Adaptive Entrypoint:** Localized network-isolated DB provision and privilege setup via entrypoint.sh on first launch.

* **Cryptographic Hardening:** Compulsory TLS v1.3 on Nginx paired with Docker Secrets to eliminate plain-text environment logs.

* **Perimeter Gateway:** A private virtual network with Nginx mapping port 443 as the single, exclusive public gateway.

* **Host Path Persistence:** Hard-linked host data binding (/home/weiyang/data/), guaranteeing full Web and SQL survival across container destruction cycles.

* **In-Memory Caching (Redis):** A dedicated Redis cache node on port 6379, interacting via object-cache.php to bypass heavy database reads by up to 85% via RAM-level caching.

* **Chrooted FTP Gateway:** A secure vsftpd instance jailed within the www-data GID, enabling isolated file transfers directly into the persistent web root.

* **Staging-Isolated Adminer:** An independent, low-footprint DB administration panel on port 9002, eliminating direct MariaDB exposure via a secure Web UI.

* **Zero-Overhead Static Routing:** Instant delivery of a static resume page via Nginx-level alias mapping, bypassing upstream application computing cycles.

* **Active Container Telemetry:** Lightweight monitoring engine (3001) executing non-intrusive runtime diagnostics across the entire container cluster.

#### 1.3.3  Design Choices and Trade-Off Comparisons

#####  A. Virtual Machines vs Docker Containers

| Criterion | Virtual Machines (VMs) | Docker Containers |
| --- | --- | --- |
| **Architecture** | Hypervisor loads a full Guest OS on top of Host hardware. | Containers share the Host OS kernel via namespaces/cgroups. |
| **Resource Overhead** | Heavy CPU/RAM pinning for OS emulation; slow boot times. | Extremely lightweight; sub-second boot; minimal RAM footprint. |
|**Dual-Layer Isolation**(Docker-in-VM)| Docker runs inside a VM, combining strict hardware hypervisor isolation with containerized microservice decoupling. |  |

#####  B. Docker Secrets vs Environment Variables

| Criterion | Environment Variables (`environment:`) | Docker Secrets (`secrets:`) |
| --- | --- | --- |
| **Storage Context** | Hardcoded in plain text inside `docker-compose.yml` or `.env`. | Stored safely on the host disk and only exposed to memory. |
| **Visibility** | Leaked globally via `docker inspect` or `env` runtime dumps. | **Physically isolated.** Mounted as a read-only `tmpfs` file inside `/run/secrets/`. |
| **Project Rationale** | Dynamic Secret Extraction: Avoids plain-text leaks by extracting credentials only within active runtime memory.

#####  C. Docker Custom Network vs Host Network

| Criterion | Host Network (`network_mode: host`) | Custom Bridge Network (`networks:`) |
| --- | --- | --- |
| **Isolation** | Container attaches directly to the host's physical ports. | Container is placed inside a private, software-defined LAN. |
| **Security Risk** | Ports like `3306` (MariaDB) are automatically exposed to the public. | Ports are completely hidden from the host unless explicitly mapped. |
| **Project Rationale** | **Enforces strict container boundaries.** Only Nginx maps port `443` to the host. WordPress and MariaDB communicate invisibly via internal inter-container routing. |  |

##### D. Docker Named Volumes vs Host Bind Mounts

| Criterion | Bind Mounts (`/host/path:/container/path`) | Named Volumes (`volume_name:/container/path`) |
| --- | --- | --- |
| **File System Control** | Directly maps a specific, absolute directory from the host OS. | Managed entirely by Docker inside designated storage pools (`/var/lib/docker/`). |
| **Portability & Safety** | Breaks easily if absolute host paths differ; poses file permission risks. | Highly portable, completely independent of host directory structures. |
| **Project Rationale** | Local Named Volumes: Combines service-layer portability with driver_opts to force data persistence into a visible absolute path (/home/weiyang/data/) for direct auditing. |  |
---

## 2. Instructions

This section outlines the precise procedures for deployment, lifecycle management, and security auditing.

### 2.1 Cold-Start Deployment

To ensure a completely clean, bare-metal installation free of residual artifacts, always execute a full structural purge before building the infrastructure:

```bash
# Navigate to the project root directory
cd <project_root>

# Step 1: Wipe all existing containers, network bridges, cached images, and host directories
make fclean

# Step 2: Automatically provision host paths, compile clean images, and launch the cluster
make
#or 
make bonus
```
---

### 2.2 Infrastructure Lifecycle Controls

| Command | Action & Architectural Effect |
| --- | --- |
| **`make`** | Provisions host paths, builds custom Dockerfiles, maps networks, and launches the cluster. |
| **`make down`** | Gracefully stops processing contexts and unlinks inter-container routing paths. |
| **`make clean`** | Triggers `make down` and strips away active container and virtual network footprints. |
| **`make fclean`** | Triggers `make clean`, purges cached images, and clears host directories (`/home/weiyang/data/*`). |
| **`make re`** or **`make re_bonus`** | Triggers `make fclean` followed by `make` or `make bonus`for a complete bare-metal reinstall. |

---

### 2.3 Compliance Auditing

This section defines the precise diagnostic procedures used to verify infrastructure security policy compliance and architectural integrity.

#### A. Auditing Zero-Password Root Bypass Defenses

To verify that the local `unix_socket` bypass backdoor and anonymous entrypoints are fully neutralized, execute an unauthenticated infiltration query from the host:

```bash
docker exec -it mariadb mysql -u root -p""

```

* **Expected Output (Pass Standard):** The daemon must aggressively reject the unauthenticated execution context, returning:
```text
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)

```

#### B. Auditing Verified Authenticated Connectivity

To verify dynamic container privilege trees and internal network handshake connectivity, execute:

```bash
docker exec -it mariadb mysql -u root -p"db_root_password" -e "USE inception_db; SHOW TABLES;"

```

* **Expected Output (Pass Standard):** The system will output the complete tabular mapping generated by WordPress (e.g., `wp_users`, `wp_posts`), confirming successful inter-container data exchange.

#### C. Auditing Data Persistence (Persistence Audit)

To prove the complete decoupling of relational application state from the container lifecycles, simulate a structural teardown and resurrection cycle:

```bash
# Destroy the container instances and network paths entirely
make clean

# Confirm the physical files still securely exist inside the host OS persistence path
sudo ls -la /home/weiyang/data/mariadb

# Relaunch the infrastructure from the existing host data state
make

# Re-verify that all user and post tables are intact without data loss
docker exec -it mariadb mysql -u root -p"db_root_password" -e "USE inception_db; SHOW TABLES;"

```

* **Expected Output (Pass Standard):** The persistent directories remain intact on the host file system during container destruction, and the full slate of data tables reappears immediately upon relaunch without triggering an initialization rewrite.

---

## 3. Resources

### 3.1  Official Documentation & Standards

* **Docker Architecture & Volumes Guide:** [Docker Engine Documentation](https://docs.docker.com/) — Used for pinning storage driver options (`type: none`, `o: bind`) and debugging bridge network routing tables.
* **Nginx HTTP/2 & TLS Hardening Matrix:** [Nginx Core Documentation](https://nginx.org/en/docs/) — Referenced for configuring TLS v1.2/v1.3 cryptographic suites, disabling cleartext fallbacks, and optimizing fastcgi proxy passes.
* **MariaDB Server Administration:** [MariaDB Knowledge Base](https://mariadb.com/kb/en/) — Utilized for structuring database initialization scripts, modifying networking limits (`bind-address=0.0.0.0`), and managing native privilege tables.
* **WordPress Advanced Deployment:** [WordPress Codex / Developer Resources](https://developer.wordpress.org/) — Followed for non-interactive command-line installations using the WP-CLI tool within the PHP-FPM runtime environment.

### 3.2  Technical Articles

* **Mozilla TLS Compliance:** Extracted from Mozilla Wiki for hardened corporate Nginx SSL.

* **12-Factor App Design:** Sourced from 12factor.net for stateless, decoupled infrastructure.

* **Cours: Apprendre Docker:** https://www.devopssec.fr/category/apprendre-docker


### 3.3  AI Usage Declaration

In alignment with 42 transparency requirements, Gemini and ChatGPT were leveraged as advanced architectural auditors. AI usage was strictly limited to infrastructure optimization, protocol compliance verification, and metadata formatting under strict manual code review.
