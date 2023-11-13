#!/bin/bash

# Profile info
make info

# Main configuration name
PROFILE="rpi-4"

PACKAGES=""

# Argon Theme
#PACKAGES="$PACKAGES luci-theme-argon luci-argon-config"

# Driver Modem Rakitan
PACKAGES="$PACKAGES kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi luci-proto-qmi kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim modemmanager luci-proto-modemmanager luci-proto-mbim usbutils luci-proto-ncm kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem picocom minicom"

# Modem Tools
#PACKAGES="$PACKAGES luci-app-modeminfo atinout luci-app-modemband modemband luci-app-mmconfig"

# Adapter UTL driver
PACKAGES="$PACKAGES kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"

# Diskman
#PACKAGES="$PACKAGES luci-app-diskman"

# OpenClash iptables and nftables
version=$(echo $BRANCH | cut -d'.' -f1)
if [ "$version" == "21" ]; then
    PACKAGES="$PACKAGES coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun unzip luci-compat luci luci-base luci-app-openclash"
else
    PACKAGES="$PACKAGES coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
fi

# Hard disk hibernation
PACKAGES="$PACKAGES luci-app-hd-idle luci-app-disks-info smartmontools kmod-usb-storage kmod-usb-storage-uas"

# Vnstat2
PACKAGES="$PACKAGES vnstat2 vnstati2 luci-app-vnstat2"

# Samba
PACKAGES="$PACKAGES samba4-server luci-app-samba4"

# Aria2
PACKAGES="$PACKAGES aria2 ariang luci-app-aria2"

# Docker
PACKAGES="$PACKAGES docker docker-compose dockerd luci-app-dockerman"

# Nlbwmon
PACKAGES="$PACKAGES nlbwmon luci-app-nlbwmon tar unrar unzip jq"

# some custom files
FILES="files"

DISABLED_SERVICES="-dnsmasq"

make image PROFILE="$PROFILE" PACKAGES="$PACKAGES $DISABLED_SERVICES" FILES="$FILES"
