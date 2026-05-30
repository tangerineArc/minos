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
        },
      },
      this,
    )
  }

  #showVolume = false
  #showBrightness = false

  // NOTE: GObject maps 'show-x' to 'show_x' in JS
  get show_volume() {
    return this.#showVolume
  }

  set show_volume(val: boolean) {
    if (this.#showVolume === val) {
      return
    }
    this.#showVolume = val

    if (val && this.#showBrightness) {
      this.#showBrightness = false
      this.notify("show-brightness")
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

    if (val && this.#showVolume) {
      this.#showVolume = false
      this.notify("show-volume")
    }
    this.notify("show-brightness")
  }
}

export const uiState = new MenuState()
