
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

# Settlement sprite names (update as needed)
SPRITE_NAMES = [
    "dome", "factory", "robot", "panel", "lab", "farm", "crane", "extractor", "pad", "storage",
    "habitat", "solar_array", "refinery", "control_tower", "greenhouse", "vehicle", "tank", "antenna", "reactor", "workshop"
]

def chromakey_magenta(img):
    # Convert magenta (255,0,255) to transparent
    img = img.convert("RGBA")
    datas = img.getdata()
    newData = []
    for item in datas:
        if item[0] == 255 and item[1] == 0 and item[2] == 255:
            newData.append((255, 0, 255, 0))
        else:
            newData.append(item)
    img.putdata(newData)
    return img

def extract_tiles():
    tiles = []
    for fname in os.listdir(INPUT_DIR):
        if not fname.lower().endswith(".png"):
            continue
        path = os.path.join(INPUT_DIR, fname)
        img = Image.open(path)
        w, h = img.size
        for y in range(0, h, TILE_SIZE):
            for x in range(0, w, TILE_SIZE):
                tile = img.crop((x, y, x + TILE_SIZE, y + TILE_SIZE))
                # Only add fully sized tiles
                if tile.size == (TILE_SIZE, TILE_SIZE):
                    tile = chromakey_magenta(tile)
                    tiles.append(tile)
                if len(tiles) >= TILES_PER_ROW:
                    return tiles[:TILES_PER_ROW]
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
