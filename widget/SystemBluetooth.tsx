import { createBinding, createComputed } from "ags"
import Bluetooth from "gi://AstalBluetooth"

export default function SystemBluetooth() {
  const bluetooth = Bluetooth.get_default()

  if (!bluetooth) {
    return (
      <box>
        <image
          iconName="bluetooth-hardware-disabled-symbolic"
          class="icon"
          pixelSize={14}
        />
      </box>
    )
  }

  const isPowered = createBinding(bluetooth, "isPowered")
  const devices = createBinding(bluetooth, "devices")

  const state = createComputed(() => {
    if (!isPowered()) {
      return {
        icon: "bluetooth-disabled-symbolic",
        label: "Off",
      }
    }

    // NOTE: might be problematic (memory hogging)
    const currentDevices = devices()
    const connectedDevice = currentDevices.find((d) => {
      const isConnected = createBinding(d, "connected")
      return isConnected()
    })

    if (connectedDevice) {
      return {
        icon: "bluetooth-active-symbolic",
        label: connectedDevice.alias || connectedDevice.name || "Connected",
      }
    }

    return {
      icon: "bluetooth-disconnected-symbolic",
      label: "Disconnected",
    }
  })

  const iconName = createComputed(() => state().icon)
  const tooltip = createComputed(() => state().label)

  return (
    <box tooltipText={tooltip}>
      <image class="icon" iconName={iconName} pixelSize={14} />
    </box>
  )
}
