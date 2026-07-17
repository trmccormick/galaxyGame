from PIL import Image
import os

# Configuration
INPUT_IMAGE = '/Users/tam0013/Documents/git/galaxyGame/data/images/test-images/Space colonization terrain tileset.png'
OUTPUT_DIR = '/Users/tam0013/Documents/git/galaxyGame/data/images/extracted_tiles'
ROWS = 5
COLS = 9

# Simple even division of the sprite sheet
TILE_W = 1536 // COLS  # 170 pixels
TILE_H = 1024 // ROWS  # 204 pixels

def extract_tiles():
    if not os.path.exists(INPUT_IMAGE):
        print(f"Error: Image not found at {INPUT_IMAGE}")
        return

    img = Image.open(INPUT_IMAGE)
    width, height = img.size
    
    print(f"Image size: {width}x{height}")
    print(f"Grid: {ROWS} rows × {COLS} cols")
    print(f"Tile size: {TILE_W}x{TILE_H}")

    # Create output directory if it doesn't exist
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for r in range(ROWS):
        for c in range(COLS):
            left = c * TILE_W
            top = r * TILE_H
            right = left + TILE_W
            bottom = top + TILE_H
            
            # Crop and save
            tile = img.crop((left, top, right, bottom))
            filename = f"tile_r{r}_c{c}.png"
            tile.save(os.path.join(OUTPUT_DIR, filename))
            
    print(f"Extraction complete! {ROWS * COLS} tiles saved to {OUTPUT_DIR}")

if __name__ == "__main__":
    extract_tiles()