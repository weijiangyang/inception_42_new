# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: root <root@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/07 18:13:35 by weiyang           #+#    #+#              #
#    Updated: 2026/06/15 11:53:58 by root             ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=weiyang.42.fr"

RUN rm -f /etc/nginx/sites-enabled/default
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R www-data:www-data /var/lib/nginx /var/log/nginx /etc/nginx/ssl

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]