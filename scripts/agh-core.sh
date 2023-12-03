#!/bin/bash

echo "Start AdGuardHome Core Download !"
echo "Current Path: $PWD"

ARCHHH=$( [ "$TARGET" == "rpi-4" ] && echo "arm64" || echo "amd64" )

cd files/opt/AdGuardHome || { echo "AdGuardHome core path does not exist!"; exit 1; }
wget -nv https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.41/AdGuardHome_linux_$ARCHHH.tar.gz
tar -zxf AdGuardHome_linux_$ARCHHH.tar.gz && rm files/opt/AdGuardHome/AdGuardHome_linux_$ARCHHH.tar.gz
