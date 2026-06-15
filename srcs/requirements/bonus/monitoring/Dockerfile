FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# 👑 1. 编译期服务自启拦截，全面拥抱轻量化 Debian 12 纯净依赖
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

# 安装 Node.js 与核心组件（Uptime Kuma 基于高性能 Node 运行时）
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

WORKDIR /app

# 👑 2. 刚性打捞官方指定代际源码，执行轻量化生产级依赖构建
RUN git clone https://github.com/louislam/uptime-kuma.git . && \
    npm run setup

EXPOSE 3001

# 👑 3. 终极常鸣通车原语：使用 exec 将 Node 进程无损提权至 PID 1 王座！
CMD ["sh", "-c", "export HOST=0.0.0.0 && export UPTIME_KUMA_HOST=0.0.0.0 && exec node server/server.js"]