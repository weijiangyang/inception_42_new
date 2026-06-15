# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: root <root@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/07 18:13:35 by weiyang           #+#    #+#              #
#    Updated: 2026/06/15 05:17:39 by root             ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装核心组件并清理缓存（Debian 12 的 nginx 已经自带了完美的用户与组拓扑）
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

# 2. 👑 OpenSSL 3.0 加密硬化：强行提权至 RSA 4096 位高阶算法，断绝明文降级与弱密钥漏洞！
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=weiyang.42.fr"

# 3. 👑 彻底注销 Debian 默认站点的软链接，并将自定义主配置文件精准并网
RUN rm -f /etc/nginx/sites-enabled/default
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# 4. 👑 物理权限赋能：确保套接字、日志和进程 PID 路径对齐，允许 Nginx Master 优雅派生 Worker 子进程
RUN chown -R www-data:www-data /var/lib/nginx /var/log/nginx /etc/nginx/ssl

EXPOSE 443

# 5. 👑 终极前台常鸣指令（Master 进程以 root 起航绑定 443，子进程自动降权为 www-data 驻留内存）
CMD ["nginx", "-g", "daemon off;"]