import { createBinding } from "ags"
import { Astal, Gdk } from "ags/gtk4"
import PowerProfiles from "gi://AstalPowerProfiles"
import { uiState } from "../../services/state"

const { TOP, RIGHT } = Astal.WindowAnchor

const profiles = [
  {
    id: "power-saver",
    label: "Battery Saver",
    icon: "power-profile-power-saver-symbolic",
  },
  {
    id: "balanced",
    label: "Balanced",
    icon: "power-profile-balanced-symbolic",
  },
  {
    id: "performance",
    label: "Performance",
    icon: "power-profile-performance-symbolic",
  },
]

export default function PowerProfilesMenu(gdkMonitor: Gdk.Monitor) {
  const powerProfiles = PowerProfiles.get_default()
  if (!powerProfiles) {
    return <window visible={false} />
  }

  const activeProfile = createBinding(powerProfiles, "active_profile")

  const isVisible = createBinding(uiState, "show_power_profiles")
  const screenWidth = gdkMonitor.get_geometry().width
  const exactRightMargin = (screenWidth - 1000) / 2 + 4

  return (
    <window
      visible={isVisible}
      name="power-profiles-menu"
      namespace="minos-menu"
      class="Menu"
      gdkmonitor={gdkMonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | RIGHT}
      defaultWidth={-1}
      defaultHeight={-1}
      marginTop={48}
      marginRight={exactRightMargin}
      onNotifyIsActive={(self) => {
        if (!self.is_active) {
          uiState.show_power_profiles = false
        }
      }}
    >
      <box class="wrapper button-group" spacing={8}>
        {profiles.map((p) => (
          <button
            class={activeProfile((active) => (active === p.id ? "active" : ""))}
            onClicked={() => {
              powerProfiles.active_profile = p.id
            }}
            tooltipText={p.label}
          >
            <box>
              <image iconName={p.icon} pixelSize={14} />
            </box>
          </button>
        ))}
      </box>
    </window>
  )
}
