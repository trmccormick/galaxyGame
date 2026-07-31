#!/usr/bin/env python3
"""
Generate placeholder unit sprite PNG files for surface view units.

Creates 16 unit sprites (32×32px per sprite in a tileset-style approach).
Location: data/images/unit_sprites/sprite_XX.png
"""

from PIL import Image, ImageDraw
import os

# Unit types (16 total) with colors
UNITS = [
    {'name': 'soldier', 'color': (200, 50, 50), 'accent': (255, 100, 100)},      # Red
    {'name': 'worker', 'color': (100, 100, 200), 'accent': (150, 150, 255)},    # Blue
    {'name': 'settler', 'color': (100, 200, 50), 'accent': (150, 255, 100)},   # Green
    {'name': 'scout', 'color': (200, 150, 50), 'accent': (255, 200, 100)},     # Orange
    {'name': 'trader', 'color': (150, 100, 200), 'accent': (200, 150, 255)},   # Purple
    {'name': 'diplomat', 'color': (200, 200, 50), 'accent': (255, 255, 100)},  # Yellow
    {'name': 'spy', 'color': (50, 50, 50), 'accent': (150, 150, 150)},         # Grey
    {'name': 'general', 'color': (200, 50, 200), 'accent': (255, 100, 255)},   # Magenta
    {'name': 'engineer', 'color': (100, 150, 200), 'accent': (150, 200, 255)}, # Light Blue
    {'name': 'scientist', 'color': (100, 200, 200), 'accent': (150, 255, 255)},# Cyan
    {'name': 'priest', 'color': (200, 100, 150), 'accent': (255, 150, 200)},   # Pink
    {'name': 'merchant', 'color': (150, 150, 50), 'accent': (200, 200, 100)},  # Olive
    {'name': 'barbarian', 'color': (100, 50, 50), 'accent': (200, 100, 100)},  # Dark Red
    {'name': 'nomad', 'color': (150, 100, 50), 'accent': (200, 150, 100)},     # Brown
    {'name': 'peasant', 'color': (100, 100, 50), 'accent': (150, 150, 100)},   # Khaki
    {'name': 'knight', 'color': (150, 150, 150), 'accent': (200, 200, 200)},   # Silver
]

TILE_SIZE = 32

def generate_unit_sprite(unit_type, base_color, accent_color):
    """Generate a simple unit sprite."""
    img = Image.new('RGB', (TILE_SIZE, TILE_SIZE), (0, 0, 0))  # Black background
    draw = ImageDraw.Draw(img)
    
    # Draw a simple circle representing the unit
    center = TILE_SIZE // 2
    radius = TILE_SIZE // 3
    
    # Draw outer circle (unit body)
    draw.ellipse(
        [center - radius, center - radius, center + radius, center + radius],
        fill=base_color,
        outline=accent_color,
        width=2
    )
    
    # Draw a marker/symbol in the center
    marker_size = radius // 2
    draw.ellipse(
        [center - marker_size, center - marker_size, center + marker_size, center + marker_size],
        fill=accent_color,
        outline=None
    )
    
    return img

def main():
    base_dir = 'data/images/unit_sprites'
    os.makedirs(base_dir, exist_ok=True)
    
    total_created = 0
    
    for i, unit_data in enumerate(UNITS):
        filename = os.path.join(base_dir, f'sprite_{i:02d}.png')
        
        # Generate the sprite
        img = generate_unit_sprite(
            unit_data['name'],
            unit_data['color'],
            unit_data['accent']
        )
        
        # Save it
        img.save(filename)
        print(f'✅ Created {filename} (32×32px) — {unit_data["name"]}')
        total_created += 1
    
    print(f'\n✅ Generated {total_created} unit sprites total')
    print(f'📁 Location: {base_dir}/')
    print(f'🎖️  Units: {", ".join([u["name"] for u in UNITS])}')

if __name__ == '__main__':
    main()
