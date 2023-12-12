#!/bin/bash

echo "Start AdGuardHome Core Download !"
echo "Current Path: $PWD"

agh_api="https://api.github.com/repos/AdguardTeam/AdGuardHome/releases" 
agh_file="AdGuardHome_linux_$ARCH"
agh_file_down="$(curl -s ${agh_api} | grep "browser_download_url" | grep -oE "https.*${agh_file}.*.tar.gz" | head -n 1)"
latest_version=$(curl -sSL "$agh_api/latest" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)

cd files/opt || { echo "AdGuardHome core path does not exist!"; exit 1; }

if wget -nv "$agh_file_down"; then
  echo "extracting core"
  tar -zxf "AdGuardHome_linux_$ARCH.tar.gz" && rm "AdGuardHome_linux_$ARCH.tar.gz"
  echo "Done! installed AdGuardHome version $latest_version"
fi
