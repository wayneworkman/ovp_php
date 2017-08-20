#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


rm -f /var/www/html/*
cp ${cwd}/../web/* /var/www/html
webpermissions="apache:apache"
chown -R $webpermissions /var/www/html

mkdir -p /data/videos
mkdir -p /data/deleted
mkdir -p /data/uploads
mkdir -p /data/scripts
mkdir -p /data/logs
mkdir -p /data/qrCodes
mkdir -p /data/jobs
mkdir -p /data/problemJobs

if [[ -e /data/scripts/processupload.sh ]]; then
    rm -f /data/scripts/processupload.sh
fi
cp $cwd/processupload.sh /data/scripts
chown -R $webpermissions /data

systemctl enable httpd
systemctl start httpd



