#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    entrypoint.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: weiyang <weiyang@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/08 04:44:54 by weiyang             #+#    #+#              #
#    Updated: 2026/06/08 04:44:59 by weiyang            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

set -Eeuo pipefail

echo "[MariaDB] Starting entrypoint..."

# =========================================================
# 1. DIRECTORY CREATION & PERMISSION REPAIR
# =========================================================
# Ensure the runtime socket directory exists
mkdir -p /var/run/mysqld

# Grant ownership of storage and socket paths to the mysql user
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld

# =========================================================
# 2. INGEST CRYPTOGRAPHIC SECRETS & ENVIRONMENT VARIABLES
# =========================================================
# Read operational passwords securely from Docker Secrets mount paths
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
MYSQL_PASSWORD="$(cat /run/secrets/db_password)"

# Enforce strict validation on critical infrastructure environment variables
: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"

# =========================================================
# 3. CONTEXTUAL COMPOSITE DUAL-TRACK INITIALIZATION
# =========================================================
# Execute first-time database builds only if system catalog OR project database is missing
if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

    echo "[MariaDB] First startup detected."
    echo "[MariaDB] Initializing base system schema tables..."

    # Provision clean, vanilla system dictionary structures on raw volume space
    mysql_install_db \
        --user=mysql \
        --datadir=/var/lib/mysql

    echo "[MariaDB] Launching isolated temporary server..."

    # Run background instance isolated from network interface to prevent WordPress race conditions
    mysqld \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --skip-networking \
        --socket=/var/run/mysqld/mysqld.sock &

    MYSQL_PID=$!

    echo "[MariaDB] Waiting for temporary daemon socket file..."

    TIMEOUT=20
    while ! mariadb-admin --socket=/var/run/mysqld/mysqld.sock ping --silent; do
        TIMEOUT=$((TIMEOUT - 1))
        if [ "$TIMEOUT" -le 0 ]; then
            echo "[ERROR] Temporary MariaDB daemon failed to provide local socket. Anti-deadlock eviction triggered."
            kill "$MYSQL_PID"
            exit 1
        fi
        sleep 1
    done

    echo "[MariaDB] Hardening security and applying privilege trees..."

    # Inject core project specifications directly via secure pipeline connection
    mariadb \
        --socket=/var/run/mysqld/mysqld.sock <<SQL

-- Purge anonymous vulnerabilities to prevent blank-user bypass exploits
DELETE FROM mysql.user WHERE User='';

-- Force secure password string onto local root instance
ALTER USER 'root'@'localhost'
IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Provision project relational data storage schema with explicit UTF8 configurations
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Enforce standard application credentials onto global network entrypoint mapping
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
IDENTIFIED BY '${MYSQL_PASSWORD}';

ALTER USER '${MYSQL_USER}'@'%'
IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Map exclusive administrative privileges of project database onto app user context
GRANT ALL PRIVILEGES
ON \`${MYSQL_DATABASE}\`.*
TO '${MYSQL_USER}'@'%';

-- Flush in-memory cache to force privilege tree modifications out to disk tables
FLUSH PRIVILEGES;

SQL

    echo "[MariaDB] Initiating graceful teardown of temporary bootstrap daemon..."

    # Command background server to close execution context cleanly
    mariadb-admin \
        --socket=/var/run/mysqld/mysqld.sock \
        shutdown

    # Wait for the background PID to exit completely to prevent open descriptor leaks
    wait "$MYSQL_PID"

    echo "[MariaDB] Volume storage initialization sequence complete."
fi

# =========================================================
# 4. FINAL PRODUCTION RUNTIME CONTEXT OVERRIDE (PID 1)
# =========================================================
echo "[MariaDB] Transitioning process context to final production daemon..."

# Launch official production daemon binding interface to cross-container networks
exec mysqld \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --socket=/var/run/mysqld/mysqld.sock \
    --bind-address=0.0.0.0