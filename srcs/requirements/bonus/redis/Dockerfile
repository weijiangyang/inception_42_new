FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

RUN apt-get update && apt-get install -y --no-install-recommends \
    redis \
    redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

RUN mkdir -p /etc/redis && \
    printf "bind 0.0.0.0\nprotected-mode no\nport 6379\n" > /etc/redis/redis.conf

RUN mkdir -p /var/lib/redis && \
    chown -R redis:redis /etc/redis /var/lib/redis

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]