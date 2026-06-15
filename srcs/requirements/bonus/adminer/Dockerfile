FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9002|g' /etc/php/8.2/fpm/pool.d/www.conf

# Download source files to a temporary staging area to prevent them from being overwritten by runtime volumes
RUN mkdir -p /tmp/adminer && \
    wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /tmp/adminer/index.php

WORKDIR /var/www/html

EXPOSE 9002

CMD ["sh", "-c", "mkdir -p /var/www/html/adminer && cp -r /tmp/adminer/* /var/www/html/adminer/ && exec php-fpm8.2 -F"]