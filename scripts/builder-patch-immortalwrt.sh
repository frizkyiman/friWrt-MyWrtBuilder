#!/bin/bash

echo "Start Builder Patch !"
echo "Current Path: $PWD"

cd $GITHUB_WORKSPACE/$WORKING_DIR || exit

branch_main=$( [ "$BRANCH" == "21.02.7" ] && echo "$BRANCH" | awk -F'.' '{print $1"."$2}' || echo "main" )
option_squashfs=$( [ "$ROOTFS_SQUASHFS" == "true" ] && echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" || echo "# CONFIG_TARGET_ROOTFS_SQUASHFS is not set" )

# Custom Repository
#sed -i "13i\src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/generic" repositories.conf
#sed -i "14i\src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/$branch_main/$ARCH" repositories.conf
sed -i '\|option check_signature| s|^|#|' repositories.conf

# Force opkg to overwrite files
#sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite/" Makefile

# Resize Boot and Rootfs partition size
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_SIZE/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=y/$option_squashfs/" .config
