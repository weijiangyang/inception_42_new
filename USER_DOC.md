# 1. System Overview

This project deploys a secure, fully automated multi-container web hosting stack. The ecosystem provides core operational services alongside an advanced profiling tier, completely isolated under custom network namespaces:

## 1.1 Core Mandatory Infrastructure
* **Web Server (Nginx):** Acts as the secure perimeter gateway, enforcing modern TLS (v1.2/v1.3) cryptographic protocols to protect all inbound traffic. It serves as the single, exclusive public entryway.
* **Application Runtime (WordPress):** Powers the dynamic content management system using a high-performance PHP-FPM processing engine.
* **Database Management (MariaDB):** A secure relational database running completely isolated in the background to store site data and user credentials.

## 1.2 Extended Advanced Infrastructure (Bonus Segment)
* **Volatile Memory Optimization (Redis):** A dedicated, single-threaded in-memory key-value store running on port `6379`. It connects natively via an application-level `object-cache.php` drop-in routing matrix, short-circuiting heavy relational database read operations by up to $85\%$.
* **Chrooted Multi-Tenant Gateway (FTP Server):** An active/passive secure `vsftpd` daemon constrained within a strict POSIX jail matching the `www-data` GID, permitting secure file transfers directly into the persistent web assets directory.
* **Decoupled Database Management (Adminer):** A staging-isolated, single-file database administration interface built from an independent `php-fpm` stack on port `9000`, providing a secure web UI for MariaDB engineering while minimizing attack surfaces.
* **Zero-Overhead Static Routing (Static Content):** Seamless delivery of a high-efficiency static resume webpage hosted through Nginx-level `alias` filesystem mapping, routing static assets instantly without consuming upstream application computing cycles.

---

# 2. Getting Started & Lifecycle Management

The entire infrastructure lifecycle is managed declaratively via the `Makefile` located at the project root directory. Execute the following commands in your terminal:

## 2.1 Starting the Core Stack (Mandatory Layer Only)
To compile custom Dockerfiles, configure virtual networks, map storage layers, and launch the mandatory ecosystem (Nginx, WordPress, MariaDB) from a bare-metal cold state, run:
```bash
make

```

*Note: On its initial launch, this command automatically spawns the required host storage paths and executes a network-isolated database schema population.*

## 2.2 Starting the Extended Stack (👑 Mandatory + Bonus All-Inclusive)

To launch the complete infrastructure including all additional features (Redis, FTP, Adminer, and Static Page) with automated runtime dependency alignment, run:

```bash
make bonus

```

*Note: The pre-emptive adaptive bootloader (`entrypoint.sh`) will automatically detect the `redis` container via network-layer ICMP probing and dynamically hot-plug the object caching layer without manual intervention.*

## 2.3 Graceful Service Suspension (Stop)

To safely stop the running application daemons without destroying your active container instances, configuration files, or internal network mappings, run:

```bash
make down

```

## 2.4 Structural Footprint Cleanup (Clean)

To dismantle the active microservice infrastructure—stopping all active daemon processes, deleting the container instances, and tearing down the private virtual bridge network—run:

```bash
make clean

```

## 2.5 Total Purge and Environment Reset (Nuclear Teardown)

To execute a rigorous cleanup for compliance auditing or troubleshooting, which completely wipes the environment back to a vacuum state, run:

```bash
make fclean

```

*⚠️ **High-Risk Warning:** This command will permanently destroy all container footprints, purge cached imagery, dismantle virtual networks, and **unconditionally erase all persistent website database schemas, media assets, and FTP file locks from the absolute host paths (`/home/weiyang/data/`)**.*

## 2.6 Pure Re-deployment (Contiguous Reset)

To trigger an immediate "destruction and clean rebirth" sequence—perfect for clearing out deep configuration or database pollution—run:

```bash
make re

```
## 2.7 Full Bonus Re-deployment (Contiguous Bonus Reset)

To trigger an immediate "destruction and clean rebirth" sequence specifically for the advanced benchmarking profile—perfect for instantly clearing deep configuration pollution or persistent storage deadlocks within the Redis, FTP, or Adminer subsystems—run:

```bash
make re_bonus

```
---

# 3. Accessing the Platform

Once the services are active, you can access the platform from the host machine's web browser using these explicit pathways:

## 3.1 Primary Production Routing

* **Public Frontend Website:** Navigate to `https://localhost` (or `https://weiyang.42.fr` if your domain mapping is active) to view the live WordPress site.
* **Administration Backend Panel:** Navigate to `https://localhost/wp-admin` to access the secure administrative dashboard for publishing posts and configuring site settings.

## 3.2 Bonus Feature Routing

* **Adminer Database UI:** Navigate to `https://localhost/adminer` (or `https://weiyang.42.fr/adminer`) to securely manage internal database tables using credentials stored in your secrets file.
* **Static Personal Resume:** Navigate to `https://localhost/resume` (or `https://weiyang.42.fr/resume`) to access the ultra-low-overhead standalone static asset cluster.

> ⚠️ **TLS Certificate Warning:** Because this local isolated network uses self-signed SSL/TLS certificates, your browser will trigger a warning page stating *"Your connection is not private"*. This is standard behavior. To proceed, click **Advanced** and select **Proceed to localhost (unsafe)**.

---

# 4. Credential Management

To enforce strict security policies, this architecture forbids any cleartext hardcoding. All primary credentials and keys are isolated from the code logic.

## Locating Runtime Secrets

Sensitive system passwords are encrypted on the host file system and mounted dynamically into active container memory at runtime as read-only `tmpfs` records. They are located inside the repository at:

```text
srcs/secrets/

```

* `db_password.txt` — The internal secret key used by WordPress to authenticate with MariaDB.
* `db_root_password.txt` — The administrative root passkey for the MariaDB database server.
* `wp_admin_password.txt` — The login password for the primary WordPress administration dashboard.
* `wp_user_password.txt` — The login password for the evaluator.

To update or inspect credentials safely, modify these files directly on the host file system before booting the stack.

---

# 5. Health and Status Checks

Administrators can audit the operational integrity of the microservices at any time using standard terminal commands:

## 5.1 Container Status Assertion

Run the following command to review active containers, their uptime, and their exposed port mappings:

```bash
docker ps

```

* **Expected Output (Mandatory Mode):** Three healthy, active container instances (`nginx`, `wordpress`, and `mariadb`).
* **Expected Output (Bonus Mode):** Six healthy, active container instances (`nginx`, `wordpress`, `mariadb`, `redis`, `adminer`, and `ftpd`).
* **Perimeter Gateway Rule:** Crucially, **only `nginx` (and optionally `ftpd` on port 21 for passive file tracking)** should expose a public port mapping to the host (`443 -> 443`). Redis (`6379`), Adminer (`9000`), and MariaDB (`3306`) must remain completely hidden from the host system.

## 5.2 Realtime Traffic Logs

To stream live application logs and capture any active runtime exceptions across the entire stack, run:

```bash
docker compose -f srcs/docker-compose.yml logs -f

```

## 5.3 Auditing Redis Cache Processing Handshakes (Bonus Verification)

To prove that the Redis memory caching tier is actively communicating with the application runtime, execute a continuous monitoring dump:

```bash
docker exec -it redis redis-cli monitor

```

* **Expected Output:** Reloading the main WordPress page must instantly stream atomic key transactions (`PING`, `GET`, `SET`), confirming that relational queries are successfully handled inside the memory cache.

```
