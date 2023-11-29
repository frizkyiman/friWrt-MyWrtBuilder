#!/bin/bash
# Created by Frizkyiman
# Github https://github.com/frizkyiman/

convert_month_to_number() {
    case "$1" in
        "Jan") echo "01";;
        "Feb") echo "02";;
        "Mar") echo "03";;
        "Apr") echo "04";;
        "May") echo "05";;
        "Jun") echo "06";;
        "Jul") echo "07";;
        "Aug") echo "08";;
        "Sep") echo "09";;
        "Oct") echo "10";;
        "Nov") echo "11";;
        "Dec") echo "12";;
        *) echo "$1";;
    esac
}

sync_time_with_curl() {
    local url="$1"
    curl_output=$(curl -Is "$url" | awk '/^Date:/ {print $2" "$3" "$4" "$5" "$6" "$7}')
    if [ -n "$curl_output" ]; then
        dayValue=$(echo "$curl_output" | cut -d' ' -f2)
        monthValue=$(echo "$curl_output" | cut -d' ' -f3)
        yearValue=$(echo "$curl_output" | cut -d' ' -f4)
        timeValue=$(echo "$curl_output" | cut -d' ' -f5)
        timeZoneValue=$(echo "$curl_output" | cut -d' ' -f6)

        monthValue=$(convert_month_to_number "$monthValue")

        new_date="$yearValue-$monthValue-$dayValue $timeValue"
        date -u -s "$new_date" > /dev/null 2>&1

        echo "Time synced successfully using $url."
        echo "Current time: $(date)"
    else
        echo "Failed to sync using $url."
    fi
}

wait_for_internet() {
    echo "Check internet connection..."
    while ! ping -c 1 "$url" > /dev/null 2>&1; do
        echo -n "."
        sleep 1
    done
    echo "Internet connection available."
}

url=${1:-"google.com"}

wait_for_internet

sync_time_with_curl "$url"

cleanup() {
    unset curl_output
    echo "Cleaning up. . ."
    echo "Done."
}

cleanup
