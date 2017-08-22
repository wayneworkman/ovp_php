#!/bin/bash

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


if [[ -e /usr/lib/systemd/system/coordinator.service ]]; then
    rm -f /usr/lib/systemd/system/coordinator.service
fi
cp $cwd/coordinator.service /usr/lib/systemd/system
if [[ -e /data/scripts/coordinator.sh ]]; then
    rm -f /data/scripts/coordinator.sh
fi
cp $cwd/coordinator.sh /data/scripts
systemctl enable coordinator.service
systemctl restart coordinator.service



