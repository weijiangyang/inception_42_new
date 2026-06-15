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
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php-redis \
    mariadb-client \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    cp -rf wordpress/* . && \
    rm -rf wordpress latest.tar.gz

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's|^listen =.*|listen = 0.0.0.0:9000|' \
    /etc/php/7.4/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]