# Resolved Conflicts

**Created**: 2026-07-16  
**Purpose**: Record of architectural conflicts resolved by canonical design intent statements, with implementation evidence.

---

## Conflict Resolution Format

Each resolution includes:
- **Conflict**: What was being debated
- **Canonical Intent**: Which intent statement(s) resolve it
- **Resolution**: What the intent confirms
- **Implementation Evidence**: Code/config references proving resolution is implemented
- **Status**: Implemented, Verified, or Needs Verification
- **Action**: What needs to happen next (if anything)

---

## Resolved Conflicts (6 items)

### Conflict #1: Colony vs Settlement vs Structure Hierarchy

**Conflict**: How should settlement administration be organized? Is Settlement a container, an autonomous unit, or something else? How do structures relate to settlements?

**Canonical Intent**: #1 (Colony = government 2+ settlements), #2 (Settlement = administrative center), #3 (Structure = physical asset)

**Resolution**: Three-tier hierarchy: Colony (government authority) → Settlement (administrative container) → Structure (owned/managed physical asset).

**Implementation Evidence**:
- `app/models/colony.rb` line 5: `has_many :settlements, dependent: :destroy` with `validates :settlements, length: {minimum: 2}`
- `app/models/settlement/base_settlement.rb` line 3: `has_many :structures, foreign_key: :settlement_id`
- `app/models/structures/base_structure.rb` line 4: `belongs_to :settlement, optional: true`

**Code Location**: 
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/colony.rb`
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/settlement/base_settlement.rb`
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/structures/base_structure.rb`

**Status**: ✅ IMPLEMENTED & VERIFIED

**Action**: Document hierarchy for contributors (see DOCUMENTATION_UPDATE_PLAN.md, D7)

---

### Conflict #2: Orbital Settlements vs Static/Dynamic Models

**Conflict**: Should orbital settlements be separate model classes? Or part of the settlement system? Can multiple Ruby models for orbital concern represent same logical entity?

**Canonical Intent**: #4 (Orbital settlements manage constellations of structures; multiple Ruby models not automatically a conflict)

**Resolution**: Orbital settlements use same Settlement::BaseSettlement hierarchy as ground settlements. Root-level OrbitalDepot RETIRED (intentional consolidation). Multiple Ruby models managing different aspects is acceptable.

**Implementation Evidence**:
- `app/models/settlement/orbital_depot.rb` line 1: `class Settlement::OrbitalDepot < BaseSettlement`
- `app/models/orbital_depot.rb` line 1: `# RETIRED — use Settlement::OrbitalDepot` (clearly marked RETIRED)
- `app/models/units/docked_vessel.rb` line 2: Docked vessels belong to orbital depots, managed as structures

**Code Location**:
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/settlement/orbital_depot.rb`
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/orbital_depot.rb`

**Status**: ✅ IMPLEMENTED & VERIFIED

**Action**: Document namespace history (see DOCUMENTATION_UPDATE_PLAN.md, D8)

---

### Conflict #3: Worldhouses — Deployment Unit or Structure?

**Conflict**: Are worldhouses deployable units that move between planets? Or structures that belong to settlements? How do they relate to terrain?

**Canonical Intent**: #5 (Worldhouses = structures built over natural terrain, not deployable units or settlements)

**Resolution**: Worldhouses inherit from BaseStructure. They belong to settlements via settlement_id. They're tied to terrain location, not independently deployable.

**Implementation Evidence**:
- `app/models/structures/worldhouse.rb` line 1: `class Worldhouse < BaseStructure`
- `app/models/structures/worldhouse.rb` line 2: `belongs_to :settlement`
- `app/models/structures/worldhouse.rb` line 3: `has_one :terrain_location, dependent: :destroy`

**Code Location**:
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/structures/worldhouse.rb`

**Status**: ✅ IMPLEMENTED & VERIFIED

**Action**: Document lava-tube enclosure design pattern (see DOCUMENTATION_UPDATE_PLAN.md, D6)

---

### Conflict #4: Biome vs PlanetBiome vs Biosphere Distinctions

**Conflict**: Are these three separate models (biome classification, planetary instance, planet-scale envelope)? Can a world have biomes without a biosphere? Can a habitat have biomes without being a biosphere?

**Canonical Intent**: #5 (worldhouses with terrain-integrated biomes). Extended design discussion clarifies:
- Biome = stable classification
- PlanetBiome = instance (planetary or engineered)
- Biosphere = self-sustaining planet-scale only
- Engineered biome ≠ Biosphere (habitat, requires technological backstop)
- Terraforming-seed may stage toward different world's conditions

**Resolution**: 
- `Biome` = classification (Earth-biome types currently; non-Earth future design intent)
- `PlanetBiome` = instance on a world OR engineered terraforming-seed (dome/lava-tube/habitat)
- `Biosphere` = planet-scale biological envelope (exists only when self-sustaining)
- Worldhouse can have PlanetBiome with NO Biosphere record (engineered incubator, not planetary)
- Terraforming-seeds track target vs current conditions (staged deployment to different worlds)

**Implementation Evidence**:
- `app/models/biome.rb`: Classification system with ranges
- `app/models/planet_biome.rb`: Instances (planetary or engineered)
- `app/models/biosphere.rb`: Planet-level model
- `app/models/structures/worldhouse.rb`: Has PlanetBiome instances (no Biosphere dependency)

**Code Location**:
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/biome.rb`
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/planet_biome.rb`
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/biosphere.rb`
- `/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/structures/worldhouse.rb`

**Status**: ✅ DESIGN CONFIRMED. Implementation verification required:
- Does `planet_biomes.biosphere_id` allow NULL? (Check schema)
- Does `LifeFormDeployment` track target_conditions? (Check model)

**Action**: 
1. Verify schema: `planet_biomes.biosphere_id` NULL allowance
2. Verify or backlog: `LifeFormDeployment` target-condition tracking
3. Update documentation (see DOCUMENTATION_UPDATE_PLAN.md, D10-D11)

---

### Conflict #5: Template Version Drift — Blocker or Acceptable?

**Conflict**: Is template schema evolution (v1 → v7) a problem? Does backward compatibility matter? Are old templates blocking new development?

**Canonical Intent**: #6 (Templates = design documents; version drift is documentation housekeeping), #7 (Blueprint evolution expected; backward compatibility not required during MVP)

**Resolution**: Template drift is intentional. Runtime blueprints separated from templates. Old templates archived; new ones reference latest schema. This is not a blocker or architectural problem — it's normal design iteration.

**Implementation Evidence**:
- `data/json-data/templates/` contains v1.1-v1.7 (intentional development versions)
- `app/services/blueprint_lookup_service.rb`: Loads from `data/json-data/blueprints/`, not templates
- No code references templates at runtime

**Code Location**:
- `/Users/tam0013/Documents/git/galaxyGame/data/json-data/templates/`
- `/Users/tam0013/Documents/git/galaxyGame/app/services/blueprint_lookup_service.rb`

**Status**: ✅ IMPLEMENTED & VERIFIED (Intentional design pattern)

**Action**: Post-MVP consolidation (see PHASE3_CANONICAL_ALIGNMENT_REPORT.md, L1)

---

### Conflict #6: AI Manager — Is 80+ Services a Problem?

**Conflict**: AI Manager has 80+ service files instead of 8 documented files. Is this architecture failure, over-engineering, or natural growth?

**Canonical Intent**: #8 (more services than documented is NOT a blocker; system expected to grow)

**Resolution**: Service growth is healthy. Documentation lags implementation. More services = more concerns successfully separated. This is not an architecture problem — it's a documentation gap.

**Implementation Evidence**:
- `app/services/ai_manager/` contains 80+ independently-concern services
- Services are well-organized (pricing, contracts, exploration, settlement, combat concerns)
- Tests pass; services work together coherently
- Docs describe 8 "core" orchestration services; this is accurate but incomplete

**Code Location**:
- `/Users/tam0013/Documents/git/galaxyGame/app/services/ai_manager/`

**Status**: ✅ IMPLEMENTED & VERIFIED (Growth is healthy; docs need expansion)

**Action**: Restructure AI Manager documentation (see DOCUMENTATION_UPDATE_PLAN.md, D1)

---

## Conflict Summary

| Conflict | Intent(s) | Status | Action |
|---|---|---|---|
| Colony-Settlement-Structure hierarchy | #1, #2, #3 | ✅ Confirmed Design | Document for contributors |
| Orbital settlements models | #4 | ✅ Confirmed Design | Document namespace history |
| Worldhouse structure classification | #5 | ✅ Confirmed Design | Document enclosure pattern |
| Biome/PlanetBiome/Biosphere semantics | #5 + design | ✅ Confirmed Design | Verify schema + update docs |
| Template version drift | #6, #7 | ✅ Confirmed Design | Post-MVP consolidation |
| AI Manager service count | #8 | ✅ Confirmed Design | Expand docs |

---

## Verification Status

**Fully Verified** (code checked, intent matched): 1, 2, 3, 5, 6

**Needs Implementation Verification**:
- **Conflict #4 (Biome/PlanetBiome)**: 
  - Check: Does `planet_biomes.biosphere_id` allow NULL?
  - Check: Does `LifeFormDeployment` track target_conditions?

---

## Next Steps

1. **Documentation Updates**: Update docs for conflicts 1-3, 5-6 (see DOCUMENTATION_UPDATE_PLAN.md)
2. **Implementation Verification**: Verify Conflict #4 schema and model attributes
3. **Backlog Addition**: If target-condition tracking missing, add to backlog as "terraforming enhancements"
4. **Contributor Communication**: Announce resolution of previous "blockers" to clarify MVP readiness
