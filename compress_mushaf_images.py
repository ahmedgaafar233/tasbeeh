#!/usr/bin/env python3
"""
Script to compress WebP images in the Mushaf directory.
Requires: cwebp (webp tools) or Pillow library

Usage:
    python3 compress_mushaf_images.py

This will compress all .webp files in assets/mushaf/pages/ 
and reduce the overall app size significantly.
"""

import os
import subprocess
import sys
from pathlib import Path

# Constants
MUSHAF_DIR = Path("assets/mushaf/pages")
BACKUP_DIR = Path("assets/mushaf/pages_original_backup")
TARGET_QUALITY = 75  # WebP quality (0-100, lower = smaller file)
TARGET_WIDTH = 1200  # Max width in pixels (original is likely higher)


def check_cwebp_installed():
    """Check if cwebp command-line tool is available"""
    try:
        subprocess.run(["cwebp", "-version"], 
                      capture_output=True, 
                      check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def check_pillow_installed():
    """Check if PIL/Pillow is available"""
    try:
        from PIL import Image
        return True
    except ImportError:
        return False


def compress_with_cwebp(input_path, output_path, quality=TARGET_QUALITY):
    """Compress using cwebp command-line tool"""
    cmd = [
        "cwebp",
        "-q", str(quality),
        "-resize", str(TARGET_WIDTH), "0",  # Resize width, auto height
        input_path,
        "-o", output_path
    ]
    subprocess.run(cmd, check=True, capture_output=True)


def compress_with_pillow(input_path, output_path, quality=TARGET_QUALITY):
    """Compress using Pillow library"""
    from PIL import Image
    
    img = Image.open(input_path)
    
    # Resize if needed
    if img.width > TARGET_WIDTH:
        ratio = TARGET_WIDTH / img.width
        new_height = int(img.height * ratio)
        img = img.resize((TARGET_WIDTH, new_height), Image.LANCZOS)
    
    # Save with compression
    img.save(output_path, "WEBP", quality=quality, method=6)


def main():
    """Main compression function"""
    
    # Check if directory exists
    if not MUSHAF_DIR.exists():
        print(f"❌ Error: Directory {MUSHAF_DIR} not found!")
        print("Make sure you run this script from the project root.")
        sys.exit(1)
    
    # Check compression tools
    has_cwebp = check_cwebp_installed()
    has_pillow = check_pillow_installed()
    
    if not has_cwebp and not has_pillow:
        print("❌ Error: No compression tool found!")
        print("\nPlease install one of the following:")
        print("  1. cwebp: sudo apt install webp  (Linux)")
        print("  2. Pillow: pip install Pillow")
        sys.exit(1)
    
    compress_func = compress_with_cwebp if has_cwebp else compress_with_pillow
    tool_name = "cwebp" if has_cwebp else "Pillow"
    
    print(f"✅ Using {tool_name} for compression")
    print(f"📁 Source: {MUSHAF_DIR}")
    print(f"🎯 Target quality: {TARGET_QUALITY}, Max width: {TARGET_WIDTH}px\n")
    
    # Create backup
    if not BACKUP_DIR.exists():
        print(f"📦 Creating backup at {BACKUP_DIR}...")
        BACKUP_DIR.mkdir(parents=True)
    
    # Get all webp files
    webp_files = sorted(MUSHAF_DIR.glob("*.webp"))
    total_files = len(webp_files)
    
    if total_files == 0:
        print("❌ No .webp files found!")
        sys.exit(1)
    
    print(f"Found {total_files} images to compress\n")
    
    # Calculate original size
    original_size = sum(f.stat().st_size for f in webp_files)
    
    # Process each file
    compressed_size = 0
    for idx, img_path in enumerate(webp_files, 1):
        # Backup original if not already backed up
        backup_path = BACKUP_DIR / img_path.name
        if not backup_path.exists():
            import shutil
            shutil.copy2(img_path, backup_path)
        
        # Compress to temp file
        temp_path = img_path.with_suffix(".webp.tmp")
        
        try:
            compress_func(str(img_path), str(temp_path), TARGET_QUALITY)
            
            # Replace original
            temp_path.replace(img_path)
            
            new_size = img_path.stat().st_size
            compressed_size += new_size
            
            # Progress
            if idx % 50 == 0 or idx == total_files:
                print(f"Progress: {idx}/{total_files} ({idx*100//total_files}%)")
        
        except Exception as e:
            print(f"❌ Error compressing {img_path.name}: {e}")
            if temp_path.exists():
                temp_path.unlink()
            continue
    
    # Report results
    print("\n" + "="*50)
    print("✅ Compression complete!")
    print(f"Original size:    {original_size / (1024*1024):.1f} MB")
    print(f"Compressed size:  {compressed_size / (1024*1024):.1f} MB")
    print(f"Saved:            {(original_size - compressed_size) / (1024*1024):.1f} MB")
    print(f"Reduction:        {(1 - compressed_size/original_size)*100:.1f}%")
    print(f"\n💾 Original files backed up to: {BACKUP_DIR}")
    print("="*50)


if __name__ == "__main__":
    main()
