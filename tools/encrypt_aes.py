import base64
import os
import sys
import hashlib
import zlib
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad

# ================================
# Validate CLI arguments
# ================================
if len(sys.argv) != 3:
    print("Usage: python3 encrypt_aes.py <input_file> <hex_key>")
    sys.exit(1)

input_path = sys.argv[1]
key_hex = sys.argv[2]

if len(key_hex) != 64:
    print("[-] ENCRYPTION_KEY must be 64 hex characters (32 bytes)")
    sys.exit(1)

# Convert key from hex to bytes
key = bytes.fromhex(key_hex)

# ================================
# Read and prepare the input
# ================================
try:
    with open(input_path, "rb") as f:
        plaintext = f.read()
except Exception as e:
    print(f"[-] Failed to read file: {e}")
    sys.exit(1)

# Add SHA256 hash for integrity check (32 bytes prefix)
hash_digest = hashlib.sha256(plaintext).digest()

# Compress the payload (adds obfuscation and size reduction)
compressed = zlib.compress(plaintext)

# Combine hash + compressed payload
data = hash_digest + compressed

# ================================
# Encrypt using AES-CBC
# ================================
iv = os.urandom(16)
cipher = AES.new(key, AES.MODE_CBC, iv)
ciphertext = cipher.encrypt(pad(data, AES.block_size))

# ================================
# Output: IV as hex + base64 ciphertext
# ================================
iv_hex = iv.hex()
b64_cipher = base64.b64encode(ciphertext).decode()

# Final format: IV_HEX:BASE64_CIPHERTEXT
print(f"{iv_hex}:{b64_cipher}")
