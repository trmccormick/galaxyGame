# External References & Inspirations

This document tracks external projects that have influenced Galaxy Game's design. We use concepts and patterns from these projects while respecting intellectual property rights.

---

## FreeMars (Standalone Java Game)

**Repository:** https://github.com/arikande/FreeMars  
**Author:** Deniz ARIKAN  
**Last Updated:** ~2014 (10+ years ago)  
**License:** ⚠️ **NO LICENSE FILE** - All rights reserved by default

### What FreeMars Is
A standalone Java Mars colonization game (NOT a FreeCiv mod). Features include:
- Turn-based Mars colonization
- Earth-Mars trade economy
- Terraforming mechanics
- Independence/rebellion endgame

### Licensing Status

| Aspect | Status |
|--------|--------|
| LICENSE file | ❌ Not present |
| Copyright headers | `@author Deniz ARIKAN` only |
| Open source indicator | None |

**Legal Implication:** Without an explicit open-source license, default copyright applies. We cannot use code or assets directly.

### What We CAN Use (Concepts Only)

These are ideas/patterns we've reimplemented from scratch:

#### 1. Dynamic Pricing Formula
FreeMars uses supply/demand-based pricing between Earth and Mars:
```
buyPrice = minPrice + (1 - currentQuantity/maxDemand) × (maxPrice - minPrice)
sellPrice = (buyPrice + markup) × multiplier
```
**Our Implementation:** Applied to GCC market mechanics in `MarketPriceService`

#### 2. TilePaintModel Caching Pattern
FreeMars caches per-tile render data for performance:
- Terrain images by direction (for blending)
- Vegetation overlay
- Resource/bonus overlays
- Improvement overlays
- Unit overlays

**Our Implementation:** Planned for Surface View in `TileRenderCache` (not yet implemented)

#### 3. Layered Rendering Order
FreeMars paints map in strict layer order:
1. Terrain (base)
2. Vegetation
3. Tile improvements (roads, irrigation)
4. Bonus resources
5. Collectables
6. Units/settlements
7. UI overlays (paths, selection)

**Our Implementation:** Already similar in `monitor.html.erb` layer system

#### 4. Earth-Mars Trade Mechanics
FreeMars tracks per-resource trade data:
- Quantity exported/imported
- Income before taxes
- Tax applied
- Net income

**Our Implementation:** Similar to our `export_history` tracking

#### 5. Independence Mechanic
Late-game option to declare independence from Earth, triggering:
- Trade embargo ("We do not buy from rebels!")
- Expeditionary force sent to Mars
- War scenario

**Our Implementation:** Not yet implemented - interesting late-game scenario

### What We CANNOT Use

| ❌ Prohibited | Reason |
|---------------|--------|
| Source code | No license = all rights reserved |
| PNG/image assets | Copyright protected |
| Tilesets | Must use GPL-licensed FreeCiv tilesets instead |
| Help documentation | Original content |
| Map files (.frm) | Derived works |

### FreeMars Terrain Types (Reference Only)
For our terrain mapping, FreeMars defines these Mars-specific types:
- Wasteland, Desert, Plains, Tundra (habitable)
- Crater, Hills, Mountains (resource-rich)
- Ice (polar, terraformable)
- Swamp (post-terraforming)
- Chasm, Misty Mountains (special)

Transformation chain: Mountains → Hills → Wasteland → Plains

### FreeMars Resources (Reference Only)
- **Raw:** Iron, Silica, Minerals, Food, Energy
- **Processed:** Steel, Glass, Chemicals, Lumber, Magnesium, Hydrogen

---

## FreeCiv / Civ4 (GPL Licensed) ✅

**License:** GPL (GNU General Public License)  
**Status:** ✅ Safe to use with attribution

### What We Use

#### Alio Tileset (Alien World) ⭐ PRIMARY
**Location:** `data/tilesets/freeciv-alien/`  
**Source:** https://github.com/freeciv/freeciv/tree/main/data/alio  
**Artists:** GriffonSpade, Peter Arbor, amplio2 team, Wesnoth team

Downloaded assets (~170KB total):

| File | Size | Purpose |
|------|------|---------|
| terrain.png | 23KB | Base terrain, thermal vents, glowing rocks |
| hills.png | 82KB | Elevated terrain (16 directional variants) |
| burrowtubes.png | 5.8KB | **Underground tunnels - perfect for lava tubes!** |
| tunnels.png | 5.6KB | Surface tunnel overlays |
| roads.png | 5.4KB | Road/path infrastructure |
| fortresses.png | 6.2KB | Base/fortification structures |
| riversbrown.png | 17KB | Brown liquid channels |
| riversgreen.png | 17KB | Green liquid channels |

**Why Alio:** Designed for "Alien World" ruleset - a sci-fi colonization scenario with:
- Hostile terrain types (radiating rocks, boiling ocean)
- Alien biomes (alien forest, huge plants)
- Burrowing unit support (burrow tubes)
- Atmospheric hazards (thermal vents)

See `data/tilesets/freeciv-alien/TILESET_ADAPTATION_PLAN.md` for full mapping.

#### Other FreeCiv Assets
- **Tilesets:** Trident 64×64 tiles (Surface View)
- **Map files:** Training data for AI terrain generation
- **Grid conventions:** 2:1 aspect ratio for cylindrical wrap

### Attribution Required
When using FreeCiv assets, include GPL notice and credit FreeCiv project.

### Tile Specifications
- **Grid size:** 126×64 pixels (hex-compatible)
- **Border:** 1 pixel between tiles
- **Adjacency:** 6-direction encoding (n, e, se, s, w, nw)

---

## SimEarth (Conceptual Inspiration)

**Publisher:** Maxis (1990)  
**Status:** Commercial software - concepts only

### Concepts Adopted
- Layered planet view (atmosphere, hydrosphere, biosphere, lithosphere)
- Toggle-able layer visibility
- Planet-scale simulation approach

We do NOT use any SimEarth code or assets.

---

## NASA Public Domain Data ✅

**License:** Public Domain (US Government work)  
**Status:** ✅ Free to use

### Data Sources
- Mars MOLA (elevation)
- Lunar LOLA (elevation)
- Earth SRTM/ETOPO (elevation)
- Various imagery datasets

---

## Contact TODO

### FreeMars Author Outreach

**Status:** 📋 TODO  
**Priority:** MEDIUM (Mars tileset assets would be valuable)

**Contact:** Deniz ARIKAN (GitHub: @arikande)

**Primary Interest:** Mars terrain tilesets and unit graphics
- FreeMars has purpose-built Mars terrain tiles (wasteland, crater, ice, etc.)
- Unit graphics designed for Mars colonization theme
- Would save significant asset creation time

**Note on Code:** Java codebase - code itself is not usable regardless of license (Galaxy Game is Ruby/Rails). Only image assets require permission.

**Purpose:**
1. **Primary:** Request permission to use/convert image assets (terrain tiles, unit sprites)
2. **Secondary:** Inquire about adding an open-source license to the repo
3. **Optional:** Share our project, potential collaboration interest

**Draft Message:**
```
Subject: FreeMars - Permission Request for Mars Terrain Assets

Hi Deniz,

I discovered your FreeMars project on GitHub while researching Mars 
colonization game mechanics. Your terrain tilesets caught my attention - 
the Mars-specific tiles (wasteland, crater, ice, plains, etc.) are 
exactly what we need.

I'm developing Galaxy Game, a web-based (Ruby on Rails) space 
colonization game. Since our tech stack is completely different (you 
used Java/Swing), your code isn't directly usable - but your Mars 
terrain and unit graphics would be incredibly valuable.

I noticed the repository doesn't have a license file. Would you be 
willing to either:

1. Grant permission to use the terrain/unit PNG assets in our project?
   (We'd credit you and link to FreeMars)

2. Or add an open-source license to the FreeMars repo?

The project seems to have been quiet for a while - if you've moved on, 
I'd love to give these assets continued life in a new game. If you're 
still interested in Mars colonization games, I'd be happy to share what 
we're building.

Our project: [link to Galaxy Game repo]

Thanks for considering!
[Your name]
```

**Action Items:**
- [ ] Open GitHub issue on arikande/FreeMars repo
- [ ] Check if @arikande has email in GitHub profile
- [ ] Send message via available channel
- [ ] Wait 2-4 weeks for response
- [ ] If no response, proceed with FreeCiv tilesets only
- [ ] Document outcome here

**Fallback Plan:** If no response or declined, continue with:
- FreeCiv terrain tilesets (GPL) - already have Mars terrain types
- OpenGameArt.org for supplemental Mars assets
- Commission custom assets if budget allows

---

## Version History

| Date | Change |
|------|--------|
| 2026-02-05 | Downloaded FreeCiv Alio tileset (170KB, 8 PNG files) |
| 2026-02-05 | Created TILESET_ADAPTATION_PLAN.md for Alio→Galaxy Game mapping |
| 2026-02-05 | Updated outreach to focus on image assets, raised priority to MEDIUM |
| 2026-02-05 | Initial document created with FreeMars analysis |
