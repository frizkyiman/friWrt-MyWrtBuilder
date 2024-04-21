#!/bin/sh
# Created by Frizkyiman
# Github https://github.com/frizkyiman/

modem_info=$(mmcli -L | awk -F']' '/Modem/{print $2}' | sed 's/^[ \t]*//')
modem_id=$(mmcli -L | awk -F'/Modem/' 'NF>1{print $2; exit}' | awk '{print $1}')
sms_list=$(mmcli -m "$modem_id" --messaging-list-sms)
sms_ids=$(echo "$sms_list" | awk -F'/SMS/' 'NF>1{print $2}' | awk '{print $1}')

if [ -n "$sms_ids" ]; then
    echo "SMS received from modem: $modem_info"
    mmcli -m "$modem_id" --messaging-status
    for sms_id in $sms_ids; do
        mmcli -m "$modem_id" --sms "$sms_id" | tee -a /root/sms_message.log
        echo "  -----------------------"  | tee -a /root/sms_message.log
    done
else
    echo "No sms messages were found from modem: $modem_info"
fi
