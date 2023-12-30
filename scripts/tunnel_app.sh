#!/bin/bash

openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"
passwall_packages="https://github.com/xiaorouji/openwrt-passwall/releases/download/4.71-2/passwall_packages_ipk_$ARCH_3.zip"
passwall_packages_file="passwall_packages_ipk_$ARCH_3.zip"

if [ "$TUNNEL" == "openclash" ]; then
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
elif [ "$TUNNEL" == "passwall" ]; then
    echo "Downloading Passwall packages"
    wget "$passwall_packages" -nv -P packages
    unzip -qq packages/"$passwall_packages_file" -d packages && rm packages/"$passwall_packages_file"
elif [ "$TUNNEL" == "openclash-passwall" ]; then
    echo "Installing Openclash and Passwall"
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
    echo "Downloading Passwall packages"
    wget "$passwall_packages" -nv -P packages
    unzip -qq packages/"$passwall_packages_file" -d packages && rm packages/"$passwall_packages_file"
fi 
if [ "$?" -ne 0 ]; then
    echo "Error: Download or extraction failed."
    exit 1
fi
echo "Done!"
