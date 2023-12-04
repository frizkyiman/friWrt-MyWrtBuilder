#!/bin/bash

echo "Start Downloading Misc files !"
echo "Current Path: $PWD"

# setup login password
#sed -i '/reboot/ i\echo -e "bluedragon12\nbluedragon12" | passwd' files/etc/uci-defaults/99-init-settings.sh


# custom script files urls
ARCHH=$( [ "$TARGET" == "rpi-4" ] && echo "aarch64" || echo "x86_64" )
branch_tag=$( [ "$BRANCH" == "21.02.7" ] && echo -"$BRANCH" | awk -F'.' '{print $1"."$2}' )
urls=("https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-$ARCHH.tgz"
      "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch"
      "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
      "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
      "https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/usr/bin/repair_ro"
      "https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd")

echo "setup 99-init-settings.sh"
if [[ -e "files/etc/uci-defaults/99-init-settings_"$BASE""$branch_tag.sh"" ]]; then
     mv "files/etc/uci-defaults/99-init-settings_"$BASE""$branch_tag.sh"" "files/etc/uci-defaults/99-init-settings.sh"
     rm files/etc/uci-defaults/99-init-settings_*.sh
fi

echo "setup 10_system.js"
if [[ -e "files/www/luci-static/resources/view/status/include/10_system_$BASE.js" ]]; then
     mv "files/www/luci-static/resources/view/status/include/10_system_$BASE.js" "files/www/luci-static/resources/view/status/include/10_system.js"
     rm files/www/luci-static/resources/view/status/include/10_system_*.js
fi

echo "Downloading custom script"
mkdir -p files/etc/init.d
mkdir -p files/sbin/
if wget --no-check-certificate -nv -P files "${urls[@]}"; then
    wget --no-check-certificate -nv https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/etc/init.d/repair_ro -O files/etc/init.d/repair_ro
    echo "sync && echo 3 > /proc/sys/vm/drop_caches && rm -rf /tmp/luci*" >> files/sbin/free.sh
    mv files/sync_time.sh files/sbin/sync_time.sh
    mv files/neofetch files/usr/bin/neofetch
    mv files/clock files/usr/bin/clock
    mv files/repair_ro files/usr/bin/repair_ro
    mv files/mount_hdd files/usr/bin/mount_hdd
    tar -zxf files/ookla-speedtest-1.2.0-linux-$ARCHH.tgz -C files/usr/bin && rm files/ookla-speedtest-1.2.0-linux-$ARCHH.tgz && rm files/usr/bin/speedtest.md
else
    echo "Error downloading files. Exiting."
    exit 1
fi

cp /packages/luci-app-oled_1.0_all.ipk /files/root/luci-app-oled_1.0_all.ipk
sed -i '/reboot/ i\opkg install /root/luci-app-oled_1.0_all.ipk --force-reinstall' files/etc/uci-defaults/99-init-settings.sh

sed -i '/reboot/ i\chmod +x /root/fix-tinyfm.sh && bash /root/fix-tinyfm.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /sbin/sync_time.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /sbin/free.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/patchoc.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/neofetch' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/clock' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /etc/init.d/repair_ro' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/repair_ro' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/mount_hdd' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/speedtest' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/enable-agh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/disable-agh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\bash /usr/bin/enable-agh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\uci set luci.main.mediaurlbase='/luci-static/bootstrap' && uci commit' files/etc/uci-defaults/99-init-settings.sh

sed -i '/reboot/ i\exec >/root/first-boot.log 2>&1' files/etc/uci-defaults/99-init-settings.sh

echo "Download and configuration completed!"
