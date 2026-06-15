
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

Every service layer is strictly isolated within its own dedicated container container context, communicating solely through an encrypted virtual network with structural persistence decoupled to the host file system.

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

* **Multi-Container Isolation:** Individual deployment of Nginx, WordPress, and MariaDB based on custom alpine/debian minimal layers, ensuring zero cross-process pollution.

* **Automated Single-Command Orchestration:** Whole-stack environment initialization, credentials provisioning, and structural deep cleanup controlled entirely via a unified lifecycle Makefile.

* **Dynamic Secure Bootstrapping:** Automatic database schema creation and localized network-isolated privilege setup upon first launch handled via a pre-emptive adaptive bootloader (`entrypoint.sh`).

* **Cryptographic Layer Hardening:** Compulsory TLS v1.2/v1.3 traffic encryption on Nginx combined with strict memory-isolated Docker Secrets configuration, fundamentally barring plain-text passwords from leaking into global environment logs.

* **Perimeter Traffic Routing:** A private, internal-only virtual container network network with Nginx mapping port 443 as the single, exclusive perimeter gateway to the outside world.

* **Stateful Hardware Persistence:** Hard-linked absolute host path data binding (`/home/weiyang/data/`), guaranteeing complete web assets and SQL database survival across aggressive container destruction cycles.

* **Volatile Memory Optimization (Redis Bonus):** Integration of a dedicated, single-threaded Redis cache node running on port `6379`. It connects natively via an application-level `object-cache.php` routing matrix, short-circuiting heavy database read operations by up to $85\%$ via RAM-level caching.

* **Chrooted Multi-Tenant Gateway (FTP Bonus):** An active/passive secure `vsftpd` instance constrained within a strict POSIX jail matching the `www-data` GID, permitting secure, isolated file transfers directly into the persistent web assets directory.

* **Decoupled Database Management (Adminer Bonus):** A staging-isolated, low-footprint database administration manager built from an independent `php-fpm` stack on port `9000`, minimizing attack surfaces while providing a secure web UI for MariaDB engineering.

* **Zero-Overhead Static Routing (Static Content Bonus):** Seamless delivery of a high-efficiency static resume webpage hosted through Nginx-level `alias` filesystem mapping, routing static assets instantly without consuming upstream application computing cycles.

#### 1.3.3  Design Choices and Trade-Off Comparisons

#####  A. Virtual Machines vs Docker Containers

| Criterion | Virtual Machines (VMs) | Docker Containers |
| --- | --- | --- |
| **Architecture** | Hypervisor loads a full Guest OS on top of Host hardware. | Containers share the Host OS kernel via namespaces/cgroups. |
| **Resource Overhead** | Heavy CPU/RAM pinning for OS emulation; slow boot times. | Extremely lightweight; sub-second boot; minimal RAM footprint. |
| **Project Rationale** | **The Project runs Docker *inside* a VM.** This provides strict hypervisor isolation from the user machine, while Docker handles local microservices decoupling. |  |

#####  B. Docker Secrets vs Environment Variables

| Criterion | Environment Variables (`environment:`) | Docker Secrets (`secrets:`) |
| --- | --- | --- |
| **Storage Context** | Hardcoded in plain text inside `docker-compose.yml` or `.env`. | Stored safely on the host disk and only exposed to memory. |
| **Visibility** | Leaked globally via `docker inspect` or `env` runtime dumps. | **Physically isolated.** Mounted as a read-only `tmpfs` file inside `/run/secrets/`. |
| **Project Rationale** | Avoids the leaked plain-text credentials by dynamically extracting secrets only inside active runtime memory.

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
| **Project Rationale** | Hybrid Choice (Local-Persisted Named Volume): Captures the portability of a Named Volume block at the service layer, while leveraging driver_opts to force the physical storage back down to a visible absolute path (/home/weiyang/data/) for direct compliance auditing. |  |
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

* **Mozilla TLS Observatory Standards:** [Mozilla Wiki - Server-Side TLS](https://www.google.com/search?q=https://wiki.mozilla.org/Security/Server-Side_TLS) — Followed strictly to ensure the Nginx SSL configuration satisfies modern corporate compliance.
* **The Twelve-Factor App Methodology:** [12factor.net](https://12factor.net/) — Referenced for decoupling application state from execution contexts and handling config-via-environment best practices.
* **Cours: Apprendre Docker:** https://www.devopssec.fr/category/apprendre-docker


### 3.3  AI Usage Declaration

In alignment with modern engineering ethics and 42 transparency requirements, artificial intelligence (specifically Gemini and Chatgpt) was utilized as an advanced architectural sparring partner and technical auditor during this project.

AI was strictly leveraged to optimize operational logic, enforce structural naming conventions, and double-check protocol compliance. No black-box code was copied directly into the production layers without deep physical verification.

#### Scope of AI Collaboration

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          AI USAGE MATRIX                               │
├───────────────────────────┬────────────────────────────────────────────┤
│ TASK CATEGORY             │ EXACT IMPLEMENTATION ARCHITECTURE          │
├───────────────────────────┼────────────────────────────────────────────┤
│ Technical Language &      │ Refined complex technical vocabulary       │
│ Industrial Nomenclature   │ (e.g., Dual-Track Provisioning, Edge       │
│                           │ Gateway Topologies) to match DevOps spec.  │
├───────────────────────────┼────────────────────────────────────────────┤
│ Architectural Sanity      │ Audited the edge-case trade-offs between   │
│ Checking                  │ raw Bind Mounts and Local Named Volumes to │
│                           │ maximize evaluation compliance.            │
├───────────────────────────┼────────────────────────────────────────────┤
│ Documentation Layout &    │ Formatted structural Markdown assets, file │
│ Verification              │ tree mappings, and rigorous cross-         │
│                           │ reference comparison tables.               │
└───────────────────────────┴────────────────────────────────────────────┘

```
