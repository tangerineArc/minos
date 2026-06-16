#!/usr/bin/env bash

get_brightness() {
    brightnessctl -m | awk -F, '{print $4}' | tr -d '%'
}

get_brightness

stdbuf -oL udevadm monitor --subsystem-match=backlight | while read -r _; do
    get_brightness
done
