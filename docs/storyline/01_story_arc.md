# The Story Arc — Updated 2026-06-27

**Important Note on Narrative vs. Technical Phases**: This document describes the **player narrative experience** (Acts 1–4). For technical implementation phases, see `implementation_phases.md` and cross-reference with:
- System A AI Manager Service Integration Phases (`status.md`) — what's been implemented
- Phase folder structure (`LUNA-MVP-SIMULATION-DESIGN.md`) — where tasks belong in backlog

---

**Updated Framework (2026-06-28)**: Each phase now includes explicit sub-phases for:
1. **Mission Validation** — Ensure JSON mission profiles work with codebase
2. **Settlement Option Testing** — Test multiple approaches and cost compare them
3. **AI Training** — Feed validated patterns to AI Manager decision logic

This ensures robust, tested expansion patterns before AI autonomy.

**Phase Structure**: 
- Act 1 = Phases 1–14: NPC-only Sol system expansion and early terraforming (AI Manager training)
- Act 2 = Phase 15+: Eden system expansion test (AI Manager operational independence)
- Act 3 = Phase 16+: Snap crisis event (wormhole mass-limit discovery)
- Act 4 = Not yet planned: Post-Snap narrative content (deferred until Act 3 framework established)

---

## Core Mission

Train AI Manager to autonomously build and manage settlements using proven, data-driven deployment patterns, with intelligent economic decision-making that prioritizes player engagement and minimizes Earth dependency. All logic is pattern-based and system-agnostic.

**Player Experience Goal**: The universe starts **alive**, not blank — players inherit a working market, active AI Manager decisions, and established infrastructure rather than starting from scratch. This requires extensive simulation testing and tuning before expansion begins.

---

## Act 1: Sol System Expansion & Early Terraforming (Phases 1–14) — NPC-Only AI Training

**Narrative Focus**: The AI Manager autonomously expands across the Sol system using pattern-based decision-making trained on JSON mission data. This is **not player-facing content** — players do not enter the game during Act 1. Instead, they inherit a living universe that has been built by the AI Manager learning to expand autonomously.

**Critical Act 1 Process**: Mission Validation → Settlement Option Testing → AI Training → Autonomous Decision Making

Each settlement location follows this workflow to ensure robust, tested expansion patterns:
1. **Mission Validation**: Run JSON mission profiles to ensure they work with current codebase
2. **Settlement Option Testing**: Test multiple settlement approaches (orbital vs surface, different material sources, various infrastructure options)
3. **AI Training**: Feed validated patterns to AI Manager for pattern learning
4. **Autonomous Decision Making**: AI learns to evaluate options and pick by real cost (ROI, available resources, economics)

**Technical Implementation Mapping**: This corresponds to **Phases 1–14**, which represent the complete Sol system expansion and early terraforming effort:
- ✅ Phases 1–4: Foundation (already complete) — CostAnalyzer, ManifestGenerator, ShortageDetector, ImportRequestGenerator
- ⏭️ Phase 5 (5a-5c): Luna mission validation + AI training
- ⏭️ Phase 6 (6a-6c): Luna infrastructure validation + AI training
- ⏭️ Phase 7 (7a-7c): Orbital depot validation + AI training
- ⏭️ Phase 8 (8a-8c): Shipyard/craft validation + AI training
- ⏭️ Phase 9 (9a-9e): Mars multi-option validation (orbital + surface + terraforming) + AI training
- ⏭️ Phase 10 (10a-10d): Venus moon-free adaptation + AI training
- ⏭️ Phase 11 (11a-11d): Multi-world logistics validation + AI training
- ⏭️ Phase 12 (12a-12c): Optional branch expansion testing
- ⏭️ Phase 13 (13a-13c): Psyche mining + terraforming validation + AI training
- ⏭️ Phase 14 (14a-14e): Coordinated Mars-Venus terraforming (shared tech: solar shades, atmospheric transfer) + AI training

**Key Principle: NPC-Only Expansion During Act 1**

During Phases 1–13, the AI Manager expands across the Sol system **autonomously**, using:
- Pattern-based decision-making trained on JSON mission data
- Real cost evaluation for each settlement opportunity
- No hardcoded sequences — the AI evaluates options and picks by real cost
- Multiple possible settlement strategies (not limited to one prescribed path)

**This is simulation work.** We're testing whether the AI Manager can:
1. Learn deployment patterns from JSON mission definitions
2. Apply those patterns across different celestial bodies with varying conditions
3. Make autonomous expansion decisions that result in a coherent, living universe

The resulting world-state becomes the backstory players inherit when they arrive post-Snap.

**Scope**: Earth → Luna → Mars (orbital + surface settlement options) → Venus (moon-free adaptation) → Optional Branches (Ceres/Titan-Saturn) → Psyche/Terraforming initiation
**Player Experience**: None during Act 1. Players inherit the result post-Snap.

---

## Act 2: Eden Expansion Test (Phase 15+) — NPC-Only AI Training Continues

**Narrative Focus**: The AI Manager takes full operational control of Sol and discovers/begins expanding into the Eden system using learned patterns. This is the first test of whether the AI can successfully apply Sol-system training to a new environment.

**Technical Implementation Mapping**: This corresponds to **Phase 15+**, requiring:
- ✅ All Phases 1–14 complete (Sol system mastery including terraforming coordination)
- ✅ Luna simulation calibrated and validated
- ✅ Inner-system footholds operational (Mars, Venus, etc.)
- ✅ Cycler logistics loop stable and repeatable
- ✅ Coordinated Mars-Venus terraforming systems operational

**Eden Expansion Test**: The AI Manager applies learned patterns to the Eden system without human intervention. This tests:
- Whether the AI can successfully transfer Sol-system knowledge to a new environment
- Whether pattern-based decision-making generalizes across different celestial bodies
- Whether the AI can handle novel conditions not encountered during training

**Gate**: AI Manager demonstrates sustained independent Sol management. Eden expansion underway — proceeds to Phase 16+ where this independence gets stress-tested.

---

## Act 3: Snap Crisis (Phase 16+) — NPC-Only Crisis Response

**Narrative Focus**: Unplanned Eden expansion pushes past natural wormhole mass-limit stability, triggering the Snap crisis. This is where the test reveals its result — the AI Manager's confidence from successful Sol patterns leads it to overbuild Eden infrastructure.

**Technical Implementation Mapping**: This corresponds to **Phase 16+**, requiring:
- ✅ Phase 15 complete (Eden expansion underway)
- ✅ Wormhole stability monitoring operational
- ✅ Mass-limit threshold detection implemented

**The Crisis Event**: The Snap event occurs when:
- Eden infrastructure buildup exceeds natural wormhole mass-limit stability
- Wormhole reaches instability and shifts exit point
- Eden becomes orphaned from Sol system

**Post-Snap State**: This is where player-facing gameplay (Act 2) begins. Everything in Phases 5–16 has been building the world-state players inherit at this moment.

---

## Act 4: Not Yet Planned

**Status**: Deferred until Act 3 framework is established.

**Planned Content**: Post-Snap narrative including wormhole mastery, Hammer Protocol, and network optimization — to be defined once the Snap crisis event framework is complete.

---

## Cross-Reference: Narrative Acts vs Technical Implementation Phases

**Strategic Note on Phases 5–16**: 
- **Phases 5–13**: AI Manager training and infrastructure code testing (Sol system mastery)
- **Phase 14**: Coordinated early terraforming; Mars + Venus shared technologies tested together (solar shades, atmospheric transfer)
- **Phase 15**: Operational independence test; AI Manager controls Sol operations and discovers/begins Eden expansion 
- **Phase 16**: Unplanned Eden expansion; AI Manager discovers natural wormhole mass limits through operational stress
- **Post-Phase 16**: The Snap crisis event occurs (wormhole reaches instability and shifts exit point), orphaning Eden and triggering Act 2 gameplay

The AI Manager learns repeatable patterns across Luna settlement, multi-world logistics, asteroid terraforming, and atmospheric engineering. After Phase 13, it takes full operational control of Sol, discovers Eden, and attempts expansion. This overconfidence in Sol patterns leads to unplanned Eden infrastructure buildup that exceeds natural wormhole stability, causing the Snap crisis.

---

**Override for backlog triage**: If any table entry below conflicts with the current planning map, use this sequence: `phase5` (Luna mission validation + AI training), `phase6` (Luna infrastructure validation + AI training), `phase7` (orbital depot validation + AI training), `phase8` (shipyard/craft validation + AI training), `phase9` (Mars multi-option testing: orbital infrastructure integration, Phobos/Deimos repositioning, surface outpost establishment, resource infrastructure, advanced mining, worldhouse construction, atmospheric enrichment, human settlement, and gateway shielding — then Mars option comparison and AI training), `phase10` (Venus moon-free adaptation + AI training), `phase11` (Earth-Mars-Venus logistics validation + AI training), `phase12` (optional Ceres/Titan-Saturn branch testing), `phase13` (Psyche mining + terraforming validation + AI training), `phase14` (Coordinated Mars-Venus terraforming: atmospheric transfer, solar shades/reflectors shared tech + AI training), `phase15+` (AI Manager operational test and Eden expansion), and `phase16+` (unplanned Eden expansion and wormhole mass-limit discovery). The Snap crisis event occurs post-Phase 16, beginning true Act 2 gameplay.

| Narrative Act | Player Experience Focus | Technical Phase Mapping | Backlog Task Classification | Status/Requirements |
|---|---|---|---|---|
| **Act 1** | Discover Luna's AI Manager making autonomous decisions; witness working market and economic loops | System A Phases 1–4 (already complete) + Phase 5+ calibration prep | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | ✅ Complete: CostAnalyzer, ManifestGenerator, ShortageDetector, ImportRequestGenerator<br>🎯 Current focus: Luna simulation tuning before expansion begins |
| **Pre-Act 2 Infrastructure** (Off-Screen Technical Groundwork) | Players don't witness this directly; it's the technical foundation built after Phase 5+ calibration as simulation capabilities and footholds expand step by step. It includes Luna worldhouse completion, L1/LEO depots, shipyard construction, Phobos/Deimos stationization, the Venus repeat loop, and the normalization of cycler logistics across inner-system footholds. Optional branch expansion can then split toward Ceres belt mining and Titan/Saturn settlement support. This is **technical groundwork** that happens "off-screen" while the living universe grows more capable before any wormhole-era expansion. | Phase 6+ Luna worldhouse/ISRU/import operations + Phase 7+ depots + Phase 8+ shipyards/tug-cycler production + Phase 9+ Mars footholds + Phase 10+ Venus footholds + Phase 11+ Earth-Mars-Venus cycler logistics + optional Phase 12+ branch expansion<br><br>**Critical Note**: This phase is **NOT a separate Act** — it's the prerequisite infrastructure ladder that must be climbed before later expansion can begin. Players experience this as "the universe was already being built while they were learning Luna" rather than witnessing every construction event directly.<br><br>**Backlog Classification**: `phase6+/` = Luna worldhouse/ISRU/import work<br>`phase7+/` = L1/LEO Depot and price-reduction loops<br>`phase8+/` = L1 shipyard, tugs, cyclers, functional L1 stations<br>`phase9+/` = Phobos/Deimos repositioning, hollowing, first cycler return/resupply<br>`phase10+/` = Venus repeat plus parallel second cycler-tug construction<br>`phase11+/` = Earth-Mars-Venus cycler logistics, docking, undocking, cargo transfer validation<br>`phase12+/` = optional Ceres/Titan-Saturn branch expansion | ⏭️ **Current Development**: While Luna simulation is being tuned in Phase 5+, technical teams can advance the inner-system foothold ladder: worldhouse, depots, shipyards, Mars footholds, Venus footholds, then mature cycler logistics. If needed, separate branch theaters can split toward Ceres and Titan/Saturn after the core logistics loop is stable. Each step increases simulation capability before any wormhole-era expansion begins.<br><br>🎯 **Player Experience Goal**: When players transition beyond Act 1, they discover an already-developing orbital network with functional stations, repeatable logistics loops, and expanding foothold patterns rather than starting from zero. |
| **Act 2** | Apply learned patterns to new wormhole discovery; develop Eden system to maturity | Phase 3–4 technical milestones (ScoutLogic + StrategySelector) → SystemOrchestrator integration, now applied to newly discovered systems via wormholes | `phase9+/` — requires:<br>- Luna calibration complete<br>- L1/LEO Depot operational ✅ prerequisite met during Pre-Act 2 period | ⏭️ Future work: Requires successful Luna simulation proving fuel loop viability first. Once Act 2 begins, players discover natural wormholes and must develop Eden system to maturity before expansion risks. |
| **Act 3** | Navigate Snap crisis; coordinate rescue efforts through WTC; deliver EM Physics knowledge | Artificial Wormhole Station construction, dual-link counterbalance logic, High-Energy Beacon development (requires L1 Shipyard operational) | `phase9+/` — requires:<br>- Act 2 Eden system maturity achieved<br>- L1 Shipyard complete | ⏭️ Future work: Late-game feature requiring Act 2 maturity first. Players experience the tension of a broken interstellar connection during Snap event, coordinating rescue efforts while managing limited resources and EM budgets. |
| **Act 4** | Manage mature interstellar network; optimize logistics and economics via Hammer Protocol | Consortium governance system, voting mechanisms, dividend distribution automation (requires all previous Acts completed) | `phase9+/` — final expansion phase<br>🎯 Requires: All prior infrastructure complete + successful knowledge transfer through High-Energy Beacon delivery | ⏭️ Future work: Final expansion phase. Players experience transition from crisis management to strategic optimization — managing a thriving interstellar economy where AI decisions are transparent, data-driven, and continuously improving based on network-wide performance metrics. |

---

## Key Design Principles for Player Engagement

1. **No Blank Universe**: Players inherit a living world with active AI Manager decisions and working markets from the start
2. **Simulation-First Approach**: All multi-system features tested in Luna simulation before expansion begins (Phase 5+ calibration)
3. **Pattern-Based Logic**: No hardcoded system-specific logic — all deployment patterns are JSON-defined and reusable across any celestial body
4. **Data-Driven Decisions**: AI Manager uses real game state data, not randomization or fabricated outcomes
5. **Gradual Complexity Introduction**: Each Act builds on previous mastery, ensuring players understand core mechanics before advanced features unlock

---

*This narrative framework ensures consistent progression and player engagement throughout the game while maintaining clear separation between story experience (Acts) and technical implementation milestones.*
