import { createState } from "ags"
import { execAsync } from "ags/process"
import { interval } from "ags/time"

export const [batteryState, setBatteryState] = createState({
  percentage: 0,
  isCharging: false,
  isFull: false,
})

updateBattery()
interval(5000, updateBattery)

async function updateBattery() {
  try {
    const capacity = await execAsync(
      "cat /sys/class/power_supply/BAT1/capacity",
    )
    const status = await execAsync("cat /sys/class/power_supply/BAT1/status")

    const p = Number(capacity) / 100
    const s = status.trim()

    setBatteryState({
      percentage: p,
      isCharging: s === "Charging",
      isFull: s === "Full" || p >= 1,
    })
  } catch {
    console.error("Failed to read BAT1. Is the path correct?")
  }
}
