FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

WORKDIR /app

RUN git clone https://github.com/louislam/uptime-kuma.git . && \
    npm run setup

EXPOSE 3001

CMD ["sh", "-c", "export HOST=0.0.0.0 && export UPTIME_KUMA_HOST=0.0.0.0 && exec node server/server.js"]