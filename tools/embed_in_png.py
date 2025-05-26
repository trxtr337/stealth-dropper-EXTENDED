from PIL import Image
import sys

def embed_text_to_png(input_png, output_png, payload):
    img = Image.open(input_png)
    img = img.convert("RGBA")
    pixels = list(img.getdata())

    binary_payload = ''.join(format(ord(c), '08b') for c in payload)
    binary_payload += '00000000' * 2  # Стоп-бит

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
    print(f"[+] Payload embedded into {output_png}")

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
