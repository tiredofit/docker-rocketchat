FROM rocketchat/rocket.chat:latest
USER root

ENV S6_OVERLAY_VERSION=v2.0.0.1 \
    TIMEZONE=Etc/GMT \
    ENABLE_CRON=FALSE \
    ENABLE_SMTP=FALSE \
    ENABLE_ZABBIX=TRUE \
    ZABBIX_VERSION=5.0

CMD echo "Completed"

### Dependencies Addon
RUN set -x && \
      apt-get update && \
      apt-get install -y --no-install-recommends \
               ca-certificates \
               curl \
               gnupg \
               less \
               logrotate \
               msmtp \
               nano \
               netcat \
               procps \
               tzdata \
               vim-tiny \
               && \
       curl https://repo.zabbix.com/zabbix-official-repo.key | apt-key add - && \
       echo "deb http://security.debian.org/ buster/updates main contrib non-free" >>/etc/apt/sources.list && \
       echo "deb-src http://security.debian.org/ buster/updates main contrib non-free" >>/etc/apt/sources.list && \
       echo "deb http://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian buster main" >>/etc/apt/sources.list && \
       echo "deb-src http://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian buster main" >>/etc/apt/sources.list && \
       apt-get update && \
       apt-get install -y \
               zabbix-agent && \
       apt-get autoremove -y && \
       apt-get clean -y && \
       rm -rf /var/lib/apt/lists/* /root/.gnupg /var/log/* && \
       mkdir -p /assets/cron && \
       echo "${TIMEZONE}" > /etc/timezone && \
       dpkg-reconfigure -f noninteractive tzdata && \
       \
### S6 Installation
       curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xfz - -C /

### Entrypoint Configuration
   ENTRYPOINT ["/init"]
   CMD []

 ### Add Folders
   ADD install /
