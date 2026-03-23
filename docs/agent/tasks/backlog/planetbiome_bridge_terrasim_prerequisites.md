# [BACKLOG] PlanetBiome Bridge - TerraSim Prerequisites

**Created:** 2026-03-07
**Priority:** LOW - Phase 4 only, do not implement until TerraSim begins
**Agent:** TBD
**Estimated Time:** 2-3 hours (Phase 4 implementation)

## Problem
AutomaticTerrainGenerator stores biome data as strings in
geosphere.terrain_map JSONB. PlanetBiome AR records are never
populated. TerraSim and DigitalTwin need PlanetBiome records
to simulate against.

## Required when Phase 4 begins

### 1. Fix PlanetBiome model:
   ```ruby
   belongs_to :biosphere (class: CelestialBodies::Spheres::Biosphere)
   belongs_to :biome
   ```
   (matches existing migration — already correct)

### 2. Add bridge in AutomaticTerrainGenerator:
   After terrain generation → read terrain_map['biomes'] grid
   → create PlanetBiome records per biosphere
   → link to Biome lookup table records

### 3. Fix planet_biome_spec.rb to use :biosphere factory (not :celestial_body)

## Current spec status
planet_biome_spec.rb → 5 failures
Mark as xdescribe with comment "Phase 4 - TerraSim prerequisite"
Do NOT attempt to fix until Phase 4

## Do NOT
- Add celestial_body_id to planet_biomes table
- Force specs green with wrong associations
- Build bridge before TerraSim is ready

## Dependencies
- Phase 4 TerraSim implementation begins
- DigitalTwin schema implemented
- Biome lookup table populated

## Architecture Context

### Current State (Phase 3)
- **Static Display**: geosphere.terrain_map['biomes'] → 2D string grid → surface_view.js
- **Dynamic Simulation**: NOT IMPLEMENTED (Phase 4)

### Phase 4 State (Future)
- **Static Display**: geosphere.terrain_map['biomes'] (unchanged)
- **Dynamic Simulation**: biosphere.planet_biomes → TerraSim simulation

### Bridge Implementation
```ruby
# In AutomaticTerrainGenerator.generate_terrain_for_body()
# AFTER terrain generation completes:

biosphere = celestial_body.biosphere
if biosphere.present?
  biome_grid = terrain_data[:biomes]  # 2D array of biome strings

  # Clear existing records
  biosphere.planet_biomes.destroy_all

  # Create PlanetBiome records
  biome_grid.each_with_index do |row, y|
    row.each_with_index do |biome_name, x|
      next if biome_name.blank?

      biome_record = Biome.find_by(name: biome_name)
      next unless biome_record

      PlanetBiome.create!(
        biosphere: biosphere,
        biome: biome_record,
        x_coordinate: x,
        y_coordinate: y
      )
    end
  end
end
```

## Success Criteria (Phase 4)
- ✅ PlanetBiome records created during terrain generation
- ✅ biosphere.planet_biomes association works
- ✅ TerraSim can query PlanetBiome for simulation
- ✅ DigitalTwin can clone PlanetBiome records
- ✅ planet_biome_spec.rb passes with correct associations

## Testing (Phase 4)
- Terrain generation creates expected PlanetBiome count
- Biosphere has_many planet_biomes works
- Biome lookup table properly linked
- TerraSim can read PlanetBiome data</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/planetbiome_bridge_terrasim_prerequisites.md