import os
from PIL import Image

def create_slideshow():
    screenshot_dir = '/home/aamy/tasbeeh_app/screenshots'
    output_path = os.path.join(screenshot_dir, 'app_preview.gif')
    
    # List of screenshot files in order
    files = [
        '1_splash.png',
        '2_athkar_categories.png',
        '3_athkar_list.png',
        '4_counter.png',
        '5_prayer_times.png',
        '6_qibla.png',
        '7_quran_index.png',
        '8_mushaf_fatihah.png',
        '10_mushaf_page.png',
        '9_about.png'
    ]
    
    images = []
    
    # Load images, resize to keep GIF size optimized (e.g. height 600px, maintaining aspect ratio)
    target_height = 600
    
    for f in files:
        path = os.path.join(screenshot_dir, f)
        if os.path.exists(path):
            img = Image.open(path)
            # Calculate new width to maintain aspect ratio
            aspect_ratio = img.width / img.height
            target_width = int(target_height * aspect_ratio)
            
            # Resize image
            resized_img = img.resize((target_width, target_height), Image.Resampling.LANCZOS)
            
            # Convert to RGB if it has transparency/alpha channel to ensure perfect GIF color output
            if resized_img.mode in ('RGBA', 'LA') or (resized_img.mode == 'P' and 'transparency' in resized_img.info):
                # Create a black background to blend the transparency smoothly
                background = Image.new('RGB', resized_img.size, (18, 24, 38)) # Beautiful dark blue background matching the app
                background.paste(resized_img, mask=resized_img.split()[3] if resized_img.mode == 'RGBA' else None)
                images.append(background)
            else:
                images.append(resized_img.convert('RGB'))
                
    if not images:
        print("No screenshots found to create GIF.")
        return
        
    print(f"Loaded {len(images)} screenshots. Compiling animated GIF...")
    
    # Save as animated GIF
    # duration is in milliseconds (2000ms = 2 seconds per slide)
    images[0].save(
        output_path,
        save_all=True,
        append_images=images[1:],
        duration=2000,
        loop=0,
        optimize=True
    )
    print(f"Animated GIF successfully saved to: {output_path}")

if __name__ == '__main__':
    create_slideshow()
