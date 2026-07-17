# Backlog Priority Alignment

**Created**: 2026-07-16  
**Purpose**: Organize backlog tasks by MVP roadmap phases to ensure work sequence supports game progression.

---

## MVP Roadmap Phases

Canonical sequence supporting playable loops:

1. **Earth** — Anchor economy, basic resources, NPC market foundation
2. **Luna** — Settlement system, manufacturing, basic ISRU
3. **L1** — Orbital depots, cycler transport, logistics
4. **Shipyards** — Construction infrastructure, large vessel manufacturing
5. **Mars** — Terraforming simulation, settlement expansion, biome system
6. **Venus** — Industrial economy, extreme environment adaptation
7. **Logistics** — Advanced transport, supply chain management
8. **Eden** — Advanced biome types, narrative locations
9. **Snap** — Story expansion, endgame mechanics
10. **Player Gameplay** — Combat, contracts, emergent gameplay

---

## Phase 1: Earth Anchor Economy

**Goal**: Establish baseline pricing, resource definitions, market foundation.

**Critical Path Tasks**:

- ✅ **DONE**: Define 30 base materials with properties (Tier: Earth)
- ✅ **DONE**: Establish EconomicConfig with Earth anchor prices
- ✅ **DONE**: Create NpcPriceCalculator (Earth baseline pricing)
- ✅ **DONE**: Initialize basic market orders (buy/sell)
- ✅ **DONE**: Create VirtualLedger for transaction tracking
- 📝 **PENDING**: Document cost-based economy principles (D5, DOCUMENTATION_UPDATE_PLAN.md)
- 📝 **PENDING**: Create economy overview with Earth → Luna pricing progression

**Backlog Status**: READY

**Blockers**: None

---

## Phase 2: Luna MVP

**Goal**: Operational settlement system, manufacturing chain, player contracts.

**Critical Path Tasks**:

- ✅ **DONE**: Colony model with 2+ settlement validation
- ✅ **DONE**: Settlement admin model (structures, resources, buildings)
- ✅ **DONE**: Construction job system
- ✅ **DONE**: Manufacturing chain (raw → processed → components → blueprints)
- ✅ **DONE**: Blueprint lookup service (JSON-driven)
- ✅ **DONE**: Contract system (mission, service, supply types)
- ✅ **DONE**: ISRU foundation (material extraction framework)
- 📝 **PENDING**: Complete manufacturing overview documentation (D2, DOCUMENTATION_UPDATE_PLAN.md)
- 📝 **PENDING**: Document NPC economy integration flow (D3, DOCUMENTATION_UPDATE_PLAN.md)
- 📝 **PENDING**: Document multiple gameplay loops (D4, DOCUMENTATION_UPDATE_PLAN.md)

**Backlog Status**: READY

**Blockers**: None

---

## Phase 3: L1 Logistics

**Goal**: Orbital settlements, cycler routes, transport economics.

**Critical Path Tasks**:

- ✅ **DONE**: OrbitalDepot model (renamed to Settlement::OrbitalDepot)
- ✅ **DONE**: Docked vessel system
- ✅ **DONE**: Cycler route calculations
- ✅ **DONE**: Transport cost service (Δ-V budget, fuel calculations)
- ✅ **DONE**: Travel time mechanics (launch windows, transit, capture)
- 📝 **PENDING**: Document orbital settlement architecture (D8, DOCUMENTATION_UPDATE_PLAN.md)
- 📝 **PENDING**: Create hierarchy diagram (D7, DOCUMENTATION_UPDATE_PLAN.md)

**Backlog Status**: READY

**Blockers**: None

---

## Phase 4: Shipyards (Optional for MVP, Nice-to-Have)

**Goal**: Large vessel construction infrastructure, advanced manufacturing.

**Dependent Tasks**:

- Manufacturing chain complete (Phase 2) ✅
- Component system mature (Phase 2) ✅
- Blueprint system extensible (Phase 2) ✅

**Tasks**:

- 🚫 **BACKLOG**: Create Shipyard structure model (large construction complex)
- 🚫 **BACKLOG**: Implement dry-dock system (vessel assembly location)
- 🚫 **BACKLOG**: Create advanced blueprint system (multi-component vessels)
- 🚫 **BACKLOG**: Implement layup/refit mechanics (vessel maintenance)
- 🚫 **BACKLOG**: Create shipyard player contracts (construction jobs)

**Note**: Shipyards enhance manufacturing loop but not required for Moon → Mars progression. Can defer to post-MVP expansion if timeline constrained.

**Backlog Status**: READY (optional)

**Blockers**: None

---

## Phase 5: Mars Terraforming

**Goal**: Planetary simulation, settlement expansion, terraforming mechanics.

**Critical Path Tasks**:

- ✅ **DONE**: Biome classification system
- ✅ **DONE**: PlanetBiome instance model (planetary + engineered)
- ✅ **DONE**: TerraSim sphere simulations (5 interconnected layers)
- ✅ **DONE**: Climate calculations
- ✅ **DONE**: Worldhouse structure model (lava-tube enclosures)
- ✅ **DONE**: Settlement expansion to multiple planets
- 🔶 **IMPLEMENTATION CHECK**: Verify planet_biomes.biosphere_id NULL allowance (D10, DOCUMENTATION_UPDATE_PLAN.md)
- 🔶 **BACKLOG**: Verify/implement LifeFormDeployment target-condition tracking (D11, DOCUMENTATION_UPDATE_PLAN.md)
- 📝 **PENDING**: Document worldhouse enclosure pattern (D6, DOCUMENTATION_UPDATE_PLAN.md)
- 📝 **PENDING**: Document terraform design and biome integration (D11, DOCUMENTATION_UPDATE_PLAN.md)

**Backlog Status**: READY (with implementation verification)

**Blockers**: None

---

## Phase 6: Venus Industrial Economy

**Goal**: Extreme environment adaptation, industrial resource extraction, economy scaling.

**Dependent Tasks**:

- Mars terraforming operational (Phase 5) ✅
- Manufacturing chain scalable (Phase 2) ✅
- Cost-based economy balanced (Phase 1) ✅

**Tasks**:

- 🚫 **BACKLOG**: Create Venus-specific material types (sulfuric acid compounds, dense atmosphere resources)
- 🚫 **BACKLOG**: Implement extreme environment adaptation (heat resistance, pressure tolerance)
- 🚫 **BACKLOG**: Create Venus-specific structure types (floating platforms, pressure domes)
- 🚫 **BACKLOG**: Implement advanced ISRU for Venus (acid chemistry processing)
- 🚫 **BACKLOG**: Create Venus economic opportunities (unique valuable resources)

**Note**: Venus adds industrial loop but relies on complete Mars infrastructure first.

**Backlog Status**: READY (deferred to post-Luna)

**Blockers**: None

---

## Phase 7: Advanced Logistics

**Goal**: Interplanetary supply chains, distributed manufacturing.

**Dependent Tasks**:

- Luna manufacturing operational (Phase 2) ✅
- L1 transport economics established (Phase 3) ✅
- Mars settlement system operational (Phase 5) ✅

**Tasks**:

- 🚫 **BACKLOG**: Create supply chain contracts (multi-hop routes)
- 🚫 **BACKLOG**: Implement distributed manufacturing (raw on Mars → processed on Luna → assembled on Earth)
- 🚫 **BACKLOG**: Create trade routes (repeating cycler paths with economic value)
- 🚫 **BACKLOG**: Implement transportation insurance/risk mechanics
- 🚫 **BACKLOG**: Create piracy/salvage opportunities (contested routes)

**Note**: Logistics loop adds complexity; not required for MVP but enhances endgame.

**Backlog Status**: READY (deferred to post-Mars)

**Blockers**: None

---

## Phase 8: Eden System

**Goal**: Advanced biome types, habitat locations, narrative expansion.

**Dependent Tasks**:

- Mars terraforming complete (Phase 5) ✅
- Biome system extensible (Phase 5) ✅
- Story framework established (as Phase 9/10 develop) (partial)

**Tasks**:

- 🚫 **BACKLOG**: Design Eden biome types (multi-species habitats, unique resources)
- 🚫 **BACKLOG**: Implement Eden locations (settlement sites, story locations)
- 🚫 **BACKLOG**: Create Eden-specific contracts (exploration, terraform, colonization)
- 🚫 **BACKLOG**: Implement narrative content (story progression)
- 🚫 **BACKLOG**: Create advanced simulation mechanics (if needed for Eden story)

**Note**: Eden is narrative/expansion phase. Implementation should follow Earth/Luna/Mars playable loop maturity.

**Backlog Status**: BACKLOG (deferred to post-MVP)

**Blockers**: None (scope-dependent on narrative design)

---

## Phase 9: Snap Event

**Goal**: Story climax, endgame mechanics, late-game expansion.

**Dependent Tasks**:

- Most game systems operational (Phases 1-8)
- Player progression reaching endgame (narrative pacing)

**Tasks**:

- 🚫 **BACKLOG**: Implement Snap mechanics (story event trigger, player impact)
- 🚫 **BACKLOG**: Create Snap story content (narrative progression)
- 🚫 **BACKLOG**: Implement endgame challenges (post-Snap gameplay)
- 🚫 **BACKLOG**: Create portal technology (if decided via ODD-3)
- 🚫 **BACKLOG**: Implement late-game resource types (Snap-related materials)

**Note**: Snap is final story expansion. Mechanics depend on prior phase completion.

**Backlog Status**: BACKLOG (deferred to late MVP)

**Blockers**: None (scope-dependent on story decisions)

---

## Phase 10: Player Gameplay Expansion

**Goal**: Combat, advanced contracts, emergent multiplayer mechanics.

**Dependent Tasks**:

- Settlement system operational (Phase 2) ✅
- Contract system operational (Phase 2) ✅
- Multiple loops established (Phases 1-7) ✅

**Tasks**:

- 🚫 **BACKLOG**: Implement combat system (PvE/PvP mechanics)
- 🚫 **BACKLOG**: Create combat contracts (raids, defense, piracy)
- 🚫 **BACKLOG**: Implement player-to-player contracts (trading, services)
- 🚫 **BACKLOG**: Create leaderboards/rankings (player progression visibility)
- 🚫 **BACKLOG**: Implement player-driven events (auctions, markets, competitions)

**Note**: Player gameplay expands naturally from loops. Can be iterative across MVP phases.

**Backlog Status**: BACKLOG (deferred to late MVP/post-launch)

**Blockers**: None

---

## Documentation Backlog

**Parallel to Development** (these should be completed as features complete):

### CRITICAL (Blocks contributor understanding)

- D1: AI Manager service inventory (6-8 hours)
- D2: Manufacturing overview (4-5 hours)

### HIGH (Affects integration work)

- D3: NPC economy flow (3-4 hours)
- D4: Gameplay loops overview (5-6 hours)
- D5: EAP pricing (2-3 hours)

### MEDIUM (Improves contributor experience)

- D6: Worldhouse design (3-4 hours)
- D7: Hierarchy diagram (1 hour)
- D8: OrbitalDepot namespace (0.5 hour)
- D9: TerraSim roadmap (1-2 hours)

### VERIFICATION REQUIRED

- D10: Biome/PlanetBiome schema check (0.5-1 hour)
- D11: LifeFormDeployment target-conditions (0.5-1 hour)
- D12: TL/MK mapping documentation (2-3 hours)

---

## Backlog Organization Recommendations

### Current Issues

1. **Phase Mixing**: Some backlog tasks tagged for wrong phase (e.g., Snap tasks in Phase 2 backlog)
2. **Priority Lack**: No clear differentiation between nice-to-have and required
3. **Documentation Gap**: No clear owner/timeline for doc updates

### Recommended Structure

```
projects/galaxy_game/tasks/
├── active/                 (in-progress)
├── completed/              (done)
└── backlog/
    ├── earth/              (Phase 1)
    ├── luna/               (Phase 2)
    ├── l1/                 (Phase 3)
    ├── mars/               (Phase 5)
    ├── venus/              (Phase 6)
    ├── eden/               (Phase 8)
    └── documentation/      (parallel track)
```

### Quarterly Planning

- **Q1 (Earth → Luna)**: Phases 1-2 critical path
- **Q2 (Luna → Mars)**: Phases 3-5 progression
- **Q3 (Mars → Venus)**: Phases 5-6 expansion
- **Q4 (Advanced Logistics)**: Phases 6-7 system integration

---

## Summary

**Current Backlog Status**: 

- ✅ Phases 1-3 READY (Earth, Luna, L1)
- ✅ Phase 5 READY with verification (Mars)
- 🚫 Phases 4, 6-10 in BACKLOG (nice-to-have or narrative phases)

**No architectural blockers** prevent execution of critical path.

**Documentation updates** should run parallel to feature development (not blocking).

**Total effort to complete MVP phases**: ~6-8 weeks (Phases 1-5) + parallel documentation updates.
