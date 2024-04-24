#!/bin/bash
# This script for custom download the latest packages version from snapshots/stable repo's url and github release.
# Put file name and url base.

# Download packages from official snapshots and stable repo's urls
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
    file_urls=$(curl -sL "$base_url" | grep -oE "$filename[0-9a-zA-Z\._~-]*\.ipk")
    for file_url in "$file_urls"; do
        if [[ "$file_url" == "$filename"_* ]]; then
            echo "Downloading $file_url"
            echo "from $base_url/$file_url"
            curl -Lo "packages/$file_url" "$base_url/$file_url"
            echo "[$filename] downloaded successfully!."
            echo ""
            break
        else
            echo "Failed to retrieve packages [$filename] because it's different from $base_url/$file_url. Retrying before exit..."
        fi
    done
done


# Download custom packages from github release api urls
if [ "$TYPE" == "AMLOGIC" ]; then
    echo "Adding [luci-app-amlogic] from bulider script type."
    files+=("luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases")
fi

files+=(
    #"luci-app-adguardhome|https://api.github.com/repos/GITHUBUSER/REPO-NAME/releases"
    "package-name|https://api.github.com/repos/kongfl888/luci-app-adguardhome/releases"
    "luci-app-sms-tool-js|https://api.github.com/repos/4IceG/luci-app-sms-tool-js/releases"
    "luci-app-modemband|https://api.github.com/repos/4IceG/luci-app-modemband/releases"
    "modemband|https://api.github.com/repos/4IceG/luci-app-modemband/releases"
    "luci-app-lite-watchdog|https://api.github.com/repos/4IceG/luci-app-lite-watchdog/releases"
    "luci-app-3ginfo-lite|https://api.github.com/repos/4IceG/luci-app-3ginfo-lite/releases"
    "luci-app-netmonitor|https://api.github.com/repos/rtaserver/rta-packages/releases"
    "luci-app-base64|https://api.github.com/repos/rtaserver/rta-packages/releases"
    "luci-theme-rta|https://api.github.com/repos/rtaserver/RTA-Theme-OpenWrt/releases"
    "luci-app-rtaconfig|https://api.github.com/repos/rtaserver/RTA-Theme-OpenWrt/releases"
    "luci-theme-alpha|https://api.github.com/repos/derisamedia/luci-theme-alpha/releases"
    "luci-app-alpha-config|https://api.github.com/repos/derisamedia/luci-theme-alpha/releases"
)

for entry in "${files[@]}"; do
    IFS="|" read -r filename base_url <<< "$entry"
    echo "Processing file: $filename"
    file_urls=$(curl -s "$base_url" | grep "browser_download_url" | grep -oE "https.*/$filename[0-9a-zA-Z\._~-]*\.ipk" | head -n 1)
    for file_url in "$file_urls"; do
        file_name=$(basename "$file_urls")
        if [[ "$file_name" == "$filename"_* ]]; then
            echo "Downloading $file_name"
            echo "from $file_url"
            curl -Lo "packages/$file_name" "$file_url"
            echo "[$filename] downloaded successfully!."
            echo ""
            break
        else
            echo "Failed to retrieve packages [$filename] because it's different from $file_url. Retrying before exit..."
        fi
    done
done


==============================================================================================================================================

# for testing download url before commiting
# remove comment# then copy to your terminal for testing it

# github release
#BRANCH="23.05.3"
#ARCH_3="x86_64"
#files=(
#    "luci-app-sms-tool-js|https://api.github.com/repos/4IceG/luci-app-sms-tool-js/releases"
#)
#
#IFS="|" read -r filename base_url <<< "$entry"
#file_urls=$(curl -s "$base_url" | grep "browser_download_url" | grep -oE "https.*/$filename[0-9a-zA-Z\._~-]*\.ipk" | head -n 1)
#file_name=$(basename "$file_urls")
#echo "file name: $filename"
#echo "remote file name: $file_name"
#echo "download url: $file_urls"

# official repo
#BRANCH="23.05.3"
#ARCH_3="x86_64"
#files=(
#    "sms-tool|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
#)
#
#IFS="|" read -r filename base_url <<< "$entry"
#file_urls=$(curl -sL "$base_url" | grep -oE "$filename[0-9a-zA-Z\._~-]*\.ipk" | head -n 1)
#file_name=$(basename "$file_urls")
#echo "file name: $filename"
#echo "remote file name: $file_urls"
#echo "download url: $base_url/$file_urls"
