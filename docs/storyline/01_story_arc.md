# The Story Arc

**Important Note on Narrative vs. Technical Phases**: This document describes the **player narrative experience** (Acts 1–4). For technical implementation phases, see `implementation_phases.md` and cross-reference with:
- System A AI Manager Service Integration Phases (`status.md`) — what's been implemented
- Phase folder structure (`LUNA-MVP-SIMULATION-DESIGN.md`) — where tasks belong in backlog

---

## Core Mission

Train AI Manager to autonomously build and manage settlements using proven, data-driven deployment patterns, with intelligent economic decision-making that prioritizes player engagement and minimizes Earth dependency. All logic is pattern-based and system-agnostic.

**Player Experience Goal**: The universe starts **alive**, not blank — players inherit a working market, active AI Manager decisions, and established infrastructure rather than starting from scratch. This requires extensive simulation testing and tuning before expansion begins.

---

## Act 1: Pattern Learning (Tutorial Phase)
**Narrative Focus**: Player discovers the Luna settlement already has an operational AI Manager making autonomous decisions based on learned patterns. They witness how the system handles resource acquisition, consumption-aware ordering, precursor phase awareness, and life support logistics.

**Technical Implementation Mapping**: This corresponds to **System A Phases 1–4**, which are **already complete**:
- ✅ Phase 1: `Settlements::CostAnalyzer` → AI Manager integration (commit cd4d6800)
- ✅ Phase 2: `Logistics::ManifestGenerator` → AI Manager integration (commit 21b10ef0)  
- ✅ Phase 3: `Logistics::ShortageDetector` + `ImportRequestGenerator` → AI Manager (commit 32b31f54)
- ✅ Phase 4: Consumption-aware ordering + precursor phase awareness (re-implemented commit 5a2af17a)

**Sol System Setup**: The AI Manager learns these techniques by executing them in the Earth-Moon-Lagrange network, mastering deployment patterns through hands-on application on Luna. These patterns are defined in JSON and are system-agnostic — they work for any celestial body once properly configured.

**The Learning Loop**: Each successful deployment refines the AI's understanding, creating a growing library of reusable techniques that enable continuous expansion across the galaxy. Players observe this loop in action during Act 1 as Luna proves its economic viability through:
- Real-time resource acquisition decisions (player market → NPC → Earth priority)
- Consumption-aware ordering with transit buffers for life-support materials
- Precursor phase awareness (population = 0 skips life support, allows non-life-support)
- Market stabilization and GCC/USD peg mechanics

**Player Engagement Goal**: By the end of Act 1, players understand that Luna is **not a blank slate** — it's an active settlement with:
- Working import/export markets
- AI Manager making autonomous decisions based on real data (no `rand()` calls)
- Economic loops proving viability before expansion begins

---

## Act 2: Wormhole Discovery & Eden System Development (Application Phase)
**Narrative Focus**: After Luna proves the fuel loop closes, players discover natural wormholes and must develop an "Eden system" to operational maturity. The AI Manager applies learned patterns to this new discovery using ScoutLogic analysis and pattern matching.

**Technical Implementation Mapping**: This corresponds to **Phase 9+ work in backlog**, requiring:
- Luna simulation calibrated (System B Phase 5 acceptance criteria met) ✅ prerequisite
- L1 Depot/LEO Depot infrastructure operational ✅ prerequisite  
- Wormhole topology integration for system expansion planning
- Multi-system resource coordination algorithms

**Eden System Maturation**: The AI Manager focuses on developing the initial colonized system ("Eden system") to operational maturity before expansion risks. This includes:
- Establishing interconnected settlements across multiple systems
- Building comprehensive orbital infrastructure (L1 Station, LEO Depot)
- Creating stable economic and resource flows between systems
- Accumulating sufficient mass to eventually trigger wormhole instability

**Maturity Conditions**: See `system_maturity_conditions.md` for detailed requirements that must be met before the Snap event can occur. These conditions ensure players don't face premature expansion failures — everything is tested in Luna simulation first, then applied to Eden system once maturity thresholds are reached.

**Wormhole Expansion**: When the Eden system reaches maturity (through accumulated infrastructure and resource flows), natural wormhole connections become unstable, leading to the "Snap" event that opens new expansion opportunities. This transition from Act 1 → Act 2 is marked by:
- Successful Luna simulation proving fuel loop viability ✅ prerequisite for all Phase 9+ work
- First discovery of natural wormholes via ScoutLogic analysis (Phase 3 technical milestone)
- Pattern matching to select appropriate deployment strategy for Eden system (Phase 4 technical milestone)

**Player Engagement Goal**: Players experience the transition from single-system operations to multi-system expansion, witnessing how Luna's proven patterns scale to new discoveries. The AI Manager now handles:
- System analysis and EM detection via ScoutLogic
- Pattern selection based on discovered system characteristics  
- Multi-settlement orchestration across wormhole-connected systems

---

## Act 3: The Orphaned Era (Tech Gap & Rescue)
**Narrative Focus**: A catastrophic Snap event creates an asymmetrical technology divide between Sol side and Eden side. Players must navigate the crisis, coordinate rescue efforts through WTC, and deliver critical EM Physics knowledge to stranded survivors.

**Technical Implementation Mapping**: This corresponds to **Phase 9+ work in backlog**, requiring:
- L1 Shipyard operational ✅ prerequisite for Act 3/4 features
- Artificial Wormhole Station construction logic (AWS)
- Dual-link counterbalance model implementation
- High-Energy Beacon infrastructure development

**The Crisis Event**: The Snap event creates an asymmetrical technology divide that players must resolve through coordinated action:

- **Sol Side (WTC)**: The Wormhole Transit Consortium forms as a rescue coalition. Sol-side scientists, including the MDC, begin to unravel EM Physics (post-Snap tech) and construct the High-Energy Beacon. This Beacon is critical for delivering the EM Physics Data-Drop to Eden.
  
- **Eden Side**: Stranded survivors, including the Martian Brain Trust, are limited to conventional/jury-rigged technology and remain in EM-ignorance. They cannot begin building a Counterbalance AWS until the Sol-side Beacon delivers the EM Physics Data-Drop and blueprints.

**Technical Requirements for Act 3 Implementation**:
1. **Snap Event Logic**: Handle wormhole crisis state transitions (Natural Anomaly → Harvesting Site → Permanent Anchor)
2. **Dual-Link Model**: Implement counterbalance logic where AWS deployed to stabilize natural/other artificial wormholes, reducing EM requirements and stabilizing network
3. **High-Energy Beacon Construction**: Develop infrastructure for delivering critical knowledge transfer between systems
4. **Emergency Response Protocols**: AI Manager must handle crisis scenarios with degraded capabilities

**Player Engagement Goal**: Players experience the tension of a broken interstellar connection during Snap event, coordinating rescue efforts while managing limited resources and EM budgets during the crisis period. The narrative emphasizes cooperation over competition — WTC forms as coalition rather than corporate entity.

---

## Act 4: Hammer Protocol & Network Mastery (Post-Data-Drop)
**Narrative Focus**: After successful knowledge transfer through High-Energy Beacon, players unlock advanced wormhole management capabilities via the Hammer Protocol. The AI Manager now operates a mature interstellar network with sophisticated logistics and economic optimization.

**Technical Implementation Mapping**: This corresponds to **Phase 9+ work in backlog**, requiring:
- Consortium formation upon first Snap event (governance system)
- Voting system for Route Proposals implementation
- Dividend distribution from transit fees automation
- Player/NPC participation mechanisms in network governance

**The Hammer Protocol Emerges**: Only after the tragedy of the first Snap and successful knowledge transfer does the Hammer Protocol emerge as a deliberate strategy. The AI Manager now manages:
- A mature wormhole network with multiple interconnected systems
- Real-time EM budget balancing across all links
- ROI-based expansion decisions using comprehensive metrics
- Branching networks where secondary hubs enable parallel expansion into new systems

**Advanced Capabilities Unlocked**: Players gain access to sophisticated management tools including:
- **Network Topology Management**: AI Manager splits traffic based on link properties and system data, maintaining gravitational tension and EM budgets via real-time metrics
- **Brown Dwarf Hub Integration**: Secondary anchors serve as logistics batteries and gateways for expanded network reach
- **Consortium Governance**: Voting systems allow player/NPC participation in Route Proposals with dividend distribution from transit fees
- **Adaptive Pattern Application**: All logic remains pattern-based and system-agnostic, adapting to any new system profile discovered through expansion

**Player Engagement Goal**: Players experience the transition from crisis management to strategic optimization — managing a thriving interstellar economy where AI decisions are transparent, data-driven, and continuously improving based on network-wide performance metrics. The narrative emphasizes that successful wormhole mastery requires both technical excellence (AI Manager tuning) and collaborative governance (Consortium voting).

---

## Cross-Reference: Narrative Acts vs Technical Implementation Phases

| Narrative Act | Player Experience Focus | Technical Phase Mapping | Backlog Task Classification | Status/Requirements |
|---|---|---|---|---|
| **Act 1** | Discover Luna's AI Manager making autonomous decisions; witness working market and economic loops | System A Phases 1–4 (already complete) + Phase 5+ calibration prep | `backlog/2026-06/` — active work<br>`phase5+/` — simulation testing/tuning | ✅ Complete: CostAnalyzer, ManifestGenerator, ShortageDetector, ImportRequestGenerator<br>🎯 Current focus: Luna simulation tuning before expansion begins |
| **Pre-Act 2 Infrastructure** (Off-Screen Technical Groundwork) | Players don't witness this directly; it's the technical foundation built during Phase 5+ calibration period that enables Act 2 narrative to begin. Includes orbital infrastructure development, L1/LEO Depot construction, gas processing pipeline establishment, shipyard construction, and Phobos/Deimos hollowing prep work. This is **technical groundwork** that happens "off-screen" while Luna simulation proves fuel loop viability — players only see the results when they transition into Act 2's wormhole discovery narrative. | Phase 6+ technical milestones (L1 Depot, LEO Depot, gas processing pipeline) + Phase 7–8 work (orbital structure deployment, shipyard construction, Phobos/Deimos hollowing prep)<br><br>**Critical Note**: This phase is **NOT a separate Act** — it's the prerequisite infrastructure that must be complete before Act 2 can begin. Players experience this as "the universe was already being built while they were learning Luna" rather than witnessing construction events directly.<br><br>**Backlog Classification**: `phase6+/` = L1/LEO Depot, gas processing pipeline (requires Phase 5+ calibration complete)<br>`phase9+/` (Phase 7–8 work) = shipyard construction, Phobos/Deimos hollowing prep (requires Act 2 Eden system maturity achieved — these are late-game features that happen concurrently with early Act 3 preparation) | ⏭️ **Current Development**: While Luna simulation is being tuned in Phase 5+, technical teams build L1/LEO Depot infrastructure and gas processing pipeline. This happens concurrently with calibration but must complete before Act 2 narrative begins.<br><br>🎯 **Player Experience Goal**: When players transition from Act 1 to Act 2, they discover an already-developing orbital network (L1 Station under construction, LEO Depot operational) rather than starting from zero. This reinforces the "living universe" principle — expansion is happening while they learn Luna's systems.<br><br>📝 **Narrative Gap Clarification**: Phase 6+/7+/8+ work sits in a narrative gap between Act 1 and Act 2 — it's technical groundwork that happens off-screen. Players don't experience this as an "Act" because the story focus remains on Luna pattern learning (Act 1) until wormhole discovery triggers Act 2. The orbital infrastructure development is background activity, not player-facing narrative content. |
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
