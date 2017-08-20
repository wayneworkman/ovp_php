#!/bin/bash


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
