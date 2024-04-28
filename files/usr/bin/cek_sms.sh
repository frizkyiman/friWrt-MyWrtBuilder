#!/bin/sh
# Created by Frizkyiman
# Github https://github.com/frizkyiman/

modem_info=$(mmcli -L | awk -F']' '/Modem/{print $2}' | sed 's/^[ \t]*//')
modem_id=$(mmcli -L | awk -F'/Modem/' 'NF>1{print $2; exit}' | awk '{print $1}')
sms_list=$(mmcli -m "$modem_id" --messaging-list-sms)
sms_ids=$(echo "$sms_list" | awk -F'/SMS/' 'NF>1{print $2}' | awk '{print $1}')

log_file="/root/sms_message.log"
max_file_size=1000000 # 1 MB

if [ -z "$modem_id" ]; then
    echo "Error: Modem not found."
    exit 1
fi

if [ -z "$sms_list" ]; then
    echo "No SMS messages were found from modem [$modem_info]"
    exit 0
else
   echo "SMS received from modem [$modem_info]"
   echo "SMS Message list:"
   echo "$sms_list"
fi

for sms_id in $sms_ids; do
    message=$(mmcli -m "$modem_id" --sms "$sms_id")
    echo "$message"
    if [ -n "$message" ]; then
        temp_file=$(mktemp)
        echo "$message" > "$temp_file"
        cat "$log_file" >> "$temp_file"
        mv "$temp_file" "$log_file"
    fi
done

file_size=$(stat -c%s "$log_file")
if [ "$file_size" -gt "$max_file_size" ]; then
    rm "$log_file" && touch "$log_file"
fi
