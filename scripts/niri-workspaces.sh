#! /usr/bin/env bash

update_state() {
    local ws=$(niri msg -j workspaces)
    local wins=$(niri msg -j windows)

    jq -c -n --argjson ws "$ws" --argjson wins "$wins" '
    $ws | sort_by(.idx // .id) | map(
        . as $w | {
            id: $w.id,
            active: $w.is_focused,
            apps: (
                $wins
                | map(select(.workspace_id == $w.id))
                | sort_by([.layout.pos_in_scrolling_layout[0]? // 9999, .layout.pos_in_scrolling_layout[1]? // 9999])
                | map({
                    appId: (.app_id // ""),
                    title: (.title // ""),
                    winId: .id,
                    isFocused: .is_focused
                })
            )
        }
    )
'
}

update_state

niri msg -j event-stream | while read -r _; do
    update_state
done
