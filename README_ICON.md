# Launcher Icon Setup

To use the SVG logo as the launcher icon, you need to convert it to PNG first (since `flutter_launcher_icons` requires PNG format).

## Option 1: Using Online Converter (Easiest)

1. Go to https://convertio.co/svg-png/ or any SVG to PNG converter
2. Upload `assets/icons/logo.svg`
3. Set output size to **1024x1024** pixels
4. Download and save as `assets/icons/logo_icon.png`
5. Run: `flutter pub run flutter_launcher_icons`

## Option 2: Using Python Script

If you have Python and can install cairosvg:

```bash
pip3 install cairosvg --break-system-packages
python3 scripts/convert_svg_to_png.py
flutter pub run flutter_launcher_icons
```

## Option 3: Using Design Tools

- Open `assets/icons/logo.svg` in Figma, Sketch, or Adobe Illustrator
- Export as PNG at 1024x1024 pixels
- Save as `assets/icons/logo_icon.png`
- Run: `flutter pub run flutter_launcher_icons`

Once `logo_icon.png` is created, the launcher icons will be generated automatically.

