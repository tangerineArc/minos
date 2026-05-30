import { With } from "ags"
import { batteryState } from "../services/battery"

export default function SystemBattery() {
  return (
    <box>
      <With value={batteryState}>
        {(bat) => {
          const level = Math.floor(bat.percentage * 100)
          const limit = Math.floor(level / 10) * 10

          let icon = bat.isCharging
            ? level === 100
              ? "battery-level-100-charged-symbolic"
              : `battery-level-${limit}-charging-symbolic`
            : `battery-level-${limit}-symbolic`

          return (
            <box spacing={6}>
              <image iconName={icon} class="icon" pixelSize={14} />
              <label label={`${level}`} />
            </box>
          )
        }}
      </With>
    </box>
  )
}
