#! /usr/bin/env bash

update_state() {
    local ws=$(niri msg -j workspaces)
    local wins=$(niri msg -j windows)

    jq -c -n --argjson ws "$ws" --argjson wins "$wins" '
    $ws | sort_by(.idx // .id) | map(
        . as $w | {
            id: $w.id,
            active: $w.is_focused,
            apps: ($wins | map(select(.workspace_id == $w.id) | {appId: (.app_id // ""), title: (.title // ""), winId: .id, isFocused: .is_focused}))
        }
    )
'
}

update_state

niri msg -j event-stream | stdbuf -oL jq --unbuffered -c '
    select(
        has("WorkspacesChanged") or
        has("WorkspaceActivated") or
        has("WindowOpenedOrChanged") or
        has("WindowClosed") or
        has("WindowFocusChanged")
    )
' | while read -r _; do
    update_state
done
