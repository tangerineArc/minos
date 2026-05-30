import { createState } from "ags"
import { execAsync, subprocess } from "ags/process"
import { Timer, timeout } from "ags/time"

const DEFAULT_STATE = { title: "Labyrinth", icon: "" }
export const [currentWindow, setCurrentWindow] = createState(DEFAULT_STATE)

fetchWindowData()

let debounceTimer: Timer | null = null
subprocess(["niri", "msg", "event-stream"], (line) => {
  if (
    line.includes("Window focus changed") ||
    line.includes("Window opened or changed")
  ) {
    if (debounceTimer) {
      debounceTimer.cancel()
    }
    debounceTimer = timeout(100, fetchWindowData)
  }
})

async function fetchWindowData() {
  try {
    const out = await execAsync("niri msg -j focused-window")
    if (!out || out === "null") {
      setCurrentWindow(DEFAULT_STATE)
      return
    }

    const data = JSON.parse(out)
    let title = data.title || ""
    const appId = data.app_id || ""

    if (title.length > 35) {
      title = title.substring(0, 32) + "..."
    }

    setCurrentWindow({
      title: title || DEFAULT_STATE.title,
      icon: getIcon(appId, title),
    })
  } catch {
    setCurrentWindow(DEFAULT_STATE)
  }
}

function getIcon(appId: string, title: string): string {
  const id = appId.toLowerCase()
  const t = title.toLowerCase()

  if (id.includes("chromium")) return ""
  if (id.includes("crunchyroll")) return "󰿎"
  if (id.includes("gemini")) return ""
  if (id.includes("ghostty")) {
    if (t.includes("btop")) return ""
    if (t.includes("nvim")) return ""
    if (t.includes("vim")) return ""
    if (t.includes("yazi")) return ""
    return ""
  }
  if (id.includes("imv")) return "󰋵"
  if (id.includes("mpv")) return ""
  if (id.includes("music")) return ""
  if (id.includes("smile")) return "󰞅"
  if (id.includes("snapshot")) return "󰄀"
  if (id.includes("whatsapp")) return "󰖣"
  if (id.includes("youtube")) return "󰗃"
  if (id.includes("zed")) return ""
  if (id.includes("zen")) return ""

  return ""
}
