#!/bin/bash

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


if [[ -e /usr/lib/systemd/system/scaleout.service ]]; then
    rm -f /usr/lib/systemd/system/scaleout.service
fi
cp $cwd/scaleout.service /usr/lib/systemd/system
if [[ -e /data/scripts/scaleout.sh ]]; then
    rm -f /data/scripts/scaleout.sh
fi
cp $cwd/scaleout.sh /data/scripts
systemctl enable scaleout.service
systemctl restart scaleout.service



if [[ -e /usr/lib/systemd/system/monitorworkers.service ]]; then
    rm -f /usr/lib/systemd/system/monitorworkers.service
fi
cp $cwd/monitorworkers.service /usr/lib/systemd/system
if [[ -e /data/scripts/monitorworkers.sh ]]; then
    rm -f /data/scripts/monitorworkers.sh
fi
cp $cwd/monitorworkers.sh /data/scripts
systemctl enable monitorworkers.service
systemctl restart monitorworkers.service


