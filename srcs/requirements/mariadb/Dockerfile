FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN printf "[mysqld]\nbind-address=0.0.0.0\nskip-networking=0\n" \
    > /etc/mysql/mariadb.conf.d/99-bind.cnf

RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
    chmod 777 /var/run/mysqld

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown mysql:mysql /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]