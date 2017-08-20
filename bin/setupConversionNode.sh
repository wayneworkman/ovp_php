#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"




if [[ -e /data/scripts/mysqlCredentials.sh ]]; then
    rm -f /data/scripts/mysqlCredentials.sh
fi
cp $cwd/mysqlCredentials.sh /data/scripts/mysqlCredentials.sh 
if [[ -e /usr/lib/systemd/system/processupload.service ]]; then
    rm -f /usr/lib/systemd/system/processupload.service
fi
cp $cwd/processupload.service /usr/lib/systemd/system
if [[ -e /data/scripts/processupload.sh ]]; then
    rm -f /data/scripts/processupload.sh
fi
cp $cwd/processupload.sh /data/scripts
systemctl enable processupload.service
systemctl restart processupload.service


