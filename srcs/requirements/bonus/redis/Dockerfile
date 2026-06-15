FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# 1. 👑 物理降维拦截：强行向系统注入禁用服务自启的规约，防止 apt 编译期因找不到 systemd 而静默夭折
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

# 2. 👑 依赖树刚性双证对齐：显式点名 redis 核心包与 redis-server 宿主包，荡平版本断层
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis \
    redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

# 3. 核心配置重写：强行扭转本地网络监听矩阵，同时关闭保护模式允许内部网格无密通信
RUN mkdir -p /etc/redis && \
    printf "bind 0.0.0.0\nprotected-mode no\nport 6379\n" > /etc/redis/redis.conf

# 4. 物理特权修复：确保 redis 系统用户对自身配置和运行时目录拥有绝对所有权，防止 Debian 12 权限熔断
RUN mkdir -p /var/lib/redis && \
    chown -R redis:redis /etc/redis /var/lib/redis

EXPOSE 6379

# 5. 终极常鸣通车原语：使用 exec 强制引渡绝对路径，并且必须显式挂载主配置文件！
CMD ["redis-server", "/etc/redis/redis.conf"]