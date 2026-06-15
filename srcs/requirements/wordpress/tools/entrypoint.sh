#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    entrypoint.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: weiyang <weiyang@student.42.fr>                 +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/09 10:40:37 by weiyang             #+#    #+#              #
#    Updated: 2026/06/09 10:40:55 by weiyang            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

set -e

mkdir -p /run/php
cd /var/www/html

# =========================================================
# 1. Load Secrets
# =========================================================
if [ -f /run/secrets/db_password ] && \
   [ -f /run/secrets/wp_admin_password ] && \
   [ -f /run/secrets/wp_user_password ]; then

    DB_PASS=$(cat /run/secrets/db_password)
    WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
    WP_USER_PASS=$(cat /run/secrets/wp_user_password)
else
    echo "[ERROR] Missing secrets"
    exit 1
fi

# =========================================================
# 2. Wait for MariaDB Availability
# =========================================================
echo "[WordPress] Waiting MariaDB..."

TIMEOUT=20
while ! mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASS}" --silent; do
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -le 0 ]; then
        echo "[ERROR] MariaDB timeout"
        exit 1
    fi
    sleep 2
done

echo "[WordPress] MariaDB ready"

# =========================================================
# 3. Download WordPress Core
# =========================================================
if [ ! -f wp-settings.php ]; then
    wp core download --allow-root
fi

# =========================================================
# 4. Generate wp-config.php
# =========================================================
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="mariadb" \
        --allow-root
fi

# =========================================================
# 5. Execute WordPress Installation & Create Users
# =========================================================
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="${WP_URL}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASS" \
        --allow-root
fi

# =========================================================
# 6. Non-Fatal Redis Container Detection
# =========================================================
REDIS_OK=0

if getent hosts redis >/dev/null 2>&1; then
    if php -r "
        \$fp=@fsockopen('redis',6379,\$e,\$s,1);
        if(\$fp){ fclose(\$fp); exit(0); }
        exit(1);
    " 2>/dev/null; then
        REDIS_OK=1
        echo "[Redis] available"
    else
        echo "[Redis] host exists but not reachable"
    fi
else
    echo "[Redis] not found (optional)"
fi

# =========================================================
# 7. Safe Cache Reset (Prevents crashes when switching modes)
# =========================================================
rm -f wp-content/object-cache.php

# =========================================================
# 8. Configure Redis Object Cache
# =========================================================
if [ "$REDIS_OK" -eq 1 ]; then

    echo "[Redis] enabling cache layer (bonus mode)"

    wp plugin install redis-cache --activate --allow-root || true

    wp config set WP_REDIS_HOST redis --allow-root || true
    wp config set WP_REDIS_PORT 6379 --raw --allow-root || true

    # Force rebuild the drop-in file to handle infrastructure updates
    wp redis enable --allow-root || true

    echo "[Redis] enabled"

else

    echo "[Redis] disabled (safe mode)"

    wp config delete WP_REDIS_HOST --allow-root || true
    wp config delete WP_REDIS_PORT --allow-root || true

fi

# =========================================================
# 9. Flush Cache as a Final Safety Measure
# =========================================================
wp cache flush --allow-root || true

# =========================================================
# 10. Start PHP-FPM Daemon
# =========================================================
echo "[WordPress] Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F