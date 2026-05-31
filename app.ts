import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import BrightnessMenu from "./widget/menus/BrightnessMenu"
import PowerProfilesMenu from "./widget/menus/PowerProfilesMenu"
import VolumeMenu from "./widget/menus/VolumeMenu"

app.start({
  css: style,
  iconTheme: "Adwaita",
  main() {
    app.get_monitors().map(Bar)
    app.get_monitors().map(VolumeMenu)
    app.get_monitors().map(BrightnessMenu)
    app.get_monitors().map(PowerProfilesMenu)
  },
})
