#!/bin/sh
envsubst < /config/backup.conf.temp > /config/backup.conf && \
envsubst < /config/rclone/rclone.conf.temp > /config/rclone/rclone.conf

FOLDER=$(rclone --config /config/rclone/rclone.conf ls ${DEST_NAME}:${BUCKET_NAME} | tail -n1 | awk '{print $2}' | awk -F '.' '{print $1}')
rclone --config /config/rclone/rclone.conf copy ${DEST_NAME}:${BUCKET_NAME}/${FOLDER}.tar.gz.gpg ./
gpg -d --batch --passphrase ${GPG_PASSPHRASE} ${FOLDER}.tar.gz.gpg | tar xz
cp -r ./${FOLDER}/* /data/
rm -rf ./${FOLDER}

echo -e '@hourly /config/backup.sh > /data/bakup/backup.log 2>&1\n@daily find "/data/bakup/archives" -name 'vaultwarden-*.tar.*' -mtime +10 -delete\n30 3 * * * sqlite3 /data/db.sqlite3 VACUUM' | crontab - 
/usr/sbin/crond &
sh /start.sh
