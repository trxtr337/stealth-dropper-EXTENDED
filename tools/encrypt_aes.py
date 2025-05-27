import base64
import os
import sys
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
from dotenv import load_dotenv
from dotenv import dotenv_values

# Явно загружаем переменные из .env, игнорируя окружение
config = dotenv_values(os.path.join(os.path.dirname(__file__), '..', '.env'))

key = config.get("ENCRYPTION_KEY")

#print(f"[DEBUG] Running from: {os.getcwd()}")
#print(f"[DEBUG] Loading .env from: {os.path.join(os.path.dirname(__file__), '..', '.env')}")
#print(f"[DEBUG] Loaded ENCRYPTION_KEY: '{key}' Length: {len(key) if key else 'None'}")

if not key or len(key) != 32:
    print("[-] ENCRYPTION_KEY must be 32 characters long in .env")
    sys.exit(1)

key = key.encode()

if len(sys.argv) != 2:
    print("Usage: python3 encrypt_aes.py <input_file>")
    sys.exit(1)

input_path = sys.argv[1]

with open(input_path, "rb") as f:
    plaintext = f.read()

iv = os.urandom(16)
cipher = AES.new(key, AES.MODE_CBC, iv)
ciphertext = cipher.encrypt(pad(plaintext, AES.block_size))
b64_cipher = base64.b64encode(ciphertext).decode()
iv_hex = iv.hex()

#print(f"[DEBUG] Encryption successful. IV: {iv_hex}")

print(f"{iv_hex}:{b64_cipher}")
