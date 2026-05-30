import { With } from "ags"
import { brightness } from "../services/brightness"
import { uiState } from "../services/state"

export default function SystemBrightness() {
  return (
    <button
      onClicked={() => {
        uiState.show_brightness = !uiState.show_brightness
      }}
    >
      <With value={brightness}>
        {(level) => (
          <box spacing={6}>
            <image
              iconName="display-brightness-symbolic"
              class="icon"
              pixelSize={14}
            />
            <label label={`${Math.floor(level * 100)}`} />
          </box>
        )}
      </With>
    </button>
  )
}
