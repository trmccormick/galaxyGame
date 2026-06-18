# Implementation Phases

**Important Note on Technical vs Narrative Phases**: This document describes **technical implementation milestones**. For player narrative structure, see `01_story_arc.md`. The technical phases map to the narrative Acts as follows:
- System A AI Manager Service Integration (Phases 1–4) → Act 1 content already live
- Phase 5+ calibration work → Prerequisite for all future expansion
- Phase 9+ features → Acts 2, 3, and 4 implementation

---

## ✅ COMPLETED: System A Phases 1–4 (Act 1 Content - Live)

These phases are **already implemented** as part of Luna AI Manager integration. They form the foundation for all future work.

### Phase 1: MissionExecutor Service (Foundation) — COMPLETE
- ✅ `Settlements::CostAnalyzer` → AI Manager integration (commit cd4d6800, archived f5fcbbe)
- **What it does**: Proves patterns are reusable and data-driven by reading mission profile JSONs
- **Player Impact**: Luna settlement has operational cost analysis driving autonomous decisions

### Phase 2: ResourceAcquisition Intelligence (Economics) — COMPLETE  
- ✅ `Logistics::ManifestGenerator` → AI Manager integration (commit 21b10ef0)
- **What it does**: Smart, data-driven sourcing with player market → NPC → Earth priority; buy order pricing, timeout/fallback logic, metrics tracking
- **Player Impact**: Working import/export markets where Luna makes autonomous acquisition decisions

### Phase 3: ScoutLogic - System Analysis (Intelligence) — COMPLETE  
- ✅ `Logistics::ShortageDetector` + `ImportRequestGenerator` → AI Manager integration (commit 32b31f54)
- **What it does**: Analyzes celestial bodies/systems, generates standardized profiles with EM detection and analysis capabilities
- **Player Impact**: Luna settlement has real-time resource monitoring and shortage prediction

### Phase 4: StrategySelector - Pattern Matching (Intelligence) — COMPLETE  
- ✅ Consumption-aware ordering + precursor phase awareness (re-implemented commit 5a2af17a, original 01919af8)
- **What it does**: Maps system profile to appropriate deployment pattern; handles edge cases and phased deployment planning
- **Player Impact**: AI Manager makes consumption-aware decisions with life-support priority logic

**Current Status of System A Phases 1–4**: All complete. Luna simulation is now ready for calibration testing (Phase 5+ work). This represents the "living universe" foundation — players inherit a working market and active AI Manager, not a blank slate.

---

## 🎯 CURRENT FOCUS: Phase 5+ Calibration Work (Prerequisite for Expansion)

**Purpose**: Test and tune Luna simulation to prove fuel loop viability before any multi-system expansion begins. This is **observation**, not feature development — run the simulation, watch market emergence and stockpile accumulation, generate tasks from what breaks or needs tuning.

### Phase 5: SystemOrchestrator (Integration) & Calibration Prep
**Status**: Ready for implementation as calibration work  
**Gate Condition**: Requires completion of System A Phases 1–4 ✅ met

This phase is **NOT about building new features**. It's about:
- Running Luna simulation with current AI Manager logic to identify gaps in fuel loop viability
- Testing consumption modeling, precursor phase gating, life support ordering under realistic conditions  
- Calibrating skimmer processing rates, multi-source supply chains, tank farm architecture parameters
- Validating inbound cargo awareness and CH₄ arbitration mechanics work as intended
- Measuring flight time modeling accuracy against real game state data

**Key Distinction**: Phase 5 is **simulation calibration**, not feature development. Only create tasks that are prerequisites needed BEFORE the Luna simulation can run (e.g., AI Manager training pipeline audit). Do NOT add new features to phase5+ — those belong in phase6+.

**Player Impact Goal**: By end of this phase, players will have a fully tuned single-system settlement where:
- Fuel loop closes reliably without Earth dependency
- Economic metrics are stable and predictable  
- Market dynamics emerge naturally from AI Manager decisions (not hardcoded)
- All parameters calibrated through observation-driven tuning

---

## ⏭️ FUTURE WORK: Phase 6+ Features (Requires Luna Calibration Complete)

These phases require **successful Luna simulation calibration** before implementation begins. They represent the transition to multi-system operations and correspond to Acts 2–4 in narrative structure.

### Phase 6: Wormhole Integration (Expansion) — NOT YET IMPLEMENTED
**Status**: Future work, requires Luna calibration complete  
**Gate Condition**: After System B Phase 5 acceptance criteria met ✅ prerequisite needed first

This phase implements the technical foundation for Act 2 expansion:
- **Artificial Wormhole Targeting**: Uses stored natural wormhole location data to precisely target artificial wormhole creation to known EM-rich locations
- **EM Opportunity Assessment**: Prioritizes systems with detected residual EM for artificial wormhole development  
- **Wormhole Lifecycle Transition**: Defines progression from Natural Anomaly → Harvesting Site → Permanent Anchor, facilitating the 'Act 2 Urbanization' transition through systematic EM resource development:
  - *Natural Anomaly*: Initial detection and mapping of EM signatures (via ScoutLogic Phase 3)
  - *Harvesting Site*: Deployment of temporary stabilization satellites for EM extraction
  - *Permanent Anchor*: Construction of Artificial Wormhole Stations for sustained network integration

**Player Impact**: Players discover natural wormholes after Luna proves viability, then begin developing Eden system to operational maturity before expansion risks.

---

### Phase 7: Wormhole Scouting Probe Development — NOT YET IMPLEMENTED  
**Status**: Future work, requires Act 2 infrastructure in place
**Gate Condition**: After L1 Depot/LEO Depot operational (Phase 6 prerequisite)

This phase develops specialized probes for surveying systems discovered through wormholes:
- **Base Platform**: Create generic_probe similar to generic_satellite using proper `base_craft` blueprint template and `craft_operational_data` operational template
- **System Survey Probe**: Comprehensive reconnaissance with multi-spectrum sensors  
- **EM Detection Probe**: Specialized for Exotic Matter signature detection, feeds data directly into AI Manager's memory systems for wormhole location mapping
- **Atmospheric Probe**: Atmospheric analysis and entry capabilities

**Player Impact**: Players can deploy autonomous scouting probes to newly discovered systems via wormholes, gathering critical intelligence before committing resources.

---

### Phase 8: The Snap Event & Dual-Link Reconnection (Crisis) — NOT YET IMPLEMENTED
**Status**: Future work, requires Act 2 maturity achieved  
**Gate Condition**: After Eden system reaches operational maturity thresholds defined in `system_maturity_conditions.md`

This phase implements the crisis mechanics for Act 3:
- **Phased Stabilization Process**:
  - *Phase 1*: Deploy orbiting stabilization satellites that gather expelled EM and refocus it at wormhole throat to maintain temporary stability  
  - *Phase 2*: Construct Artificial Wormhole Stations (AWS) to replace temporary satellites
  - *Phase 3*: Build additional AWS on opposite side of system (L3 Lagrange point) for gravitational counterbalance, similar to Jupiter stabilizing Sol's wormhole

**Technical Requirements**:
- Dual-link model: AWS deployed to counterbalance natural/other artificial wormholes, reducing EM requirements and stabilizing network
- Brown Dwarfs can serve as secondary anchors for additional stability  
- All logic is data-driven and adapts to system metadata (no hardcoded crisis scenarios)

**Player Impact**: Players experience the tension of a broken interstellar connection during Snap event, coordinating rescue efforts while managing limited resources and EM budgets. The narrative emphasizes cooperation over competition — WTC forms as coalition rather than corporate entity.

---

### Phase 9: Inter-System Network Management (Topology) — NOT YET IMPLEMENTED
**Status**: Future work, requires Act 3 crisis resolved  
**Gate Condition**: After successful knowledge transfer through High-Energy Beacon delivery

This phase implements advanced network management for Act 4 mastery:
- **Traffic Splitting Logic**: AI Manager splits traffic based on link properties and system data
- **EM Budget Management**: Maintains gravitational tension and EM budgets using real-time metrics across all wormhole links  
- **Brown Dwarf Hub Integration**: Secondary anchors serve as logistics batteries and gateways for expanded network reach

**Player Impact**: Players manage a mature interstellar network with sophisticated optimization capabilities, balancing multiple systems through data-driven AI decisions.

---

### Phase 10: Consortium Integration (Governance) — NOT YET IMPLEMENTED
**Status**: Future work, final expansion phase  
**Gate Condition**: After all previous Acts completed successfully

This phase implements governance mechanics for Act 4 collaborative management:
- **Consortium Formation**: Implement upon first Snap event as rescue coalition mechanism
- **Voting System**: Route Proposals voting system with player/NPC participation rights
- **Dividend Distribution**: Automated transit fee distribution to Consortium members  
- **Governance Participation**: Enable player and NPC involvement in network governance decisions

**Player Impact**: Players participate in collaborative interstellar governance, making collective decisions about route priorities and resource allocation through transparent democratic processes. The narrative emphasizes that successful wormhole mastery requires both technical excellence (AI Manager tuning) AND collaborative governance (Consortium voting).

---

## Cross-Reference: Technical Implementation Phases vs Narrative Acts

| Technical Phase | Status | Player Experience Focus | Corresponding Act | Backlog Task Classification | Requirements Before Starting |
|---|---|---|---|---|---|
| **System A 1** (CostAnalyzer) | ✅ Complete | Discover Luna's AI Manager making autonomous decisions; witness working market and economic loops | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **System A 2** (ManifestGenerator) | ✅ Complete | Witness real-time resource acquisition decisions and consumption-aware ordering with transit buffers | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **System A 3** (ShortageDetector) | ✅ Complete | See precursor phase awareness in action; population = 0 skips life support, allows non-life-support materials | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **System A 4** (StrategySelector) | ✅ Complete | Understand Luna is not a blank slate; AI Manager making autonomous decisions based on real data, no `rand()` calls | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **Phase 5** (SystemOrchestrator) | 🎯 Current Focus | Tune Luna simulation to prove fuel loop viability; observation-driven calibration before expansion begins | Act 1 → Act 2 transition | `phase9+/` — requires:<br>- Luna calibration complete<br>- L1/LEO Depot operational | ✅ System A Phases 1–4 complete<br>🎯 Current focus: Simulation tuning and parameter validation |
| **Phase 6** (Wormhole Integration) | ⏭️ Future | Apply learned patterns to new wormhole discovery; develop Eden system to maturity through multi-settlement orchestration | Act 2: Wormhole Discovery & Eden System Development | `phase9+/` — requires:<br>- Luna calibration complete<br>- L1/LEO Depot operational | ✅ Phase 5 acceptance criteria met (Luna simulation calibrated)<br>⏭️ Requires successful fuel loop proof before expansion begins |
| **Phase 7** (Scouting Probes) | ⏭️ Future | Deploy autonomous scouting probes to newly discovered systems via wormholes, gathering intelligence before committing resources | Act 2: Wormhole Discovery & Eden System Development | `phase9+/` — requires:<br>- L1 Depot operational<br>- LEO Depot operational | ✅ Phase 6 infrastructure complete (L1/LEO Depots)<br>⏭️ Requires successful multi-system operations established first |
| **Phase 8** (Snap Event) | ⏭️ Future | Experience tension of broken interstellar connection during crisis; coordinate rescue efforts while managing limited resources and EM budgets | Act 3: The Orphaned Era (Tech Gap & Rescue) | `phase9+/` — requires:<br>- L1 Shipyard operational<br>- Crisis protocols implemented | ✅ Phase 6–7 complete (wormhole infrastructure)<br>⏭️ Requires Eden system maturity thresholds met before Snap event can occur naturally |
| **Phase 9** (Network Management) | ⏭️ Future | Manage mature interstellar network with sophisticated optimization capabilities; balance multiple systems through data-driven AI decisions | Act 4: Hammer Protocol & Network Mastery | `phase9+/` — requires:<br>- All previous Acts completed<br>- Knowledge transfer successful | ✅ Phase 8 crisis resolved (High-Energy Beacon delivered)<br>⏭️ Requires all prior expansion phases complete before network mastery begins |
| **Phase 10** (Consortium Governance) | ⏭️ Future | Participate in collaborative interstellar governance; make collective decisions about route priorities and resource allocation through democratic processes | Act 4: Hammer Protocol & Network Mastery | `phase9+/` — requires:<br>- All previous Acts completed<br>- First Snap event occurred | ✅ Phase 8–9 complete (crisis resolved, network operational)<br>⏭️ Requires successful knowledge transfer before governance system can activate |

---

## Key Implementation Principles for Technical Phases

1. **Simulation-First Approach**: All multi-system features tested in Luna simulation before expansion begins (Phase 5+ calibration)
2. **Pattern-Based Logic**: No hardcoded system-specific logic — all deployment patterns are JSON-defined and reusable across any celestial body  
3. **Data-Driven Decisions**: AI Manager uses real game state data, not randomization or fabricated outcomes (`rand()` calls removed from decision gates)
4. **Gradual Complexity Introduction**: Each phase builds on previous mastery, ensuring players understand core mechanics before advanced features unlock
5. **Observation-Driven Tuning**: Phase 5 is about watching what breaks in simulation and generating tasks from real failure modes, not adding new features prematurely

---

## Current Implementation Status Summary (June 2026)

**What's Live**: System A Phases 1–4 complete — Luna AI Manager making autonomous decisions with working markets  
**Current Focus**: Phase 5+ calibration work to prove fuel loop viability before expansion begins  
**Next Milestone**: Successful Luna simulation tuning → transition to Act 2/3/4 implementation (Phase 9+)

This phased approach ensures players inherit a **living universe**, not a blank slate. The AI Manager is already making decisions based on real data, markets are active and responsive, and the foundation for multi-system expansion exists — it just needs calibration before we begin expanding beyond Luna.

---

*These phases provide a structured rollout for the wormhole expansion system while maintaining clear separation between technical implementation milestones (this document) and player narrative experience (`01_story_arc.md`).*
