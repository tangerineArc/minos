import { createState } from "ags"
import { monitorFile } from "ags/file"
import { exec, execAsync } from "ags/process"
import { timeout, Timer } from "ags/time"

const interfaceName = (() => {
  try {
    return exec("sh -c 'ls -w1 /sys/class/backlight | head -n 1'").trim()
  } catch {
    return ""
  }
})()
const basePath = `/sys/class/backlight/${interfaceName}`

const maxBrightness = (() => {
  try {
    return Number(exec(`cat ${basePath}/max_brightness`)) || 1
  } catch {
    return 1
  }
})()

const getScreenBrightness = () => {
  try {
    const current = Number(exec(`cat ${basePath}/brightness`))
    return clamp(current / maxBrightness)
  } catch {
    return 0
  }
}

export const [brightness, setBrightness] = createState(getScreenBrightness())

let throttleTimer: Timer | null = null
export const updateBrightness = (percent: number) => {
  const p = clamp(percent)
  setBrightness(p)

  if (throttleTimer) {
    throttleTimer.cancel()
  }

  throttleTimer = timeout(16, () => {
    const hwValue = Math.floor(p * maxBrightness)

    // Fast path: bypass the binary and write straight to the kernel file.
    execAsync(`sh -c 'echo ${hwValue} > ${basePath}/brightness'`).catch(() => {
      // Slow path fallback: if NixOS seat permissions deny the direct write,
      // fallback to brightnessctl (which uses a setuid wrapper/udev to bypass root)
      execAsync(`brightnessctl set ${hwValue} -q`).catch(console.error)
    })

    throttleTimer = null
  })
}

try {
  if (interfaceName) {
    monitorFile(`${basePath}/brightness`, () => {
      if (!throttleTimer) {
        setBrightness(getScreenBrightness())
      }
    })
  }
} catch {
  // Nothing here
}

function clamp(value: number, min = 0, max = 1) {
  return Math.max(min, Math.min(max, value))
}
