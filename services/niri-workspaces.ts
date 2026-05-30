import { createState } from "ags"
import { execAsync, subprocess } from "ags/process"
import { timeout, Timer } from "ags/time"

export interface Workspace {
  idx: number
  name: string
  is_active: boolean
  active_window_id: number | null
}

export const [workspaces, setWorkspaces] = createState<Workspace[]>([])

fetchWorkspaces()

let debounceTimer: Timer | null = null
subprocess(["niri", "msg", "event-stream"], (line) => {
  if (line.includes("Workspace") || line.includes("Window")) {
    if (debounceTimer) {
      debounceTimer.cancel()
    }
    debounceTimer = timeout(50, fetchWorkspaces)
  }
})

async function fetchWorkspaces() {
  try {
    const out = await execAsync("niri msg -j workspaces")
    if (!out) {
      return
    }

    const data: Workspace[] = JSON.parse(out)
    data.sort((a, b) => a.idx - b.idx)

    setWorkspaces(data)
  } catch (_err) {
    return
  }
}
