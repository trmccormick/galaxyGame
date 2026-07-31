#!/usr/bin/env python3
"""
Generate placeholder biome sprite PNG files for BiomeRenderer.

Creates 12 biome images at 142×142px.
Location: data/images/biomes/{biome_name}.png
"""

from PIL import Image, ImageDraw
import os

# Biome definitions with colors and characteristics
BIOMES = {
    'hot_desert': {
        'color': (212, 160, 23),       # Golden/orange
        'accents': [(230, 180, 40), (200, 140, 20)],
        'label': 'Hot Desert'
    },
    'cold_desert': {
        'color': (138, 122, 106),      # Grey-brown
        'accents': [(158, 142, 126), (118, 102, 86)],
        'label': 'Cold Desert'
    },
    'polar_desert': {
        'color': (232, 232, 240),      # White ice
        'accents': [(200, 200, 220), (210, 210, 230)],
        'label': 'Polar Desert'
    },
    'forest': {
        'color': (45, 106, 45),        # Dark green
        'accents': [(65, 126, 65), (25, 86, 25)],
        'label': 'Forest'
    },
    'grasslands': {
        'color': (122, 181, 78),       # Light green
        'accents': [(142, 201, 98), (102, 161, 58)],
        'label': 'Grasslands'
    },
    'jungle': {
        'color': (26, 107, 26),        # Dense green
        'accents': [(46, 127, 46), (6, 87, 6)],
        'label': 'Jungle'
    },
    'tropical_jungle': {
        'color': (10, 74, 10),         # Ultra-dense green
        'accents': [(30, 94, 30), (0, 54, 0)],
        'label': 'Tropical Jungle'
    },
    'savanna': {
        'color': (154, 205, 50),       # Yellow-green
        'accents': [(174, 225, 70), (134, 185, 30)],
        'label': 'Savanna'
    },
    'ocean': {
        'color': (30, 58, 138),        # Deep blue
        'accents': [(50, 78, 158), (10, 38, 118)],
        'label': 'Ocean'
    },
    'plains': {
        'color': (200, 184, 106),      # Tan/beige
        'accents': [(220, 204, 126), (180, 164, 86)],
        'label': 'Plains'
    },
    'swamp': {
        'color': (74, 107, 58),        # Murky green-brown
        'accents': [(94, 127, 78), (54, 87, 38)],
        'label': 'Swamp'
    },
    'tundra': {
        'color': (160, 184, 192),      # Pale blue-grey
        'accents': [(180, 204, 212), (140, 164, 172)],
        'label': 'Tundra'
    }
}

TILE_SIZE = 142

def generate_biome_sprite(biome_name, base_color, accents):
    """Generate a procedural biome sprite with texture."""
    img = Image.new('RGB', (TILE_SIZE, TILE_SIZE), base_color)
    draw = ImageDraw.Draw(img)
    
    # Seed randomness for reproducibility
    import random
    random.seed(hash(biome_name))
    
    # Add noise/texture pattern with varying density
    noise_density = 0.20
    
    for _ in range(int(TILE_SIZE * TILE_SIZE * noise_density / 100)):
        x = random.randint(0, TILE_SIZE - 1)
        y = random.randint(0, TILE_SIZE - 1)
        
        # Mix of accent colors
        color = random.choice(accents)
        draw.point((x, y), fill=color)
    
    # Add some features (mountains, trees, water features)
    feature_count = random.randint(4, 8)
    for _ in range(feature_count):
        x = random.randint(10, TILE_SIZE - 30)
        y = random.randint(10, TILE_SIZE - 30)
        size = random.randint(8, 25)
        
        # Feature color (variation of accents)
        feature_color = random.choice(accents)
        draw.ellipse([x, y, x + size, y + size], fill=feature_color, outline=None)
    
    return img

def main():
    base_dir = 'data/images/biomes'
    os.makedirs(base_dir, exist_ok=True)
    
    total_created = 0
    
    for biome_name, biome_data in BIOMES.items():
        filename = os.path.join(base_dir, f'{biome_name}.png')
        
        # Generate the sprite
        img = generate_biome_sprite(
            biome_name,
            biome_data['color'],
            biome_data['accents']
        )
        
        # Save it
        img.save(filename)
        print(f'✅ Created {filename} (142×142px) — {biome_data["label"]}')
        total_created += 1
    
    print(f'\n✅ Generated {total_created} biome sprites total')
    print(f'📁 Location: {base_dir}/')
    print(f'🌍 Biomes: {", ".join(BIOMES.keys())}')

if __name__ == '__main__':
    main()
