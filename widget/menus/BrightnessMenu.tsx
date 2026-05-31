import { createBinding, createComputed } from "ags"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { BAR_WIDTH, DEFAULT_MENU_WIDTH, MENU_MARGIN_TOP } from "../../config"
import { brightness, updateBrightness } from "../../services/brightness"
import {
  nightlight,
  setTemperature,
  toggleNightlight,
} from "../../services/nightlight"
import { uiState } from "../../services/state"

const { TOP, RIGHT } = Astal.WindowAnchor
const { VERTICAL } = Gtk.Orientation
const { CENTER, END } = Gtk.Align

export default function BrightnessMenu(gdkmonitor: Gdk.Monitor) {
  const tempValue = createComputed(() => {
    const t = nightlight().temperature
    return (t - 2500) / 4000
  })

  const isVisible = createBinding(uiState, "show_brightness")
  const screenWidth = gdkmonitor.get_geometry().width
  const exactRightMargin = (screenWidth - BAR_WIDTH) / 2 + 4

  return (
    <window
      visible={isVisible}
      name="brightness-menu"
      namespace="minos-menu"
      class="Menu"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | RIGHT}
      defaultWidth={DEFAULT_MENU_WIDTH}
      defaultHeight={-1}
      marginTop={MENU_MARGIN_TOP}
      marginRight={exactRightMargin}
      onNotifyIsActive={(self) => {
        if (!self.is_active) uiState.show_brightness = false
      }}
    >
      <box class="wrapper" orientation={VERTICAL} spacing={16}>
        <box class="DefaultDevice">
          <box orientation={VERTICAL} spacing={6} class="ControlBlock">
            <box class="EndpointGroup" spacing={12}>
              <label label="󰃠" />
              <label label="display brightness" />
            </box>
            <box spacing={10} class="SliderGroup">
              <slider
                hexpand
                drawValue={false}
                value={brightness}
                onChangeValue={({ value }) => updateBrightness(value)}
              />
              <label label={brightness((b) => `${Math.floor(b * 100)}`)} />
            </box>
          </box>
        </box>

        <box class="group">
          <box
            orientation={VERTICAL}
            valign={CENTER}
            spacing={8}
            class="ControlBlock"
          >
            <box class="EndpointGroup" valign={CENTER}>
              <box spacing={12} hexpand>
                <image iconName="night-light-symbolic" pixelSize={14} />
                <label label="night light" />
              </box>
              <switch
                heightRequest={10}
                halign={END}
                valign={CENTER}
                active={nightlight((s) => s.enabled)}
                onNotifyActive={toggleNightlight}
              />
            </box>
            <box spacing={10} class="SliderGroup">
              <slider
                hexpand
                drawValue={false}
                value={tempValue}
                onChangeValue={({ value }) => {
                  const rawTemp = 2500 + value * 4000
                  const snappedTemp = Math.round(rawTemp / 10) * 10
                  setTemperature(snappedTemp)
                }}
              />
              <label label={nightlight((s) => `${s.temperature}K`)} />
            </box>
          </box>
        </box>
      </box>
    </window>
  )
}
