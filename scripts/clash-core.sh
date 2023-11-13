#!/bin/bash

echo "Start Clash Core Download !"
echo "Current Path: $PWD"

mkdir -p files/etc/openclash/core
cd files/etc/openclash/core || { echo "Clash core path does not exist!"; exit 1; }

urls=(
  "https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.16.0/clash.meta-linux-arm64-v1.16.0.gz"
  "https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz"
  "https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-2023.08.17.gz"
)
targets=("clash_meta" "clash" "clash_tun")

extract_and_cleanup() {
  { tar -zxvf "$1" && rm -f "$1" && echo "Success using tar!"; } ||
  { gzip -d -c "$1" > "$2" && rm -f "$1" && echo "Success using gzip!"; } ||
  echo "Failed to extract $1"
}

for ((i=0; i<${#urls[@]}; i++)); do
  wget "${urls[i]}" && extract_and_cleanup "$(basename "${urls[i]}")" "${targets[i]}"
done


