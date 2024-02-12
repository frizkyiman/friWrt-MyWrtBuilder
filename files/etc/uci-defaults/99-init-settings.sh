#!/bin/sh

exec > /root/setup.log 2>&1

# dont remove!
echo "$(date '+%A, %d %B %Y %T')"
echo "Device Model: $(grep '\"name\":' /etc/board.json | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
echo "Processor: $(grep "model name" /proc/cpuinfo | awk -F ": " '{print $2}' | head -n 1 && grep "Hardware" /proc/cpuinfo | awk -F ": " '{print $2}')"
sed -i "s#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' / ':'')+(luciversion||''),#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' build by friWrt ':''),#g" /www/luci-static/resources/view/status/include/10_system.js
if grep -q "ImmortalWrt" /etc/openwrt_release; then
  sed -i "s/\(DISTRIB_DESCRIPTION='ImmortalWrt [0-9]*\.[0-9]*\.[0-9]*\).*'/\1'/g" /etc/openwrt_release
  echo Branch version: "$(grep 'DISTRIB_DESCRIPTION=' /etc/openwrt_release | awk -F"'" '{print $2}')"
elif grep -q "OpenWrt" /etc/openwrt_release; then
  sed -i "s/\(DISTRIB_DESCRIPTION='OpenWrt [0-9]*\.[0-9]*\.[0-9]*\).*'/\1'/g" /etc/openwrt_release
  echo Branch version: "$(grep 'DISTRIB_DESCRIPTION=' /etc/openwrt_release | awk -F"'" '{print $2}')"
fi

# Set login root password
(echo "friwrt"; sleep 1; echo "friwrt") | passwd > /dev/null

# Set hostname and Timezone to Asia/Jakarta
uci set system.@system[0].hostname='friWrt'
uci set system.@system[0].timezone='WIB-7'
uci set system.@system[0].zonename='Asia/Jakarta'
uci -q delete system.ntp.server
uci add_list system.ntp.server="pool.ntp.org"
uci add_list system.ntp.server="id.pool.ntp.org"
uci add_list system.ntp.server="time.google.com"
uci commit system

# configure wan interface
uci set network.wan=interface 
uci set network.wan.proto='modemmanager'
uci set network.wan.device='/sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb2/2-1'
uci set network.wan.apn='internet'
uci set network.wan.auth='none'
uci set network.wan.iptype='ipv4'
uci set network.lan.ipaddr="192.168.1.1"
uci set network.tethering=interface
uci set network.tethering.proto='dhcp'
uci set network.tethering.device='usb0'
uci commit network
uci set firewall.@zone[1].network='wan tethering'
uci commit firewall

# configure ipv6
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci -q delete dhcp.lan.ndp
uci commit dhcp

# configure WLAN
if iw dev | grep -q "Interface"; then
  uci set wireless.@wifi-device[0].disabled='0'
  uci set wireless.@wifi-iface[0].disabled='0'
  uci set wireless.@wifi-iface[0].encryption='psk2'
  uci set wireless.@wifi-iface[0].key='friwrt2023'
  uci set wireless.@wifi-device[0].country='ID'
  if grep -q "Raspberry Pi 4" /proc/cpuinfo; then
    uci set wireless.@wifi-iface[0].ssid='friWrt_5g'
    uci set wireless.@wifi-device[0].channel='161'
  else
    uci set wireless.@wifi-iface[0].ssid='friWrt_2g'
    uci set wireless.@wifi-device[0].channel='1'
    uci set wireless.@wifi-device[0].band='2g'
  fi
  uci commit wireless
  wifi up
  if ! grep -q "wifi up" /etc/rc.local; then
    sed -i '/exit 0/i wifi up' /etc/rc.local
  fi
else
  echo "No wireless detected"
fi

# remove huawei me909s usb-modeswitch
sed -i -e '/12d1:15c1/,+5d' /etc/usb-mode.json

# remove dw5821e usb-modeswitch
sed -i -e '/413c:81d7/,+5d' /etc/usb-mode.json

# Disable /etc/config/xmm-modem
uci set xmm-modem.@xmm-modem[0].enable='0'
uci commit

# custom repo and Disable opkg signature check
if grep -qE '^VERSION_ID="21' /etc/os-release; then
  sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
  echo "src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/21.02/generic" >> /etc/opkg/customfeeds.conf
  echo "src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/21.02/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')" >> /etc/opkg/customfeeds.conf
else
  sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
  echo "src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/main/generic" >> /etc/opkg/customfeeds.conf
  echo "src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/main/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')" >> /etc/opkg/customfeeds.conf
fi

# Remove watchcat default config
uci -q delete watchcat.@watchcat[0]
uci commit

# setting firewall for samba4
uci -q delete firewall.samba_nsds_nt
uci set firewall.samba_nsds_nt="rule"
uci set firewall.samba_nsds_nt.name="NoTrack-Samba/NS/DS"
uci set firewall.samba_nsds_nt.src="lan"
uci set firewall.samba_nsds_nt.dest="lan"
uci set firewall.samba_nsds_nt.dest_port="137-138"
uci set firewall.samba_nsds_nt.proto="udp"
uci set firewall.samba_nsds_nt.target="NOTRACK"
uci -q delete firewall.samba_ss_nt
uci set firewall.samba_ss_nt="rule"
uci set firewall.samba_ss_nt.name="NoTrack-Samba/SS"
uci set firewall.samba_ss_nt.src="lan"
uci set firewall.samba_ss_nt.dest="lan"
uci set firewall.samba_ss_nt.dest_port="139"
uci set firewall.samba_ss_nt.proto="tcp"
uci set firewall.samba_ss_nt.target="NOTRACK"
uci -q delete firewall.samba_smb_nt
uci set firewall.samba_smb_nt="rule"
uci set firewall.samba_smb_nt.name="NoTrack-Samba/SMB"
uci set firewall.samba_smb_nt.src="lan"
uci set firewall.samba_smb_nt.dest="lan"
uci set firewall.samba_smb_nt.dest_port="445"
uci set firewall.samba_smb_nt.proto="tcp"
uci set firewall.samba_smb_nt.target="NOTRACK"
uci commit firewall

# set argon as default theme
uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit

# remove login password required when accessing terminal
uci set ttyd.@ttyd[0].command='/bin/bash --login'
uci commit

# setup nlbwmon database dir
uci set nlbwmon.@nlbwmon[0].database_directory='/etc/nlbwmon'
uci set nlbwmon.@nlbwmon[0].commit_interval='3h'
uci set nlbwmon.@nlbwmon[0].refresh_interval='60s'
uci commit nlbwmon

# setup auto vnstat database backup
chmod +x /etc/init.d/vnstat_backup
bash /etc/init.d/vnstat_backup enable

# adjusting app catagory
sed -i 's/services/nas/g' /usr/lib/lua/luci/controller/aria2.lua 2>/dev/null || sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-aria2.json
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-samba4.json
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-hd-idle.json
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-disks-info.json
sed -i 's/services/status/g' /usr/share/luci/menu.d/luci-app-log.json
sed -i 's/services/modem/g' /usr/share/luci/menu.d/luci-app-lite-watchdog.json

# setup misc settings
sed -i 's/\[ -f \/etc\/banner \] && cat \/etc\/banner/#&/' /etc/profile
sed -i 's/\[ -n "$FAILSAFE" \] && cat \/etc\/banner.failsafe/& || \/usr\/bin\/neofetch/' /etc/profile
chmod +x /usr/share/3ginfo-lite/modem/413c81d7
chmod +x /root/fix-tinyfm.sh && bash /root/fix-tinyfm.sh
chmod +x /root/install2.sh && bash /root/install2.sh
chmod +x /sbin/sync_time.sh
chmod +x /sbin/free.sh
chmod +x /usr/bin/neofetch
chmod +x /usr/bin/clock
chmod +x /usr/bin/mount_hdd
chmod +x /usr/bin/speedtest
chmod +x /usr/bin/openclash.sh

# configurating openclash
if opkg list-installed | grep luci-app-openclash > /dev/null; then
  if [ -d "/usr/share/openclash/ui/yacd.new" ]; then
    if mv /usr/share/openclash/ui/yacd /usr/share/openclash/ui/yacd.old; then
      mv /usr/share/openclash/ui/yacd.new /usr/share/openclash/ui/yacd
    fi
  fi
  chmod +x /etc/openclash/core/clash
  chmod +x /etc/openclash/core/clash_tun
  chmod +x /etc/openclash/core/clash_meta
  chmod +x /usr/bin/patchoc.sh
  bash /usr/bin/patchoc.sh
  sed -i '/exit 0/i #/usr/bin/patchoc.sh' /etc/rc.local
else
  uci delete internet-detector.Openclash
  uci commit internet-detector
  service internet-detector  restart
fi

# adding new line for enable i2c oled display
if ARCH_1=$(uname -m) && [ "$ARCH_1" != "x86_64" ]; then
  echo -e "\ndtparam=i2c1=on\ndtparam=spi=on\ndtparam=i2s=on" >> /boot/config.txt
fi

# enable adguardhome
chmod +x /usr/bin/adguardhome
bash /usr/bin/adguardhome enable

echo "All done!"

exit 0
