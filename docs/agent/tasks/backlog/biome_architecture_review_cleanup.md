# [MEDIUM PRIORITY] Biome Architecture Review & Cleanup Task

**Created:** 2026-03-07
**Priority:** Medium
**Estimated Time:** 20 minutes
**Expected Impact:** planet_biome_spec.rb properly skipped, terrain display untouched, architecture clarified

## Current State
- ✅ **geosphere.terrain_map** stores biome grid (working display)
- ❌ **INCORRECT**: PlanetBiome.celestial_body_id migration exists but is wrong
- ❌ **Model confusion**: belongs_to :celestial_body vs Biosphere#has_many :planet_biomes

## Scope (Review Only - No Breaking Changes)
1. **Audit current usage:**
   - `grep -r "PlanetBiome" app/ spec/` (where used?)
   - Confirm terrain generation ignores PlanetBiome records
   - Verify surface_view.js uses geosphere.terrain_map['grid']

2. **Document intended hierarchy:**
   - Static terrain: geosphere.terrain_map (display)
   - Dynamic simulation: biosphere → planet_biomes (TerraSim future)

3. **Minimal spec alignment:**
   - planet_biome_spec.rb should be SKIPPED (marked xdescribe) 
     with comment: "Phase 4 - TerraSim not yet implemented"
   - PlanetBiome model belongs_to :biosphere (not :celestial_body)
     but NO migration yet — Phase 4 only
   - Remove the wrong migration if it still exists

**Correct Architecture (Phase 4 Future Reference):**
- PlanetBiome → belongs_to :biosphere (TerraSim dynamic simulation)
- NOT PlanetBiome → belongs_to :celestial_body (wrong relationship)

## Files to Review
- `app/models/planet_biome.rb`
- `app/models/celestial_bodies/spheres/biosphere.rb`
- `spec/models/planet_biome_spec.rb`
- `app/services/starsim/automatic_terrain_generator.rb`

## Success Criteria
- ✅ **planet_biome_spec.rb SKIPPED cleanly** (not forced green with wrong schema)
- ✅ **Surface view cursor**: "Biome: desert" still works
- ✅ **No terrain generation breakage**
- ✅ **No migrations added**
- 📄 **Architecture decision documented** in task completion notes

## Implementation Steps

### Step 1: Audit Current Usage
```bash
# Find all PlanetBiome references
grep -r "PlanetBiome" app/ spec/
```

### Step 2: Review Model Relationships
- Examine `PlanetBiome` belongs_to relationship
- Check `Biosphere` has_many relationship
- Document current vs intended architecture

### Step 3: Skip PlanetBiome Spec Correctly
- Mark planet_biome_spec.rb as xdescribe with Phase 4 comment
- **CRITICAL**: Remove the incorrect migration `20260308031950_add_celestial_body_to_planet_biomes.rb`
- Document correct architecture: PlanetBiome belongs_to :biosphere (Phase 4)

### Step 4: Verify Terrain Generation
- Confirm `AutomaticTerrainGenerator` doesn't use PlanetBiome
- Validate surface view still works with geosphere.terrain_map

### Step 5: Document Findings
- Create completion documentation
- Update any relevant architecture docs

## Dependencies
- Check if migration `20260308031950_add_celestial_body_to_planet_biomes.rb` has been run
- Backup database state if migration was applied

## Risk Assessment
- **Medium Risk**: Migration removal if already run in production
- **Mitigation**: Check migration status before removal, rollback if necessary
- **Fallback**: Keep migration but mark as deprecated for Phase 4 correction

## Testing
- Confirm planet_biome_spec.rb is properly skipped (shows as pending, not failed)
- Verify surface view biome cursor functionality
- Confirm terrain generation still works

## Completion Checklist
- [ ] PlanetBiome usage audit completed
- [ ] Model relationships documented
- [ ] planet_biome_spec.rb passes
- [ ] Surface view cursor works
- [ ] Terrain generation unaffected
- [ ] Documentation created