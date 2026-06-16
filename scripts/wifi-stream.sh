#!/usr/bin/env bash

get_wifi() {
    local status=$(nmcli -t -f WIFI g)

    if [ "$status" != "enabled" ]; then
        echo '{"status": "disabled", "ssid": "off", "signal": 0}'
        return
    fi

    local active=$(nmcli -t -f IN-USE,SSID,SIGNAL dev wifi | grep '^\*')

    if [ -z "$active" ]; then
        echo '{"status": "disconnected", "ssid": "disconnected", "signal": 0}'
        return
    fi

    local ssid=$(echo "$active" | cut -d':' -f2)
    local signal=$(echo "$active" | cut -d':' -f3)

    echo "{\"status\": \"connected\", \"ssid\": \"$ssid\", \"signal\": $signal}"
}

get_wifi

stdbuf -oL nmcli monitor | while read -r _; do
    get_wifi
done
