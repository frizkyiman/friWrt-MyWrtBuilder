#!/bin/bash

if [ "$TUNNEL" == "openclash" ]; then
    echo "Downloading Openclash packages"
    openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
    openclash_file="luci-app-openclash"
    openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"
    wget ${openclash_file_down} -nv -P packages
elif [ "$TUNNEL" == "passwall" ]; then
    echo "Downloading Passwall packages"
    wget https://github.com/xiaorouji/openwrt-passwall/releases/download/4.71-2/passwall_packages_ipk_$ARCH_3.zip -nv -P packages
    unzip -qq packages/passwall_packages_ipk_$ARCH_3.zip -d packages && rm packages/passwall_packages_ipk_$ARCH_3.zip
elif [ "$TUNNEL" == "openclash_passwall" ]; then
    echo "Installing Openclash and Passwall"
    echo "Downloading Openclash packages"
    openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
    openclash_file="luci-app-openclash"
    openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"
    wget ${openclash_file_down} -nv -P packages
	  echo "Downloading Passwall packages"
    wget https://github.com/xiaorouji/openwrt-passwall/releases/download/4.71-2/passwall_packages_ipk_$ARCH_3.zip -nv -P packages
    unzip -qq packages/passwall_packages_ipk_$ARCH_3.zip -d packages && rm packages/passwall_packages_ipk_$ARCH_3.zip
fi 
echo "Done!"
