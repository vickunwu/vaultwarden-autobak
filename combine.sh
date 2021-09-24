#!/bin/sh
envsubst < /config/backup.conf.temp > /config/backup.conf && \
envsubst < /config/rclone/rclone.conf.temp > /config/rclone/rclone.conf
echo -e '@hourly /config/backup.sh > /data/bakup/backup.log 2>&1\n@daily find "/data/bakup/archives" -name 'vaultwarden-*.tar.*' -mtime +10 -delete\n30 3 * * * sqlite3 /data/db.sqlite3 VACUUM' | crontab - 
/usr/sbin/crond &
sh /start.sh
