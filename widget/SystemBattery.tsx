import { createBinding } from "ags"
import Battery from "gi://AstalBattery"
import { uiState } from "../services/state"

export default function SystemBattery() {
  const bat = Battery.get_default()
  if (!bat) {
    return (
      <button
        onClicked={() => {
          uiState.show_power_profiles = !uiState.show_power_profiles
        }}
      >
        <image iconName="computer-symbolic" class="icon" pixelSize={14} />
      </button>
    )
  }

  const percentage = createBinding(bat, "percentage")
  const iconName = createBinding(bat, "iconName")

  return (
    <button
      onClicked={() => {
        uiState.show_power_profiles = !uiState.show_power_profiles
      }}
    >
      <box spacing={6}>
        <image iconName={iconName} class="icon" pixelSize={14} />
        <label label={percentage((p) => `${Math.floor(p * 100)}`)} />
      </box>
    </button>
  )
}
