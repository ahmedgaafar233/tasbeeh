# Tasbeeh App - Asset Optimization

## Quick Start

To compress the Quran images and reduce app size:

```bash
cd /home/aamy/tasbeeh_app
python3 compress_mushaf_images.py
```

## What This Does

- Compresses 604 Quran page images from ~300MB to ~100-150MB
- Maintains visual quality (75% quality, 1200px max width)
- Creates backup at `assets/mushaf/pages_original_backup/`

## Requirements

One of the following (both are installed):
- `cwebp` CLI tool (preferred) ✅
- Python Pillow library ✅

## After Compression

1. Test the app to verify images display correctly
2. Build release: `flutter build apk --release`
3. Check final APK size

## Permissions Status ✅

All required Android permissions are already configured:
- `SCHEDULE_EXACT_ALARM` - For prayer notifications
- `RECEIVE_BOOT_COMPLETED` - For post-reboot scheduling
- Location, notifications, wake lock - All present

## Dependencies Status ✅

All dependencies in `pubspec.yaml` are actively used. None can be removed without breaking functionality.
