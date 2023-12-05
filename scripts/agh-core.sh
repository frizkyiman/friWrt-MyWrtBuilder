#!/bin/bash

echo "Start AdGuardHome Core Download !"
echo "Current Path: $PWD"

ARCHHH=$( [ "$TARGET" == "rpi-4" ] && echo "arm64" || echo "amd64" )
repo_url="https://github.com/AdguardTeam/AdGuardHome/releases"
latest_version=$(curl -sSL "$repo_url/latest" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)
url="$repo_url/download/$latest_version/AdGuardHome_linux_$ARCHHH.tar.gz"

cd files/opt || { echo "AdGuardHome core path does not exist!"; exit 1; }

if wget -nv "$url"; then
  echo "extracting core"
  tar -zxf "AdGuardHome_linux_$ARCHHH.tar.gz" && rm "AdGuardHome_linux_$ARCHHH.tar.gz"
  echo "Done! AdGuardHome version $latest_version"
fi
