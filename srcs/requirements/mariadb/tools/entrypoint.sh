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
mkdir -p /var/run/mysqld /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# =========================================================
# 2. INGEST CRYPTOGRAPHIC SECRETS & ENVIRONMENT VARIABLES
# =========================================================
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
MYSQL_PASSWORD="$(cat /run/secrets/db_password)"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"

# =========================================================
# 3. CONTEXTUAL COMPOSITE DUAL-TRACK INITIALIZATION
# =========================================================
if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

    echo "[MariaDB] First startup detected."
    echo "[MariaDB] Initializing base system schema tables..."

    mysql_install_db \
        --user=mysql \
        --datadir=/var/lib/mysql

    echo "[MariaDB] Launching isolated temporary server..."
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
    mariadb --socket=/var/run/mysqld/mysqld.sock <<SQL
DELETE FROM mysql.user WHERE User='';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

    echo "[MariaDB] Initiating graceful teardown of temporary bootstrap daemon..."

    mariadb-admin \
        --socket=/var/run/mysqld/mysqld.sock \
        -uroot \
        -p"${MYSQL_ROOT_PASSWORD}" \
        shutdown

    wait "$MYSQL_PID"

    echo "[MariaDB] Volume storage initialization sequence complete."
fi

# =========================================================
# 4. FINAL PRODUCTION RUNTIME CONTEXT OVERRIDE (PID 1)
# =========================================================
echo "[MariaDB] Transitioning process context to final production daemon..."

exec mysqld \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --socket=/var/run/mysqld/mysqld.sock