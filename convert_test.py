from PIL import Image
try:
    with Image.open("assets/mushaf/pages/page001.webp") as img:
        img.save("assets/mushaf/pages/test_page.png")
    print("Success: converted to test_page.png")
except Exception as e:
    print(f"Error: {e}")
