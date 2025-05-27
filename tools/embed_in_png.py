from PIL import Image
import sys
import struct

def embed_text_to_png(input_png, output_png, payload):
    img = Image.open(input_png)
    img = img.convert("RGBA")
    pixels = list(img.getdata())

    payload_bytes = payload.encode()
    payload_len = len(payload_bytes)
    # В начало payload кладём длину (4 байта big-endian)
    header = struct.pack(">I", payload_len)
    full_bytes = header + payload_bytes
    binary_payload = ''.join(format(b, '08b') for b in full_bytes)

    data_index = 0
    new_pixels = []
    for pixel in pixels:
        r, g, b, a = pixel
        if data_index < len(binary_payload):
            r = (r & ~1) | int(binary_payload[data_index])
            data_index += 1
        if data_index < len(binary_payload):
            g = (g & ~1) | int(binary_payload[data_index])
            data_index += 1
        if data_index < len(binary_payload):
            b = (b & ~1) | int(binary_payload[data_index])
            data_index += 1
        new_pixels.append((r, g, b, a))
    img.putdata(new_pixels)
    img.save(output_png)
    print(f"[+] Payload embedded into {output_png} (length={payload_len} bytes)")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 embed_in_png.py <input_encoded.txt> <input_png> <output_png>")
        sys.exit(1)
    payload_file = sys.argv[1]
    input_png = sys.argv[2]
    output_png = sys.argv[3]
    with open(payload_file, "r") as f:
        payload = f.read().strip()
    embed_text_to_png(input_png, output_png, payload)
