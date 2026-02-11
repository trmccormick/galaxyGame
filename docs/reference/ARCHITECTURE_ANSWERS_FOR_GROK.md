# ANSWERS: Game Architecture Questions for Seeding & Terrain

## 1. Seeding Data Structure - JSON Schema

### File Locations
```
data/json-data/star_systems/
├── sol-complete.json      # Complete Sol system (canonical)
├── aol-732356.json        # AOL-732356 system
├── atjd-566085.json       # ATJD-566085 system
└── sol.json               # Partial/test (DO NOT USE)
```

### JSON Schema Structure

**Top Level:**
```json
{
  "galaxy": {
    "name": "Milky Way",
    "identifier": "MILKY-WAY"
  },
  "solar_system": {
    "name": "Sol",
    "identifier": "SOL-01"
  },
  "stars": [...],
  "celestial_bodies": {
    "terrestrial_planets": [...],
    "gas_giants": [...],
    "ice_giants": [...],
    "dwarf_planets": [...],
    "asteroids": [...]
  }
}
```

**Celestial Body Structure:**
```json
{
  "name": "Earth",
  "identifier": "EARTH-01",
  "type": "terrestrial",
  
  // CRITICAL ATTRIBUTES (all required by model):
  "size": 1.0,                    // ← This was missing in mapping!
  "mass": 5.972e24,               // kg
  "radius": 6371000.0,            // meters
  "density": 5514.0,              // kg/m³
  "gravity": 9.807,               // m/s²
  "surface_temperature": 288.0,   // Kelvin
  "albedo": 0.3,                  // 0-1
  
  // ORBITAL DATA:
  "orbital_period": 365.25,       // days
  "orbits": [{
    "around": "Primary Star",
    "semi_major_axis_au": 1.0,
    "eccentricity": 0.0167,
    "inclination_deg": 0.0
  }],
  
  // OPTIONAL ATTRIBUTES:
  "insolation": 1361.0,           // W/m²
  "geological_activity": 75,      // 0-100 scale
  "known_pressure": 1.0,          // atm
  
  // COMPLEX NESTED OBJECTS:
  "atmosphere": {
    "composition": {
      "N2": {"percentage": 78.0},
      "O2": {"percentage": 21.0}
    },
    "pressure": 1.0,
    "total_atmospheric_mass": 5.15e18
  },
  
  "hydrosphere": {
    "liquid_bodies": {
      "oceans": true
    },
    "composition": {"H2O": 100.0},
    "state_distribution": {
      "liquid": 97.0,
      "solid": 3.0
    },
    "total_hydrosphere_mass": 1.4e21
  },
  
  "geosphere_attributes": {
    "geological_activity": 75,
    "tectonic_activity": true,
    "total_crust_mass": 2.6e22,
    "total_mantle_mass": 4.0e24,
    "total_core_mass": 1.9e24
  },
  
  // CHILD OBJECTS (nested arrays):
  "moons": [
    {
      "name": "Luna",
      "identifier": "LUNA-01",
      "type": "moon",
      "orbiting_body": "Earth",  // Parent reference
      // ... same structure as parent
    }
  ]
}
```

### Validation Rules & Transformations

**In SystemBuilderService:**
```ruby
# Required attributes (must be present in JSON):
validates :name, presence: true
validates :identifier, presence: true
validates :size, presence: true, numericality: true  # ← Was failing!
validates :mass, presence: true, numericality: true
validates :radius, presence: true, numericality: true

# Transformations applied:
- type: Maps JSON string to STI class
  "terrestrial" → CelestialBodies::Planets::Rocky::TerrestrialPlanet
  "gas_giant" → CelestialBodies::Planets::Gaseous::GasGiant
  
- atmosphere: Stored as JSONB column
- hydrosphere: Stored as JSONB column
- geosphere_attributes: Stored as JSONB column

# Parent-child relationships:
- Moons reference parent by identifier
- Parent must exist BEFORE moon creation
- If parent fails, moon skips (that's why all moons failed)
```

**Critical Discovery:**
The `size` field is a **normalized radius** (Earth = 1.0). It's used for:
- UI display (relative size comparisons)
- Game mechanics (resource extraction rates)
- Habitat construction costs

**Why it was missing:** SystemBuilder was only mapping fields that existed in the OLD schema. When `size` was added to the model later, the mapping code wasn't updated.

---

## 2. Terrain Generation Dependencies

### Component Architecture

```
User loads monitor view
  ↓
MonitorController#show
  ↓
AutomaticTerrainGenerator.generate_base_terrain(celestial_body)
  ↓
  ┌─────────────────────────────────────┐
  │ Does NASA GeoTIFF exist?            │
  └─────────────────────────────────────┘
           ↓YES                    ↓NO
  Load NASA heightmap     PlanetaryMapGenerator.generate_with_patterns
     (WORKS)                       (BROKEN - grid patterns)
           ↓                              ↓
    Return terrain               Return terrain
```

### PlanetaryMapGenerator - Key Inputs/Outputs

**File:** `app/services/ai_manager/planetary_map_generator.rb`

**Inputs:**
```ruby
def generate_planetary_map_with_patterns(
  planet: CelestialBodies::CelestialBody,  # Target planet
  sources: [],                              # Training sources (currently empty!)
  options: {                                # Grid dimensions
    width: 80,
    height: 50
  }
)
```

**Current (Broken) Logic:**
```ruby
# When sources is empty, falls back to sine wave:
elevation = Math.sin(x * 0.1) * Math.cos(y * 0.1) + rand * 0.5
# ↑ Creates grid pattern!
```

**Desired (Fixed) Logic:**
```ruby
# Should do:
1. Load Earth Civ4 map → Extract landmass SHAPES
2. Load NASA pattern file for planet type → Get elevation VARIANCE
3. Combine: Realistic elevation on Earth-like continents
```

**Outputs:**
```ruby
{
  elevation: [[height_grid]],        # 2D array of elevations (meters)
  biomes: [[biome_grid]],            # 2D array of biome types
  resources: [{x, y, type}],         # Resource markers
  strategic_markers: [{x, y, value}],
  metadata: {
    source: 'nasa_patterns_with_landmass',
    generation_method: 'learned_from_nasa_data'
  }
}
```

### External Data Sources

**NASA GeoTIFFs (Real Data):**
```
Location: app/data/geotiff/processed/
Files:
  - geotiff_earth_8192x4096.tif      # ETOPO 2022
  - geotiff_mars_5760x2880.tif       # MOLA
  - geotiff_luna_5760x2880.tif       # LOLA
  - geotiff_mercury_2880x1440.tif    # MESSENGER
  - geotiff_venus_2880x1440.tif      # Magellan
  - geotiff_titan_900x450.tif        # Cassini
  - geotiff_vesta_1800x900.tif       # Dawn

Used by: AutomaticTerrainGenerator ONLY for Sol bodies
Access: Direct file read via GDAL bindings
```

**NASA Pattern Files (Learned Statistics):**
```
Location: app/data/ai_manager/
Files:
  - geotiff_patterns_earth.json
  - geotiff_patterns_mars.json
  - geotiff_patterns_luna.json
  - geotiff_patterns_mercury.json
  - geotiff_patterns_venus.json
  - geotiff_patterns_titan.json
  - geotiff_patterns_vesta.json

Contains:
{
  "elevation_stats": {
    "mean": 450.2,
    "variance": 890000.0,
    "min": -11000,
    "max": 8848
  },
  "crater_patterns": {...},
  "terrain_roughness": {...}
}

Used by: PlanetaryMapGenerator for procedural generation
Generated by: scripts/lib/pattern_extractor.rb
```

**Civ4/FreeCiv Maps (Landmass Shapes):**
```
Location: app/data/maps/
Files:
  - civ4/earth/Earth.Civ4WorldBuilderSave
  - freeciv/earth/earth-180x90-v1-3.sav

Contains:
  - Continent/ocean patterns
  - Mountain range placement
  - River networks
  - Biome distribution

Used by: PlanetaryMapGenerator to get realistic landmass shapes
Currently: NOT BEING USED (that's the bug!)
```

### Integration Between Generators

**AutomaticTerrainGenerator** (coordinator):
```ruby
def generate_base_terrain(celestial_body)
  # Priority 1: Real NASA data (Sol bodies only)
  if nasa_geotiff_available?(celestial_body.name)
    return load_nasa_terrain(celestial_body)
  end
  
  # Priority 2: AI procedural (exoplanets)
  # THIS IS BROKEN - uses sine waves instead of patterns
  result = planetary_map_generator.generate_planetary_map_with_patterns(
    planet: celestial_body,
    sources: [],  # ← Should load NASA patterns here!
    options: { width: 80, height: 50 }
  )
  
  return format_terrain_data(result)
end
```

**PlanetaryMapGenerator** (procedural engine):
```ruby
def generate_planetary_map_with_patterns(planet:, sources:, options:)
  # Should do:
  # 1. Load landmass reference from Civ4
  # 2. Load NASA patterns based on planet type
  # 3. Generate realistic terrain
  
  # Currently does:
  # Uses sine waves (creates grid pattern)
end
```

---

## 3. Admin Interface Data Flow

### Monitor View Request Flow

```
User: GET /admin/celestial_bodies/:id/monitor
  ↓
CelestialBodiesController#monitor
  │
  ├─ Load celestial_body from database
  │
  ├─ Generate terrain data:
  │   terrain_map = @celestial_body.geosphere.terrain_map
  │   ↓
  │   GeosphereService.generate_terrain_map(celestial_body)
  │   ↓
  │   AutomaticTerrainGenerator.generate_base_terrain(celestial_body)
  │   ↓
  │   Cache result in geosphere.terrain_map JSONB column
  │
  ├─ Load civilization features (if Earth):
  │   features = CivilizationFeatureLoader.load_all(celestial_body)
  │
  └─ Render: admin/celestial_bodies/monitor.html.erb
      │
      ├─ JavaScript receives terrain data
      ├─ Canvas renders elevation as heightmap
      └─ Layers toggle (hydrosphere, biomes, civilization)
```

### Terrain Data Structure in View

**Controller passes to view:**
```ruby
@terrain_map = {
  elevation: [[height_array]],    # 80x50 or 1800x900 grid
  biomes: [[biome_array]],
  width: 80,
  height: 50,
  metadata: {
    source: 'nasa_geotiff' or 'procedural',
    body_name: 'Earth',
    resolution: '80x50'
  }
}
```

**JavaScript rendering (monitor.html.erb):**
```javascript
// Canvas context
const ctx = canvas.getContext('2d');

// Render elevation as grayscale heightmap
terrainMap.elevation.forEach((row, y) => {
  row.forEach((height, x) => {
    const color = heightToColor(height);  // Maps elevation to RGB
    ctx.fillStyle = color;
    ctx.fillRect(x * scale, y * scale, scale, scale);
  });
});

// Apply layers if toggled
if (layers.hydrosphere) renderHydrosphere(ctx);
if (layers.biomes) renderBiomes(ctx);
if (layers.civilization) renderCivilization(ctx);
```

### Error Handling & Fallbacks

**If terrain generation fails:**

```ruby
# In GeosphereService:
def generate_terrain_map(celestial_body)
  begin
    AutomaticTerrainGenerator.generate_base_terrain(celestial_body)
  rescue => e
    Rails.logger.error "Terrain generation failed: #{e.message}"
    
    # Fallback: Return flat terrain
    {
      elevation: Array.new(50) { Array.new(80, 0) },
      biomes: Array.new(50) { Array.new(80, 'plains') },
      metadata: { source: 'fallback', error: e.message }
    }
  end
end
```

**In the view:**
- If terrain data is empty: Shows "No terrain data available"
- If generation throws error: Logs to console, shows fallback message
- If layers fail to render: Gracefully degrades (just shows base elevation)

**Current issue:** When procedural generation creates grid patterns, it doesn't "fail" - it just looks wrong. No error is raised, so monitor displays it.

---

## 4. Testing Environment Setup

### Docker Container Configuration

**Required containers:**
```yaml
# docker-compose.yml
services:
  web:
    image: galaxy_game:latest
    volumes:
      - ./app:/home/galaxy_game/app
      - ./data:/home/galaxy_game/data  # ← CRITICAL: Maps data folder
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=postgresql://...
```

**Key volume mounts:**
```
Host                          → Container
./data                        → /home/galaxy_game/data
./app                         → /home/galaxy_game/app
```

**Why volumes matter:**
- NASA GeoTIFFs are in `data/geotiff/` (large files, not in git)
- Civ4 maps are in `data/maps/civ4/` (also large)
- Pattern files in `data/ai_manager/` (small, in git)

### Environment Variables

**For terrain generation (none needed!):**
- GeoTIFF access: Direct file I/O, no special env vars
- Pattern files: Direct file I/O, no special env vars

**For testing:**
```bash
# In container:
export RAILS_ENV=test
unset DATABASE_URL  # Use test database

# NOT needed for terrain:
# - No API keys
# - No external services
# - No network access
```

### Prerequisites for Data Access

**NASA GeoTIFFs:**
```bash
# Files MUST exist in container at:
/home/galaxy_game/data/geotiff/processed/geotiff_earth_8192x4096.tif
/home/galaxy_game/data/geotiff/processed/geotiff_mars_5760x2880.tif
# etc.

# Check if accessible:
docker exec -it web bash
ls -lh /home/galaxy_game/data/geotiff/processed/

# If missing: Download from NASA (separate process)
```

**Civ4 Landmass Shapes:**
```bash
# Files MUST exist at:
/home/galaxy_game/data/maps/civ4/earth/Earth.Civ4WorldBuilderSave

# Check:
docker exec -it web bash
ls -lh /home/galaxy_game/data/maps/civ4/earth/
```

**NASA Pattern Files:**
```bash
# Files should exist (these ARE in git):
/home/galaxy_game/app/data/ai_manager/geotiff_patterns_earth.json

# Check:
docker exec -it web bash
ls -lh /home/galaxy_game/app/data/ai_manager/geotiff_patterns_*.json
```

### Testing Commands

**Console test (no prerequisites):**
```bash
docker exec -it web rails console

# Test basic terrain generation
planet = CelestialBodies::CelestialBody.find_by(name: 'Earth')
generator = StarSim::AutomaticTerrainGenerator.new
terrain = generator.generate_base_terrain(planet)

puts terrain[:elevation].size  # Should output grid dimensions
```

**File access test:**
```bash
docker exec -it web bash

# Check GeoTIFF access
ls -lh /home/galaxy_game/data/geotiff/processed/

# Check Civ4 access
ls -lh /home/galaxy_game/data/maps/civ4/earth/

# Check pattern files
cat /home/galaxy_game/app/data/ai_manager/geotiff_patterns_earth.json | head -20
```

---

## 5. Documentation Gaps

### High Priority (Document Now)

**StarSim Module:**
```
Location: app/services/star_sim/
Current state: No README.md, minimal inline docs

Services:
- automatic_terrain_generator.rb  # Main coordinator
- system_builder_service.rb       # JSON → Database seeding
- geosphere_service.rb            # Terrain data management

Needed:
- CREATE: app/services/star_sim/README.md
- Document: Flow between services
- Document: When each service is used
- Document: Data format expectations
```

**AI Manager Terrain Components:**
```
Location: app/services/ai_manager/
Current state: Some inline docs, no overview

Services:
- planetary_map_generator.rb      # Procedural generation
- pattern_extractor.rb (scripts/) # Creates pattern files

Needed:
- UPDATE: app/services/ai_manager/README.md
- Document: How patterns are extracted
- Document: How patterns are used
- Document: Pattern file schema
```

**TerraSim Integration:**
```
Location: app/services/terra_sim/
Current state: Mentioned but not implemented

What exists:
- BiomeValidator (being added by Grok)
- DigitalTwinSandbox (placeholder)

What's missing:
- How TerraSim relates to terrain generation
- How terrain validation works
- When/how Digital Twin is used

Needed:
- CREATE: Architectural decision doc
- Clarify: TerraSim vs StarSim responsibilities
```

### Medium Priority (Can Wait)

**Geosphere Model:**
```ruby
# app/models/geosphere.rb
# Current state: Minimal docs

# Document:
- What terrain_map JSONB stores
- When terrain is regenerated vs cached
- How layers are structured
- Grid dimension standards
```

**Monitor View Rendering:**
```javascript
// app/views/admin/celestial_bodies/monitor.html.erb
// Current state: No inline comments

// Document:
- Layer rendering order
- Canvas scaling logic
- Color mapping functions
- Event handlers
```

### Low Priority (Nice to Have)

**Data File Formats:**
```
# Document format of:
- GeoTIFF files (GDAL standards)
- Civ4 .Civ4WorldBuilderSave format
- FreeCiv .sav format
- Pattern JSON schema
```

**Testing Strategy:**
```
# Document:
- Why we skip RSpec for terrain (visual testing needed)
- Console testing workflow
- Manual verification steps
- When to use monitor vs console
```

---

## Summary for Grok

**Immediate Focus:**
1. Fix seeding (you're doing this)
2. After seeding works, fix procedural terrain (GROK_FIX_PROCEDURAL_TERRAIN.md)
3. Pattern files and Civ4 maps already exist in the container

**Key Architecture Points:**
- SystemBuilder maps JSON → Database (size was missing)
- AutomaticTerrainGenerator checks for GeoTIFF, falls back to procedural
- PlanetaryMapGenerator should use patterns but uses sine waves (the bug)
- Monitor view renders cached terrain data from geosphere.terrain_map

**Testing Environment:**
- All data accessible via volume mounts
- No special env vars needed
- Test in Rails console first
- Verify visually in monitor view

**Documentation Gaps:**
- StarSim module needs README
- AI Manager terrain needs better docs
- TerraSim integration unclear
- But: Don't block on documentation - fix functionality first

**Next Steps:**
1. Finish seeding fix
2. Test that planets exist
3. Move to procedural terrain fix
4. Document learnings as you go

Does this clarify the architecture?
