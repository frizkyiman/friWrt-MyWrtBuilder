#!/bin/bash

echo "Start Builder Patch !"
echo "Current Path: $PWD"

cd $GITHUB_WORKSPACE/$WORKING_DIR || exit

# No signature check packages
sed -i '\|option check_signature| s|^|#|' repositories.conf

echo "Patching Makefile"
# Force opkg to overwrite files
sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite --force-downgrade/" Makefile

# Resize Boot and Rootfs partition size
option_squashfs=$( [ "$ROOTFS_SQUASHFS" == "true" ] && echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" || echo "# CONFIG_TARGET_ROOTFS_SQUASHFS is not set" )
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_SIZE/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=y/$option_squashfs/" .config

# Not generate ISO images for it is too big
if [[ "$TARGET" == "x86-64" ]]; then
sed -i "s/CONFIG_ISO_IMAGES=y/# CONFIG_ISO_IMAGES is not set/" .config
# Not generate VHDX images
sed -i "s/CONFIG_VHDX_IMAGES=y/# CONFIG_VHDX_IMAGES is not set/" .config
fi
echo "Done!"
