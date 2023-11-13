#!/bin/bash

echo "Start Builder Patch !"
echo "Current Path: $PWD"

if [ "$BRANCH" == "snapshots" ]; then
    cd $GITHUB_WORKSPACE/$BASE-imagebuilder-bcm27xx-bcm2711.Linux-x86_64 || exit
else
    cd $GITHUB_WORKSPACE/$BASE-imagebuilder-$BRANCH-bcm27xx-bcm2711.Linux-x86_64 || exit
fi

version=$(echo "$BRANCH" | cut -d'.' -f1)

if [ "$version" == "21" ]; then
    branch_main=$(echo "$BRANCH" | awk -F'.' '{print $1"."$2}')
elif [ "$version" == "22" ] || [ "$version" == "23" ] || [ "$BRANCH" == "snapshots" ]; then
    branch_main=main
fi

if [ "$ROOTFS_SQUASHFS" == "true" ]; then
    option_squashfs="CONFIG_TARGET_ROOTFS_SQUASHFS=y"
else
    option_squashfs="# CONFIG_TARGET_ROOTFS_SQUASHFS is not set"
fi

# Remove redundant default packages
sed -i "/luci-app-cpufreq/d" include/target.mk

# Custom Repository
sed -i "13i\src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/generic" repositories.conf
sed -i "14i\src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/aarch64_cortex-a72" repositories.conf
sed -i "s/option check_signature/# option check_signature/g" repositories.conf

# Force opkg to overwrite files
#sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite/" Makefile

# Resize Boot and Rootfs partition size
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_SIZE/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=y/$option_squashfs/" .config
sed -i "s/CONFIG_PACKAGE_kmod-rtl8821cu=m/CONFIG_PACKAGE_kmod-rtl8821cu=y/" .config
