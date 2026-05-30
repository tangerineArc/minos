import { createBinding, createComputed, For, With } from "ags"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import Wp from "gi://AstalWp"
import { uiState } from "../../services/state"

const { TOP, RIGHT } = Astal.WindowAnchor
const { VERTICAL } = Gtk.Orientation

const iconMap: Record<string, string> = {
  "audio-card-symbolic": "󰗅",
  "audio-card-analog-pci": "󰓃",
  "audio-headset-bluetooth": "",
  "chromium-browser": "",
}

export default function VolumeMenu(gdkmonitor: Gdk.Monitor) {
  const wp = Wp.get_default()
  const audio = wp?.audio
  if (!audio) {
    return <window visible={false} />
  }

  const speakers = createBinding(audio, "speakers").as((s) => s ?? [])
  const streams = createBinding(audio, "streams").as((s) => s ?? [])

  const isVisible = createBinding(uiState, "show_volume")
  const screenWidth = gdkmonitor.get_geometry().width
  const exactRightMargin = (screenWidth - 1000) / 2 + 4

  return (
    <window
      visible={isVisible}
      name="volume-menu"
      namespace="minos-menu"
      class="Menu"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | RIGHT}
      defaultWidth={320}
      defaultHeight={-1} // Fixes the window height to the content size
      marginTop={48}
      marginRight={exactRightMargin}
      onNotifyIsActive={(self) => {
        if (!self.is_active) uiState.show_volume = false
      }}
    >
      <box class="wrapper" orientation={VERTICAL} spacing={16}>
        <box class="DefaultDevice">
          <AudioControl endpoint={audio.defaultSpeaker} />
        </box>

        <box
          class="group"
          spacing={8}
          orientation={VERTICAL}
          visible={streams((s) => (s ? s.length > 0 : false))}
        >
          <label label="󰲸 streams" halign={Gtk.Align.START} />
          <box spacing={14} orientation={VERTICAL}>
            <For each={streams}>
              {(s) => <AudioControl endpoint={s} isStream={true} />}
            </For>
          </box>
        </box>

        <box class="group" orientation={VERTICAL} spacing={8}>
          <label label="󰤽 devices" halign={Gtk.Align.START} />
          <box orientation={VERTICAL} spacing={14}>
            <For each={speakers}>
              {(s) => <AudioControl endpoint={s} showRadio={true} />}
            </For>
          </box>
        </box>
      </box>
    </window>
  )
}

function AudioControl({
  endpoint,
  isStream = false,
  showRadio = false,
}: {
  endpoint: Wp.Endpoint | Wp.Stream
  isStream?: boolean
  showRadio?: boolean
}) {
  const volume = createBinding(endpoint, "volume")
  const mute = createBinding(endpoint, "mute")
  const name = createBinding(endpoint, "description")

  const icon = createBinding(endpoint, "icon")
  const displayIcon = createComputed(() => {
    const muted = mute()
    return muted ? "" : iconMap[icon().trim()] || (isStream ? "󰎆" : "󰓃")
  })

  return (
    <box orientation={VERTICAL} spacing={6} class="ControlBlock">
      <box spacing={14} class="EndpointGroup">
        <button
          onClicked={() => {
            endpoint.mute = !endpoint.mute
          }}
        >
          <With value={displayIcon}>{(i) => <label label={i} />}</With>
        </button>
        <label
          label={name((n) => {
            if (!n) return "Unknown"
            if (n.length > 25) return `${n.slice(0, 25)}...`
            return n
          })}
        />
      </box>

      <box spacing={10} class="SliderGroup">
        <slider
          hexpand
          drawValue={false}
          value={volume}
          onChangeValue={({ value }) => {
            endpoint.volume = value
          }}
        />
        <label label={volume((v) => `${Math.round(v * 100)}`)} />

        {showRadio && (
          <button
            onClicked={() => {
              ;(endpoint as Wp.Endpoint).isDefault = true
            }}
          >
            <label
              label={createBinding(endpoint as Wp.Endpoint, "isDefault").as(
                (active) => (active ? "" : ""),
              )}
            />
          </button>
        )}
      </box>
    </box>
  )
}
