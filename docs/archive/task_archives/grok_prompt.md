# Task: Wire Mars Terrain Generation — Three-Layer Combined Approach

## What's Actually Happening (Corrected)

Mars terrain is a three-layer system. Each source has a distinct role:

| Layer | Source | Role | Applied When |
|---|---|---|---|
| **Elevation** | NASA GeoTIFF patterns | Base topography — the real Mars surface | Always, first |
| **Current State** | `MARS1_22b.Civ4WorldBuilderSave` (80x57) | Overlays current biomes, resources, features onto that elevation | During generation |
| **Terraforming Target** | `mars-terraformed-133x64-v2_0.sav` (133x64) | What Mars becomes after terraforming — stored for TerraSim, NOT applied now | Stored only |

The previous prompt incorrectly referenced Arda. Arda is for other worlds. Mars has its own dedicated maps — these two files.

---

## Map Analysis

**Civ4 map (80x57) — Current State of Mars:**
- Desert(1292, 28%) Coast(942, 21%) Plains(750, 16%) Snow(617, 14%) Grass(536, 12%) Ocean(296, 6.5%) Tundra(127, 3%)
- The 942 Coast tiles are ancient dry seabeds — where water *used to be*
- Only 296 actual Ocean tiles — Mars is mostly dry right now
- PlotType breakdown: Hills 53%, Coast 17%, Water 27% — very rugged surface
- Resources already placed: Iron(42), Copper(24), Aluminum(24), Oil(17), Uranium(12), etc.
- Features: Forest(522), Ice(142), Flood_Plains(137), Oasis(26)

**FreeCiv map (133x64) — Terraforming Target:**
- This is what Mars looks like AFTER water and atmosphere arrive
- Deep Ocean(2295, 27%) + Ocean(1087, 13%) = ~40% water coverage
- North hemisphere is almost entirely deep ocean — the Borealis Basin filled
- South hemisphere stays glacier/tundra/desert — matches real Mars geology
- Has real geographic labels: Olympus Mons, Valles Marineris, Tharsis Plateau, Hellas Sea, Argyre Sea, etc.
- Terrain ident chars: `:` deep_ocean, ` ` ocean, `a` glacier, `d` desert, `g` grassland, `p` plains, `h` hills, `m` mountains, `f` forest, `t` tundra, `j` jungle, `s` swamp, `+` lake

---

## The Current Broken Path

```
seeds.rb
  → SystemBuilderService.build!
    → generate_automatic_terrain(body)
      → AutomaticTerrainGenerator.generate_terrain_for_body(body)
        → generate_mars_terrain(body)        ← BREAKS HERE
            1. find_mars_freeciv_map          ← finds the .sav file
            2. extract_elevation_from_freeciv ← RETURNS NIL (stub, line 567)
            3. load_nasa_elevation_data       ← RETURNS NIL (stub, line 576)
            4. generate_procedural_elevation  ← fallback sin/cos noise
```

Neither Civ4 map nor FreeCiv map data actually gets used. `find_mars_civ4_map` exists (line 545) but is never called. `MultiBodyTerrainGenerator` handles NASA elevation for Mars but is never invoked.

---

## What Needs to Change

### 1. Rewrite `generate_mars_terrain` in `automatic_terrain_generator.rb`

```ruby
def generate_mars_terrain(body)
  # Layer 1: Base elevation from NASA patterns
  generator = Terrain::MultiBodyTerrainGenerator.new
  nasa_terrain = generator.generate_terrain('mars', width: 1800, height: 900, options: {})

  # Layer 2: Current-state biomes and resources from Civ4 map
  civ4_path = find_mars_civ4_map
  civ4_data = nil
  if civ4_path
    processor = Import::Civ4MapProcessor.new
    civ4_data = processor.process(civ4_path, mode: :terrain)
    Rails.logger.info "[AutomaticTerrainGenerator] Loaded Mars current-state from Civ4: #{civ4_path}"
  end

  # Layer 3: Terraforming target from FreeCiv map — store it, don't apply it
  freeciv_path = find_mars_freeciv_map
  terraforming_target = nil
  if freeciv_path
    freeciv_processor = Import::FreecivMapProcessor.new
    terraforming_target = freeciv_processor.process(freeciv_path)
    Rails.logger.info "[AutomaticTerrainGenerator] Loaded Mars terraforming target from FreeCiv: #{freeciv_path}"
  end

  # Combine: NASA elevation is the base, Civ4 overlays current biomes/resources on top
  terrain_data = {
    grid: civ4_data ? scale_grid(civ4_data[:biomes], 1800, 900) : nil,
    elevation: nasa_terrain[:elevation],
    biomes: civ4_data ? extract_biome_counts(civ4_data[:biomes]) : {},
    resource_grid: civ4_data ? scale_grid(civ4_data[:features], 1800, 900) : {},
    strategic_markers: civ4_data ? civ4_data[:strategic_markers] : [],
    resource_counts: civ4_data ? count_resources(civ4_data) : {},
    terraforming_target: terraforming_target
  }

  store_generated_terrain(body, terrain_data)
  terrain_data
end
```

- NASA elevation is always the base — `MultiBodyTerrainGenerator` already does Mars correctly
- Civ4 biomes and resources get scaled up from 80x57 to 1800x900 to match the elevation grid
- FreeCiv target is stored in the terrain record but not applied — TerraSim will reference it later when running terraforming sequences
- If either map file is missing, degrades gracefully — elevation still works from NASA alone

### 2. Add a grid scaling helper

Civ4 is 80x57, FreeCiv is 133x64, but elevation is 1800x900. Biome and feature grids need nearest-neighbor scaling to match:

```ruby
def scale_grid(source_grid, target_width, target_height)
  return nil unless source_grid&.any?

  source_height = source_grid.size
  source_width = source_grid.first&.size || 0
  return nil if source_width == 0

  Array.new(target_height) do |y|
    source_y = (y.to_f / target_height * source_height).to_i.clamp(0, source_height - 1)
    Array.new(target_width) do |x|
      source_x = (x.to_f / target_width * source_width).to_i.clamp(0, source_width - 1)
      source_grid[source_y][source_x]
    end
  end
end
```

### 3. Confirm the map file paths resolve

`find_mars_civ4_map` (line 545) globs for `*.Civ4WorldBuilderSave` in `data/maps/civ4/mars/`. The file is `MARS1_22b.Civ4WorldBuilderSave` — confirm it's actually in that directory.

`find_mars_freeciv_map` (line 541) globs for `*.sav` in `data/maps/freeciv/mars/`. The file is `mars-terraformed-133x64-v2_0.sav` — confirm it's there too.

If they're not in those paths, either move the files or update the globs to point where they actually are.

### 4. Clean up duplicate methods

Same pattern as the ISRU evaluator — later definition silently overwrites the earlier one in Ruby.

**In `civ4_map_processor.rb`:**

| Method | Delete | Keep | Why |
|---|---|---|---|
| `extract_biomes_from_terrain` | line 70 | line 130 | Identical copies |
| `add_realistic_variation` | line 282 | line 331 | 331 is biome-aware, has desert boost and land/water floor separation |
| `smooth_elevation` | line 294 | line 371 | Functionally identical, keep 371 for position consistency |
| `private` | line 557 | line 57 | Everything after 57 is already private, 557 is redundant |

**In `automatic_terrain_generator.rb`:**

| Method | Delete | Keep | Why |
|---|---|---|---|
| `nasa_data_available?` | line 357 | line 418 | Both return false |
| `find_nasa_data` | line 362 | line 424 | Both return nil |
| `private` | line 368 | line 93 | Everything after 93 is already private |

---

## What NOT to Change

- `MultiBodyTerrainGenerator` — NASA elevation for Mars already works correctly
- `Civ4MapProcessor` extraction logic — solid, just remove the duplicates above
- `FreecivMapProcessor` — already parses the terrain grid format correctly
- `generate_earth_terrain` — separate path, leave alone
- `generate_luna_terrain` — separate path, leave alone
- `seeds.rb` — no changes needed there

---

## Verification

After changes, a reseed should log all three layers loading:

```
[AutomaticTerrainGenerator] Loaded Mars current-state from Civ4: .../MARS1_22b.Civ4WorldBuilderSave
[AutomaticTerrainGenerator] Loaded Mars terraforming target from FreeCiv: .../mars-terraformed-133x64-v2_0.sav
✅ Generated MARS terrain: 1800x900 with XXXX elevation values
```

If the Civ4 or FreeCiv lines don't appear, the file paths aren't resolving — check what the glob methods are actually returning. If NASA elevation still falls through to procedural noise, `MultiBodyTerrainGenerator` isn't being called — check that the instantiation and `generate_terrain` call are actually executing.
