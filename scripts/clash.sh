#!/bin/bash

echo "Start Clash Core Download !"
echo "Current Path: $PWD"

download_url="https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.16.0/clash.meta-linux-arm64-v1.16.0.gz"
file="clash.meta-linux-arm64-v1.16.0.gz"

mkdir -p files/etc/openclash/core
cd files/etc/openclash/core || (echo "Clash core path does not exist! " && exit)
wget -q $download_url
{ tar -zxvf "$file" && echo "Success using tar!"; } ||
{ gzip -d "$file" && echo "Success using gzip!"; } ||
echo "Failed to extract file!";
rm -rf "$file"
