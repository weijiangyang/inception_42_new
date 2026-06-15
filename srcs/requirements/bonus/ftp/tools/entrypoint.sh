#!/bin/bash
# 👑 刚性错误拦截机制，确保任何管道断裂或命令异常瞬间熔断自愈
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
    
    # 👑 联合并网绝杀 1：创建用户时，强行将其加入到 www-data 附加组 (-G)！
    # 同时将家目录 (-d) 锚定在共享有状态卷上，允许其合法跨域访问
    useradd -m -d /var/www/html -s /bin/bash -G www-data "$FTP_USER"
    
    # 向系统特权树安全下发加密凭证
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    echo "[FTP] Re-aligning shared volume permissions safely..."
    # 👑 联合并网绝杀 2：绝对不能把所有者改成 FTP_USER！
    # 保持所有者依然属于 www-data:www-data，但下发 G+w（组内可写）以及 775 刚性安全格栅！
    # 这允许你的 FTP 用户（因为加入了 www-data 组）能够自由上传下载，且 WordPress 绝不崩溃！
    chown -R www-data:www-data /var/www/html
    chmod -R 775 /var/www/html
else
    echo "[FTP] User $FTP_USER already exists in system context. Bypassing provisioning."
fi

# =========================================================
# 3. FINAL PRODUCTION RUNTIME CONTEXT OVERRIDE (PID 1)
# =========================================================
echo "[FTP] Symmetrical storage gateway initialized. Handing over to vsftpd daemon..."

# 👑 核心合龙：使用 exec 注入使 vsftpd 顶替当前的 Shell 进程成为 PID 1，以便优雅传递系统信号
exec /usr/sbin/vsftpd /etc/vsftpd.conf