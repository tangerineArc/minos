#!/usr/bin/env bash

get_window() {
    local win=$(niri msg -j focused-window 2>/dev/null)

    if [ -z "$win" ] || [ "$win" == "null" ]; then
        echo '{"title": "", "appId": ""}'
    else
        echo "$win" | jq -c '{title: (.title // ""), appId: (.app_id // "")}'
    fi
}

get_window

niri msg -j event-stream | while read -r _; do
    get_window
done
