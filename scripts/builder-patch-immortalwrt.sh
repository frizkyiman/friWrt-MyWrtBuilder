#!/bin/bash

echo "Start Builder Patch !"
echo "Current Path: $PWD"

cd $GITHUB_WORKSPACE/$WORKING_DIR || exit
mv files-$BASE/* files
mv packages-$BASE/* packages

version=$(echo "$BRANCH" | cut -d'.' -f1)
branch_main=$( [ "$version" == "21" ] && echo "$BRANCH" | awk -F'.' '{print $1"."$2}' || echo "main" )
option_squashfs=$( [ $ROOTFS_SQUASHFS" == "true" ] && echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" || echo "# CONFIG_TARGET_ROOTFS_SQUASHFS is not set" )

# custom repo and Disable opkg signature check
sed -i "43i\sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf" /files-openwrt/etc/uci-defaults/99-init-settings.sh
sed -i "44i\echo "src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/generic" >> /etc/opkg/customfeeds.conf" /files/etc/uci-defaults/99-init-settings.sh
sed -i "45i\echo "src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/$(cat /etc/os-release | grep OPENWRT_ARCH | awk -F '"' '{print $2}')" >> /etc/opkg/customfeeds.conf" /files/etc/uci-defaults/99-init-settings.sh

# Custom Repository
sed -i "13i\src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/generic" repositories.conf
sed -i "14i\src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/$ARCH" repositories.conf
sed -i "s/option check_signature/# option check_signature/g" repositories.conf

# Force opkg to overwrite files
#sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite/" Makefile

# Resize Boot and Rootfs partition size
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_SIZE/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=y/$option_squashfs/" .config
