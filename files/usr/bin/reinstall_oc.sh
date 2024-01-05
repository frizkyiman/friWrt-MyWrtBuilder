#!/bin/bash

INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"
openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"
patchoc="https://raw.githubusercontent.com/frizkyiman/friWrt-MyWrtBuilder/main/files/usr/bin/patchoc.sh"

echo -e "${INFO} Start downloading [ ${openclash_file} ]."
if wget ${openclash_file_down} -q -P /root; then
  echo -e "${SUCCESS} The [ $(basename "${openclash_file_down}") ] is downloaded successfully."
  echo -e "${INFO} Start installing [ ${openclash_file} ]"
  opkg update && opkg install /root/*openclash*.ipk --force-reinstall
  rm /root/*openclash*.ipk
  if wget "$patchoc" -q -N -P /usr/bin; then
    echo -e "${INFO} Start apply patch for [ ${openclash_file} ]."
    chmod +x /usr/bin/patchoc.sh && patchoc.sh
  else
    echo -e "${ERROR} Patch download failed!"
  fi
  echo -e "${SUCCESS} Openclash successfully installed and patched."
else
  echo -e "${ERROR} [ ${openclash_file} ] download failed!"
fi
