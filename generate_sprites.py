from PIL import Image, ImageDraw
import random

TILE_SIZE = 32
TILES = [
    ("Ocean", "#1e3a8a"), ("Plains", "#84cc16"), ("Desert", "#f4a261"),
    ("Forest", "#15803d"), ("Mountains", "#64748b"), ("Tundra", "#60a5fa"),
    ("Grasslands", "#4ade80"), ("Swamp", "#6b7280"), ("Jungle", "#059669")
]

atlas = Image.new("RGBA", (TILE_SIZE * len(TILES), TILE_SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(atlas)

for i, (name, color) in enumerate(TILES):
    x_offset = i * TILE_SIZE
    draw.rectangle([x_offset, 0, x_offset + TILE_SIZE, TILE_SIZE], fill=color)
    # Pixel art noise
    for _ in range(40):
        nx = random.randint(x_offset, x_offset + TILE_SIZE - 1)
        ny = random.randint(0, TILE_SIZE - 1)
        draw.point((nx, ny), fill=(255, 255, 255, 30))

atlas.save("app/assets/images/galaxy_surface.png")
print("✅ galaxy_surface.png = 288x32 PERFECT")
