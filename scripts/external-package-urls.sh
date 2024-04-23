#!/bin/bash
# This script for custom download the latest packages version from snapshots/stable repo's url.
# Put file name and url base.

files=(
    #"luci-proto-modemmanager|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/luci"
    #"luci-proto-mbim|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/luci"
    #"modemmanager|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    #"libmbim|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    #"libqmi|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    "sms-tool|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    "luci-proto-modemmanager|https://downloads.openwrt.org/releases/packages-23.05/$ARCH_3/luci"
    "luci-proto-mbim|https://downloads.openwrt.org/releases/packages-23.05/$ARCH_3/luci"
    "modemmanager|https://downloads.openwrt.org/releases/packages-23.05/$ARCH_3/packages"
    "libmbim|https://downloads.openwrt.org/releases/packages-23.05/$ARCH_3/packages"
    "libqmi|https://downloads.openwrt.org/releases/packages-23.05/$ARCH_3/packages"
    #"sms-tool|https://downloads.openwrt.org/releases/packages-23.05/$ARCH_3/packages"
    "luci-app-argon-config|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "luci-theme-argon|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "luci-app-cpu-status-mini|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "luci-app-diskman|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "luci-app-disks-info|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "luci-app-log-viewer|https://fantastic-packages.github.io/packages/releases/23.05/packages/$ARCH_3/luci"
    "luci-app-temp-status|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "luci-app-tinyfilemanager|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "luci-app-internet-detector|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "internet-detector|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/packages"
    "internet-detector-mod-modem-restart|https://fantastic-packages.github.io/packages/releases/23.05/packages/$ARCH_3/packages"
    "luci-app-netspeedtest|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/$ARCH_3/luci"
    "python3-speedtest-cli|https://downloads.openwrt.org/releases/packages-$(echo "$BRANCH" | cut -d'.' -f1-2)/$ARCH_3/packages"
    "librespeed-go|https://downloads.openwrt.org/releases/packages-$(echo "$BRANCH" | cut -d'.' -f1-2)/$ARCH_3/packages"
)

for entry in "${files[@]}"; do
    IFS="|" read -r filename base_url <<< "$entry"
    echo "Processing file: $filename"
    file_url=$(curl -sL "$base_url" | grep -oE "$filename[0-9a-zA-Z\._~-]*\.ipk" | head -n 1)
    if [ -n "$file_url" ]; then
        if [[ " ${files[*]} " == *" $filename|"* ]]; then
            echo "Downloading $file_url"
            echo "from $base_url/$file_url"
            curl -Lo "packages/$file_url" "$base_url/$file_url"
            echo "Download complete."
        else
            echo "File $file_url is not in the allowed list. Skipping this download."
        fi
    else
        echo "Failed to retrieve $filename filename from $base_url. Exiting."
        exit 1
    fi
done
