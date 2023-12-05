#!/bin/bash

echo "Current Path: $PWD"

echo "Start YACD Download !"
if [ -d files/usr/share/openclash/ui ]; then
   mkdir -p files/usr/share/openclash/ui
   if wget --no-check-certificate -nv https://github.com/taamarin/yacd-meta/archive/gh-pages.zip -O files/usr/share/openclash/ui/yacd.zip; then
      unzip -qq files/usr/share/openclash/ui/yacd.zip -d files/usr/share/openclash/ui
      mv files/usr/share/openclash/ui/yacd-* files/usr/share/openclash/ui/yacd.new
      rm files/usr/share/openclash/ui/yacd.zip
   fi
fi


echo "Start Clash Core Download !"
if [ -d files/etc/openclash/core ]; then
   mkdir -p files/etc/openclash/core
   cd files/etc/openclash/core || { echo "Clash core path does not exist!"; exit 1; }

   echo "Downloading clash_meta.gz..."
   if wget -nv -O clash_meta.gz https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.16.0/clash.meta-linux-arm64-v1.16.0.gz; then
      gzip -d clash_meta.gz
      echo "clash_meta.gz downloaded successfully."
   else
      echo "Failed to download clash_meta.gz."
   fi

   echo "Downloading clash_tun.gz..."
   if wget -nv -O clash_tun.gz https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz; then
      gzip -d clash_tun.gz
      echo "clash_tun.gz downloaded successfully."
   else
      echo "Failed to download clash_tun.gz."
   fi

   echo "Downloading clash.tar.gz..."
   if wget -nv -O clash.tar.gz https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz; then
      tar -zxf clash.tar.gz
      rm clash.tar.gz
      echo "clash.tar.gz downloaded and extracted successfully."
   else
      echo "Failed to download clash.tar.gz."
   fi
fi
echo "All Core Downloaded succesfully"
