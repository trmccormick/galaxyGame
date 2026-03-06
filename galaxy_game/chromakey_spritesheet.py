import os
from PIL import Image
import json

# Input directory containing candidate PNGs
INPUT_DIR = "docs/agent/image-generation"
# Output spritesheet path
OUTPUT_SPRITESHEET = "app/assets/images/settlement_sprites.png"
# Output atlas JSON path
OUTPUT_ATLAS = "app/assets/images/settlement_atlas.json"

# Sprite and atlas specs
TILE_SIZE = 32
TILES_PER_ROW = 20
ATLAS_WIDTH = TILE_SIZE * TILES_PER_ROW  # 640
ATLAS_HEIGHT = TILE_SIZE * 2             # 64

# Candidate PNGs (add more as needed)
CANDIDATE_FILES = [
    "Tracy_McCormick_Generate_a_single_PNG_image_with_EXACT_dimensions_288x32_pixelsT_36eb60f8-2093-40c1-82f0-9854258e00f7.png",
    # Add other ChatGPT PNG filenames here
]

# Settlement sprite names (update as needed)
SPRITE_NAMES = [
    "dome", "factory", "robot", "panel", "lab", "farm", "crane", "extractor", "pad", "storage",
    "habitat", "solar_array", "refinery", "control_tower", "greenhouse", "vehicle", "tank", "antenna", "reactor", "workshop"
]

assert len(SPRITE_NAMES) == TILES_PER_ROW, "Sprite names must match tile count"

# Extraction logic
def extract_tiles():
    tiles = []
    for fname in CANDIDATE_FILES:
        path = os.path.join(INPUT_DIR, fname)
        if not os.path.exists(path):
            continue
        img = Image.open(path)
        if img.size == (288, 32):
            # 9 tiles per image
            for i in range(9):
                tile = img.crop((i * TILE_SIZE, 0, (i + 1) * TILE_SIZE, TILE_SIZE))
                tiles.append(tile)
        # Add logic for other formats if needed
        if len(tiles) >= TILES_PER_ROW:
            break
    # Pad with blank tiles if needed
    while len(tiles) < TILES_PER_ROW:
        tiles.append(Image.new("RGBA", (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0)))
    return tiles[:TILES_PER_ROW]

def build_spritesheet(tiles):
    sheet = Image.new("RGBA", (ATLAS_WIDTH, ATLAS_HEIGHT), (0, 0, 0, 0))
    for idx, tile in enumerate(tiles):
        y = 0 if idx < 10 else TILE_SIZE
        x = (idx % 10) * TILE_SIZE
        sheet.paste(tile, (x, y))
    sheet.save(OUTPUT_SPRITESHEET)

def build_atlas_json():
    atlas = []
    for idx, name in enumerate(SPRITE_NAMES):
        atlas.append({
            "index": idx,
            "name": name,
            "x": (idx % 10) * TILE_SIZE,
            "y": 0 if idx < 10 else TILE_SIZE,
            "width": TILE_SIZE,
            "height": TILE_SIZE
        })
    with open(OUTPUT_ATLAS, "w") as f:
        json.dump(atlas, f, indent=2)


def main():
    tiles = extract_tiles()
    if all([tile.getbbox() is None for tile in tiles]):
        print("WARNING: No sprites extracted. Output will be blank. Check input PNGs and candidate file list.")
    build_spritesheet(tiles)
    build_atlas_json()

if __name__ == "__main__":
    main()
