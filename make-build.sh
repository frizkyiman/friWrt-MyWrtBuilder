#!/bin/bash

# Profile info
make info

# Main configuration name
PROFILE=""
PACKAGES=""

# Modem and UsbLAN Driver
PACKAGES+=" kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"
PACKAGES+=" kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi luci-proto-qmi \
kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils \
kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim \
modemmanager luci-proto-modemmanager usbutils luci-proto-mbim luci-proto-ncm \
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless \
kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem"

# Modem Tools
PACKAGES+=" luci-app-modeminfo atinout luci-app-modemband modemband luci-app-mmconfig sms-tool luci-app-sms-tool-js luci-app-lite-watchdog luci-app-3ginfo-lite luci-app-modemdefine picocom minicom"

# Tunnel option
OPENCLASH_FW3="coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun unzip luci-compat luci luci-base luci-app-openclash"
OPENCLASH_FW4="coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
PASSWALL="ipset ipt2socks iptables iptables-legacy iptables-mod-iprange iptables-mod-socket iptables-mod-tproxy kmod-ipt-nat coreutils coreutils-base64 coreutils-nohup curl dns2socks ip-full libuci-lua lua luci-compat luci-lib-jsonc microsocks resolveip tcping unzip dns2tcp brook hysteria trojan-go xray-core xray-plugin sing-box chinadns-ng haproxy ip6tables-mod-nat kcptun-client naiveproxy pdnsd-alt shadowsocks-libev-ss-local shadowsocks-libev-ss-redir shadowsocks-libev-ss-server shadowsocks-rust-sslocal shadowsocksr-libev-ssr-local shadowsocksr-libev-ssr-redir shadowsocksr-libev-ssr-server simple-obfs trojan-plus v2ray-core v2ray-plugin luci-app-passwall"
if [ "$2" == "openclash" ]; then
    PACKAGES+=" $([ "$(echo "$BRANCH" | cut -d'.' -f1)" == "21" ] && echo "$OPENCLASH_FW3" || echo "$OPENCLASH_FW4")"
elif [ "$2" == "passwall" ]; then
    PACKAGES+=" $PASSWALL"
elif [ "$2" == "openclash-passwall" ]; then
    PACKAGES+=" $([ "$(echo "$BRANCH" | cut -d'.' -f1)" == "21" ] && echo "$OPENCLASH_FW3" || echo "$OPENCLASH_FW4") $PASSWALL"
fi

# Adguardhome
PACKAGES+=" luci-app-adguardhome ca-certificates ca-bundle curl wget wget-ssl tar unzip bind-tools"

# NAS and Hard disk tools
PACKAGES+=" luci-app-diskman luci-app-hd-idle luci-app-disks-info smartmontools kmod-usb-storage kmod-usb-storage-uas ntfs-3g"
PACKAGES+=" samba4-server luci-app-samba4 aria2 ariang luci-app-aria2 luci-app-tinyfm"

# Docker
PACKAGES+=" docker docker-compose dockerd luci-app-dockerman"

# Bandwidth Monitoring
PACKAGES+=" luci-app-internet-detector internet-detector nlbwmon luci-app-nlbwmon vnstat2 vnstati2 luci-app-vnstat2"

# Argon Theme
PACKAGES+=" luci-theme-argon luci-app-argon-config"

# PHP8
PACKAGES+=" libc php8 php8-fastcgi php8-fpm php8-mod-session php8-mod-ctype php8-mod-fileinfo php8-mod-zip php8-mod-iconv php8-mod-mbstring coreutils-stat zoneinfo-asia"

# Misc and some custom .ipk files
misc=""
if [ "${RELEASE_BRANCH%:*}" == "openwrt" ]; then
    misc+=" luci-app-temp-status luci-app-cpu-status-mini"
elif [ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]; then
    misc+=" "
fi

if [ "$1" == "rpi-4" ]; then
    misc+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio luci-app-oled speedtest-web luci-app-speedtest-web"
elif [ "$1" == "generic" ]; then
    misc+=" speedtest-web luci-app-speedtest-web"
fi
PACKAGES+=" $misc zram-swap adb parted losetup resize2fs luci luci-ssl block-mount luci-app-poweroff iperf3 luci-app-log luci-app-ramfree htop bash curl tar unzip unrar jq luci-app-ttyd nano"

# Exclude package (must use - before packages name)
EXCLUDED=""
if [ "${RELEASE_BRANCH%:*}" == "openwrt" ]; then
    EXCLUDED+=" -dnsmasq"
elif [ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]; then
    EXCLUDED+=" -dnsmasq -automount -libustream-openssl -default-settings-chn -luci-i18n-base-zh-cn"
    if [ "$1" == "generic" ]; then
      EXCLUDED+=" -kmod-usb-net-rtl8152-vendor"
    fi
fi

# Custom Files
FILES="files"

# Disable service
DISABLED_SERVICES="AdGuardHome"

# Start build firmware
echo "Custom packages list:"
echo "$PACKAGES"
echo "Number of packages: $(echo "$PACKAGES" | tr ' ' '\n' | wc -l)"
make image PROFILE="$1" PACKAGES="$PACKAGES $EXCLUDED" FILES="$FILES" DISABLED_SERVICES="$DISABLED_SERVICES"
