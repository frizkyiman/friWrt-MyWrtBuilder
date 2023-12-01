#!/bin/bash

echo "Start Downloading Misc files !"
echo "Current Path: $PWD"

branch_main=$( [ "$BRANCH" == "21.02.7" ] && echo -"$BRANCH" | awk -F'.' '{print $1"."$2}' )
ARCHH=$( [ "$TARGET" == "rpi-4" ] && echo "aarch64" || echo "x86_64" )
urls=("https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-$ARCHH.tgz"
      "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch"
      "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
      "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
      "https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/usr/bin/repair_ro"
      "https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd")


mkdir -p files/etc/uci-defaults
mkdir -p files/etc/init.d
mkdir -p files/usr/bin/
mkdir -p files/sbin/
mkdir -p files/www/luci-static/resources/view/status/include
cd files/

wget --no-check-certificate -nv https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/etc/init.d/repair_ro
mv files//repair_ro files/etc/init.d/repair_ro
wget --no-check-certificate -nv "$urls"

tar -xzvf files/usr/bin/*-speedtest-*.tgz -C files/usr/bin
rm files/*-speedtest-*.tgz
rm files/usr/bin/speedtest.md

echo "sync && echo 3 > /proc/sys/vm/drop_caches && rm -rf /tmp/luci* >> files/sbin/free.sh
mv files/sync_time.sh files/sbin/sync_time.sh
mv files/neofetch files/usr/bin/neofetch
mv files/clock files/usr/bin/clock
mv files/repair_ro files/usr/bin/repair_ro
mv files/mount_hdd files/usr/bin/mount_hdd
mv files/patchoc.sh files/usr/bin/patchoc.sh 

mv files/10_system_$BASE.js files/www/luci-static/resources/view/status/include/10_system.js
mv files/99-init-settings_"$BASE""$branch_main".sh files/etc/uci-defaults/99-init-settings.sh


