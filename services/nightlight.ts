import { createState } from "ags"
import { exec, execAsync } from "ags/process"
import GLib from "gi://GLib?version=2.0"

const DEFAULT_STATE = { enabled: true, temperature: 4000 }

const CACHE_DIR = `${GLib.get_user_cache_dir()}/minos`
const STATE_FILE = `${CACHE_DIR}/nightlight.json`

exec(`mkdir -p ${CACHE_DIR}`)

let initialState = DEFAULT_STATE
try {
  const content = exec(`cat ${STATE_FILE}`)
  initialState = JSON.parse(content)
} catch (error) {
  console.warn("[nightlight] falling back to default", error)
}

export const [nightlight, setNightlight] = createState(initialState)
applyState(initialState)

export const toggleNightlight = () => {
  const newState = { ...nightlight(), enabled: !nightlight().enabled }
  setNightlight(newState)
  applyState(newState)
}

export const setTemperature = (temp: number) => {
  const newState = { ...nightlight(), temperature: temp }
  setNightlight(newState)
  applyState(newState)
}

async function applyState(state: typeof DEFAULT_STATE) {
  const payload = `{\\"enabled\\": ${state.enabled}, \\"temperature\\": ${state.temperature}}`
  execAsync(`sh -c 'echo "${payload}" > ${STATE_FILE}'`).catch(console.error)

  const targetTemp = state.enabled ? state.temperature : 6500
  execAsync(
    `busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q ${targetTemp}`,
  ).catch(console.error)
}
