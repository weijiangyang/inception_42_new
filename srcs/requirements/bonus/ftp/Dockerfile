FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装核心组件并全量清洗包管理器缓存（极致精简图层）
RUN apt-get update && apt-get install -y --no-install-recommends \
    vsftpd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. 👑 核心加固：写入基础配置（注意：我们将 pasv_address 移除，改由 entrypoint.sh 在运行时动态注入或让其绑定网卡，防止物理锁死 127.0.0.1！）
RUN echo "listen=YES\n\
local_enable=YES\n\
write_enable=YES\n\
local_umask=022\n\
chroot_local_user=YES\n\
allow_writeable_chroot=YES\n\
secure_chroot_dir=/var/run/vsftpd/empty\n\
pasv_enable=YES\n\
pasv_min_port=40000\n\
pasv_max_port=40005" > /etc/vsftpd.conf

# 创建运行时安全沙箱沙盒路径
RUN mkdir -p /var/run/vsftpd/empty

# 3. 👑 引渡控制面自举脚本，强制写死绝对路径并下发执行特权
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 声明式网络天线对齐（死死锁在安全合规的 21 端口与被动随机通道上！）
EXPOSE 21 40000-40005

# 4. 👑 终极绝对路径修复：打碎 $PATH 路由真空死锁，保驾护航
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]