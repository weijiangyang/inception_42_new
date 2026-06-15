# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: weiyang <weiyang@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/07 18:13:44 by weiyang           #+#    #+#              #
#    Updated: 2026/06/09 10:36:04 by weiyang           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# 1. 👑 核心依赖代际升级：全面注销 7.4，无缝引渡 Debian 12 原生 PHP 8.2 高性能网格
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    php-redis \
    mariadb-client \
    wget \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# 2. 静态离线源码开荒（保持无状态 staging 洁净度）
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    cp -rf wordpress/* . && \
    rm -rf wordpress latest.tar.gz

# 3. 👑 物理权限赋能：创建运行时临时套接字根节点，并将 VFS 属权彻底归还给 www-data 用户沙箱
RUN mkdir -p /run/php /var/www/html && \
    chown -R www-data:www-data /run/php /var/www/html

# 4. 引渡命令行控制面工具 WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 5. 👑 核心配置重写：精准修正 PHP 8.2 路径，并将监听天线强行咬合在自定义的 9001 端口！
RUN sed -i 's|^listen =.*|listen = 0.0.0.0:9001|' \
    /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 6. 声明式非标网络天线对齐
EXPOSE 9001

ENTRYPOINT ["/entrypoint.sh"]