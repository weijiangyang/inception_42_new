#!/bin/bash

set -Eeuo pipefail

echo "[FTP] Starting symmetrical storage entrypoint..."

# =========================================================
# 1. LOAD CRYPTOGRAPHIC SECRETS SECURELY
# =========================================================
if [ -f /run/secrets/ftp_password ]; then
    FTP_PASSWORD=$(cat /run/secrets/ftp_password)
else
    echo "[ERROR] Missing cryptographic operational secrets. Eviction triggered."
    exit 1
fi

FTP_USER="${FTP_USER:?FTP_USER env variable is missing}"
FTP_PASS="${FTP_PASSWORD}"

# =========================================================
# 2. IDEMPOTENT MULTI-TENANT USER PROVISIONING
# =========================================================
if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "[FTP] Core payload missing. Programmatically creating user: $FTP_USER..."
    
    useradd -m -d /var/www/html -s /bin/bash -G www-data "$FTP_USER"

    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    echo "[FTP] Re-aligning shared volume permissions safely..."
    chown -R www-data:www-data /var/www/html
    chmod -R 775 /var/www/html
else
    echo "[FTP] User $FTP_USER already exists in system context. Bypassing provisioning."
fi

# =========================================================
# 3. FINAL PRODUCTION RUNTIME CONTEXT OVERRIDE (PID 1)
# =========================================================
echo "[FTP] Symmetrical storage gateway initialized. Handing over to vsftpd daemon..."

exec /usr/sbin/vsftpd /etc/vsftpd.conf