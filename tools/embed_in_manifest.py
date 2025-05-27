import sys
import json

if len(sys.argv) != 3:
    print("Usage: python3 embed_in_manifest.py <input_encoded.txt> <output_manifest.json>")
    sys.exit(1)

input_path = sys.argv[1]
output_path = sys.argv[2]

with open(input_path, "r") as f:
    encoded = f.read().strip()

# Просто вставляем как одну строку:
manifest = {
    "name": "FluentUI Runtime",
    "version": "10.2025.4",
    "background_color": "#ffffff",
    "theme_color": "#0078d4",
    "display": "standalone",
    "payload": encoded
}

with open(output_path, "w") as f:
    json.dump(manifest, f, indent=2)

print(f"[+] Encrypted payload written to {output_path} as JSON")
