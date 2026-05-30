import { createBinding } from "ags"
import Network from "gi://AstalNetwork"

export default function SystemWifi() {
  const network = Network.get_default()
  const wifi = network.wifi

  if (!wifi) {
    return (
      <box>
        <image
          iconName="network-wireless-hardware-disabled-symbolic"
          class="icon"
          pixelSize={14}
        />
      </box>
    )
  }

  const ssid = createBinding(wifi, "ssid")
  const iconName = createBinding(wifi, "iconName")

  return (
    <box tooltipText={ssid}>
      <image iconName={iconName} class="icon" pixelSize={14} />
    </box>
  )
}
