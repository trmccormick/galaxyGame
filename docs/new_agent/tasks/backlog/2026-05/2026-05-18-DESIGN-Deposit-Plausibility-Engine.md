---
status: design-needed
priority: HIGH
type: design
system_domain: AI_MANAGER
parent_task: AI Manager Resource Spawning System (2026-05-01)
created: 2026-05-18
supervision_level: 🔴 WATCHED CAREFULLY - Core balance mechanic
assigned_to: Gemini (geological domain) + You (game balance)
depends_on: 2026-05-18-DESIGN-Resource-Deposit-Model-And-Persistence.md
---

# DESIGN: Deposit Plausibility Engine

**Status**: DESIGN INVESTIGATION REQUIRED  
**Priority**: HIGH  
**Type**: design  
**Parent**: AI Manager Resource Spawning System  
**Depends On**: Resource Deposit Model (design must come first)
**Blockers**: Blocks ResourceSpawningService implementation

---

## Problem Statement

The codebase reads body properties like `stored_volatiles`, `materials`, `crust_composition` but **has no system to enforce geological plausibility when spawning deposits**. This allows:

- Deposits of resources that don't exist on that body
- Deposits in impossible locations (water ice on Venus)
- Deposits that violate real scientific data constraints

## Design Principles (Inherited from Architecture)

### Real data drives plausibility
- `stored_volatiles` = scientific upper bound on what exists
- `materials` array = confirmed resource types present
- `crust_composition` = mineral makeup informing ore types
- **Plausibility engine must never allow deposits of resources not in `materials`**

### Equipment tier gates discovery, not existence
- Deposits exist regardless of equipment tier
- Equipment tier determines which deposits are visible/accessible
- Tier-0 equipment: only surface resources revealed
- Tier-2 equipment: deep subsurface resources revealed
- **Model must support this separation**

### Civ4-style clustering (geological realism)
- Rare resources spawn clustered (not evenly distributed)
- Abundant resources spread across multiple regions
- Resource rarity should map to real geological frequency

## Design Questions to Answer

### 1. Input Data Validation

**How do we use CelestialBody properties to constrain deposit placement?**

Current CelestialBody attributes available:
- `stored_volatiles` → total amount (e.g., "H2O": 1000000000) 
- `materials` → confirmed types (e.g., ["regolith", "basalt", "olivine"])
- `crust_composition` → mineral makeup percentages
- `atmosphere` → atmospheric composition
- `geological_features` → known locations

**Design Questions**:
- Is `stored_volatiles` the authoritative source? (max amount of resource that can spawn)
- If Luna has H2O stored_volatiles = 1B kg, how many deposits should we spawn?
- Should deposit density vary by latitude/elevation?

### 2. Plausibility Rules Engine

**What rules determine where each deposit type can spawn?**

Example rules needed:
```
Water Ice (clathrates):
  - Only on cold bodies (avg temp < 200K)
  - Only at polar regions (latitude > 60° or < -60°)
  - Never in sunlit PSRs initially (only after survey)
  - Must have atmosphere or subsurface access
  
Rare Metals (ores):
  - Only where crust_composition contains them
  - Prefer mountainous terrain (elevation > 80%)
  - Density correlates with ore concentration in materials[]
  
Regolith (always available):
  - Surface layers everywhere
  - Depth/composition varies by location
  
Geothermal:
  - Only on volcanically active worlds
  - Only near geological features marked volcanic
  - Rare, high-value
```

**Design Decision Needed**:
- Should rules be hardcoded in a PlausibilityEngine class?
- Or should rules be data-driven (JSON config)?
- How do we handle bodies with no real scientific data (generated worlds)?

### 3. Generated Worlds Fallback

**How do we handle planets/moons with no JSON data?**

Current state:
- Luna, Mars, Europa have detailed JSON data
- Generated worlds have none
- PrecursorCapabilityService creates synthetic properties

**Design Questions**:
- Should generated worlds get synthetic `stored_volatiles` and `materials`?
- Should deposit spawning use the same plausibility rules?
- How do we ensure variety across generated worlds?

### 4. Survey Revelation

**How do deposits get "discovered" through survey?**

Two scenarios:
1. **Known deposits** (in geological_features JSON): Revealed when surveyed
2. **Spawned deposits** (procedural): Should they also be revealed on survey?

**Design Decision Needed**:
- Do we spawn ALL deposits upfront, but hide them until surveyed?
- Or spawn deposits on-demand when survey completes?
- What's the performance impact?

---

## Engine Inputs vs Outputs

### Inputs to Plausibility Engine
```
celestial_body {
  stored_volatiles: { resource => amount },
  materials: [array of confirmed types],
  crust_composition: { mineral => percentage },
  atmosphere: { gas => percentage },
  average_temperature: float,
  geological_features: [array of Features]
}
```

### Output from Plausibility Engine
```
viable_deposits: {
  water_ice: {
    max_count: 12,
    spawn_probability: 0.8,
    allowed_regions: [:polar],
    depth_range: [10, 100],
    required_equipment_tier: 2
  },
  regolith: {
    max_count: unlimited,
    spawn_probability: 1.0,
    allowed_regions: [:all],
    depth_range: [0, 5],
    required_equipment_tier: 1
  }
}
```

---

## Acceptance Criteria for Design

- [ ] Define complete plausibility rule set for 8+ deposit types
- [ ] Specify how `stored_volatiles` → deposit count mapping works
- [ ] Document how `materials` and `crust_composition` constrain deposits
- [ ] Define rules for generated worlds (synthetic properties)
- [ ] Specify equipment tier gating rules
- [ ] Document survey revelation mechanics
- [ ] Propose implementation strategy (hardcoded vs data-driven vs hybrid)
- [ ] Show example: "Spawn deposits on Luna given luna.json properties"

---

## Next Steps After Design Approval

Once this design is approved:
1. Create PlausibilityEngine or config rules
2. Integrate with ResourceSpawningService
3. Add validation specs
4. Test against known bodies (Luna, Mars)

---

## Required Input From

- **Gemini**: Domain expertise on geological plausibility - create the rules
- **Local Agent**: Engine implementation patterns
- **You**: Game balance - how many deposits per body? How rare should rare materials be?

