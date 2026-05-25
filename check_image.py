import os
from PIL import Image

def check_image(path):
    try:
        with Image.open(path) as img:
            print(f"Path: {path}")
            print(f"Format: {img.format}")
            print(f"Size: {img.size}")
            print(f"Mode: {img.mode}")
            # Check if it's mostly white or transparent
            extrema = img.getextrema()
            print(f"Extrema: {extrema}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_image("assets/mushaf/pages/page001.webp")
    check_image("assets/mushaf/pages/page002.webp")
