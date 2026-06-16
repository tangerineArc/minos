#! /usr/bin/env bash

get_bluetooth() {
    local adapter=$(busctl tree org.bluez 2>/dev/null | grep -o '/org/bluez/hci[0-9]' | head -n 1)
    if [ -z "$adapter" ]; then
        echo '{"status": "disabled", "device": "no adapter"}'
        return
    fi

    local power=$(busctl get-property org.bluez "$adapter" org.bluez.Adapter1 Powered 2>/dev/null | awk '{print $2}')
    if [ "$power" != "true" ]; then
        echo '{"status": "disabled", "device": "off"}'
        return
    fi

    local dev_name=""
    for dev in $(busctl tree org.bluez 2>/dev/null | grep -o '/org/bluez/hci[0-9]/dev_[0-9A-Z_]*'); do
        local connected=$(busctl get-property org.bluez "$dev" org.bluez.Device1 Connected 2>/dev/null | awk '{print $2}')

        if [ "$connected" == "true" ]; then
            dev_name=$(busctl get-property org.bluez "$dev" org.bluez.Device1 Name 2>/dev/null | cut -d '"' -f 2)
            break
        fi
    done

    if [ -n "$dev_name" ]; then
        echo "{\"status\": \"connected\", \"device\": \"$dev_name\"}"
    else
        echo '{"status": "disconnected", "device": "disconnected"}'
    fi
}

get_bluetooth

stdbuf -oL dbus-monitor --system "sender='org.bluez'" 2>/dev/null | grep --line-buffered "PropertiesChanged" | while read -r _; do
    get_bluetooth
done
