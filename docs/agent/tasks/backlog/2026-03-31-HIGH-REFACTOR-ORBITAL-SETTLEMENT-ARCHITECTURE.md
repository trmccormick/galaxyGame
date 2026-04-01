# TASK: Refactor Orbital Settlement Architecture — Separate Structure from Settlement
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-03-31
**Last Updated**: 2026-03-31

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Major architectural refactor across models, concerns, 
factories, and specs — requires careful reasoning about blast radius
**Supervision Level**: 🔴 Watched carefully

---

## Context
`Settlement::SpaceStation` currently conflates two distinct concepts:
- **Settlement** — population, economy, contracts, jurisdiction
- **Structure** — physical shell, docking ports, dimensions, damage/repair

This is architecturally incorrect and limits scalability. Real orbital 
deployments (e.g., L1 Gateway) require a single settlement to contain 
multiple peer structures (a shipyard station AND a depot), which the 
current model cannot support.

`BaseSettlement` already has `has_many :structures` — the correct 
relationship is already modeled. `Structures::BaseStructure` already has 
`belongs_to :settlement` — the reverse is already modeled. The refactor 
is about using these existing relationships correctly.

The `Structures::Shell` concern is fully implemented and self-contained — 
it handles construction lifecycle, panel management, and atmosphere 
integration. It is currently only included by `Settlement::SpaceStation` 
but should be included by `Structures::SpaceStation` instead.

**Real-world example — L1 Gateway settlement:**
```
Settlement::OrbitalSettlement "L1 Gateway"
  ├── Structures::SpaceStation (construction/repair berths)
  └── Structures::OrbitalDepot (cargo/refueling/processing)
```

**Explicit Blocker**: Do not implement until test suite is under 10 failures.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/simulation/SIMULATION_SANDBOX.md`
- `docs/architecture/stations/` — all station architecture docs
- `docs/architecture/services/ai_manager/` — AI Manager uses settlements
- `docs/agent/README.md` — key architectural decisions
- `docs/GUARDRAILS.md` — architectural constraints
- `app/models/concerns/structures/shell.rb` — fully implemented concern
- `app/models/structures/base_structure.rb` — base for all structures
- `app/models/settlement/base_settlement.rb` — base for all settlements

---

## Problem Statement
`Settlement::SpaceStation` includes `Structures::Shell`, `LifeSupport`, 
and `Docking` — structural concerns that belong in a structure model, 
not a settlement model. This creates:

1. A 1:1 settlement-to-station mapping that breaks multi-structure 
   orbital deployments (L1, Venus orbit, etc.)
2. Conflated test factories that don't know if they're testing a 
   structure or a settlement
3. `OrbitalShipyardService` confusion about whether `station` is a 
   structure or a settlement
4. `add_module` method conflict between `Settlement::SpaceStation` 
   and `HasModules` concern

**Current behavior**: One model does both settlement and structure work  
**Expected behavior**: Clean separation — settlement manages economy/population, 
structures manage physical assets

---

## Files Involved

### Primary Files — you will create
| File | Purpose |
|------|---------|
| `app/models/settlement/orbital_settlement.rb` | New orbital settlement model |
| `app/models/structures/space_station.rb` | New space station structure model |
| `app/models/structures/orbital_depot.rb` | New orbital depot structure model |
| `db/migrate/[timestamp]_add_orbital_settlement_type.rb` | Migration if needed |

### Primary Files — you will modify
| File | Purpose | Change |
|------|---------|--------|
| `app/models/settlement/space_station.rb` | Existing conflated model | Add deprecation warning, keep alive |
| `spec/factories/settlement/space_station.rb` | Factory | Add orbital_settlement factory |
| `spec/services/construction/orbital_shipyard_service_spec.rb` | Spec | Update to use correct models |

### Reference Files — read but do not edit
| File | Why You Need It |
|------|----------------|
| `app/models/concerns/structures/shell.rb` | Include in Structures::SpaceStation |
| `app/models/structures/base_structure.rb` | Parent class for new structures |
| `app/models/settlement/base_settlement.rb` | Parent class for OrbitalSettlement |
| `app/models/structures/worldhouse.rb` | Pattern to follow for structure models |
| `app/models/orbital_construction_project.rb` | Used by OrbitalShipyardService |

---

## Target Architecture

### Settlement::OrbitalSettlement < BaseSettlement
```ruby
module Settlement
  class OrbitalSettlement < BaseSettlement
    # NO structural concerns — pure settlement
    # Economy, population, jurisdiction, contracts
    # has_many :structures already inherited from BaseSettlement
    
    validates :settlement_type, inclusion: { in: %w[orbital_station orbital_depot l1_gateway] }
  end
end
```

### Structures::SpaceStation < BaseStructure
```ruby
module Structures
  class SpaceStation < BaseStructure
    include Structures::Shell    # Construction lifecycle
    include Docking              # Docking ports
    include LifeSupport          # Life support systems
    
    # belongs_to :settlement already in BaseStructure
    # Physical: shell, dimensions, damage/repair, atmosphere
    # Blueprint-driven via existing load_structure_info
  end
end
```

### Structures::OrbitalDepot < BaseStructure
```ruby
module Structures
  class OrbitalDepot < BaseStructure
    # belongs_to :settlement already in BaseStructure
    # Cargo transfer, refueling, processing
    # Blueprint-driven
  end
end
```

---

## Implementation Steps

> Read ALL reference docs and existing models before touching anything.
> This is a large refactor — proceed phase by phase, verify after each.

### Phase 1 — Audit blast radius
```bash
grep -rn "Settlement::SpaceStation\|space_station" app/ spec/ --include="*.rb" | wc -l
grep -rn "Settlement::SpaceStation\|space_station" app/ spec/ --include="*.rb"
```
Document every file that references `Settlement::SpaceStation`.

### Phase 2 — Create Settlement::OrbitalSettlement
- Inherit from BaseSettlement
- Remove all structural concerns
- Keep economy, population, jurisdiction
- Add new settlement_type validations

### Phase 3 — Create Structures::SpaceStation
- Inherit from BaseStructure
- Include Structures::Shell, Docking, LifeSupport
- Move shell logic from Settlement::SpaceStation
- Wire blueprint lookup via existing load_structure_info
- belongs_to :settlement → OrbitalSettlement

### Phase 4 — Create Structures::OrbitalDepot
- Inherit from BaseStructure
- Blueprint-driven
- belongs_to :settlement → OrbitalSettlement

### Phase 5 — Add deprecation to Settlement::SpaceStation
```ruby
def initialize(*)
  ActiveSupport::Deprecation.warn(
    "Settlement::SpaceStation is deprecated. " \
    "Use Settlement::OrbitalSettlement with " \
    "Structures::SpaceStation instead."
  )
  super
end
```

### Phase 6 — Update factories
- Add `:orbital_settlement` factory
- Add `:structures_space_station` factory
- Keep `:space_station` factory pointing to deprecated model 
  until all specs updated

### Phase 7 — Update specs
- Update `orbital_shipyard_service_spec` to use new models
- Update any spec using `Settlement::SpaceStation` for structural 
  behavior to use `Structures::SpaceStation`

### Phase 8 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/ spec/services/construction/'
```

---

## Acceptance Criteria
- [ ] `Settlement::OrbitalSettlement` created, inherits BaseSettlement
- [ ] `Structures::SpaceStation` created, includes Shell/Docking/LifeSupport
- [ ] `Structures::OrbitalDepot` created, blueprint-driven
- [ ] L1 Gateway pattern works: one OrbitalSettlement, two structures
- [ ] `Settlement::SpaceStation` deprecated but not deleted
- [ ] All orbital shipyard specs pass
- [ ] No regressions in settlement or structure specs
- [ ] Full suite run logged after completion

---

## Stop Conditions — escalate to user immediately if:
- Test suite is at or above 10 failures — halt immediately
- Migration required for existing SpaceStation records — stop, 
  do not migrate without human approval
- `Docking` or `LifeSupport` concerns have dependencies that 
  prevent inclusion in BaseStructure subclass
- Any spec regression outside the files being modified
- Blast radius audit shows 50+ references — reassess scope before proceeding

---

## Luna/Settlement Hub Note
Surface settlements (lava tube, crater dome) already work correctly via 
`BaseSettlement has_many :structures`. The orbital refactor follows the 
same pattern. A future task should add hub-based port connections for 
surface settlements where physical distance between structures requires 
an intermediate connection hub.

---

## Dependencies
**Blocked by**: Test suite must be under 10 failures  
**Blocks**: OrbitalShipyardService clean implementation  
**Related tasks**:
- `2026-03-30-HIGH-BUG-FIX-BLUEPRINT-PORTS-REMOVE-FALLBACK.md`
- `2026-03-30-HIGH-FEATURE-DIGITAL-TWIN-SCHEMA.md`
- `2026-03-29-HIGH-REFACTOR-WORMHOLE-EXPANSION-SERVICE.md`

---

## Commit Instructions
Run git commands on host, not inside container:
```bash
git add app/models/settlement/orbital_settlement.rb \
        app/models/structures/space_station.rb \
        app/models/structures/orbital_depot.rb \
        app/models/settlement/space_station.rb \
        spec/factories/settlement/ \
        spec/services/construction/
git commit -m "refactor: introduce OrbitalSettlement + Structures::SpaceStation — separate settlement from structure"
git push
```

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:  
**Completion date**:  
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned