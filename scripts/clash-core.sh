#!/bin/bash

echo "Current Path: $PWD"

echo "Start YACD Download !"
yacd="https://github.com/taamarin/yacd-meta/archive/gh-pages.zip"
mkdir -p files/usr/share/openclash/ui
wget --no-check-certificate -nv "$yacd" -O files/usr/share/openclash/ui/yacd.zip
unzip files/usr/share/openclash/ui/yacd.zip -d files/usr/share/openclash/ui
mv files/usr/share/openclash/ui/yacd-* /files/usr/share/openclash/ui/yacd.new
rm files/usr/share/openclash/ui/yacd.zip

echo "Start Clash Core Download !"
mkdir -p files/etc/openclash/core
cd files/etc/openclash/core || { echo "Clash core path does not exist!"; exit 1; }

urls=("https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.16.0/clash.meta-linux-arm64-v1.16.0.gz"
      "https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz"
      "https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz")
targets=("clash_meta" "clash_tun" "clash")

extract_and_cleanup() {
  local extracted_file=$(basename "$1") temp_dir=$(mktemp -d)

  if tar -zxf "$extracted_file" -C "$temp_dir" && mv "$temp_dir"/* "$2"; then
    echo "Success using tar!"
  elif gzip -dc "$extracted_file" > "$2"; then
    echo "Success using gzip!"
  else
    echo "Failed to extract $extracted_file"
  fi

  rm -f "$extracted_file" "$temp_dir"/*
}

for ((i=0; i<${#urls[@]}; i++)); do
  wget --no-check-certificate -nv "${urls[i]}" && extract_and_cleanup "${urls[i]}" "${targets[i]}" || echo "Failed to download ${urls[i]}"
done
