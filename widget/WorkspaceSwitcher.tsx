import { For } from "ags"
import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { workspaces } from "../services/niri-workspaces"

export default function WorkspaceSwitcher() {
  return (
    <box
      $type="start"
      cssName="WorkspaceSwitcher"
      halign={Gtk.Align.START}
      spacing={16}
    >
      <For each={workspaces}>
        {(ws) => {
          const stateClass = ws.is_active
            ? "active"
            : ws.active_window_id !== null
              ? "occupied"
              : "empty"
          const icon = ws.is_active
            ? ""
            : ws.active_window_id !== null
              ? "󰻂"
              : ""

          return (
            <button
              class={stateClass}
              onClicked={() =>
                execAsync([
                  "niri",
                  "msg",
                  "action",
                  "focus-workspace",
                  ws.name || ws.idx.toString(),
                ])
              }
            >
              <label label={icon} />
            </button>
          )
        }}
      </For>
    </box>
  )
}
