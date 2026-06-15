#!/bin/bash
set -e

# Fetch environment variables with fallback defaults
if [ -f /run/secrets/ftp_password ];then
    FTP_PASSWORD=$(cat /run/secrets/ftp_password)
else
    echo "[ERROR] Missing secrets"
    exit 1
fi
FTP_USER=${FTP_USER}
FTP_PASS=${FTP_PASSWORD}

# Check if the user exists using the exit status of the id command
if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "[FTP] Core payload missing. Programmatically creating user: $FTP_USER..."
    
    # 1. Create the system user with the specified home directory
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
    
    # 2. Set the user password
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    # 3. Grant ownership of the shared storage volume to the user
    chown -R "$FTP_USER:$FTP_USER" /var/www/html
else
    echo "[FTP] User $FTP_USER already exists in system context."
fi

echo "[FTP] Symmetrical storage gateway initialized. Handing over to vsftpd daemon..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf