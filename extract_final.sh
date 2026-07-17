#!/bin/bash

INPUT="/Users/tam0013/Documents/git/galaxyGame/data/images/test-images/Space colonization terrain tileset.png"
OUTPUT_DIR="/Users/tam0013/Documents/git/galaxyGame/data/images/extracted_tiles"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

COLS=9
ROWS=5
TILE_W=137
TILE_H=145
MARGIN_H=30  # Horizontal gap/margin
MARGIN_V=50  # Vertical gap/margin

echo "Extracting ${TILE_W}x${TILE_H} tiles"
echo "Starting at (30, 50) with gaps: H=${MARGIN_H}, V=${MARGIN_V}"

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
echo "Total tiles: $(ls "$OUTPUT_DIR" | wc -l)"
echo ""
echo "Verifying tile positions:"
echo "  r0_c8 should start at: $((MARGIN_H + 8 * (TILE_W + MARGIN_H))), $((MARGIN_V + 0 * (TILE_H + MARGIN_V)))"
echo "  r0_c8 should end at: $((MARGIN_H + 8 * (TILE_W + MARGIN_H) + TILE_W)), $((MARGIN_V + 0 * (TILE_H + MARGIN_V) + TILE_H))"
