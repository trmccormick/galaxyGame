#!/usr/bin/env python3
"""
Generate placeholder terrain sprite PNG files for TerrainTileRenderer.

Creates 45 images (5 terrains × 9 variants) at 150×150px.
Location: data/images/terrain/{terrain}/variant_XX.png
"""

from PIL import Image, ImageDraw
import os
import sys

# Terrain families and their base colors
TERRAINS = {
    'dust': {
        'base': (184, 156, 102),      # Brown/tan dust
        'accent': (220, 180, 130),
        'dark': (139, 117, 77)
    },
    'frozen': {
        'base': (200, 220, 255),      # Light blue ice
        'accent': (220, 240, 255),
        'dark': (100, 150, 200)
    },
    'regolith': {
        'base': (180, 140, 100),      # Mars-like reddish
        'accent': (210, 160, 120),
        'dark': (120, 90, 60)
    },
    'temperate': {
        'base': (100, 180, 100),      # Green grass
        'accent': (130, 210, 130),
        'dark': (60, 120, 60)
    },
    'volcanic': {
        'base': (80, 80, 80),         # Dark gray/black
        'accent': (120, 120, 120),
        'dark': (40, 40, 40)
    }
}

TILE_SIZE = 150
VARIANT_COUNT = 9

def generate_terrain_variant(terrain_name, variant_index, base_color, accent_color, dark_color):
    """Generate a procedural terrain sprite with pseudo-random noise pattern."""
    img = Image.new('RGB', (TILE_SIZE, TILE_SIZE), base_color)
    draw = ImageDraw.Draw(img)
    
    # Seed the randomness based on terrain and variant for reproducibility
    import random
    random.seed(hash(f"{terrain_name}_{variant_index}"))
    
    # Add noise/texture pattern
    noise_density = 0.15 + (variant_index * 0.01)  # Vary density per variant
    
    for _ in range(int(TILE_SIZE * TILE_SIZE * noise_density / 100)):
        x = random.randint(0, TILE_SIZE - 1)
        y = random.randint(0, TILE_SIZE - 1)
        
        # Mix of accent and dark colors for texture
        color = accent_color if random.random() > 0.5 else dark_color
        draw.point((x, y), fill=color)
    
    # Add some larger features for visual variety
    feature_count = random.randint(3, 8)
    for _ in range(feature_count):
        x = random.randint(10, TILE_SIZE - 20)
        y = random.randint(10, TILE_SIZE - 20)
        size = random.randint(5, 20)
        
        feature_color = tuple(
            max(0, min(255, c + random.randint(-30, 30)))
            for c in dark_color
        )
        draw.ellipse([x, y, x + size, y + size], fill=feature_color, outline=None)
    
    return img

def main():
    base_dir = 'data/images/terrain'
    os.makedirs(base_dir, exist_ok=True)
    
    total_created = 0
    
    for terrain_name, colors in TERRAINS.items():
        terrain_dir = os.path.join(base_dir, terrain_name)
        os.makedirs(terrain_dir, exist_ok=True)
        
        for variant_num in range(1, VARIANT_COUNT + 1):
            filename = os.path.join(terrain_dir, f'variant_{variant_num:02d}.png')
            
            # Generate the sprite
            img = generate_terrain_variant(
                terrain_name,
                variant_num,
                colors['base'],
                colors['accent'],
                colors['dark']
            )
            
            # Save it
            img.save(filename)
            print(f'✅ Created {filename} (150×150px)')
            total_created += 1
    
    print(f'\n✅ Generated {total_created} terrain sprites total')
    print(f'📁 Location: {base_dir}/')
    print(f'🎨 Terrains: {", ".join(TERRAINS.keys())}')
    print(f'📊 Variants per terrain: {VARIANT_COUNT}')

if __name__ == '__main__':
    main()
