import { createBinding, createComputed, With } from "ags"
import Wp from "gi://AstalWp"
import { uiState } from "../services/state"

const defaultWidget = (
  <box>
    <image iconName="audio-volume-muted-symbolic" class="icon" pixelSize={14} />
  </box>
)

export default function SystemVolume() {
  const wp = Wp.get_default()
  const audio = wp?.audio
  if (!audio) {
    return defaultWidget
  }

  const defaultSpeaker = createBinding(audio, "defaultSpeaker")
  return (
    <button
      onClicked={() => {
        uiState.show_volume = !uiState.show_volume
      }}
    >
      <With value={defaultSpeaker}>
        {(speaker) => {
          if (!speaker) {
            return defaultWidget
          }

          const volume = createBinding(speaker, "volume")
          const mute = createBinding(speaker, "mute")

          const icon = createComputed(() => {
            const isMuted = mute()
            const vol = volume()

            if (isMuted || vol === 0) return "audio-volume-muted-symbolic"
            if (vol < 0.33) return "audio-volume-low-symbolic"
            if (vol < 0.67) return "audio-volume-medium-symbolic"
            return "audio-volume-high-symbolic"
          })

          return (
            <box spacing={6}>
              <image iconName={icon} class="icon" pixelSize={14} />
              <label label={volume((v) => `${Math.round(v * 100)}`)} />
            </box>
          )
        }}
      </With>
    </button>
  )
}
