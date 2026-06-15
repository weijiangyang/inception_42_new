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

#!/bin/sh
# 👑 刚性错误拦截，任何一环发生非预期断裂立刻熔断自愈
set -Eeuo pipefail

# 👑 物理特权修复：赶在引导流第一秒，强行将 PHP 运行时目录重新对齐，断绝属权真空
mkdir -p /run/php
chown -R www-data:www-data /run/php /var/www/html

cd /var/www/html

# =========================================================
# 1. Load Secrets Safely
# =========================================================
if [ -f /run/secrets/db_password ] && \
   [ -f /run/secrets/wp_admin_password ] && \
   [ -f /run/secrets/wp_user_password ]; then

    DB_PASS=$(cat /run/secrets/db_password)
    WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
    WP_USER_PASS=$(cat /run/secrets/wp_user_password)
else
    echo "[ERROR] Missing cryptographic operational secrets. Eviction triggered."
    exit 1
fi

# =========================================================
# 2. Wait for MariaDB Availability (Debian 12 Realignment)
# =========================================================
echo "[WordPress] Actively probing MariaDB cluster database..."

TIMEOUT=20
# 👑 绝杀修正：全面摒弃 mysqladmin，改用 Debian 12 官方原生的 mariadb-admin 特权原语
while ! mariadb-admin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASS}" --silent; do
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -le 0 ]; then
        echo "[ERROR] MariaDB cluster transport layer timeout. Bootstrap terminated."
        exit 1
    fi
    sleep 2
done

echo "[WordPress] MariaDB database back-end connection established."

# =========================================================
# 3. Download WordPress Core
# =========================================================
if [ ! -f wp-settings.php ]; then
    echo "[WordPress] Extracting clean vanilla source framework..."
    wp core download --allow-root
fi

# =========================================================
# 4. Generate wp-config.php
# =========================================================
if [ ! -f wp-config.php ]; then
    echo "[WordPress] Generating master config topology sheet..."
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
    echo "[WordPress] Running primary platform core provision sequence..."
    wp core install \
        --url="${WP_URL}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "[WordPress] Provisioning global non-privileged author account..."
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
        echo "[Redis] Microservice cluster node detected and handshake responsive."
    else
        echo "[Redis] Host resolve successful but four-layer socket unreachable."
    fi
else
    echo "[Redis] Optional object caching layer bypassed."
fi

# =========================================================
# 7. Safe Cache Reset (Prevents crashes when switching modes)
# =========================================================
# 👑 宿主机与容器双层联防：抹去前一周期残留的任何脏 Drop-in 描述符
rm -f wp-content/object-cache.php

# =========================================================
# 8. Configure Redis Object Cache
# =========================================================
if [ "$REDIS_OK" -eq 1 ]; then

    echo "[Redis] Injecting in-memory object cache acceleration matrix (Bonus Mode)"

    wp plugin install redis-cache --activate --allow-root || true

    wp config set WP_REDIS_HOST redis --allow-root || true
    wp config set WP_REDIS_PORT 6379 --raw --allow-root || true

    # Force rebuild the drop-in file to handle infrastructure updates
    wp redis enable --allow-root || true
    echo "[Redis] Dynamic caching optimization pipeline up and running."

else

    echo "[Redis] Invoking fail-safe fallback policy (Vanilla Mode)"
    wp config delete WP_REDIS_HOST --allow-root || true
    wp config delete WP_REDIS_PORT --allow-root || true

fi

# =========================================================
# 9. Flush Cache as a Final Safety Measure
# =========================================================
wp cache flush --allow-root || true

# =========================================================
# 10. Start PHP-FPM Daemon (Debian 12代际内核对齐)
# =========================================================
echo "[WordPress] Transitioning runtime process context to production interpreter..."

# 👑 终极绝杀修正：路径切换至 8.2，利用 exec 彻底将 php-fpm 托举至 PID 1 特权王座，长鸣通车！
exec /usr/sbin/php-fpm8.2 -F