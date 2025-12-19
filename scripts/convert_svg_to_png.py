#!/usr/bin/env python3
"""
Simple script to convert SVG to PNG for launcher icon.
Requires: pip install cairosvg
"""

import sys
import os

try:
    import cairosvg
except ImportError:
    print("Error: cairosvg not installed.")
    print("\nTo install cairosvg, try one of these options:")
    print("1. pip3 install cairosvg --break-system-packages")
    print("2. pip3 install --user cairosvg")
    print("3. Use a virtual environment: python3 -m venv venv && source venv/bin/activate && pip install cairosvg")
    print("\nAlternatively, convert the SVG to PNG manually using:")
    print("- Online converter: https://convertio.co/svg-png/")
    print("- Design tools: Figma, Sketch, Adobe Illustrator")
    print("\nSave the PNG as: assets/icons/logo_icon.png (1024x1024 pixels)")
    sys.exit(1)

def convert_svg_to_png(svg_path, png_path, size=1024):
    """Convert SVG to PNG at specified size."""
    try:
        cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=size, output_height=size)
        print(f"✓ Successfully converted {svg_path} to {png_path} ({size}x{size})")
        return True
    except Exception as e:
        print(f"✗ Error converting SVG: {e}")
        return False

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    svg_path = os.path.join(project_root, "assets", "icons", "logo.svg")
    png_path = os.path.join(project_root, "assets", "icons", "logo_icon.png")
    
    if not os.path.exists(svg_path):
        print(f"Error: SVG file not found at {svg_path}")
        sys.exit(1)
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(png_path), exist_ok=True)
    
    # Convert to PNG (1024x1024 for high quality)
    if convert_svg_to_png(svg_path, png_path, size=1024):
        print(f"\nPNG icon created at: {png_path}")
        print("You can now run: flutter pub run flutter_launcher_icons")
    else:
        sys.exit(1)

