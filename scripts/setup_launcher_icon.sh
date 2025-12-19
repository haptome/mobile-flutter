#!/bin/bash

# Script to set up launcher icon from SVG
# This script helps convert logo.svg to PNG and generate launcher icons

echo "🚀 Setting up launcher icon from logo.svg"
echo ""

# Check if logo_icon.png exists
if [ -f "assets/icons/logo_icon.png" ]; then
    echo "✓ logo_icon.png already exists"
    echo "Generating launcher icons..."
    flutter pub run flutter_launcher_icons
    echo ""
    echo "✅ Launcher icons generated successfully!"
    exit 0
fi

echo "⚠️  logo_icon.png not found. You need to convert logo.svg to PNG first."
echo ""
echo "📋 Quick conversion options:"
echo ""
echo "Option 1: Online Converter (Easiest)"
echo "  1. Go to: https://convertio.co/svg-png/"
echo "  2. Upload: assets/icons/logo.svg"
echo "  3. Set size: 1024x1024 pixels"
echo "  4. Download and save as: assets/icons/logo_icon.png"
echo ""
echo "Option 2: Using Python (if cairosvg is installed)"
echo "  python3 scripts/convert_svg_to_png.py"
echo ""
echo "Option 3: Using Design Tools"
echo "  - Open logo.svg in Figma/Sketch/Illustrator"
echo "  - Export as PNG at 1024x1024"
echo "  - Save as assets/icons/logo_icon.png"
echo ""
echo "After creating logo_icon.png, run this script again or:"
echo "  flutter pub run flutter_launcher_icons"

