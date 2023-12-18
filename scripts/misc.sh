#!/bin/bash

echo "Start Downloading Misc files and setup configuration!"
echo "Current Path: $PWD"

# setup custom repo and Disable opkg signature check
{
if [[ "$(echo "${RELEASE_BRANCH#*:}" | awk -F '.' '{print $1"."$2}')" == "21.02" ]]; then
    sed -i '/# custom repo/ a\echo "src/gz custom_arch https:\/\/raw.githubusercontent.com\/lrdrdn\/my-opkg-repo\/21.02\/$(cat \/etc\/os-release | grep OPENWRT_ARCH | awk -F '"' '"' '\''{print $2}'"'"')" >> \/etc\/opkg\/customfeeds.conf' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# custom repo/ a\echo "src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/21.02/generic" >> /etc/opkg/customfeeds.conf' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# custom repo/ a\sed -i '\''s/option check_signature/# option check_signature/g'\'' /etc/opkg.conf' files/etc/uci-defaults/99-init-settings.sh
else
    sed -i '/# custom repo/ a\echo "src/gz custom_arch https:\/\/raw.githubusercontent.com\/lrdrdn\/my-opkg-repo\/main\/$(cat \/etc\/os-release | grep OPENWRT_ARCH | awk -F '"' '"' '\''{print $2}'"'"')" >> \/etc\/opkg\/customfeeds.conf' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# custom repo/ a\echo "src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/main/generic" >> /etc/opkg/customfeeds.conf' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# custom repo/ a\sed -i '\''s/option check_signature/# option check_signature/g'\'' /etc/opkg.conf' files/etc/uci-defaults/99-init-settings.sh
fi
}

#setup custom setting for openwrt or immortalwrt
{
if [[ "${RELEASE_BRANCH%:*}" == "openwrt" ]]; then
    sed -i '/reboot/ i\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh
    mv "files/www/luci-static/resources/view/status/include/10_system_openwrt.js" "files/www/luci-static/resources/view/status/include/10_system.js"
    rm files/www/luci-static/resources/view/status/include/10_system_immortalwrt.js
elif [[ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]]; then
    if [[ "$(echo "${RELEASE_BRANCH#*:}" | awk -F '.' '{print $1"."$2}')" == "23.05" ]]; then
        cp packages/luci-app-oled_1.0_all.ipk files/root/luci-app-oled_1.0_all.ipk
        sed -i '/reboot/ i\opkg install /root/luci-app-oled_1.0_all.ipk --force-reinstall' files/etc/uci-defaults/99-init-settings.sh
        sed -i '/reboot/ i\rm /root/luci-app-oled_1.0_all.ipk' files/etc/uci-defaults/99-init-settings.sh
    fi
    mv "files/www/luci-static/resources/view/status/include/10_system_immortalwrt.js" "files/www/luci-static/resources/view/status/include/10_system.js"
    rm files/www/luci-static/resources/view/status/include/10_system_openwrt.js
fi
}

# setup login/wifi password information
{
if [ -n "$LOGIN_PASSWORD" ]; then
    echo "Login password was set: $LOGIN_PASSWORD"
    sed -i "/exec > \/root\/setup.log 2>&1/ a\\(echo "$LOGIN_PASSWORD"; sleep 1; echo "$LOGIN_PASSWORD") | passwd > /dev/null\\" files/etc/uci-defaults/99-init-settings.sh
else
    echo "Login password is not set, skipping..."
fi

echo "Wifi SSID was set: $WIFI_SSID"

if [ -n "$WIFI_PASSWORD" ]; then
    echo "Wifi password was set: $WIFI_PASSWORD"
    sed -i "/#configure WLAN/ a\uci set wireless.@wifi-iface[0].encryption='psk2'" files/etc/uci-defaults/99-init-settings.sh
    sed -i "/#configure WLAN/ a\uci set wireless.@wifi-iface[0].key=\"$WIFI_PASSWORD\"" files/etc/uci-defaults/99-init-settings.sh
else
    echo "Wifi password is not set, skipping..."
fi

sed -i "/#configure WLAN/ a\uci set wireless.@wifi-iface[0].ssid=\"$WIFI_SSID\"" files/etc/uci-defaults/99-init-settings.sh
}

{
echo "Downloading custom script" 
# custom script files urls
urls=("https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-$ARCH_2.tgz"
      "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch"
      "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
      "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
      "https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/sbin/repair_ro"
      "https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd")

mkdir -p files/etc/init.d
mkdir -p files/sbin/
if wget --no-check-certificate -nv -P files "${urls[@]}"; then
    echo "sync && echo 3 > /proc/sys/vm/drop_caches && rm -rf /tmp/luci*" >> files/sbin/free.sh
    mv files/sync_time.sh files/sbin/sync_time.sh
    mv files/neofetch files/usr/bin/neofetch
    mv files/clock files/usr/bin/clock
    mv files/repair_ro files/sbin/repair_ro
    mv files/mount_hdd files/usr/bin/mount_hdd
    tar -zxf files/ookla-speedtest-1.2.0-linux-$ARCH_2.tgz -C files/usr/bin && rm files/ookla-speedtest-1.2.0-linux-$ARCH_2.tgz && rm files/usr/bin/speedtest.md
fi
}

{
sed -i '/reboot/ i\chmod +x /etc/openclash/core/clash' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /etc/openclash/core/clash_tun' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /etc/openclash/core/clash_meta' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /root/fix-tinyfm.sh && bash /root/fix-tinyfm.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /sbin/sync_time.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /sbin/free.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/patchoc.sh' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/neofetch' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/clock' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /etc/init.d/repair_ro' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/repair_ro' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /sbin/repair_ro' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/mount_hdd' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/speedtest' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /usr/bin/adguardhome' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\bash /usr/bin/adguardhome --force-enable' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\chmod +x /etc/init.d/vnstat_backup' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\bash /etc/init.d/vnstat_backup enable' files/etc/uci-defaults/99-init-settings.sh
sed -i '/reboot/ i\uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit' files/etc/uci-defaults/99-init-settings.sh
}
echo "Download and configurating completed!"
