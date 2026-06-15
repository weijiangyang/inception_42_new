FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install core components and security certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4-fpm \
    php7.4-mysqli \
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

# 2. Modify listen configuration to allow cross-container networking
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/g' /etc/php/7.4/fpm/pool.d/www.conf

# Download source files to a temporary staging area to prevent them from being overwritten by runtime volumes
RUN mkdir -p /tmp/adminer && \
    wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /tmp/adminer/index.php

WORKDIR /var/www/html

EXPOSE 9000

# Copy files from staging to the shared volume at startup, then launch PHP-FPM
CMD ["sh", "-c", "mkdir -p /var/www/html/adminer && cp -r /tmp/adminer/* /var/www/html/adminer/ && php-fpm7.4 -F"]