FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN printf "[mysqld]\n\
bind-address            = 0.0.0.0\n\
skip-networking         = 0\n\
skip-name-resolve       = 1\n\
log_error               = stderr\n\
character-set-server    = utf8mb4\n\
collation-server        = utf8mb4_general_ci\n\n\
[client]\n\
port                    = 3306\n\
socket                  = /var/run/mysqld/mysqld.sock\n\n\
[mysql]\n\
default-character-set   = utf8mb4\n" \
> /etc/mysql/mariadb.conf.d/99-hardened.cnf

RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
    chmod 777 /var/run/mysqld

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown mysql:mysql /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]