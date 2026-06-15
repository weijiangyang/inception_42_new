FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装核心组件并全量清洗包管理器缓存（极致精简图层）
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
# 2. 强制扭转本地网络监听矩阵，允许跨容器 SDN 虚拟网格握手
RUN printf "[mysqld]\nbind-address=0.0.0.0\nskip-networking=0\n" \
    > /etc/mysql/mariadb.conf.d/99-bind.cnf

# 3. 👑 核心加固：同步创建并强行归还“运行期套接字”与“物理存储期有状态卷”的绝对所有权！
RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
    chmod 777 /var/run/mysqld

# 4. 引渡控制面自举脚本，并确保其具备刚性可执行特权
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown mysql:mysql /entrypoint.sh

EXPOSE 3306

# 5. 保持最高优先级的声明式引导，将控制权正式交接给自举状态机
ENTRYPOINT ["/entrypoint.sh"]