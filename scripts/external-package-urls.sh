#!/bin/bash
# This script for custom download the latest packages version from snapshots/stable repo's url.
# Put file name and url base.

files=(
    "luci-proto-modemmanager|https://downloads.openwrt.org/releases/23.05.3/packages/$ARCH_3/luci"
    "luci-proto-mbim|https://downloads.openwrt.org/releases/23.05.3/packages/$ARCH_3/luci"
    "modemmanager|https://downloads.openwrt.org/releases/23.05.3/packages/$ARCH_3/packages"
    "libmbim|https://downloads.openwrt.org/releases/23.05.3/packages/$ARCH_3/packages"
    "libqmi|https://downloads.openwrt.org/releases/23.05.3/packages/$ARCH_3/packages"
    #"sms-tool|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    "sms-tool|https://downloads.openwrt.org/releases/23.05.3/packages/$ARCH_3/packages"
)

for entry in "${files[@]}"; do
    IFS="|" read -r filename base_url <<< "$entry"
    file_url=$(curl -sL "$base_url" | grep -o "$filename[_0-9a-zA-Z\.-]*\.ipk" | head -n 1)
    if [ -n "$file_url" ]; then
        echo "Downloading $file_url from $base_url..."
        curl -Lo "packages/$file_url" "$base_url/$file_url"
        echo "Download complete."
    else
        echo "Failed to retrieve $filename filename from $base_url. Exiting."
        exit 1
    fi
done
