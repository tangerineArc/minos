import { Astal, Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import { currentWindow } from "../services/niri-window"
import SystemBattery from "./SystemBattery"
import SystemBluetooth from "./SystemBluetooth"
import SystemBrightness from "./SystemBrightness"
import SystemVolume from "./SystemVolume"
import SystemWifi from "./SystemWifi"
import WorkspaceSwitcher from "./WorkspaceSwitcher"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      name="bar"
      namespace="minos-bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP}
      defaultHeight={40}
      defaultWidth={1000}
      marginTop={4}
      marginBottom={0}
      application={app}
    >
      <centerbox cssName="centerbox">
        <WorkspaceSwitcher />

        <box $type="center" class="FocusedWindowDetails" spacing={16}>
          <label
            class="FocusedWindowIcon"
            halign={Gtk.Align.CENTER}
            label={currentWindow((w) => w.icon)}
          />
          <label label={currentWindow((w) => w.title)} />
        </box>

        <box
          $type="end"
          class="SystemStats"
          halign={Gtk.Align.CENTER}
          spacing={3}
        >
          <box class="left-box" spacing={16}>
            <SystemVolume />
            <SystemBrightness />
            <SystemBattery />
          </box>
          <box class="right-box" spacing={12}>
            <SystemWifi />
            <SystemBluetooth />
          </box>
        </box>
      </centerbox>
    </window>
  )
}
