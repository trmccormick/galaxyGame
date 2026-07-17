# Open Design Decisions

**Created**: 2026-07-16  
**Purpose**: Explicitly document unresolved design questions that require human decision. These are not blockers; they're clarifications that can be addressed in parallel with implementation.

---

## Definition

**Open Design Decision**: A game design question where:
- Canonical intent statements do NOT provide guidance (silence on topic)
- Implementation is not blocked (workaround exists or feature is non-critical)
- Explicit human decision required to formalize rules
- Does not prevent MVP execution

---

## Open Design Decision #1: Technology Level vs MK Mapping Mechanics

**Topic**: Exact rules for how Technology Level (TL) and Model Kit (MK) progression interact.

**Canonical Intent**: Partial resolution (#7, #12)
- Intent #7: Blueprint evolution expected; backward compatibility not required
- Intent #12: Technology = civilization capability tier (TL), Engineering iteration within tier (MK)
- **Silence on**: Exact TL/MK gating rules (e.g., which TL unlocks which max MK?)

**Current Implementation**:
- Code has 19 technology categories (TL progression)
- Blueprint system tracks MK versions (iteration within tier)
- Tech tree gates blueprint availability
- Exact mapping rules not formalized in code or config

**Decision Required**:

Define exact TL/MK mapping table. Example options:

**Option A: Linear Progression** (each TL unlocks corresponding MK)
```
TL1: MK1 only
TL2: MK1-MK2
TL3: MK1-MK3
TL4: MK1-MK4
TL5: MK1-MK5 (max)
```

**Option B: Cascading Tiers** (TL determines max available MK; all lower MKs always available)
```
TL1: MK1
TL2: MK1-MK2 (any blueprint can be TL2+MK2)
TL3: MK1-MK3
TL4: MK1-MK4
TL5: MK1-MK5
```

**Option C: Decoupled Axes** (TL and MK independently progressive; no gating relationship)
```
Any TL can have any MK
Player must discover/unlock MK separately from TL progression
```

**Impact**:
- **Gameplay pacing**: Determines when players access advanced refinements (MK3+ variants)
- **Economy balance**: Affects when players can manufacture high-value components
- **Skill expression**: Determines if optimization (higher MK) requires tech progression
- **Content stretch**: Affects how many distinct blueprints feel "new" vs "refined"

**Evidence Base** (what would inform decision):
- Player feedback: Is optimizing (MK progression) fun without new TL content?
- Economy data: Do MK refinements justify manufacturing time vs TL variants?
- Content production: How many unique MK variants per TL can content team produce?

**Timeline to Decide**: Before player progression balancing (medium priority)

**Status**: UNRESOLVED — requires explicit game design choice

---

## Open Design Decision #2: Simulation Sandbox Purpose

**Topic**: What is the Simulation Sandbox for? Is it a development tool, orchestration layer, admin feature, or something else?

**Canonical Intent**: None — no canonical statement addresses Simulation Sandbox

**Current Implementation**:
- `docs/architecture/simulation/SIMULATION_SANDBOX.md` exists
- File describes sandbox but purpose is ambiguous
- Feature is not on MVP critical path
- No test cases defining expected behavior

**Decision Required**:

Choose one purpose (or combination) and document explicit scope:

**Option A: Developer Testing Environment**
- Purpose: Local testing of sphere simulation without full game context
- Users: Developers and QA
- Scope: Isolated sphere calculations, parameter tweaking, regression testing
- Implementation: Runnable script or utility class
- Dependencies: None on game systems

**Option B: Orchestration Layer**
- Purpose: Coordinate multiple sphere simulations (atmosphere ↔ hydrosphere ↔ biosphere)
- Users: Internal system (not directly player-facing)
- Scope: Simulation lifecycle management, feedback loop control
- Implementation: Service layer managing sphere interactions
- Dependencies: Deep integration with TerraSim

**Option C: Admin/Observatory Tool**
- Purpose: Player-accessible feature to observe/adjust planetary conditions
- Users: Administrators or advanced players
- Scope: Real-time observation of simulation state, parameter adjustment UI
- Implementation: Controller + views
- Dependencies: TerraSim core simulations

**Option D: Defer (Not MVP)**
- Purpose: None currently needed
- Users: N/A
- Scope: Feature deprioritized; archive documentation
- Implementation: No implementation for MVP
- Timeline: Post-Mars phase if needed

**Impact**:
- **MVP scope**: Determines if feature should be worked on or deprioritized
- **Development time**: A (testing) = 2-3 days; B (orchestration) = 5-7 days; C (admin tool) = 7-10 days
- **Architecture**: Affects whether feature integrates with core systems or remains isolated

**Decision Maker**: Lead designer (feature scope choice)

**Timeline to Decide**: Before Mars phase simulation work (can defer to mid-MVP)

**Status**: UNRESOLVED — requires explicit feature scope decision

---

## Open Design Decision #3: Advanced Portal Technology Mechanics

**Topic**: How does Portal technology work? What are the mechanical rules for advanced interstellar transport?

**Canonical Intent**: Mentioned as late-game expansion but no mechanical specification

**Current Implementation**:
- Portal technology mentioned in design docs as future feature
- No code implementation (deliberately deferred)
- Wormhole network is primary transport mechanism (not portals)
- No requirements specification for portal mechanics

**Decision Required**:

Define portal technology mechanical rules for when implementation begins (late MVP phases):

**Example Design Space**:

1. **Access Model**: How are portals accessed?
   - One-way (hub-to-destination only)?
   - Bidirectional (both hubs open portal)?
   - Point-to-point (no hub needed)?

2. **Gateway Requirements**: What infrastructure needed?
   - Paired stations (one on each side)?
   - Single hub with multiple destinations?
   - Natural wormholes vs engineered gates?

3. **Cost Model**: What's the resource/energy cost?
   - One-time infrastructure cost (build gate)?
   - Per-transit cost (energy to open)?
   - Time cost (charging time before use)?
   - Fuel cost (mass penalty for large transits)?

4. **Navigation Model**: How does EM budget interact?
   - Portals consume EM (require EM ship to use)?
   - Portals bypass EM constraints (free transport)?
   - Portals open new EM pathways (novel navigation)?

5. **Spatial Scope**: Which systems connected?
   - Same solar system only?
   - Inter-system connections (rare)?
   - Inter-galactic (late-game expansion)?

**Impact**:
- **Late-game strategy**: Determines if portals replace/supplement wormhole routes
- **Economy balance**: Determines if transport cost remains value driver
- **Expansion design**: Affects accessibility of Eden/Snap systems
- **Content scope**: Determines how many portal networks needed

**Evidence Base** (what would inform decision):
- Wormhole system balance: Are cycler routes still valuable if portals exist?
- Player feedback (if available): Do players want "easy" transport or value time cost?
- Narrative intent: Does portal tech enable or contradict game story?

**Timeline to Decide**: Late MVP (Mars → Venus → Eden phases)

**Status**: UNRESOLVED — requires explicit mechanics design decision

---

## Decision Log Template

When an Open Design Decision is resolved:

**Resolution Record**:
```
Decision: [ODD-N name]
Resolved By: [Name/Date]
Choice: [Selected option]
Reasoning: [Why this option]
Implementation Owner: [Who builds it]
Timeline: [When]
Files Updated: [Docs to update]
```

---

## Current Status Summary

| Decision | Status | Priority | Impact | Timeline |
|---|---|---|---|---|
| ODD-1: TL/MK Mapping | UNRESOLVED | MEDIUM | Progression pacing | Before balance phase |
| ODD-2: Sandbox Purpose | UNRESOLVED | LOW | Feature scope | Before Mars simulation |
| ODD-3: Portal Mechanics | UNRESOLVED | LOW | Late-game expansion | Late MVP phases |

---

## Next Steps

1. **Schedule Decision Sessions**: Allocate design time for each ODD
2. **Gather Evidence**: Collect feedback/metrics that inform decisions
3. **Document Rationale**: When decided, record why each choice was made
4. **Communicate**: Inform team of decisions to guide implementation

**None of these decisions block MVP execution.** They're clarifications that improve design coherence and help contributors understand game intent.
