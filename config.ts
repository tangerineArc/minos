import { monitorFile } from "ags/file"
import { Gdk, Gtk } from "ags/gtk4"
import { exec } from "ags/process"
import GLib from "gi://GLib"

const CONFIG_DIR = `${GLib.get_user_config_dir()}/minos`
const CONFIG_FILE = `${CONFIG_DIR}/config.json`

const DEFAULT_CONFIG = {
  general: {
    bar_width: 1000,
    bar_height: 40,
    bar_margin_top: 4,
    default_menu_width: 320,
    bat_id: "BAT1",
  },
  colors: {
    "accent-primary": "#c7bfff",
    "accent-secondary": "#c8c3dc",
    "accent-tertiary": "#ecb8ce",

    "accent-primary-fg": "#2f295f",
    "accent-secondary-fg": "#302e41",
    "accent-tertiary-fg": "#482537",

    "fg-1": "#e5e1e9",
    "fg-2": "#e5e1e9",
    "fg-3": "#c9c5d0",

    "bg-1": "#141318",
    "bg-2": "#141318",
    "bg-3": "#47464f",

    "container-primary": "#463f77",
    "container-secondary": "#474459",
    "container-tertiary": "#613b4d",

    "container-primary-fg": "#e4dfff",
    "container-secondary-fg": "#e5dff9",
    "container-tertiary-fg": "#ffd8e7",
  },
}

exec(`mkdir -p ${CONFIG_DIR}`)

let userConfig: Partial<typeof DEFAULT_CONFIG> = {}
try {
  const content = exec(`cat ${CONFIG_FILE}`)
  if (content) {
    userConfig = JSON.parse(content)
  }
} catch (error) {
  console.warn("[config] falling back to default", error)
}

const config = {
  general: { ...DEFAULT_CONFIG.general, ...(userConfig.general || {}) },
  colors: { ...DEFAULT_CONFIG.colors, ...(userConfig.colors || {}) },
}

export const BAR_WIDTH = config.general.bar_width
export const BAR_HEIGHT = config.general.bar_height
export const BAR_MARGIN_TOP = config.general.bar_margin_top

export const DEFAULT_MENU_WIDTH = config.general.default_menu_width
export const MENU_MARGIN_TOP = BAR_HEIGHT + BAR_MARGIN_TOP + 4

export const BAT_ID = config.general.bat_id

let cssProvider: Gtk.CssProvider | null = null

function applyCss(colors: typeof DEFAULT_CONFIG.colors) {
  const css = `
    @define-color accent-primary ${colors["accent-primary"]};
    @define-color accent-secondary ${colors["accent-secondary"]};
    @define-color accent-tertiary ${colors["accent-tertiary"]};

    @define-color accent-primary-fg ${colors["accent-primary-fg"]};
    @define-color accent-secondary-fg ${colors["accent-secondary-fg"]};
    @define-color accent-tertiary-fg ${colors["accent-tertiary-fg"]};

    @define-color fg-1 ${colors["fg-1"]};
    @define-color fg-2 ${colors["fg-2"]};
    @define-color fg-3 ${colors["fg-3"]};

    @define-color bg-1 ${colors["bg-1"]};
    @define-color bg-2 ${colors["bg-2"]};
    @define-color bg-3 ${colors["bg-3"]};

    @define-color container-primary ${colors["container-primary"]};
    @define-color container-secondary ${colors["container-secondary"]};
    @define-color container-tertiary ${colors["container-tertiary"]};

    @define-color container-primary-fg ${colors["container-primary-fg"]};
    @define-color container-secondary-fg ${colors["container-secondary-fg"]};
    @define-color container-tertiary-fg ${colors["container-tertiary-fg"]};
  `

  if (!cssProvider) {
    cssProvider = new Gtk.CssProvider()
    Gtk.StyleContext.add_provider_for_display(
      Gdk.Display.get_default()!,
      cssProvider,
      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1,
    )
  }
  cssProvider.load_from_string(css)
}

applyCss(config.colors)

try {
  monitorFile(CONFIG_FILE, () => {
    try {
      const content = exec(`cat ${CONFIG_FILE}`)
      const parsed = JSON.parse(content) as typeof DEFAULT_CONFIG
      if (parsed.colors) applyCss(parsed.colors)
    } catch (error) {
      console.error("[config] failed to reload colors:", error)
    }
  })
} catch (error) {
  console.warn("[config] failed to setup file monitor", error)
}
