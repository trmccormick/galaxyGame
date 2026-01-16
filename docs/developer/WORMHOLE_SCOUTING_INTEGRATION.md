# Wormhole Scouting Integration

## Overview
Integration between WormholeScoutingService and ProceduralGenerator for on-demand system completion during scouting missions.

## Architecture Intent

### Data Flow
1. **Seed Files** (`data/json-data/star_systems/`) contain real astronomical data
   - Alpha Centauri: 2 confirmed exoplanets
   - YZ Ceti: 1 confirmed exoplanet  
   - Tau Ceti: Known star, minimal planet data
   - **These are READ-ONLY canonical sources**

2. **SOL Features** (`data/json-data/star_systems/sol/celestial_bodies/`) contain known body features
   - Luna lava tubes, Mars craters, etc.
   - Used by lookup services for gameplay (discoveries, base sites)
   - **NOT star systems to be processed**

3. **Generation Happens On-Demand** during wormhole scouting
   - Player opens artificial wormhole → Scout system
   - Natural wormhole discovered → Scout system
   - AI Manager evaluates scouting data for "Prizes" (terraformable worlds, resources)
   - Decision: Build permanent wormhole station or close temporary link

## Current State Issues

### WormholeScoutingService (Line 62)
```ruby
# CURRENT - Just loads seed file
system_data = load_system_data(target_system_name)
```

**Problem**: Returns incomplete seed data (only confirmed exoplanets)

**Needed**: Complete system generation with all body types
```ruby
# SHOULD BE
complete_system = generate_complete_system_from_seed(target_system_name)
```

### ProceduralGenerator Limitation
Current `generate_hybrid_system_from_seed_generic()` only adds:
- 1 terraformable terrestrial per star (if none exist)
- Tags preserved seed bodies with `from_seed=true`

**Missing**:
- Gas giants (H2/He ISRU, gravity assists)
- Ice giants (volatile harvesting)
- Dwarf planets (mining, Ceres-like targets)
- Asteroids (mining, base sites)
- Multiple terrestrials per star

## Required Changes

### 1. Enhance ProceduralGenerator
Add method: `generate_complete_system_from_seed(seed_path)`
- Preserves all seed bodies (`from_seed=true`)
- Fills system with diverse body types:
  - Gas giants: 1-2 per system (resource value)
  - Ice giants: 0-2 per system (volatiles)
  - Terrestrial planets: 2-5 per star (including terraformable templates)
  - Dwarf planets: 1-3 per system (mining)
  - Asteroids: 3-10 per system (resources, bases)

### 2. Integrate with WormholeScoutingService
Update `execute_scouting_mission()` (line 52-82):
```ruby
def execute_scouting_mission(target_system_name)
  # Step 1: Create temporary wormhole
  wormhole = create_scouting_wormhole(target_system_name)
  return { status: :failed, reason: :wormhole_creation_failed } unless wormhole

  # Step 2: Generate complete system from seed
  complete_system = generate_complete_system_from_seed(target_system_name)
  return { status: :failed, reason: :generation_failed } unless complete_system

  # Step 3: Deploy probes and analyze
  probe_results = deploy_scouting_probes(complete_system)
  analysis = analyze_scouting_results(probe_results, complete_system)

  # Step 4: AI evaluation for "Prizes"
  recommendation = generate_investment_recommendation(analysis)

  { status: :success, system_data: complete_system, analysis: analysis, recommendation: recommendation }
end
```

Update `process_natural_discovery()` similarly (line 87-113)

### 3. AI Manager "Prize" Evaluation
Both artificial and natural wormhole paths use same analysis:

**Prize Criteria**:
- Terrestrial planets in habitable zone (within r_ecosphere range)
- Terraformable candidates (atmosphere composition, volatiles, temperature)
- Resource value (gas giants for fuel, ice giants for water/volatiles, asteroids for materials)
- Strategic position (distance from SOL, connectivity)

**Decision Logic**:
- High value (Prize found) → Recommend permanent wormhole station investment
- Medium value (Resources) → Recommend limited exploitation
- Low value (Barren) → Recommend close temporary link

## Pre-Generated Files Cleanup

### Remove Incorrect Hybrids
Delete 41 pre-generated files from `data/json-data/generated_star_systems/`:
- `hybrid_61CYGNI-01_*.json` through `hybrid_YZCETI-01_*.json`
- `hybrid_canyons_*.json` (geographic features, not star systems)
- `hybrid_craters_*.json`  (geographic features)
- `hybrid_lava_tubes_*.json` (geographic features)
- `hybrid_SOL-01_*.json` (SOL is hard-coded, not generated)

**Reason**: Pre-generation is incorrect workflow. Generation happens on-demand during scouting.

### Scripts Become Dev Tools
`scripts/generate_hybrid_system.rb`, `scripts/local_bubble_expand.rb`:
- Testing/development tools only
- Not production workflow
- Used for:
  - Testing generator behavior
  - Validating seed file compatibility
  - Development iteration

## Implementation Order

1. **Documentation** (this file) ✅
2. **Delete pre-generated hybrids** from generated_star_systems/
3. **Enhance ProceduralGenerator**:
   - Add `generate_complete_system_from_seed(seed_path)` method
   - Include all body type generation (gas giants, ice giants, dwarf planets, asteroids)
4. **Update WormholeScoutingService**:
   - Integrate generator call in `execute_scouting_mission()`
   - Integrate generator call in `process_natural_discovery()`
5. **Add RSpec tests**:
   - Test complete system generation preserves seed bodies
   - Test AI analysis identifies "Prizes"
   - Test decision logic for investment recommendations
6. **Update LOCAL_BUBBLE_EXPANSION.md** to clarify on-demand vs pre-generation

## Acceptance Criteria

- ✅ Seed files remain untouched
- ✅ Generated systems include all body types (diverse, realistic)
- ✅ AI Manager evaluates complete system data for strategic value
- ✅ WormholeScoutingService calls generator during scouting (not beforehand)
- ✅ Scripts documented as dev tools only
- ✅ RSpec tests validate workflow
- ✅ Documentation clarifies on-demand generation intent

## References
- Generator: [galaxy_game/app/services/star_sim/procedural_generator.rb](../../galaxy_game/app/services/star_sim/procedural_generator.rb)
- Scouting: [galaxy_game/app/services/ai_manager/wormhole_scouting_service.rb](../../galaxy_game/app/services/ai_manager/wormhole_scouting_service.rb)
- Scripts: [scripts/generate_hybrid_system.rb](../../scripts/generate_hybrid_system.rb)
- Guardrails: [DATA_DRIVEN_SYSTEMS.md](DATA_DRIVEN_SYSTEMS.md)
