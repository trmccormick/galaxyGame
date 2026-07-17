#!/bin/bash

INPUT="/Users/tam0013/Documents/git/galaxyGame/data/images/test-images/Space colonization terrain tileset.png"
OUTPUT_DIR="/Users/tam0013/Documents/git/galaxyGame/data/images/extracted_tiles"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

COLS=9
ROWS=5
TILE_W=141
TILE_H=155

# Image analysis: 
# Total: 1536x1024
# Content: 9*141=1269 width, 5*155=775 height
# Remaining: 1536-1269=267 H, 1024-775=249 V
# Gaps: 10 horizontal (sides + between), 6 vertical (top/bottom + between)
MARGIN_H=27      # Distributed margin/gap
MARGIN_V=41     # Try 41 instead of 42

echo "Extracting ${TILE_W}x${TILE_H} tiles with margins H=${MARGIN_H}, V=${MARGIN_V}"

for r in $(seq 0 $((ROWS-1))); do
  for c in $(seq 0 $((COLS-1))); do
    LEFT=$((MARGIN_H + c * (TILE_W + MARGIN_H)))
    TOP=$((MARGIN_V + r * (TILE_H + MARGIN_V)))
    CROP="${TILE_W}x${TILE_H}+${LEFT}+${TOP}"
    OUTPUT="${OUTPUT_DIR}/tile_r${r}_c${c}.png"
    
    magick "$INPUT" -crop "$CROP" +repage "$OUTPUT"
  done
done

echo "Extraction complete!"
echo "Check coordinates for r3_c1: LEFT=$((MARGIN_H + 1*(TILE_W + MARGIN_H))), TOP=$((MARGIN_V + 3*(TILE_H + MARGIN_V)))"
ls "$OUTPUT_DIR" | wc -l
