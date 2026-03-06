# chromakey_gemini.py - VSCode @Grok/Copilot
from PIL import Image

def clean_gemini_atlas(input_path, output_path):
    img = Image.open(input_path).convert('RGBA')

    # Chromakey magenta #FF00FF → transparent
    data = img.getdata()
    new_data = []
    for item in data:
        # If magenta, make transparent
        if item[0] == 255 and item[1] == 0 and item[2] == 255:
            new_data.append((0, 0, 0, 0))  # Transparent
        else:
            new_data.append(item)

    img.putdata(new_data)

    # Validate 9 tiles (32px boundaries)
    width, height = img.size
    if width != 288 or height != 32:
        print(f"❌ Wrong size: {width}x{height}")
        return False

    tile_changes = 0
    for x in range(32, 288, 32):  # Tile boundaries
        left_color = img.getpixel((x-1, 15))[0:3]   # Sample center
        right_color = img.getpixel((x, 15))[0:3]
        if left_color != right_color:
            tile_changes += 1

    print(f"✅ {tile_changes}/8 tile boundaries detected")
    img.save(output_path)
    print(f"✅ Saved cleaned atlas to {output_path}")
    return True

# Usage - Place gemini_sprites_v2.png in the data/ directory first
if __name__ == "__main__":
    clean_gemini_atlas('data/gemini_sprites_v2.png', 'data/galaxy_surface.png')