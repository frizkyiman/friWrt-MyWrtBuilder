#!/bin/bash

echo "Start Builder Patch !"
echo "Current Path: $PWD"

cd $GITHUB_WORKSPACE/$WORKING_DIR || exit

branch_main=$( [ "$BRANCH" == "21.02.7" ] && echo "$BRANCH" | awk -F'.' '{print $1"."$2}' || echo "main" )
option_squashfs=$( [ "$ROOTFS_SQUASHFS" == "true" ] && echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" || echo "# CONFIG_TARGET_ROOTFS_SQUASHFS is not set" )

sed -i '\|option check_signature| s|^|#|' repositories.conf

# Patch ImageBuilder's Makefile to force-install local packages
sed -i '/$(OPKG) install $(BUILD_PACKAGES)/ {N;N;N;N;N;s/\($(OPKG) install $(BUILD_PACKAGES)\)/\1\n\t@echo\n\t@echo Force-reinstalling local packages\n\t$$(OPKG) install --force-reinstall --force-downgrade $$(wildcard $$(PACKAGE_DIR)\/\*.ipk)/}' Makefile

# Resize Boot and Rootfs partition size
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_SIZE/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=y/$option_squashfs/" .config
