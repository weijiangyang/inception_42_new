FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    vsftpd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "listen=YES\n\
local_enable=YES\n\
write_enable=YES\n\
local_umask=022\n\
chroot_local_user=YES\n\
allow_writeable_chroot=YES\n\
secure_chroot_dir=/var/run/vsftpd/empty\n\
pasv_enable=YES\n\
pasv_min_port=40000\n\
pasv_max_port=40005" > /etc/vsftpd.conf

RUN mkdir -p /var/run/vsftpd/empty

COPY tools/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21 40000-40005

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]