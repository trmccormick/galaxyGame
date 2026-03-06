# Chromakey Gemini Sprite Processor

## Purpose
Processes Gemini/ChatGPT-generated sprite atlases by:
1. Removing magenta (#FF00FF) backgrounds (chromakey)
2. Validating sprite dimensions (288x32 for 9×32px tiles)
3. Detecting tile boundaries for quality assurance

## Usage
1. Generate `gemini_sprites_v2.png` using the prompt in `docs/agent/outputs/PHASE_2_SPRITE_SHEET_PROMPT.md`
2. Place the file in the `data/` directory
3. Run: `python chromakey_gemini.py`
4. Output: `data/galaxy_surface.png` (cleaned sprite atlas)

## Requirements
- Python 3.x with Pillow (PIL) installed
- Input: 288×32 pixel PNG with magenta backgrounds
- Output: Same dimensions with transparent backgrounds

## Validation
- Checks for exact 288×32 dimensions
- Counts color transitions at 32px boundaries (should detect 8 transitions for 9 tiles)
- Reports success/failure with detailed feedback

## Integration
The cleaned `galaxy_surface.png` will be used in the JSON tileset system for Phase 2 Regional View terrain rendering.