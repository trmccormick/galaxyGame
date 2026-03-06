# Chromakey Phase 3 Sprite Extraction

## Overview
This workflow extracts 32x32 settlement sprites from ChatGPT and Tracy_McCormick PNGs to build the Phase 3 atlas for the Settlement View.

### Input Directory
- `docs/agent/image-generation/`
  - Includes: Tracy_McCormick_288x32.png, ChatGPT PNGs

### Extraction Script
- `chromakey_spritesheet.py`
  - Scans candidate PNGs for 288x32 format
  - Extracts 32x32 tiles (up to 20 total)
  - Builds `settlement_sprites.png` (640x64, 20 tiles)
  - Generates `settlement_atlas.json` (sprite metadata)

### Output Files
- `galaxy_game/app/assets/images/settlement_sprites.png` (atlas)
- `galaxy_game/app/assets/images/settlement_atlas.json` (sprite index)

### Sprite Index
- 20 settlement sprites: domes, factories, robots, panels, labs, farms, cranes, extractors, pads, storage, habitat, solar array, refinery, control tower, greenhouse, vehicle, tank, antenna, reactor, workshop

### Usage
- Run `chromakey_spritesheet.py` to generate atlas and JSON
- Use atlas and index for Phase 3 Settlement View rendering

### Notes
- Add new candidate PNGs to `CANDIDATE_FILES` in the script as needed
- Sprite names and order are defined in the script and JSON
- All output is 32x32 RGBA tiles, arranged in two rows (10 per row)

---
**No code execution performed. This is a documentation and planning workflow only.**
