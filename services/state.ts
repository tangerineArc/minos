import GObject from "gi://GObject"

class MenuState extends GObject.Object {
  static {
    GObject.registerClass(
      {
        Properties: {
          "show-volume": GObject.ParamSpec.boolean(
            "show-volume",
            "Show Volume Menu",
            "Toggle the visibility of the volume control center",
            GObject.ParamFlags.READWRITE,
            false,
          ),
          "show-brightness": GObject.ParamSpec.boolean(
            "show-brightness",
            "Show Brightness Menu",
            "Toggle the visibility of the brightness control center",
            GObject.ParamFlags.READWRITE,
            false,
          ),
          "show-power-profiles": GObject.ParamSpec.boolean(
            "show-power-profiles",
            "Show Power Profiles Menu",
            "Toggle the visibility of the power profiles control center",
            GObject.ParamFlags.READWRITE,
            false,
          ),
        },
      },
      this,
    )
  }

  #showVolume = false
  #showBrightness = false
  #showPowerProfiles = false

  // NOTE: GObject maps 'show-x' to 'show_x' in JS
  get show_volume() {
    return this.#showVolume
  }

  set show_volume(val: boolean) {
    if (this.#showVolume === val) {
      return
    }
    this.#showVolume = val

    if (val) {
      if (this.#showBrightness) {
        this.show_brightness = false
        this.notify("show-brightness")
      }
      if (this.#showPowerProfiles) {
        this.#showPowerProfiles = false
        this.notify("show-power-profiles")
      }
    }
    this.notify("show-volume")
  }

  get show_brightness() {
    return this.#showBrightness
  }

  set show_brightness(val: boolean) {
    if (this.#showBrightness === val) {
      return
    }
    this.#showBrightness = val

    if (val) {
      if (this.#showVolume) {
        this.#showVolume = false
        this.notify("show-volume")
      }
      if (this.#showPowerProfiles) {
        this.#showPowerProfiles = false
        this.notify("show-power-profiles")
      }
    }
    this.notify("show-brightness")
  }

  get show_power_profiles() {
    return this.#showPowerProfiles
  }

  set show_power_profiles(val: boolean) {
    if (this.#showPowerProfiles === val) {
      return
    }
    this.#showPowerProfiles = val

    if (val) {
      if (this.#showVolume) {
        this.#showVolume = false
        this.notify("show-volume")
      }
      if (this.#showBrightness) {
        this.#showBrightness = false
        this.notify("show-brightness")
      }
    }
    this.notify("show-power-profiles")
  }
}

export const uiState = new MenuState()
