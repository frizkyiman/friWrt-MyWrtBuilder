#!/bin/bash

# Profile info
make info

# Main configuration name
PROFILE=""
PACKAGES=""

# Argon Theme
PACKAGES="$PACKAGES luci-theme-argon luci-app-argon-config"

# Driver Modem Rakitan
PACKAGES="$PACKAGES kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi luci-proto-qmi \
kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils \
kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim \
modemmanager luci-proto-modemmanager usbutils luci-proto-mbim luci-proto-ncm \
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless \
kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem"

# Modem Tools
PACKAGES="$PACKAGES luci-app-modeminfo atinout luci-app-modemband modemband luci-app-mmconfig sms-tool luci-app-sms-tool-js picocom minicom"

# Adapter UTL driver
PACKAGES="$PACKAGES kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"

# OpenClash iptables and nftables
if [[ "$(echo $BRANCH | cut -d'.' -f1)" == "21" ]]; then
    # iptables
	PACKAGES="$PACKAGES coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun unzip luci-compat luci luci-base luci-app-openclash"
else
    # nftables
	PACKAGES="$PACKAGES coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
fi

# Adguardhome
PACKAGES="$PACKAGES luci-app-adguardhome ca-certificates ca-bundle curl wget wget-ssl tar unzip bind-tools"

# Hard disk tools
PACKAGES="$PACKAGES luci-app-diskman luci-app-hd-idle luci-app-disks-info smartmontools kmod-usb-storage kmod-usb-storage-uas ntfs-3g"

# Nas tools
PACKAGES="$PACKAGES samba4-server luci-app-samba4 aria2 ariang luci-app-aria2 luci-app-tinyfm"

# Docker
PACKAGES="$PACKAGES docker docker-compose dockerd luci-app-dockerman"

# Monitoring
PACKAGES="$PACKAGES luci-app-internet-detector internet-detector nlbwmon luci-app-nlbwmon vnstat2 vnstati2 luci-app-vnstat2 luci-app-speedtest-web"

# i2c tools
PACKAGES="$PACKAGES i2c-tools kmod-i2c-core kmod-i2c-gpio luci-app-oled"

# PHP8
PACKAGES="$PACKAGES libc php8 php8-fastcgi php8-fpm php8-mod-session php8-mod-ctype php8-mod-fileinfo php8-mod-zip php8-mod-iconv php8-mod-mbstring coreutils-stat zoneinfo-asia"

# Misc
if [ "${RELEASE_BRANCH%:*}" == "openwrt" ]; then
    PACKAGES="$PACKAGES zram-swap adb parted losetup resize2fs luci luci-ssl block-mount luci-app-poweroff iperf3 luci-app-log luci-app-temp-status luci-app-cpu-status-mini luci-app-ramfree htop luci-app-watchcat bash curl tar unzip unrar jq luci-app-ttyd nano git git-http"
elif [ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]; then
    PACKAGES="$PACKAGES zram-swap adb parted losetup resize2fs luci luci-ssl block-mount luci-app-poweroff iperf3 luci-app-log luci-app-ramfree htop luci-app-watchcat bash curl tar unzip unrar jq luci-app-ttyd nano git git-http"
fi

# Custom Files
FILES="files"

# some custom .ipk files
CUSTOM=$( [ "$TARGET" == "rpi-4" ] && echo "kmod-i2c-bcm2835" )

# Exclude package
if [ "${RELEASE_BRANCH%:*}" == "openwrt" ]; then
    EXCLUDED="-dnsmasq"
elif [ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]; then
    EXCLUDED="-dnsmasq -automount -libustream-openssl -default-settings-chn -luci-i18n-base-zh-cn"
fi

# Disable service
DISABLED_SERVICES="AdGuardHome"

# Start build firmware
make image PROFILE="$PROFILE" PACKAGES="$PACKAGES $CUSTOM $EXCLUDED" FILES="$FILES" DISABLED_SERVICES="$DISABLED_SERVICES"
