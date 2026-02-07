# Grok Task: Wire Alio Tileset to Surface View

## Context

We've downloaded the FreeCiv Alio tileset (GPL-2.0+) and created a service to parse it. Now we need to integrate it into the Surface View for rendering planetary maps.

## What's Already Done

### 1. AlioTilesetService (COMPLETE)
**Location:** `galaxy_game/app/services/tileset/alio_tileset_service.rb`

```ruby
# Key methods:
service = Tileset::AlioTilesetService.new
service.load  # Parses all .spec files, returns true/false

# Get tiles by type:
service.get_burrow_tube_tile(n: true, s: true)  # Adjacency-aware
service.get_hill_tile(n: true, e: true)
service.get_feature_tile(:thermal_vent)
service.get_terrain_base('radiating_rocks', 0)

# Body-specific configs:
service.tiles_for_body('Luna')
# => { base: 'radiating_rocks', elevation: 'hills', underground: 'burrow_tube', features: ['glowing_rocks'] }

# For rendering:
service.tile_css('ts.thermal_vent:0')
# => "background-image: url('/tilesets/alio/terrain.png'); background-position: -1px -1px; width: 126px; height: 64px;"

service.tile_data('ts.thermal_vent:0')
# => { 'tile-image' => '/tilesets/alio/terrain.png', 'tile-x' => 1, 'tile-y' => 1, ... }
```

### 2. Tileset Assets (COMPLETE)
**Location:** `galaxy_game/public/tilesets/alio/`
- terrain.png (23KB) - base terrain, features
- hills.png (82KB) - 16 elevation variants
- burrowtubes.png (5.8KB) - 64 lava tube connection patterns
- tunnels.png (5.6KB) - 64 tunnel patterns
- roads.png (5.4KB) - infrastructure
- fortresses.png (6.2KB) - bases
- riversbrown.png, riversgreen.png (17KB each) - liquids

**Tile Grid:** 126×64 pixels, 1px border

### 3. Tests (COMPLETE)
**Location:** `galaxy_game/spec/services/tileset/alio_tileset_service_spec.rb`
- 25 passing tests
- Run: `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/tileset/alio_tileset_service_spec.rb'`

## YOUR TASK: Integrate Alio into Surface View

### Files to Modify

#### 1. Controller: Add Alio tileset option
**File:** `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb`
**Method:** `def surface` (line ~67)

Add:
```ruby
def surface
  @geological_features = load_geological_features
  @ai_missions = load_ai_missions
  @sphere_summary = build_sphere_summary
  @tileset_name = params[:tileset] || 'alio'  # Changed default
  
  # NEW: Load Alio service for body-specific tile config
  if @tileset_name == 'alio'
    @alio_service = Tileset::AlioTilesetService.new
    @alio_service.load
    @alio_tile_config = @alio_service.tiles_for_body(@celestial_body.name)
  end
end
```

#### 2. View: Add Alio option to tileset selector
**File:** `galaxy_game/app/views/admin/celestial_bodies/surface.html.erb`
**Section:** Tileset selector dropdown (~line 47)

Change:
```erb
<select id="tilesetSelect">
    <option value="alio" <%= 'selected' if @tileset_name == 'alio' %>>Alio (Sci-Fi)</option>
    <option value="bigtrident" <%= 'selected' if @tileset_name == 'bigtrident' %>>BigTrident</option>
    <option value="trident" <%= 'selected' if @tileset_name == 'trident' %>>Trident</option>
</select>
```

#### 3. JavaScript: Create Alio tileset loader
**New File:** `galaxy_game/app/assets/javascripts/alio_tileset_loader.js`

```javascript
// Alio Tileset Loader for Surface View
// Handles 126×64 hex-compatible tiles with adjacency encoding

class AlioTilesetLoader {
  constructor() {
    this.tiles = {};
    this.loaded = false;
    this.tileWidth = 126;
    this.tileHeight = 64;
    this.images = {};
  }

  async loadTileset() {
    const imageFiles = [
      'terrain.png', 'hills.png', 'burrowtubes.png', 
      'tunnels.png', 'roads.png', 'fortresses.png'
    ];
    
    const loadPromises = imageFiles.map(file => this.loadImage(file));
    await Promise.all(loadPromises);
    
    this.loaded = true;
    return true;
  }

  loadImage(filename) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        this.images[filename] = img;
        resolve(img);
      };
      img.onerror = reject;
      img.src = `/tilesets/alio/${filename}`;
    });
  }

  // Draw a tile at canvas position
  drawTile(ctx, tileData, destX, destY, scale = 1) {
    const img = this.images[tileData.image];
    if (!img) return false;

    ctx.drawImage(
      img,
      tileData.x, tileData.y,           // Source x, y
      tileData.width, tileData.height,  // Source w, h
      destX, destY,                      // Dest x, y
      tileData.width * scale, tileData.height * scale  // Dest w, h
    );
    return true;
  }

  // Encode adjacency for auto-tiling
  encodeAdjacency(neighbors) {
    const dirs = ['n', 'e', 'se', 's', 'w', 'nw'];
    return dirs.map(d => `${d}${neighbors[d] ? 1 : 0}`).join('');
  }

  // Get burrow tube tile for given neighbors
  getBurrowTubeTile(neighbors) {
    const pattern = this.encodeAdjacency(neighbors);
    // Map pattern to row/col in burrowtubes.png
    // See burrowtubes.spec for full mapping
    return this.calculateTilePosition('burrowtubes.png', pattern);
  }

  calculateTilePosition(image, pattern) {
    // Burrow tube encoding: each direction is a bit
    // n=bit5, e=bit4, se=bit3, s=bit2, w=bit1, nw=bit0
    const bits = {
      n: pattern.includes('n1') ? 1 : 0,
      e: pattern.includes('e1') ? 1 : 0,
      se: pattern.includes('se1') ? 1 : 0,
      s: pattern.includes('s1') ? 1 : 0,
      w: pattern.includes('w1') ? 1 : 0,
      nw: pattern.includes('nw1') ? 1 : 0
    };
    
    // Row is determined by se and nw bits (rows 0-7)
    // Col is determined by n, e, s, w bits (cols 0-7)
    const row = (bits.se << 1) | (bits.nw << 2) | (bits.se && bits.nw ? 4 : 0);
    const col = bits.n | (bits.e << 1) | (bits.s << 2) | (bits.w << 3);
    
    return {
      image: image,
      x: 1 + col * (this.tileWidth + 1),
      y: 1 + row * (this.tileHeight + 1),
      width: this.tileWidth,
      height: this.tileHeight
    };
  }
}

// Export for use
window.AlioTilesetLoader = AlioTilesetLoader;
```

#### 4. View: Pass tile config to JavaScript
**File:** `galaxy_game/app/views/admin/celestial_bodies/surface.html.erb`
**Section:** Script block (~line 160+)

Add after planet data:
```erb
<% if @alio_tile_config %>
// Alio tile configuration for this body
const alioConfig = <%= raw @alio_tile_config.to_json %>;
<% end %>
```

### Testing Your Changes

1. **Unit test still passes:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/tileset/alio_tileset_service_spec.rb'
```

2. **Visual test:**
```bash
# Open browser to: http://localhost:3000/admin/celestial_bodies/3/surface?tileset=alio
# Should see Luna with grey radiating rocks terrain
```

3. **Console test:**
```bash
docker exec -it web bash -c 'rails runner "
s = Tileset::AlioTilesetService.new
s.load
puts s.tiles_for_body(\"Luna\")
puts s.get_burrow_tube_tile(n: true, s: true)
"'
```

## Key Reference Files

| File | Purpose |
|------|---------|
| `app/services/tileset/alio_tileset_service.rb` | Ruby service (DONE) |
| `public/tilesets/alio/*.spec` | Tile definitions |
| `data/tilesets/freeciv-alien/TILESET_ADAPTATION_PLAN.md` | Full mapping docs |
| `docs/developer/EXTERNAL_REFERENCES.md` | Licensing info |
| `docs/developer/SURFACE_VIEW_IMPLEMENTATION_PLAN.md` | Architecture |

## Burrow Tube Auto-Tiling (Key Feature)

The burrow tubes have 64 variants for seamless connections. When rendering a lava tube colony:

```javascript
// For each tube cell, check neighbors and get correct tile
const neighbors = {
  n: hasTubeNorth(x, y),
  e: hasTubeEast(x, y),
  se: hasTubeSoutheast(x, y),
  s: hasTubeSouth(x, y),
  w: hasTubeWest(x, y),
  nw: hasTubeNorthwest(x, y)
};
const tile = loader.getBurrowTubeTile(neighbors);
loader.drawTile(ctx, tile, screenX, screenY);
```

This creates seamless underground tunnel networks - perfect for Luna Marius Hills lava tubes!

## Expected Outcome

After completing this task:
1. Surface view defaults to Alio tileset
2. Luna shows grey radiating rocks with burrow tube option
3. Mars shows rusty radiating rocks
4. Titan shows alien forest
5. Dropdown allows switching between Alio and legacy tilesets

## Notes

- Alio tiles are 126×64 (not 64×64 like Trident) - scale appropriately
- The service is already tested and working
- Focus on the JavaScript integration
- Don't modify the AlioTilesetService - it's complete
