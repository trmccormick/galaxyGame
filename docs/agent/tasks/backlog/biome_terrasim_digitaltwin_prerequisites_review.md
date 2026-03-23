# [COORDINATION] Biome/TerraSim/DigitalTwin Prerequisites Review

**Created:** 2026-03-07
**Priority:** HIGH (Foundation for Phase 4)
**Agent:** Coordination Agent
**Estimated Time:** 30 minutes (review only)

## Purpose
Review existing tasks related to biomes, TerraSim, and DigitalTwin to ensure proper implementation order and prevent conflicts before Phase 4 development begins.

## Related Tasks Analysis

### 1. Current Active Task: Biome Architecture Review & Cleanup
**File:** `biome_architecture_review_cleanup.md`
**Status:** Ready for implementation
**Priority:** Medium

**Key Actions Required:**
- Skip planet_biome_spec.rb (xdescribe with Phase 4 comment)
- Remove incorrect migration: `20260308031950_add_celestial_body_to_planet_biomes.rb`
- Document correct architecture: PlanetBiome → belongs_to :biosphere

**Dependencies:** BLOCKER: Requires TerraSim Regression Engine (Phase 3)

### 2. Phase 4 Prerequisite: PlanetBiome Bridge
**File:** `planetbiome_bridge_terrasim_prerequisites.md`
**Status:** Backlog (Phase 4 only)
**Priority:** Low

**Key Requirements:**
- PlanetBiome belongs_to :biosphere (correct)
- Bridge in AutomaticTerrainGenerator to create PlanetBiome records
- Fix planet_biome_spec.rb with correct associations

**Dependencies:** BLOCKER: Requires TerraSim Regression Engine (Phase 3)

### 3. DigitalTwin Schema Implementation
**File:** `phase_4_digital_twin_schema.md`
**Status:** Backlog
**Priority:** Medium
**Dependencies:** BLOCKER: Requires TerraSim Regression Engine (Phase 3)

**Key Components:**
- DigitalTwin, SimulationRun, SimulationResult models
- Database schema and migrations
- Cleanup jobs for expired twins

**Dependencies:** Phase 4 planning

### 4. TerraSim Integration Tasks
**Status:** Scattered references, no dedicated task file
**Priority:** TBD

**Current State:**
- TerraSim service exists but is placeholder
- Referenced in multiple architecture docs
- No dedicated implementation task

## Implementation Order Validation

### ✅ SAFE TO IMPLEMENT NOW (Phase 3)
1. **Biome Architecture Review & Cleanup**
   - Cleans up current confusion
   - Documents correct Phase 4 architecture
   - No breaking changes to current functionality

### ⚠️ PHASE 4 ONLY (Do Not Implement Yet)
2. **PlanetBiome Bridge**
   - Requires TerraSim to be functional
   - Depends on biosphere.planet_biomes working
   - Should not be built before TerraSim exists

3. **DigitalTwin Schema**
   - Phase 4 feature
   - Depends on simulation framework

## Critical Findings

### ✅ Architecture is Correct
- **Static Display**: geosphere.terrain_map['biomes'] → surface view ✅
- **Future Dynamic**: biosphere.planet_biomes → TerraSim simulation ✅
- **No Conflicts**: Two separate data paths for different purposes

### ❌ Migration Issue Identified
- Migration `20260308031950_add_celestial_body_to_planet_biomes.rb` is wrong
- Must be removed before Phase 4
- PlanetBiome should belong_to :biosphere, not :celestial_body

### ⚠️ Spec Handling
- planet_biome_spec.rb currently fails (5 failures)
- Should be marked xdescribe for Phase 4, not forced green
- Correct associations will be tested when Phase 4 implements TerraSim

## Recommended Action Plan

### Immediate (This Week)
1. **Implement Biome Architecture Review & Cleanup**
   - Execute the medium priority task
   - Remove wrong migration
   - Document correct architecture

2. **Mark Phase 4 Tasks Clearly**
   - Ensure all TerraSim/DigitalTwin tasks are marked "Phase 4 Only"
   - Add clear dependencies and warnings

### Phase 4 Preparation (Future)
3. **Create TerraSim Implementation Task**
   - Dedicated task for TerraSim service implementation
   - Should precede PlanetBiome bridge

4. **Validate Prerequisites**
   - Before implementing PlanetBiome bridge, ensure:
     - TerraSim service is functional
     - Biosphere model has planet_biomes association
     - Biome lookup table is populated

## Success Criteria
- ✅ Biome Architecture Review task completed
- ✅ Wrong migration removed
- ✅ Phase 4 tasks properly gated
- ✅ Clear implementation order documented
- ✅ No premature TerraSim/DigitalTwin work

## Risk Mitigation
- **Phase 4 tasks blocked** until prerequisites are clear
- **Current functionality preserved** (terrain display works)
- **Documentation updated** with correct architecture
- **No breaking changes** to Phase 3 features</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/biome_terrasim_digitaltwin_prerequisites_review.md