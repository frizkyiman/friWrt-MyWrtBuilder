#!/bin/bash

echo "Start AdGuardHome Core Download !"
echo "Current Path: $PWD"

if [ ! -d "files/opt/AdGuardHome" ]; then
        echo "Creating AdGuardHome Directory!"
        mkdir -p files/opt/AdGuardHome
else
        echo "AdGuardHome core path does not exist!"
fi

cd files/opt/AdGuardHome || { echo "AdGuardHome core path does not exist!"; exit 1; }
wget -nv https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.41/AdGuardHome_linux_arm64.tar.gz
tar -zxf AdGuardHome_linux_arm64.tar.gz

echo "Configuring AdGuardHome"
cd $GITHUB_WORKSPACE/$WORKING_DIR
mv files/AdGuardHome.yaml files/opt/AdGuardHome/AdGuardHome.yaml
