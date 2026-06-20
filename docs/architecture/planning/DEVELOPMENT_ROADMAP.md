# Development Roadmap — AI Manager & Luna Simulation

**Purpose**: Canonical development sequence for Galaxy Game, aligned with resolved phase structure (June 17 reconciliation).  
**Last Updated**: 2026-06-19  
**Status**: ✅ CURRENT — matches resolved phase structure

---

## 📋 RESOLVED PHASE STRUCTURE (Canonical — June 17)

### System A: AI Manager Service Integration (COMPLETE)

| Phase | Service | Status |
|-------|---------|--------|
| 1 | `Settlements::CostAnalyzer` → AI Manager | ✅ Complete |
| 2 | `Logistics::ManifestGenerator` → AI Manager | ✅ Complete |
| 3 | `Logistics::ShortageDetector` + `ImportRequestGenerator` → AI Manager | ✅ Complete |
| 4 | Consumption-aware ordering + precursor phase awareness | ✅ Complete |

### System B: Settlement Expansion (Current Focus)

| Phase | Focus | Status |
|-------|-------|--------|
| 5+ | Luna simulation calibration/observation | 🎯 CURRENT — observation, not features |
| 6+ | L1 Depot, LEO Depot, gas processing pipeline | ⏳ Requires Luna calibration complete |
| 9+ | Wormhole topology, multi-system coordination | ⏳ Far future |

### Narrative Acts (Cross-Reference)

| Act | Player Experience | Technical Phase |
|-----|-------------------|-----------------|
| 1 | AI Manager already operational on Luna | System A Phases 1–4 (live) |
| 2 | Natural wormhole discovery, Eden expansion | Phase 9+ |
| 3–4 | Multi-system network, Consortium governance | Phase 9+ |

---

## 🎯 CURRENT FOCUS: Luna Simulation Calibration (Phase 5+)

**Goal**: Run the Luna simulation with current AI Manager logic to identify gaps in fuel loop viability. This is **observation**, not feature development.

### What We're Testing
- Fuel loop closes reliably without Earth dependency
- Consumption modeling, precursor phase gating, life support ordering under realistic conditions
- Skimmer processing rates, multi-source supply chains, tank farm parameters
- Inbound cargo awareness and CH₄ arbitration mechanics
- Flight time modeling accuracy against real game state data

### Key Principle
> Phase 5 is **simulation calibration**, not feature development. Only create tasks that are prerequisites needed BEFORE the Luna simulation can run. Do NOT add new features to phase5+ — those belong in phase6+.

---

## 📚 Supporting Documentation (ISRU & Operations)

These documents define the operational rules for Luna work:

| Document | What It Covers |
|----------|---------------|
| `isru_operations.md` | Agent rules, JSON-as-truth, unit roles, geosphere-driven yields |
| `precursor_industrial_loop.md` | Work Camp → ISRU → Settlement transition |
| `precursor_mission_bootstrap_architecture.md` | Bootstrap sequence, lava tube construction pattern |
| `lunar_isru_flow.md` | TEU→PVE→Separator→Cryo flow diagram |

---

## 📚 Supporting Documentation (Planning)

These documents define the planning direction and phase alignment:

| Document | What It Covers |
|----------|---------------|
| `docs/planning/GALAXY-GAME-PHASE-ALIGNMENT.md` | System A ↔ System B mapping, task placement rules |
| `docs/planning/AI-MANAGER—LUNA-BEHAVIOR-GOALS.md` | Luna settlement behavior goals (siting, buildout, decision principles) |
| `docs/planning/GALAXY-GAME-PLANNING-GOALS.md` | Planning principles, current focus, near-term objectives |
| `docs/storyline/10_implementation_phases.md` | Canonical technical phases with narrative cross-reference |
| `docs/new_agent/projects/galaxy_game/status.md` | Live project status, test baseline, active tasks |

---

## 📋 FUTURE PHASES (Deferred)

### Phase 6+: L1/LEO Depot & Gas Processing Pipeline
**Gate**: Requires Luna calibration complete  
**Scope**: Orbital depot staging, gas processing infrastructure  
**Not yet started** — depends on Phase 5+ proving Luna fuel loop viability first.

### Phase 9+: Wormhole Topology & Multi-System Coordination
**Gate**: Requires Phase 6+ complete  
**Scope**: Artificial wormhole targeting, EM opportunity assessment, multi-system network management  
**Not yet started** — far future work corresponding to narrative Acts 2–4.

---

## 📊 Historical Context (January 2026 Roadmap)

The original roadmap (`DEVELOPMENT_ROADMAP.md` from January 2026) described a Sol→Wormhole NPC buildout sequence that is **no longer the current plan**. The resolved phase structure above supersedes it.

**What changed:**
- Original Phase 1 (Sol NPC buildout) → Now System A Phases 1–4 (complete, live)
- Original Phase 2 (Pattern learning) → Now System A Phases 1–4 (patterns extracted and implemented)
- Original Phase 3 (Wormhole expansion to AOL-732356) → Now Phase 9+ (deferred)
- Original Phase 4 ("The Snap" crisis) → Now Phase 9+ (deferred)
- Original Phase 5 (Multi-system network) → Now Phase 9+ (deferred)
- **New**: Phase 5+ = Luna simulation calibration (observation, not features)

**Why it changed:**
- The January roadmap assumed NPC buildout was the priority. Discovery showed we needed to prove Luna behavior first before any expansion work.
- Dual-agent session (June 16–17) reconciled phase numbering and established canonical structure.
- Current focus is on making Luna a believable, testable simulation — not building out later phases prematurely.

---

## 📖 Related Documentation

### Architecture
- `wh-expansion.md` — AI Manager training, wormhole expansion, pattern learning
- `GUARDRAILS.md` — Anchor Law, ISRU mandate, economic priorities
- `NPC_INITIAL_DEPLOYMENT_SEQUENCE.md` — Sol system 10-phase buildout (historical reference)

### Systems
- `docs/systems/aol-732356.md` — Prize World reference implementation
- `docs/storyline/07_procedural_generation.md` — System generation, TEI scoring

### Player Integration (Future)
- `PLAYER_UI_VISION.md` — Player dashboard, contracts, markets (vision only)
- `docs/developer/AI_MANAGER_PLANNER.md` — Admin mission planner (existing UI)

---

**Last Updated**: 2026-06-19  
**Status**: ✅ CURRENT — matches resolved phase structure from June 17 reconciliation  
**Next Review**: After Phase 5+ Luna calibration complete or when planning direction changes
