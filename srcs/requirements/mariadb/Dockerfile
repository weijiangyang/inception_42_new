# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: root <root@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/07 18:27:57 by weiyang           #+#    #+#              #
#    Updated: 2026/06/12 09:59:40 by root             ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:bullseye

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*
    
# Force the daemon to listen on all network interfaces (Critical Compliance Layer)
RUN printf "[mysqld]\nbind-address=0.0.0.0\nskip-networking=0\n" \
> /etc/mysql/mariadb.conf.d/99-bind.cnf

# Provision and assign proper ownership to the runtime directory
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]