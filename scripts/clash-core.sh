#!/bin/bash

echo "Current Path: $PWD"

echo "Start YACD Download !"

if [ -d files/usr/share/openclash/ui ]; then
   yacd="https://github.com/taamarin/yacd-meta/archive/gh-pages.zip"
   mkdir -p files/usr/share/openclash/ui
   if wget --no-check-certificate -nv $yacd -O files/usr/share/openclash/ui/yacd.zip; then
      unzip files/usr/share/openclash/ui/yacd.zip -d files/usr/share/openclash/ui && rm files/usr/share/openclash/ui/yacd.zip
      mv files/usr/share/openclash/ui/yacd* files/usr/share/openclash/ui/yacd.new
      echo "YACD Dashboard download successfully."
   else
      echo "Failed to download YACD Dashboard"
   fi
fi

echo "Start Clash Core Download !"
#core download url
clash="https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-$ARCH.tar.gz"
clash_meta="https://github.com/MetaCubeX/mihomo/releases/download/$(curl -sSL "https://github.com/MetaCubeX/mihomo/releases/latest" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)/mihomo-linux-$ARCH-$(curl -sSL "https://github.com/MetaCubeX/mihomo/releases/latest" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1).gz"
clash_tun="https://github.com/vernesong/OpenClash/raw/core/master/premium/$(curl -s "https://github.com/vernesong/OpenClash/tree/core/master/premium" | grep -o "clash-linux-$ARCH-[0-9]*\.[0-9]*\.[0-9]*-[0-9]*-[a-zA-Z0-9]*\.gz" | awk 'NR==1 {print $1}')"

if [ -d files/etc/openclash/core ]; then
   mkdir -p files/etc/openclash/core
   cd files/etc/openclash/core || { echo "Clash core path does not exist!"; exit 1; }

   echo "Downloading clash.tar.gz..."
   if wget --no-check-certificate -nv -O clash.tar.gz $clash; then
      tar -zxf clash.tar.gz
      rm clash.tar.gz
      echo "clash.tar.gz downloaded and extracted successfully."
   else
      echo "Failed to download clash.tar.gz."
   fi
   
   echo "Downloading clash_meta.gz..."
   if wget --no-check-certificate -nv -O clash_meta.gz $clash_meta; then
      gzip -d clash_meta.gz
      echo "clash_meta.gz downloaded successfully."
   else
      echo "Failed to download clash_meta.gz."
   fi
   
   echo "Downloading clash_tun.gz..."
   if wget --no-check-certificate -nv -O clash_tun.gz $clash_tun; then
      gzip -d clash_tun.gz
      echo "clash_tun.gz downloaded successfully."
   else
      echo "Failed to download clash_tun.gz."
   fi
fi
echo "All Core Downloaded succesfully"
