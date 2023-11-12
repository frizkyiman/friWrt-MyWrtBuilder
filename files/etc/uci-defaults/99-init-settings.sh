#!/bin/sh

# Set hostname and Timezone to Asia/Jakarta
uci set system.@system[0].hostname='friWrt'
uci set system.@system[0].timezone='WIB-7'
uci set system.@system[0].zonename='Asia/Jakarta'
uci commit system
/etc/init.d/system reload

#configure LAN
uci set network.lan.ipaddr="192.168.1.1"
uci commit network

#root_password="bluedragon12"
#if [ -n "$root_password" ]; then
#  (echo "$root_password"; sleep 1; echo "$root_password") | passwd > /dev/null
#fi

#configure wan interface
uci set network.wan=interface 
uci set network.wan.proto='modemmanager'
uci set network.wan.device='/sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb2/2-1'
uci set network.wan.apn='internet'
uci set network.wan.auth='none'
uci set network.wan.iptype='ipv4'
uci set network.@device[0].ipv6='0'
uci commit network
/etc/init.d/network reload

uci set firewall.@zone[1].network='wan'
uci commit firewall
/etc/init.d/firewall reload

uci set network.lan.ipv6=0
uci set dhcp.lan.dhcpv6=disabled
uci commit
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci commit dhcp
/etc/init.d/odhcpd reload
uci set network.lan.delegate="0"
uci commit network
/etc/init.d/network restart
#/etc/init.d/odhcpd restart
#/etc/init.d/odhcpd disable

#configure WLAN
uci set wireless.@wifi-device[0].disabled='0'
#uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.@wifi-iface[0].ssid='friWrt_5g'
#uci set wireless.@wifi-iface[0].key='bluedragon12'
uci set wireless.@wifi-device[0].country='ID'
uci set wireless.radio0.channel='161'
uci commit wireless
/etc/init.d/wireless restart

# custom repo and Disable opkg signature check
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
echo "src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/main/generic" >> /etc/opkg/customfeeds.conf
echo "src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/main/$(cat /etc/os-release | grep OPENWRT_ARCH | awk -F '"' '{print $2}')" >> /etc/opkg/customfeeds.conf

cat <<'EOF' >/etc/opkg/distfeeds.conf
src/gz immortalwrt_core https://downloads.immortalwrt.org/releases/21.02.7/targets/bcm27xx/bcm2711/packages
src/gz immortalwrt_base https://downloads.immortalwrt.org/releases/21.02.7/packages/aarch64_cortex-a72/base
src/gz immortalwrt_luci https://downloads.immortalwrt.org/releases/21.02.7/packages/aarch64_cortex-a72/luci
src/gz immortalwrt_packages https://downloads.immortalwrt.org/releases/21.02.7/packages/aarch64_cortex-a72/packages
src/gz immortalwrt_routing https://downloads.immortalwrt.org/releases/21.02.7/packages/aarch64_cortex-a72/routing
src/gz immortalwrt_telephony https://downloads.immortalwrt.org/releases/21.02.7/packages/aarch64_cortex-a72/telephony
EOF

# remove huawei me909s usb-modeswitch
sed -i -e '/12d1:15c1/,+5d' /etc/usb-mode.json

# remove dw5821e usb-modeswitch
sed -i -e '/413c:81d7/,+5d' /etc/usb-mode.json

# Disable /etc/config/xmm-modem
uci set xmm-modem.@xmm-modem[0].enable='0'
uci commit

# add cron job for modem rakitan
echo '#auto renew ip lease for modem rakitan' >> /etc/crontabs/root
echo '30 3 * * 1,2,3,4,5,6 echo  AT+CFUN=4 | atinout - /dev/ttyUSB0 - && sleep 3 && ifdown wan && sleep 3 && echo  AT+CFUN=1 | atinout - /dev/ttyUSB0 - && sleep 3 && ifup wan' >> /etc/crontabs/root
echo '#auto restart for modem rakitan once a week'  >> /etc/crontabs/root
echo '30 3 * * 0 echo  AT^RESET | atinout - /dev/ttyUSB0 - && sleep 20 && ifdown wan && ifup wan'  >> /etc/crontabs/root

# Remove watchcat default config
uci delete watchcat.@watchcat[0]
uci commit

#setting firewall samba4
uci -q delete firewall.samba_nsds_nt
uci set firewall.samba_nsds_nt="rule"
uci set firewall.samba_nsds_nt.name="NoTrack-Samba/NS/DS"
uci set firewall.samba_nsds_nt.src="lan"
uci set firewall.samba_nsds_nt.dest="lan"
uci set firewall.samba_nsds_nt.dest_port="137-138"
uci set firewall.samba_nsds_nt.proto="udp"
uci set firewall.samba_nsds_nt.target="NOTRACK"
uci -q delete firewall.samba_ss_nt
uci set firewall.samba_ss_nt="rule"
uci set firewall.samba_ss_nt.name="NoTrack-Samba/SS"
uci set firewall.samba_ss_nt.src="lan"
uci set firewall.samba_ss_nt.dest="lan"
uci set firewall.samba_ss_nt.dest_port="139"
uci set firewall.samba_ss_nt.proto="tcp"
uci set firewall.samba_ss_nt.target="NOTRACK"
uci -q delete firewall.samba_smb_nt
uci set firewall.samba_smb_nt="rule"
uci set firewall.samba_smb_nt.name="NoTrack-Samba/SMB"
uci set firewall.samba_smb_nt.src="lan"
uci set firewall.samba_smb_nt.dest="lan"
uci set firewall.samba_smb_nt.dest_port="445"
uci set firewall.samba_smb_nt.proto="tcp"
uci set firewall.samba_smb_nt.target="NOTRACK"
uci commit firewall
/etc/init.d/firewall restart

#samba setting
cat <<'EOF' >/etc/config/samba4
config samba
	option workgroup 'WORKGROUP'
	option charset 'UTF-8'
	option description 'Samba on OpenWRT'

config sambashare
	option name 'NAS-STORAGE'
	option path '/mnt/sda1'
	option read_only 'no'
	option guest_ok 'yes'
	option create_mask '0777'
	option dir_mask '0777'
EOF
uci commit samba4
service samba4 restart

#aria setting
uci set aria2.main=aria2
uci set aria2.main.bt_enable_lpd='true'
uci set aria2.main.enable_dht='true'
uci set aria2.main.follow_torrent='true'
uci set aria2.main.file_allocation='none'
uci set aria2.main.save_session_interval='30'
uci set aria2.main.user='root'
uci set aria2.main.dir='/mnt/sda1/download'
uci set aria2.main.config_dir='/etc/aria2'
uci set aria2.main.rpc_auth_method='none'
uci set aria2.main.rpc_secure='false'
uci set aria2.main.enable_proxy='0'
uci set aria2.main.check_certificate='false'
uci set aria2.main.http_accept_gzip='true'
uci set aria2.main.max_connection_per_server='8'
uci set aria2.main.split='8'
uci set aria2.main.enable_dht6='false'
uci set aria2.main.enable_peer_exchange='true'
uci set aria2.main.disable_ipv6='true'
uci set aria2.main.enabled='1'
uci set aria2.main.enable_logging='1'
uci set aria2.main.log='/var/log/aria2.log'
uci set aria2.main.log_level='info'
uci commit aria2
service aria2 restart

uci set ttyd.@ttyd[0].command='/bin/bash --login'
uci commit

sed -i 's/services/nas/g' /usr/lib/lua/luci/controller/aria2.lua
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-samba4.json
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-hd-idle.json
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-disks-info.json
sed -i 's/services/status/g' /usr/share/luci/menu.d/luci-app-log.json

chmod +x /sbin/sync_time.sh
chmod +x /sbin/free.sh
chmod +x /usr/bin/patchoc.sh
chmod +x /usr/bin/neofetch
chmod +x /usr/bin/clock
chmod +x /usr/bin/repair_ro
chmod +x /usr/bin/mount_hdd

#uci set hd-idle.@hd-idle[0].enabled='1'

sed -i '/exit 0/i /usr/bin/patchoc.sh' /etc/rc.local

sed -i 's/\[ -f \/etc\/banner \] && cat \/etc\/banner/#&/' /etc/profile
sed -i 's/\[ -n "$FAILSAFE" \] && cat \/etc\/banner.failsafe/& || \/usr\/bin\/neofetch/' /etc/profile

echo '*/15 * * * * /sbin/free.sh' >> /etc/crontabs/root
echo '0 12 * * * /sbin/sync_time.sh beacon.liveon.id' >> /etc/crontabs/root
/etc/init.d/cron restart

tar -xzvf /root/speedtest.tgz -C /usr/bin/
chmod +x /usr/bin/speedtest
rm /root/speedtest.tgz

unzip /root/yacd-gh-pages.zip -d /usr/share/openclash/ui
mv /usr/share/openclash/ui/yacd /usr/share/openclash/ui/yacd.old && mv /usr/share/openclash/ui/yacd-gh-pages /usr/share/openclash/ui/yacd
rm /root/yacd-gh-pages.zip

echo -e "\ndtparam=i2c1=on\ndtparam=spi=on\ndtparam=i2s=on" >> /boot/config.txt

uci set nlbwmon.@nlbwmon[0].database_directory='/etc/nlbwmon'
uci set nlbwmon.@nlbwmon[0].commit_interval='3h'
uci set nlbwmon.@nlbwmon[0].refresh_interval='60s'
uci commit nlbwmon

cat <<'EOF' >/etc/vnstat.conf
# vnStat 1.18 config file
##

# default interface
Interface "eth0"

# location of the database directory
DatabaseDir "/etc/vnstat"

# locale (LC_ALL) ("-" = use system locale)
Locale "-"

# on which day should months change
MonthRotate 1

# date output formats for -d, -m, -t and -w
# see 'man date' for control codes
DayFormat    "%x"
MonthFormat  "%b '%y"
TopFormat    "%x"

# characters used for visuals
RXCharacter       "%"
TXCharacter       ":"
RXHourCharacter   "r"
TXHourCharacter   "t"

# how units are prefixed when traffic is shown
# 0 = IEC standard prefixes (KiB/MiB/GiB/TiB)
# 1 = old style binary prefixes (KB/MB/GB/TB)
UnitMode 0

# how units are prefixed when traffic rate is shown
# 0 = IEC binary prefixes (Kibit/s...)
# 1 = SI decimal prefixes (kbit/s...)
RateUnitMode 1

# output style
# 0 = minimal & narrow, 1 = bar column visible
# 2 = same as 1 except rate in summary and weekly
# 3 = rate column visible
OutputStyle 3

# used rate unit (0 = bytes, 1 = bits)
RateUnit 1

# number of decimals to use in outputs
DefaultDecimals 2
HourlyDecimals 1

# spacer for separating hourly sections (0 = none, 1 = '|', 2 = '][', 3 = '[ ]')
HourlySectionStyle 2

# try to detect interface maximum bandwidth, 0 = disable feature
# MaxBandwidth will be used as fallback value when enabled
BandwidthDetection 1

# maximum bandwidth (Mbit) for all interfaces, 0 = disable feature
# (unless interface specific limit is given)
MaxBandwidth 1000

# interface specific limits
#  example 8Mbit limit for 'ethnone':
MaxBWethnone 8

# how many seconds should sampling for -tr take by default
Sampletime 5

# default query mode
# 0 = normal, 1 = days, 2 = months, 3 = top10
# 4 = exportdb, 5 = short, 6 = weeks, 7 = hours
QueryMode 0

# filesystem disk space check (1 = enabled, 0 = disabled)
CheckDiskSpace 1

# database file locking (1 = enabled, 0 = disabled)
UseFileLocking 1

# how much the boot time can variate between updates (seconds)
BootVariation 15

# log days without traffic to daily list (1 = enabled, 0 = disabled)
TrafficlessDays 1


# vnstatd
##

# switch to given user when started as root (leave empty to disable)
DaemonUser ""

# switch to given user when started as root (leave empty to disable)
DaemonGroup ""

# how many minutes to wait during daemon startup for system clock to
# sync time if most recent database update appears to be in the future
TimeSyncWait 5

# how often (in seconds) interface data is updated
UpdateInterval 60

# how often (in seconds) interface status changes are checked
PollInterval 30

# how often (in minutes) data is saved to file
SaveInterval 30

# how often (in minutes) data is saved when all interface are offline
OfflineSaveInterval 30

# how often (in minutes) bandwidth detection is redone when
# BandwidthDetection is enabled (0 = disabled)
BandwidthDetectionInterval 5

# force data save when interface status changes (1 = enabled, 0 = disabled)
SaveOnStatusChange 1

# enable / disable logging (0 = disabled, 1 = logfile, 2 = syslog)
UseLogging 2

# create dirs if needed (1 = enabled, 0 = disabled)
CreateDirs 1

# update ownership of files if needed (1 = enabled, 0 = disabled)
UpdateFileOwner 1

# file used for logging if UseLogging is set to 1
LogFile "/var/log/vnstat/vnstat.log"

# file used as daemon pid / lock file
PidFile "/var/run/vnstat/vnstat.pid"


# vnstati
##

# title timestamp format
HeaderFormat "%x %H:%M"

# show hours with rate (1 = enabled, 0 = disabled)
HourlyRate 1

# show rate in summary (1 = enabled, 0 = disabled)
SummaryRate 1

# layout of summary (1 = with monthly, 0 = without monthly)
SummaryLayout 1

# transparent background (1 = enabled, 0 = disabled)
TransparentBg 0

# image colors
CBackground     "FFFFFF"
CEdge           "AEAEAE"
CHeader         "606060"
CHeaderTitle    "FFFFFF"
CHeaderDate     "FFFFFF"
CText           "000000"
CLine           "B0B0B0"
CLineL          "-"
CRx             "92CF00"
CTx             "606060"
CRxD            "-"
CTxD            "-"
EOF

chmod +x /etc/vnstat.conf

cat <<'EOF' >/etc/config/vnstat
config vnstat
	list interface 'br-lan'
	list interface 'wwan0'
EOF

cat <<'EOF' >/etc/config/atcmds.user
AT Check;AT
Modem Info;ATI
Debug Info;ATI^DEBUG?
Restart Modem;AT^RESET
Airplane Mode On;AT+CFUN=4
Airplane Mode Off;AT+CFUN=1
Check IMSI SIM;AT+CIMI
Check IMEI;AT+GSN
Enable Carrier Aggregation;AT^CA_ENABLE=0
Disable Carrier Aggregation;AT^CA_ENABLE=1
Check band Carrier Aggregation;AT^CA_INFO?
Check signal band neighbour;AT+VZWRSRP?
Set WCDMA only;AT^SLMODE=1,14
Set LTE only;AT^SLMODE=1,30
Set WCDMA & LTE;AT^SLMODE=1,35
Check USB mode USB 2.0/USB 3.0;AT^USBTYPE
Check modem CAT;AT^GETLTECAT?
Disable GPS;AT+GPS=0
Volt Check;AT+VOLT?
Temp Check;AT^TEMP?
Check Lock Band;AT^SLBAND?
Reset Lock Band;AT^SLBAND
Lock Band B1;AT^SLBAND=LTE,2,1
Lock Band B3;AT^SLBAND=LTE,2,3
Lock Band B8;AT^SLBAND=LTE,2,8
Lock Band B40;AT^SLBAND=LTE,2,40
Lock Band B1 & B3;AT^SLBAND=LTE,2,1,3
Lock Band B1, B3 & B40;AT^SLBAND=LTE,2,1,3,40
EOF

reboot

exit 0
