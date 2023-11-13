#!/bin/bash

echo "Start Clash Core Download !"
echo "Current Path: $PWD"

meta_core="https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.16.0/clash.meta-linux-arm64-v1.16.0.gz"
clash_core="https://github.com/vernesong/OpenClash/blob/core/master/dev/clash-linux-arm64.tar.gz"
clash_tun_core="https://github.com/vernesong/OpenClash/blob/core/master/premium/clash-linux-arm64-2023.08.17.gz"
file="*-arm64-*.gz"

mkdir -p files/etc/openclash/core
cd files/etc/openclash/core || { echo "Clash core path does not exist!"; exit 1; }
wget -q "$meta_core" "$clash_core" "$clash_tun_core"

{ tar -zxvf "$file" && echo "Success using tar!"; } ||
{ gzip -d "$file" && echo "Success using gzip!"; } ||
echo "Failed to extract file!"

rm -rf "$file"
