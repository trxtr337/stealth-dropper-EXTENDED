import base64
import os
import sys
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
from dotenv import load_dotenv

# Загрузка переменной окружения
load_dotenv()
key = os.getenv("ENCRYPTION_KEY")
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

# Вывод: IV_HEX:Base64Ciphertext
print(f"{iv_hex}:{b64_cipher}")