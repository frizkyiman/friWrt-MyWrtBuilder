#!/bin/bash

echo "Start AdGuardHome Core Download !"
echo "Current Path: $PWD"

agh_api="https://api.github.com/repos/AdguardTeam/AdGuardHome/releases" 
agh_file="AdGuardHome_linux_$ARCH_1"
agh_file_down="$(curl -s ${agh_api}/latest | grep "browser_download_url" | grep -oE "https.*${agh_file}.*.tar.gz" | head -n 1)"
latest_version=$(curl -sSL "$agh_api/latest" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)

if wget -nv "$agh_file_down" -P files/opt; then
  echo "Extracting core"
  if tar -zxvf files/opt/AdGuardHome_linux_"$ARCH_1".tar.gz -C files/opt; then
    rm files/opt/AdGuardHome_linux_"$ARCH_1".tar.gz
    echo "Done! Installed AdGuardHome version $latest_version"
  else
    echo "Error: Failed to extract AdGuardHome."
  fi
else
  echo "Error: Failed to download AdGuardHome."
fi
