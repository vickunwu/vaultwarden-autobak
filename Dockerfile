FROM rclone/rclone as bin
FROM vaultwarden/server:alpine

ENV XDG_CONFIG_HOME=/config

COPY --chown=root:root --from=bin /usr/local/bin/rclone /usr/bin/
COPY --chown=root:root backup.conf.temp backup.sh combine.sh /config/
COPY --chown=root:root rclone.conf.temp /config/rclone/

RUN chmod +x /config/combine.sh && \
    curl -L https://github.com/FiloSottile/age/releases/download/v1.0.0/age-v1.0.0-linux-amd64.tar.gz | tar zx && \
    mv age/age /usr/bin/ && \
	rm -rf age && \
    mkdir /backup && \
    apk update && \
    apk upgrade && \
    apk add --no-cache sqlite && \
    apk add --no-cache tzdata && \
    apk add --no-cache gettext && \
    envsubst < /config/backup.conf.temp > /config/backup.conf && \
    envsubst < /config/rclone/rclone.conf.temp > /config/rclone/rclone.conf && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

HEALTHCHECK --interval=60s --timeout=10s CMD ["/healthcheck.sh"]

# Configures the startup!
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/config/combine.sh"]
