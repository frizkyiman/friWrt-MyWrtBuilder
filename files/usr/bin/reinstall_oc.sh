#!/bin/bash

INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"

openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s "${openclash_api}" | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"
patchoc="https://raw.githubusercontent.com/frizkyiman/friWrt-MyWrtBuilder/main/files/usr/bin/patchoc.sh"

echo -e "${INFO} Start downloading [ ${openclash_file} ]."
if wget -q -N -P /root "${openclash_file_down}" && wget -q -N -P /usr/bin "$patchoc"; then
  echo -e "${SUCCESS} The [ $(basename "${openclash_file_down}") ] is downloaded successfully."
  echo -e "${INFO} Start installing [ ${openclash_file} ]"
  if opkg update && opkg install /root/*openclash*.ipk --force-reinstall; then
    echo -e "${INFO} Start applying patch for [ ${openclash_file} ]."
    chmod +x /usr/bin/patchoc.sh && /usr/bin/patchoc.sh
    [ "${?}" -eq "0" ] && echo -e "${SUCCESS} Openclash successfully installed and patched." || echo -e "${ERROR} Failed to apply patch! Check for errors during patching."
  else
    echo -e "${ERROR} Failed to install [ ${openclash_file} ]! Check for errors during installation."
  fi
  rm /root/*openclash*.ipk
else
  echo -e "${ERROR} [ ${openclash_file} ] download failed! Make sure the connection is accessible."
fi
