#!/bin/bash

echo "Start Download Amlogic Service !"
echo "Current Path: $PWD"

cd packages

# Download luci-app-amlogic
amlogic_api="https://api.github.com/repos/ophub/luci-app-amlogic/releases"
amlogic_file="luci-app-amlogic"
amlogic_file_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_name}.*.ipk" | head -n 1)"

curl -fsSOJL ${amlogic_file_down}
