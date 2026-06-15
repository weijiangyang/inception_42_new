FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# 1. 👑 核心依赖代际升级：注销 7.4，全面拥抱 Debian 12 原生 PHP 8.2 高性能栈
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建运行时临时套接字根节点
RUN mkdir -p /run/php

# 2. 👑 核心配置重写：精准修正 PHP 8.2 路径，并将网络天线强行咬合在自定义的 9002 端口！
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9002|g' /etc/php/8.2/fpm/pool.d/www.conf

# Download source files to a temporary staging area to prevent them from being overwritten by runtime volumes
RUN mkdir -p /tmp/adminer && \
    wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /tmp/adminer/index.php

WORKDIR /var/www/html

# 3. 声明式非标网络天线对齐
EXPOSE 9002

# 4. 👑 运行期状态机合龙：将末端的启动路径无缝平移至 php-fpm8.2 
CMD ["sh", "-c", "mkdir -p /var/www/html/adminer && cp -r /tmp/adminer/* /var/www/html/adminer/ && exec php-fpm8.2 -F"]