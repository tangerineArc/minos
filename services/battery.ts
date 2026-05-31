import { createState } from "ags"
import { execAsync } from "ags/process"
import { interval } from "ags/time"
import { BAT_ID } from "../config"

const basePath = `/sys/class/power_supply/${BAT_ID}`
const capacityPath = `${basePath}/capacity`
const statusPath = `${basePath}/status`

export const [batteryState, setBatteryState] = createState({
  percentage: 0,
  isCharging: false,
  isFull: false,
})

updateBattery()
interval(5000, updateBattery)

async function updateBattery() {
  try {
    const capacity = await execAsync(`cat ${capacityPath}`)
    const status = await execAsync(`cat ${statusPath}`)

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
