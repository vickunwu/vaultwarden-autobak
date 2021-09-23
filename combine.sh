#!/bin/sh
echo -e '@hourly /config/backup.sh > /backup/backup.log 2>&1\n@daily find "/backup/archives" -name 'vaultwarden-*.tar.*' -mtime +10 -delete\n30 3 * * * sqlite3 /data/db.sqlite3 VACUUM' | crontab - && /usr/sbin/crond -f -L /dev/stdout
sh /start.sh
