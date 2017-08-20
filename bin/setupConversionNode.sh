#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/functions.sh"


#Get ffmpeg.
curl --silent https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz > /tmp/ffmpeg-release-64bit-static.tar.xz
#Make directories if not present.
mkdir -p /data/ffmpeg
mkdir -p /data/ffmpeg-old
#Move old versions if present.
mv /data/ffmpeg/* /data/ffmpeg-old > /dev/null 2>&1
#Extract.
tar -xf /tmp/ffmpeg-release-64bit-static.tar.xz -C /data/ffmpeg
rm -f /tmp/ffmpeg-release-64bit-static.tar.xz




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


