#!/bin/bash

INPUT="/Users/tam0013/Documents/git/galaxyGame/data/images/test-images/Space colonization terrain tileset.png"
OUTPUT_DIR="/Users/tam0013/Documents/git/galaxyGame/data/images/extracted_tiles"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

COLS=9
ROWS=5
TILE_W=170
TILE_H=204
CONTENT_W=141
CONTENT_H=155

# Calculate offset to center content within each tile region
OFFSET_X=$(( (TILE_W - CONTENT_W) / 2 ))
OFFSET_Y=$(( (TILE_H - CONTENT_H) / 2 ))

echo "Extracting ${CONTENT_W}x${CONTENT_H} content from each ${TILE_W}x${TILE_H} tile"
echo "Content offset: ($OFFSET_X, $OFFSET_Y)"

for r in $(seq 0 $((ROWS-1))); do
  for c in $(seq 0 $((COLS-1))); do
    TILE_LEFT=$((c * TILE_W))
    TILE_TOP=$((r * TILE_H))
    
    # Content starts at offset within the tile region
    LEFT=$((TILE_LEFT + OFFSET_X))
    TOP=$((TILE_TOP + OFFSET_Y))
    CROP="${CONTENT_W}x${CONTENT_H}+${LEFT}+${TOP}"
    OUTPUT="${OUTPUT_DIR}/tile_r${r}_c${c}.png"
    
    magick "$INPUT" -crop "$CROP" +repage "$OUTPUT"
  done
done

echo "Extraction complete!"
ls "$OUTPUT_DIR" | wc -l
