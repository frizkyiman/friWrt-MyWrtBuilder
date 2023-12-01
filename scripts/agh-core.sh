#!/bin/bash

echo "Start AdGuardHome Core Download !"
echo "Current Path: $PWD"

branch_tag=$( [ "$BRANCH" == "21.02.7" ] && echo -"$BRANCH" | awk -F'.' '{print $1"."$2}' )
if [ ! -d "files/"$BASE""$branch_tag"/opt/AdGuardHome" ]; then
        echo "AdGuardHome core path does not exist!"
        mkdir -p files/"$BASE""$branch_tag"/opt/AdGuardHome
fi

cd files/"$BASE""$branch_tag"/opt/AdGuardHome || { echo "AdGuardHome core path does not exist!"; exit 1; }
wget -q https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.41/AdGuardHome_linux_arm64.tar.gz
tar -zxf AdGuardHome_linux_arm64.tar.gz

echo "Configuring AdGuardHome"
cp scripts/AdGuardHome.yaml files/"$BASE""$branch_tag"/opt/AdGuardHome/AdGuardHome.yaml
