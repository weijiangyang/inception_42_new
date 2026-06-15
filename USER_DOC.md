## 1. Services Provided by the Stack
The system splits all services into two categories: "Core Services" and "Bonus Services", working together inside the same secure internal network.

### Core Infrastructure
* **Nginx Gateway:** The main entry point and security guard. It handles all incoming traffic and makes sure everything is safely encrypted.

* **WordPress Engine:** The core website builder. It uses PHP to process and display all the main pages and content.

* **MariaDB Database:** The storage room. It holds all the website data and is completely hidden away from the outside world for safety.

### Bonus Infrastructure
* **Redis Cache:** A super-fast memory booster. It stores temporary website data so the database doesn't have to work so hard every time a page loads.

* **FTP Server (vsftpd):** A secure file uploader. It lets you upload files directly to the website while safely locking users into their own folders.

* **Adminer Panel:** A simple database manager. It gives you a clean web page to easily look at and manage your database tables without using the command line.

* **Static Page Host:** A lightweight resume page. It is served instantly by Nginx, meaning it opens fast without wasting any system power.

* **Uptime Kuma:** A live status monitor. It watches all your services around the clock and shows you a clean dashboard to prove everything is running perfectly.

---

## 2. Start and Stop the Project
The entire infrastructure lifecycle is converged inside a unified Makefile. Run these commands from the root directory of the project:

* **To Launch the Cluster:** Fully boots up all core and bonus containers, initializes storage volumes, and provisions internal networking in background mode.
    ```bash
    make       # Launches core services only
    make bonus # Launches all core and bonus services together
    ```

* **To Stop the Cluster:** Gracefully terminates all active runtime containers and unbinds virtual networking boundaries without wiping persistent data.
    ```bash
    make clean
    ```
* **To Force Full Purge & Rebuild:** Completely obliterates all containers, network layers, and physical host storage volumes, triggering a clean-slate zero-cache deployment.
    ```bash
    make fclean
    ```

---

## 3. Accessing the Website and Administration Panels
All web ingress points are routed securely. Before accessing, ensure `weiyang.42.fr` is mapped to your target host IP inside your local `/etc/hosts` file.
| Interface / Service | Access URL | Port / Protocol | log in |
| :--- | :--- | :--- | :--- |
| **Main WordPress Site** | `https://weiyang.42.fr` | Port 443 (HTTPS) | No login needed (Public website) |
| **WordPress Dashboard** | `https://weiyang.42.fr/wp-admin` | Port 443 (HTTPS) | Your WP Admin username & password |
| **Redis Cache Status** | Inside WP Dashboard $\rightarrow$ Settings $\rightarrow$ Redis | Internal Routing | Checked inside WordPress after logging in |
| **Static Resume Page** | `https://weiyang.42.fr/resume` | Port 443 (HTTPS) | No login needed (Your static CV) |
| **Adminer DB Control** | `https://weiyang.42.fr:adminer` | Port 9002 (HTTPS) | Your MariaDB Database user & password |
| **Uptime Kuma Monitor** | `http://weiyang.42.fr:3001` | Port 3001 (HTTP) | Create your own admin account on first visit |
| **FTP File Uploader** | `weiyang.42.fr` | Port 21 (FTP) | Your FTP username & password |
---

## 4. Credentials Management
Secrets are managed securely via Docker Secrets to prevent plain-text leaks in logs or code.

* **Storage Path:** `srcs/secrets/`
* **Runtime Extraction:** Loaded securely into memory (`/run/secrets/`) by `entrypoint.sh` during startup.
* **To Update Credentials:** Modify the files in `srcs/secrets/`, then restart the stack:
    ```bash
    make clean && make bonus
    ```

## 5. Verifying Service Health
You can check if everything is running correctly using either method:

### Option A: Web Dashboard (Easiest)
Open `http://weiyang.42.fr:3001` in your browser. Uptime Kuma will display a real-time status page showing a 100% green "UP" status for all services.

### Option B: Terminal Commands
Run these commands to verify the stack manually:

1. **Check Container Status:** Verify all services are listed as `Up`.
   ```bash
   docker ps

2. **Check Logs:** Inspect active logs for any errors.
```bash
docker logs nginx
docker logs wordpress
docker logs monitoring

```


3. **Check Network:** Ensure the isolated network layer exists.
```bash
docker network ls

```