# Development Phase Mapping — Galaxy Game

**Created**: 2026-07-16  
**Purpose**: Map existing systems, code, documentation, and backlog into development phases  
**Rule**: Treat existing documentation as evidence, not authority. Prefer current code architecture over old design documents.

---

## Phase 0 — Foundation

### Scope
Core infrastructure required before any gameplay system can function.

### Systems Mapped

| System | Intended Phase | Implementation Status | Documentation Status | Missing Pieces | Blocking Dependencies |
|--------|---------------|----------------------|---------------------|----------------|----------------------|
| Rails 7.0 + PostgreSQL 16 + Docker | Phase 0 | ✅ CONFIRMED | CANONICAL | None | None |
| JSON-driven architecture (blueprints, operational data) | Phase 0 | ✅ CONFIRMED | CANONICAL | Template versioning needs consolidation (v1-v7 across types) | None |
| Core models (Galaxy, SolarSystem, CelestialBody hierarchy) | Phase 0 | ✅ CONFIRMED | CANONICAL | Cryosphere service unclear | None |
| Sphere model (Atmosphere, Hydrosphere, Geosphere, Biosphere) | Phase 0 | ✅ CONFIRMED | CANONICAL | Cryosphere service gap | None |
| Database schema (schema.rb + migrations) | Phase 0 | ✅ CONFIRMED | CANONICAL | Some seed files duplicated (seeds copy.rb, seeds copy 2.rb) | None |
| Financial::Account polymorphic model | Phase 0 | ✅ CONFIRMED | CANONICAL | Exchange rate phase implementation unclear | None |
| Currency system (GCC, USD) | Phase 0 | ✅ CONFIRMED in code | CANONICAL in docs | Phase progression logic not clearly implemented | None |
| Virtual Ledger for NPC trading | Phase 0 | ✅ CONFIRMED | CANONICAL | Overdraft limits need verification against GUARDRAILS | None |
| Lookup service pattern (14 services) | Phase 0 | ✅ CONFIRMED | CANONICAL | Legacy port adapter needs cleanup | None |
| Blueprint model + cost schema v1.1 | Phase 0 | ✅ CONFIRMED | CANONICAL | Schema version drift (v1-v7 across types) | None |
| Tech tree (19 categories) | Phase 0 | ✅ CONFIRMED in data | CANONICAL | TL-to-MK relationship unresolved | None |
| GUARDRAILS.md operational boundaries | Phase 0 | ✅ CONFIRMED | CANONICAL | Some guardrails referenced but not enforced in code | None |
| AI pattern learning system | Phase 0 | ✅ CONFIRMED | CANONICAL | Pattern validation needs review | None |
| Name generation (planets, stars) | Phase 0 | ✅ CONFIRMED | REFERENCE | None | None |
| Raw materials config (YAML) | Phase 0 | ✅ CONFIRMED | CANONICAL | None | None |
| Unit definitions (YAML) | Phase 0 | ✅ CONFIRMED | CANONICAL | None | None |

### Phase 0 Summary

**Foundation is substantially complete.** All core infrastructure exists and is documented as CANONICAL. The main issues are:
- Template version drift across blueprint types (v1-v7)
- Cryosphere service gap
- Exchange rate phase progression logic unclear in code
- Some seed file duplication

**No Phase 0 blockers identified.** Foundation systems can support all higher phases.

---

## Phase 1 — Lunar Settlement Bootstrap

### Scope
Precursor missions, robotics, resource extraction, initial habitation, power systems, manufacturing foundation.

### Systems Mapped

| System | Intended Phase | Implementation Status | Documentation Status | Missing Pieces | Blocking Dependencies |
|--------|---------------|----------------------|---------------------|----------------|----------------------|
| Precursor mission bootstrap architecture | Phase 1 | ✅ CONFIRMED in code + docs | CANONICAL | Multiple docs with different scopes need consolidation | None |
| Robotics (Units::Robot) | Phase 1 | ✅ CONFIRMED in code | CANONICAL | Operational data needs verification against current blueprints | None |
| Resource extraction (Units::Extractor, ExtractionService) | Phase 1 | ✅ CONFIRMED in code | REFERENCE | ISRU pricing model needs verification against current services | None |
| Initial habitation (Units::Habitat, EnclosedHabitat::Atmosphere) | Phase 1 | ✅ CONFIRMED in code | CANONICAL | Habitat.rb has .new variant — verify which is active | None |
| Power systems (PowerStation structure, SolarArray) | Phase 1 | ✅ CONFIRMED in code | REFERENCE | Power generation tech tree integration unclear | None |
| Manufacturing foundation (Fabricators Mk1-Mk3) | Phase 1 | ✅ CONFIRMED in code + docs | CANONICAL | Blueprint version drift (unit_blueprint_v1.4.json vs v1.1 templates) | None |
| ISRU system (isru_evaluator.rb, isru_optimizer.rb) | Phase 1 | ✅ CONFIRMED in code | CANONICAL | ISRU_PRICING_MODEL.md needs verification against current services | None |
| Regolith processing (RegolithProcessingService) | Phase 1 | ✅ CONFIRMED in code | REFERENCE | None | None |
| Component production (ComponentProductionService) | Phase 1 | ✅ CONFIRMED in code | CANONICAL | None | None |
| Material processing chain | Phase 1 | ✅ CONFIRMED in code | REFERENCE | Raw materials YAML → processed materials flow needs verification | None |
| Storage (StorageManager, SurfaceStorage, MaterialPile) | Phase 1 | ✅ CONFIRMED in code | REFERENCE | Surface storage integration with units unclear | None |
| Base rig system (Rigs::BaseRig) | Phase 1 | ✅ CONFIRMED in code | CANONICAL | Rig vs Station vs Depot distinction needs documentation | None |
| Luna base establishment profile | Phase 1 | ✅ CONFIRMED in docs | CANONICAL | Profile may need updating against current code state | None |
| 3D-printed fabricator blueprints | Phase 1 | ✅ CONFIRMED in data | CANONICAL | Mk2 requires Mk1 as component — verify enforcement | None |
| Enclosed habitat atmosphere model | Phase 1 | ✅ CONFIRMED in code | REFERENCE | Pressurization service integration unclear | None |
| Pressurization system (6 services) | Phase 1 | ✅ CONFIRMED in code | REFERENCE | Integration with construction flow unclear | None |
| ConstructionJob model (surface construction) | Phase 1 | ✅ CONFIRMED in code | CANONICAL | Job System Mechanics Spec is authoritative — verify code matches | None |
| Job system (Job, ConstructionJob, OrbitalConstructionProject) | Phase 1 | ✅ CONFIRMED in code | CANONICAL | Category 3 (OrbitalConstructionProject) needs review per spec | None |

### Phase 1 Summary

**Phase 1 systems are substantially implemented.** The lunar bootstrap chain exists from precursor missions → robotics → extraction → habitation → power → manufacturing. Key issues:
- Habitat.rb has `.new` variant — verify which is active
- ISRU pricing documentation may be outdated
- Storage integration with units needs clarification
- Job system code must match the authoritative Job System Mechanics Spec

**No Phase 1 blockers identified.** Systems exist and are documented. Integration verification needed.

---

## Phase 2 — Industrial Expansion

### Scope
ISRU scaling, fabrication, storage networks, logistics, orbital infrastructure.

### Systems Mapped

| System | Intended Phase | Implementation Status | Documentation Status | Missing Pieces | Blocking Dependencies |
|--------|---------------|----------------------|---------------------|----------------|----------------------|
| ISRU scaling (beyond Mk1) | Phase 2 | ✅ CONFIRMED in code (Mk2, Mk3) | CANONICAL | Mk2→Mk3 dependency chain enforcement unclear | None |
| Advanced fabrication (shell printing, byproduct manufacturing) | Phase 2 | ✅ CONFIRMED in code | REFERENCE | Byproduct manufacturing gameplay integration unclear | None |
| Storage networks (material piles, surface storage) | Phase 2 | ✅ CONFIRMED in code | REFERENCE | Network-level storage management not documented | None |
| Logistics architecture | Phase 2 | ✅ CONFIRMED in code + docs | CANONICAL | Contract fulfillment vs player contract distinction unclear | None |
| Orbital infrastructure (SpaceStation, OrbitalDepot) | Phase 2 | ⚠️ DUAL NAMESPACE | CANONICAL | **CONFLICT**: OrbitalDepot exists in root AND settlement namespaces | Resolve dual namespace before proceeding |
| L1 Lagrange facilities | Phase 2 | ✅ CONFIRMED in docs | REFERENCE | Implementation status vs documentation unclear | None |
| Foundry logic and lunar elevator | Phase 2 | ✅ CONFIRMED in docs | CANONICAL | Code implementation status unclear | None |
| Cycler system (mobile space stations) | Phase 2 | ✅ CONFIRMED in code + docs | CANONICAL | Model location (root namespace) vs documentation (AI Manager) mismatch | None |
| Asteroid relocation tug | Phase 2 | ✅ CONFIRMED in code + docs | CANONICAL | None | None |
| Universal docking service | Phase 2 | ✅ CONFIRMED in code | REFERENCE | Integration with settlement docking unclear | None |
| Transport cost service | Phase 2 | ✅ CONFIRMED in code | REFERENCE | EM physics integration for transport costs unclear | None |
| Route cost calculator | Phase 2 | ✅ CONFIRMED in code | REFERENCE | None | None |
| Market stabilization service | Phase 2 | ✅ CONFIRMED in code | REFIRMED | AI-driven price stabilization logic unclear | None |
| NPC price calculator | Phase 2 | ✅ CONFIRMED in code | CANONICAL | Integration with market conditions unclear | None |
| Trade execution service | Phase 2 | ✅ CONFIRMED in code | REFERENCE | Player vs NPC trade priority enforcement unclear | None |
| Consortium membership system | Phase 2 | ✅ CONFIRMED in code + docs | CANONICAL | Voting quorum (66%) enforcement unclear | None |
| Escalation service | Phase 2 | ✅ CONFIRMED in code | CANONICAL | Integration with AI Manager unclear | None |

### Phase 2 Summary

**Phase 2 systems exist but have integration gaps.** The industrial expansion chain is built but:
- **OrbitalDepot dual namespace is a blocker** — must resolve before documentation consolidation
- Cycler model location mismatch (root vs AI Manager docs) needs clarification
- Market stabilization and NPC pricing integration unclear
- Transport cost service EM physics integration unclear

**1 blocker identified**: OrbitalDepot dual namespace.

---

## Phase 3 — Solar System Expansion

### Scope
Mars, Venus, outer planets, cyclers, wormhole infrastructure.

### Systems Mapped

| System | Intended Phase | Implementation Status | Documentation Status | Missing Pieces | Blocking Dependencies |
|--------|---------------|----------------------|---------------------|----------------|----------------------|
| Mars terraforming simulation | Phase 3 | ✅ CONFIRMED in code (TerraSim) | CANONICAL | Terraformable planets criteria needs verification against current simulation | None |
| Venus industrial hub design | Phase 3 | ✅ CONFIRMED in docs | REFERENCE | Implementation status vs documentation unclear | None |
| Outer planet systems (Titan, gas giants) | Phase 3 | ✅ CONFIRMED in code + data | CANONICAL | Titan terrain generation uses AI Manager (no NASA data) — verify | None |
| Cycler system (interplanetary transport) | Phase 3 | ✅ CONFIRMED in code + docs | CANONICAL | Model location mismatch (root vs AI Manager docs) | Resolve cycler namespace |
| Wormhole scouting integration | Phase 3 | ✅ CONFIRMED in code + docs | CANONICAL | Natural discovery event flow unclear | None |
| Wormhole network architecture | Phase 3 | ✅ CONFIRMED in code + docs | CANONICAL | BFS wayfinding vs EM physics integration unclear | None |
| Wormhole placement service | Phase 3 | ✅ CONFIRMed in code | REFERENCE | Gravitational anchor detection (≥10^16 kg) enforcement unclear | None |
| Consortium voting engine (66% quorum) | Phase 3 | ✅ CONFIRMED in code + docs | CANONICAL | Quorum enforcement in code unclear | None |
| Hammer Protocol (EM reset/snap control) | Phase 3 | ✅ CONFIRMED in code + docs | CANONICAL | EM buffer saturation threshold unclear | None |
| EM harvesting service | Phase 3 | ✅ CONFIRMED in code | REFERENCE | EM fountain mechanics unclear | None |
| Brown dwarf hub management | Phase 3 | ⚠️ INFERRED | REFERENCE | brown_dwarf_hub_manager.rb referenced but implementation status unclear | Verify code existence |
| SystemArchitect (infrastructure deployment) | Phase 3 | ✅ CONFIRMED in code | CANONICAL | Integration with wormhole discovery unclear | None |
| Protoplanet classification | Phase 3 | ✅ CONFIRMED in code | REFERENCE | Large asteroid classification logic unclear | None |
| Asteroid belt generation | Phase 3 | ✅ CONFIRMED in code | CANONICAL | Dynamic population rules need verification | None |
| Oort cloud generation | Phase 3 | ✅ CONFIRMED in code | CANONICAL | None | None |
| Frost line calculator | Phase 3 | ✅ CONFIRMED in code | CANONICAL | Integration with planet composition unclear | None |
| Habitable zone calculator | Phase 3 | ✅ CONFIRMED in code | CANONICAL | Integration with terraforming criteria unclear | None |

### Phase 3 Summary

**Phase 3 systems are well-documented but have verification gaps.** The solar system expansion chain exists from Mars/Venus terraforming through wormhole infrastructure. Key issues:
- Cycler namespace mismatch needs resolution
- Brown dwarf hub manager implementation status unclear (INFERRED)
- Several integration points need code verification (quorum enforcement, EM thresholds, habitat classification)

**No Phase 3 blockers identified.** Systems exist; verification needed.

---

## Phase 4 — Interstellar / Advanced Simulation

### Scope
AI autonomy, large-scale civilization simulation, advanced technologies, interstellar expansion.

### Systems Mapped

| System | Intended Phase | Implementation Status | Documentation Status | Missing Pieces | Blocking Dependencies |
|--------|---------------|----------------------|---------------------|----------------|----------------------|
| AI Manager orchestration (80+ services) | Phase 4 | ✅ CONFIRMED in code | ⚠️ DOCUMENTATION OUTDATED | Architecture doc describes 8 files; actual system has 80+ | **Update architecture documentation** |
| Pattern learning and adaptation | Phase 4 | ✅ CONFIRMED in code + docs | CANONICAL | Pattern validation needs review | None |
| Multi-wormhole event handling | Phase 4 | ✅ CONFIRMED in code + docs | CANONICAL | Event flow unclear | None |
| Strategic evaluation system | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Strategy selector integration unclear | None |
| Priority arbitration system | Phase 4 | ✅ CONFIRMED in code | CANONICAL | Heuristic vs decision tree distinction unclear | None |
| LLM planner service | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Integration with pattern learning unclear | None |
| Task execution engine (v1 + v2) | Phase 4 | ✅ CONFIRMED in code | REFERENCE | v1 vs v2 distinction unclear | None |
| System intelligence service | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Scope unclear | None |
| System discovery service | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Integration with wormhole scouting unclear | None |
| Resource flow simulation | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Scale of simulation unclear | None |
| Economic forecasting | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Forecasting horizon unclear | None |
| Colony management (AI-driven) | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Colony vs Settlement relationship unclear | Resolve colony/settlement distinction |
| Emergency mission system | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Trigger conditions unclear | None |
| Precursor learning service | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Scope and timeline unclear | None |
| Network optimization (wormhole) | Phase 4 | ✅ CONFIRMED in code | CANONICAL | Algorithm details unclear | None |
| Station cost-benefit analysis | Phase 4 | ✅ CONFIRMED in code | REFERENCE | Metrics unclear | None |

### Phase 4 Summary

**Phase 4 systems are the most complex and least well-documented.** The AI Manager has grown to 80+ services but its architecture documentation describes only 8 core files. Key issues:
- **Architecture documentation is severely outdated** (8 files vs 80+ services)
- Colony vs Settlement relationship unclear
- Task execution engine v1 vs v2 distinction unclear
- Several service scopes are undocumented

**No Phase 4 blockers identified.** Systems exist but documentation needs major update.

---

## Cross-Phase Dependencies

### Critical Path (Must Complete in Order)

```
Phase 0 (Foundation)
    ↓
Phase 1 (Lunar Bootstrap) — requires: JSON architecture, core models, financial system
    ↓
Phase 2 (Industrial Expansion) — requires: Phase 1 manufacturing + storage
    ↓
Phase 3 (Solar System Expansion) — requires: Phase 2 logistics + orbital infrastructure
    ↓
Phase 4 (Interstellar/AI) — requires: Phase 3 wormhole network + all economy systems
```

### Parallel Paths (Can Develop Concurrently)

| Path | Systems | Depends On |
|------|---------|------------|
| Rendering pipeline | Terrain, tilesets, JS rendering | Phase 0 (core models) |
| Player UI | Game interface, admin panel | Phase 0 + Phase 1 |
| Technology tree | 19 categories, TL/MK system | Phase 0 (foundation) |
| Storyline/lore | Narrative documents | None (independent) |

### Cross-Phase Blockers

| Blocker | Affects | Resolution Required Before |
|---------|---------|---------------------------|
| OrbitalDepot dual namespace | Phase 2, Phase 3 | Any documentation consolidation |
| Cycler model location mismatch | Phase 2, Phase 3 | Any architecture documentation update |
| Colony vs Settlement distinction | Phase 1, Phase 4 | Any system integration work |
| TL-to-MK relationship unresolved | Phase 0 (tech tree), Phase 1 (fabricators) | Blueprint schema finalization |
| AI Manager architecture docs outdated | Phase 4 | Any AI Manager development |
| Cryosphere service gap | Phase 0, Phase 3 | Complete sphere simulation |

---

## Implementation Priority Recommendation

### Immediate (Before Any New Development)

1. **Resolve OrbitalDepot dual namespace** — affects Phase 2+ documentation
2. **Update AI Manager architecture documentation** — 8 files → 80+ services
3. **Clarify Colony vs Settlement relationship** — affects Phase 1 and Phase 4
4. **Resolve TL-to-MK relationship** — affects blueprint schema

### Phase 1 Priority

1. Verify Habitat.rb active version (.new variant)
2. Verify ISRU pricing against current code
3. Verify Job system code matches authoritative spec
4. Consolidate storage integration documentation

### Phase 2 Priority

1. Resolve OrbitalDepot namespace (see above)
2. Clarify Cycler model location
3. Document market stabilization integration
4. Document transport cost EM physics

### Phase 3 Priority

1. Verify brown dwarf hub manager implementation
2. Verify quorum enforcement in code
3. Verify terraformable planets criteria against current simulation
4. Consolidate wormhole discovery event flow documentation

### Phase 4 Priority

1. Rewrite AI Manager architecture document (8 → 80+ services)
2. Document task execution engine v1 vs v2 distinction
3. Clarify colony management scope
4. Document strategic evaluation integration
