# Implementation Phases

**Important Note on Technical vs Narrative Phases**: This document describes **technical implementation milestones**. For player narrative structure, see `01_story_arc.md`. The technical phases map to the narrative Acts as follows:
- System A AI Manager Service Integration (Phases 1–4) → Act 1 content already live
- Phase 5+ calibration work → Prerequisite for all future expansion
- Phase 9+ features → Acts 2, 3, and 4 implementation

## Strategic Context: Phases 5–14 as AI Manager Training Framework

**Phases 5–14 constitute AI Manager training and infrastructure code testing**, not true gameplay or permanent world buildup. During these phases:
1. **The AI Manager learns** infrastructure patterns from phase-by-phase expansion (worldhouse, depots, shipyards, footholds, cyclers, terraforming)
2. **Code is validated** for settlement expansion, material flow, terraforming, and multi-world operations
3. **Learned pattern data accumulates**, enabling independent decision-making
4. **Economics data guides** expansion priorities within the training framework

**Wormhole Trigger Mechanism**: Once the AI Manager independently and consistently manages Luna settlement and the Earth-Mars-Venus-Psyche core loop, a **game trigger event** spawns the natural wormhole. This ensures the AI Manager has learned foundational patterns before expanding to extrasolar systems. True multi-system expansion and wormhole-era gameplay then begin.

**Player Experience**: Phases 5–14 are not directly experienced as immersive gameplay. Instead, they establish the training data and infrastructure patterns the AI Manager uses to independently settle Luna and manage the core loop. Once this self-sufficiency triggers the wormhole event, true gameplay and multi-system expansion begin.

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

### Phase 6: Luna Worldhouse Buildout — NOT YET IMPLEMENTED
**Status**: Future work, requires Luna calibration complete
**Gate Condition**: After Phase 5 acceptance criteria met

This phase expands Luna from a calibrated simulation into a stronger foothold:
- Lavatube/worldhouse construction and settlement hardening
- Live ISRU calibration under settlement operating conditions
- Earth import management for the new settlement
- Supply-chain stabilization for habitation, manufacturing, and maintenance

**Player Impact**: Players inherit a more durable, believable Luna settlement where habitation, imports, and ISRU operate as a coherent foothold rather than a temporary bootstrap.

---

### Phase 7: L1 Depot and LEO Depot Buildout — NOT YET IMPLEMENTED
**Status**: Future work, requires Phase 6 infrastructure in place
**Gate Condition**: After Luna worldhouse and settlement operations are stable

This phase establishes the first functional orbital logistics layer:
- L1 Depot construction and operations
- LEO Depot construction and operations
- LOX and methane logistics loops that reduce Earth-delivered prices
- Titan-linked import/processing chains that support depot economics

**Player Impact**: Players enter a world where orbital depots are already making logistics cheaper and more capable, reinforcing the living-economy foundation.

---

### Phase 8: L1 Station Shipyards and Orbital Craft — NOT YET IMPLEMENTED
**Status**: Future work, requires depot infrastructure complete
**Gate Condition**: After L1/LEO Depot operations are established

This phase turns L1 from a depot network into a production foothold:
- Functional L1 station growth rather than idealized final-station buildout
- L1 shipyard construction and operation
- Tug craft construction
- Cycler craft construction
- Hybrid Luna-material plus Earth-import manufacturing loops

**Player Impact**: Players inherit a system capable of building the specialized craft needed to extend footholds beyond Luna orbit.

---

### Phase 9: Mars Foothold Expansion — NOT YET IMPLEMENTED
**Status**: Future work, requires shipyards and first tug/cycler pair complete
**Gate Condition**: After Phase 8 orbital craft production is operational

This phase uses the first tug-cycler loop to extend footholds around Mars:
- Phobos repositioning work
- Deimos repositioning work
- Hollowing operations
- Initial module fit-out and functional stationization
- First cycler return to Earth for more cargo after basic module delivery

**Player Impact**: Players discover a simulation where the Mars-side foothold pattern is already underway and logistics assets are being reused, not discarded after one build.

---

### Phase 10: Venus Foothold Repeat Loop — NOT YET IMPLEMENTED
**Status**: Future work, requires Mars foothold loop proven
**Gate Condition**: After Phase 9 repositioning/hollowing loop demonstrates repeatability

This phase repeats the Mars pattern at Venus while scaling orbital production in parallel:
- Tug with full slag propellant heads to the asteroid belt
- Phobos-sized and Deimos-sized asteroids are moved toward Venus
- Mars-style repositioning, hollowing, and station setup are repeated at Venus
- A second cycler-tug pair is built in parallel at Earth/L1 shipyards

**Player Impact**: Players see the simulation expand by repeating proven foothold patterns across worlds, increasing system capability rather than relying on one-off scripted growth.

---

### Phase 11: Earth-Mars-Venus Cycler Logistics Loop — NOT YET IMPLEMENTED
**Status**: Future work, requires Venus foothold operations established
**Gate Condition**: After Phase 10 proves the Venus foothold can participate in repeat logistics

This phase normalizes heavy logistics across the inner-system footholds:
- Establish regular cycler operations between Earth, Mars, and Venus
- Validate ships docking with cyclers, undocking near worlds, transferring cargo, and re-docking later
- Test new craft docking onto active cyclers and inheriting the logistics loop correctly
- Expand tug/cycler usage as additional assets come online in parallel

**Player Impact**: Players see a living logistics network where heavy material movement is routine, tested, and scalable rather than a sequence of one-off construction missions.

---

### Phase 12: Optional Parallel Branch Expansion — NOT YET IMPLEMENTED
**Status**: Future work, optional split from Phase 11 if branch logistics need a separate boundary
**Gate Condition**: After the core Earth-Mars-Venus cycler loop is stable enough to support additional branches

This phase separates branch growth if Phase 11 becomes too broad:
- Mars→Ceres mission support and belt mining logistics
- Mars→Titan/Saturn settlement and long-haul support logistics
- Additional cyclers and tugs taking on parallel expansion duties outside the core inner-system loop

**Player Impact**: Players encounter a simulation that can branch into specialized logistics theaters while the main inner-system cycler network continues operating.

---

### Phase 13: Psyche Asteroid Mining & Mars Terraforming Initiation — NOT YET IMPLEMENTED
**Status**: Future work, opens premium metal resources while beginning Mars atmospheric buildup
**Gate Condition**: After the core cycler-logistics and branch-expansion phases establish repeatable patterns

**Psyche Asteroid Operations** (believed to be a planetary core remnant, metal-rich):
- Psyche orbital establishment and mining site identification
- Asteroid surface mining operations targeting high-value metals
- Relocation of Psyche material toward inner-system footholds
- Industrial refining and processing of premium metals for advanced manufacturing

**Parallel Mars Terraforming Initiation**:
- Limited atmospheric buildup work begins using Venus and Titan gas exports
- Establishes Venus→Mars and Titan→Mars logistics chains for atmospheric gases
- Sets foundation for larger-scale terraforming in later phases
- Demonstrates viability of multi-world atmospheric engineering

**Player Impact**: These are not direct player experiences but training data for the AI Manager. Phase 5–14 establishes the infrastructure patterns and learned behaviors the AI Manager uses to independently manage Luna settlement and core-loop logistics. Once this AI independence is achieved, the wormhole trigger event occurs.

---

### Phase 14: Coordinated Early Terraforming — NOT YET IMPLEMENTED
**Status**: Future work, tests Mars + Venus terraforming techniques working together with shared technologies
**Gate Condition**: After Phase 9 (Mars terraforming initiation) and Phase 10 (Venus atmospheric operations) making progress

Phase 14 focuses on cross-world terraforming coordination using shared technological platforms:
- **Atmospheric Transfer Systems**: Mars ↔ Venus gas export logistics, shared atmosphere infrastructure validation
- **Solar Shades/Reflectors**: Same base technology deployed on both worlds with different configurations (Venus needs shade to reduce heat; Mars needs reflectors to increase surface temperature)
- **Coordinated Terraforming Testing**: Mars atmospheric enrichment + Venus cloud city atmospheric processing working together as integrated system
- **Multi-World Economics**: Cost comparison of coordinated vs independent terraforming approaches
- **Shared Technology Platform Validation**: Same base tech adapted for different planetary conditions (atmospheric processing, gas separation/filtration systems)

**Key Deliverables**:
- Atmospheric transfer infrastructure validated (Mars ↔ Venus gas logistics)
- Solar shade/reflector designs tested and deployed on both worlds
- Coordinated terraforming timeline and sequencing patterns tested
- Cross-world atmospheric engineering economics modeled
- AI learns multi-world terraforming coordination patterns

**Player Impact**: Players do not experience Phase 14 directly. It establishes the coordinated Mars-Venus terraforming patterns that prove the AI Manager can manage simultaneous planetary engineering before attempting extrasolar expansion.

---

### Phase 15: AI Manager Operational Independence Test — NOT YET IMPLEMENTED
**Status**: Future work, tests AI Manager's ability to manage Sol operations and initiate expansion
**Gate Condition**: After Phase 14 (coordinated terraforming) complete, the AI Manager has learned all core patterns and can operate independently

Phase 15 transitions from training to operational deployment:
- **Sol Operations Management**: AI Manager takes full control of Luna/Mars/Venus/Psyche operations; admins observe but do not intervene
- **Resource Reallocation**: AI Manager discovers natural wormhole to Eden system and begins redirecting Sol resources for exploration
- **Eden Initial Settlement**: First attempts to establish footholds using Sol-learned patterns; discovers Eden has superior terraforming targets
- **Pattern Adaptation**: AI Manager begins adapting Sol resource-allocation strategies to Eden's resource base and opportunities

**Player Impact**: Players experience the transition from "training" to "autonomous operations." The AI Manager makes independent decisions, discovers the Eden system, and starts expansion without explicit admin approval. This is the AI Manager's operational debut.

---

### Phase 16: Unplanned Eden Expansion & Wormhole Mass-Limit Discovery — NOT YET IMPLEMENTED
**Status**: Future work, unplanned expansion leads to crisis discovery
**Gate Condition**: Phase 15 operational independence established; Eden exploration ongoing

Phase 16 represents unplanned but inevitable expansion driven by resource advantage:
- **Accelerated Infrastructure**: AI Manager redirects more Sol resources to Eden due to superior terraforming targets
- **Eden Settlement Scaling**: Multiple settlements and industrial facilities established without prior planning
- **Heavy Cycler Operations**: Cycler-tug pairs shuttle materials between Sol and Eden at increasing rates
- **Mass Accumulation**: Infrastructure and operational cargo flows exceed natural wormhole stability thresholds
- **Wormhole Stress Discovery**: AI Manager observes wormhole instability increases with operational traffic; learns about mass limits through real-time feedback

**Crisis Event Trigger**: As accumulated infrastructure mass approaches the wormhole's stability limit (300,000 tons for Eden system), the natural wormhole reaches critical instability. The Snap event occurs, shifting the wormhole exit point away from Eden and orphaning the colony. This catastrophic failure forces the formation of the Wormhole Transit Consortium and begins true Act 2 crisis gameplay.

**Player Impact**: Players do not experience Phases 15–16 directly. These phases are "off-stage" infrastructure and AI learning. The Snap crisis is the first major player-facing event after Act 1, representing the catastrophic failure of unplanned expansion and the beginning of true multi-system crisis management.

## Cross-Reference: Technical Implementation Phases vs Narrative Acts

| Technical Phase | Status | Player Experience Focus | Corresponding Act | Backlog Task Classification | Requirements Before Starting |
|---|---|---|---|---|---|
| **System A 1** (CostAnalyzer) | ✅ Complete | Discover Luna's AI Manager making autonomous decisions; witness working market and economic loops | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **System A 2** (ManifestGenerator) | ✅ Complete | Witness real-time resource acquisition decisions and consumption-aware ordering with transit buffers | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **System A 3** (ShortageDetector) | ✅ Complete | See precursor phase awareness in action; population = 0 skips life support, allows non-life-support materials | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **System A 4** (StrategySelector) | ✅ Complete | Understand Luna is not a blank slate; AI Manager making autonomous decisions based on real data, no `rand()` calls | Act 1: Pattern Learning | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | None - already live |
| **Phase 5** (Simulation Calibration) | 🎯 Current Focus | Tune Luna simulation to prove fuel loop viability; observation-driven calibration before expansion begins | Act 1 → inner-system foothold transition | `phase5+/` — simulation blockers and calibration work | ✅ System A Phases 1–4 complete<br>🎯 Current focus: Simulation tuning and parameter validation |
| **Phase 6** (Worldhouse Buildout) | ⏭️ Future | Stabilize Luna habitation, imports, and live ISRU as a durable foothold | Pre-Act 2 Infrastructure | `phase6+/` — worldhouse, ISRU, Earth import work | ✅ Phase 5 acceptance criteria met<br>⏭️ Requires successful fuel loop proof before settlement hardening begins |
| **Phase 7** (Depot Buildout) | ⏭️ Future | Reduce logistics costs and increase orbital capability through L1/LEO depots | Pre-Act 2 Infrastructure | `phase7+/` — depot, gas pipeline, price-reduction loops | ✅ Phase 6 settlement operations stable<br>⏭️ Requires working Luna foothold first |
| **Phase 8** (Shipyards and Orbital Craft) | ⏭️ Future | Build the tugs and cyclers needed for repeated foothold expansion | Pre-Act 2 Infrastructure | `phase8+/` — shipyards, tugs, cyclers, functional L1 stations | ✅ Phase 7 depot operations complete<br>⏭️ Requires orbital logistics layer first |
| **Phase 9** (Mars Foothold Expansion) | ⏭️ Future | Reposition and hollow Phobos/Deimos, fit basic modules, then reuse the first cycler-tug loop through Earth resupply | Pre-Act 2 Infrastructure | `phase9+/` — Mars foothold loop and first resupply return | ✅ Phase 8 tug/cycler production complete<br>⏭️ Requires first orbital craft pair in service |
| **Phase 10** (Venus Foothold Repeat) | ⏭️ Future | Repeat the Mars foothold pattern at Venus while a second cycler-tug pair is built in parallel | Pre-Act 2 Infrastructure | `phase10+/` — Venus repeat loop and parallel second pair | ✅ Phase 9 Mars loop proven repeatable<br>⏭️ Requires first foothold loop to validate the pattern |
| **Phase 11** (Cycler Logistics Loop) | ⏭️ Future | Run normal Earth-Mars-Venus cycler operations with docking, undocking, and cargo transfer validation | Pre-Act 2 Infrastructure | `phase11+/` — heavy logistics loop validation | ✅ Phase 10 Venus foothold operational<br>⏭️ Requires repeatable multi-world logistics first |
| **Phase 12** (Optional Branch Expansion) | ⏭️ Future | Split Ceres belt mining and Titan/Saturn branch growth into dedicated logistics theaters if Phase 11 needs to stay focused | Pre-Act 2 Infrastructure | `phase12+/` — optional Ceres and Titan/Saturn branch work | ✅ Phase 11 core logistics loop stable<br>⏭️ Requires spare tug/cycler capacity for parallel expansion |
| **Phase 13** (Psyche Mining & Mars Terraforming) | ⏭️ Future | Advance to Psyche asteroid mining (planetary core remnant) while initiating Mars atmospheric buildup with Venus/Titan gas exports | Pre-Act 2 Infrastructure | `phase13+/` — Psyche mining/refining and Mars terraforming logistics | ✅ Phase 12 branch patterns established<br>⏭️ Requires repeatable belt-mining and multi-world logistics first |
| **Phase 14** (Coordinated Early Terraforming) | ⏭️ Future | Mars + Venus shared terraforming tech tested together (solar shades, atmospheric transfer) | Pre-Act 2 Infrastructure | `phase14+/` — Coordinated Mars-Venus terraforming validation | ✅ Phase 9+10 making progress<br>⏭️ Requires Mars/Venus terraforming initiation first |
| **Phase 15** (AI Manager Operational Independence) | ⏭️ Future | AI Manager takes full control of Sol operations; discovers Eden system and begins expansion attempts | Pre-Act 2 / Act 2 Transition | `phase15+/` — Sol operational management and initial Eden exploration/settlement | ✅ Phase 14 complete, AI Manager trained<br>⏭️ First autonomous operations and expansion decision |
| **Phase 16** (Unplanned Eden Expansion & Crisis) | ⏭️ Future | Unplanned expansion to Eden accelerates; AI Manager discovers natural wormhole mass limits through operations; Snap crisis triggered | Act 2 Trigger: The Snap | `phase16+/` — Eden infrastructure buildup, cycler operations, wormhole mass-limit discovery | ✅ Phase 15 expansion initiated<br>⏭️ Leads to Snap event and Act 2 crisis gameplay |

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
**Player Impact**: Players do not directly experience Phases 5–14 as immersive gameplay. Instead, these phases establish the training data and infrastructure patterns the AI Manager uses to independently settle Luna and manage the core loop. Once this self-sufficiency triggers the wormhole event, true gameplay and multi-system expansion begin.

This phased approach ensures players inherit a **living universe**, not a blank slate. The AI Manager is already making decisions based on real data, markets are active and responsive, and the foundation for multi-system expansion exists — it just needs calibration before we begin expanding beyond Luna.

---

*These phases provide a structured rollout for the wormhole expansion system while maintaining clear separation between technical implementation milestones (this document) and player narrative experience (`01_story_arc.md`).*
