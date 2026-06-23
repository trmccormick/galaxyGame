---
title: Complete Phase Structure with Narrative Acts & Task Dependencies
date: 2026-06-20
status: active
intent: Map narrative progression to technical implementation phases and AI Manager task_v2 generation
---

# Galaxy Game: Full Phase & Act Structure

## Context
- **Acts**: Narrative structure for player experience
- **Technical Phases**: Implementation milestones  
- **task_v2 JSON files**: Data-driven missions AI Manager generates using learned patterns
- **Goal**: AI Manager learns from initial patterns, then generates new missions autonomously based on current system state

---

## ✅ ACT 1: Pattern Learning (System A Phases 1-4) — COMPLETE

**Narrative**: Player discovers Luna settlement with operational AI Manager already making autonomous decisions. They witness market dynamics, resource logistics, and life-support prioritization.

**Technical Status**: All complete (System A Phases 1-4 already live)

**Key Codebase Components Live**:
- ✅ `Settlements::CostAnalyzer` — autonomous cost analysis
- ✅ `Logistics::ManifestGenerator` — smart sourcing (player → NPC → Earth priority)
- ✅ `Logistics::ShortageDetector` — resource monitoring
- ✅ `ImportRequestGenerator` — shortage prediction
- ✅ Pattern matching in `StrategySelector` — life-support prioritization
- ✅ NPC market system with dynamic pricing

**Current task_v2 Files**: None yet (manual setup tasks used Act 1)

**Player Engagement**: Luna fuel loop proven viable. Market is emerging. AI Manager makes observable autonomous decisions.

---

## 🎯 PHASE 5+: Luna Calibration Loop (System B Prerequisite) — CURRENT FOCUS

**Narrative**: Invisible phase — the system proves itself. AI Manager runs Luna simulation unobserved, learning patterns and accumulating stockpiles. This is observation before expansion.

**Purpose**: NOT new features. Calibration and tuning of Phase 1-4 systems.

**Technical Focus**: 
- Run Luna ISRU loop (TEU → PVE → Gas Separator → Cryo Storage)
- Validate fuel loop viability
- Observe market emergence and NPC behavior  
- Identify gaps/breakage that generate new task_v2 files
- Collect metrics for AI Manager learning

**Key Codebase Components Needed**:
- ✅ `TerraSim` for Luna atmosphere simulation
- ✅ ISRU pipeline services (operational)
- ✅ Market system (operational)
- ✅ AI Manager dispatch logic
- **NEW**: task_v2 JSON execution engine (TaskExecutionEngineV2)
- **NEW**: Learned pattern storage/retrieval

**task_v2 Files Created**: 
- None yet (waiting for calibration findings)

**Gate Condition**: Luna simulation runs for observable cycle showing fuel loop stabilization, market behavior, stockpile accumulation.

**When to Move to Phase 6**: After fuel loop proven stable and AI Manager can generate missions from learned patterns.

---

## 🚀 PHASE 6+: Luna Lava-Tube Base Construction — NEXT (After Phase 5 Gate Met)

**Narrative**: Infrastructure expansion. Luna settlement grows from initial automated outpost to full multi-dome base with redundant systems. The AI Manager coordinates construction autonomously.

**Purpose**: Expand simulation to building sector (structural enclosure, sealing, pressurization).

**Technical Focus**:
- Worldhouse mega-structure construction pipeline
- Structural enclosure (sealing optional)
- Pressurization and TTR metrics
- Failure cascade modeling for simulation depth

**Key Codebase Components Needed**:
- ✅ `Worldhouse`, `WorldhouseSegment` models (exist but no wiring)
- ✅ Structural integrity tracking
- ✅ Pressurization logic
- **NEW**: WorldhouseSimulationService (analogous to TerraSim)
- **NEW**: task_v2 construction task generation
- **NEW**: AI Manager expansion decision logic

**task_v2 Files Ready for Use**:
- `task_worldhouse_segment_fabrication.json`
- `task_worldhouse_segment_transport.json`
- `task_worldhouse_segment_installation.json`
- `task_worldhouse_bracing_installation.json`
- `task_worldhouse_panel_deployment.json`
- `task_worldhouse_sealing_and_pressurization.json`
- `task_lava_tube_habitat_preparation.json`

**AI Manager Behavior**: Uses learned patterns from Phase 5 to autonomously sequence construction tasks. Prioritizes life support + redundancy.

**Gate Condition**: Lava-tube base structural construction complete. Simulation layer stable. AI Manager demonstrates autonomous construction sequencing.

---

## 🌍 ACT 2: Interplanetary Expansion & Colonial Operations (Phases 6-12) — Partial (Phase 6+ Gate Met for Start)

**Narrative**: Luna proves viable, infrastructure expands. LEO/L1 depots operational. Mars orbital presence established. Supply chains tested. Venus, Ceres, and Saturn/Titan become expansion frontiers. Three separate cycler networks emerge: Venus-Mars-Earth cycle, Mars-Ceres mining cycle, Mars-Saturn/Titan outer system cycle. Surface operations begin on Mars. Colonial settlement autonomy emerges at multiple worlds simultaneously.

**Technical Mapping**: 
- **Phase 6+**: Luna lava-tube base foundation
- **Phase 7+**: Depot building (LEO/L1 infrastructure)
- **Phase 8+**: Shipyards & large craft (cyclers, tugs, transports)
- **Phase 9**: Mars orbital presence (Phobos/Demios conversion & repositioning)
- **Phase 10**: First cycler shakedown (Mars-Venus-Earth supply chain test)
- **Phase 11**: Ceres operations & asteroid belt mining hub (separate Mars-Ceres cycler)
- **Phase 12**: Saturn/Titan outer system operations (separate Mars-Saturn/Titan cycler)
- **Phase 13**: Three-cycler steady-state operations (Venus, Ceres, Saturn/Titan cycles simultaneous)

**Key Narrative Beats**:
1. Luna base complete → supplies flow autonomously
2. LEO/L1 depots online → transport costs drop
3. Shipyard operational → large craft built locally (cyclers, mining craft)
4. Mars orbit infrastructure established → first cycler test missions
5. Venus-Mars-Earth cycler validates supply chains → proof of concept
6. Ceres discovered viable mining hub → asteroid belt operations begin
7. Mars-Ceres cycler constructed → automated mining cycle initiated
8. Saturn/Titan assessed for outer system expansion → resource abundance confirmed
9. Mars-Saturn/Titan cycler constructed → outer frontier operations begin
10. Three cycler networks operate simultaneously → solar system colonization backbone
11. Mars surface operations expand → orbital stations supply surface settlements
12. Slag monetization & asteroid mining revenue scale → economy sustains expansion

**AI Manager at this stage**: Orchestrates three simultaneous cycler networks. Coordinates multi-frontier logistics. Manages resource routing across Venus, Ceres, and Saturn/Titan. Optimizes mining, harvesting, and manufacturing across solar system. Autonomously scales surface ISRU based on cycler capacity at each frontier.

---

## 🏭 PHASE 7+: Depot Building (LEO Depot + Resource Management) — FUTURE

**Prerequisites**: Phase 6+ gate met

**Narrative Focus**: Supply chain optimization. LEO depot becomes key infrastructure node, reducing transport costs across inner system.

**Technical Focus**:
- LEO depot construction and operations
- Resource deposit spawning/gating  
- Transport cost reduction modeling
- Deposit plausibility engine

**Key Codebase Components Needed**:
- **NEW**: DepositSpawnerService
- **NEW**: Resource deposit model (persistence)
- **NEW**: Trigger gating system
- ✅ TransportCostService (update to dynamic rates)
- **NEW**: Depot simulation and TTR tracking

**task_v2 Files for This Phase**:
- Resource deposit discoveries → task_v2 mining missions
- Depot construction sequencing
- Equipment gating/availability updates

**Economics Impact**: 
- Transport cost to Luna: drops ~30%
- AstroLift `base_fee_per_kg`: 150 → ~100 GCC/kg

---

## ⚙️ PHASE 8+: Shipyard Construction & First Large Craft — FUTURE

**Prerequisites**: Phase 7+ gate met

**Narrative Focus**: Heavy industry. First generation orbital shipyard begins producing large craft (tugs, cyclers) from Luna-sourced materials.

**Technical Focus**:
- L1 shipyard construction
- Orbital construction logistics
- Heavy Lift Transport design
- Cycler deployment (Earth-Mars cycler established)

**Key Codebase Components Needed**:
- **NEW**: OrbitalConstructionLogisticsService
- **NEW**: Heavy Lift Transport templates
- ✅ Orbital structure models (need wiring)
- **NEW**: Cycler route optimization
- **NEW**: Supply chain sequencing for large craft

**task_v2 Files for This Phase**:
- Shipyard construction tasks
- Heavy Lift Transport manufacturing
- Cycler deployment and testing
- Orbital position simulation

**Economics Impact**:
- No Earth launch costs for ships
- Transport cost to Luna: drops ~50% from baseline
- AstroLift `base_fee_per_kg`: ~100 → ~60 GCC/kg
- Mars bulk cargo costs drop ~60%

---

## � PHASE 9: Mars Orbital Presence — Phobos/Demios Conversion & Repositioning

**Prerequisites**: Phase 8+ gate met (cyclers operational, tug capability proven)

**Narrative Focus**: Establish Mars orbital infrastructure. Convert Phobos/Demios into specialized orbital stations (hybrid manufacturing + fuel depot). Reposition moons to strategic orbits.

**Technical Focus**:
- Phobos/Demios hollowing and structural conversion
- Moon repositioning with tug fleets
- Orbital mechanics for strategic placement
- Station integration planning (power, life support, manufacturing/fuel depot dual-use)

**Key Codebase Components Needed**:
- ✅ Tug deployment mechanics (Phase 8)
- **NEW**: TugDeploymentService for moon repositioning
- **NEW**: Structural relocation simulation
- **NEW**: Moon hollowing algorithms  
- **NEW**: Orbital mechanics solver (Phobos/Demios positioning)
- **NEW**: Dual-station integration architecture

**Mission Profile Reference**: 
- `mars_orbital_establishment_profile_v1.json` — Complete Mars orbital establishment with Phobos/Demios conversion phases

**task_v2 Files for This Phase**:
- `task_phobos_deimos_organic_assessment.json` (Martian legacy organics survey)
- `task_phobos_deimos_conversion_setup.json` (preparation & assessment)
- `task_phobos_hybrid_station_construction.json` (manufacturing + processing)
- `task_deimos_fuel_depot_construction.json` (fuel storage + crew staging)
- `task_orbital_infrastructure_integration.json` (cycler network connection)

**AI Manager Behavior**: 
- Coordinates tug fleets for moon repositioning
- Manages construction sequencing across Phobos/Demios
- Prioritizes dual-use station layout (manufacturing on Phobos, fuel logistics on Deimos)
- Tracks structural integrity during hollowing

**Gate Condition**: Both Phobos and Deimos operational as specialized stations in strategic orbits, cycler network connected, ready for supply delivery.

---

## 🌀 ACT 3: Orphaned Era (Snap Event & Crisis) — FUTURE (Phase 9+ Gate Met)

**Narrative**: Catastrophic Snap event creates technology divide. Players coordinate rescue through Wormhole Transit Consortium. Knowledge transfer critical.

**Technical Mapping**: Phase 10+ advanced features requiring:
- Wormhole destabilization mechanics  
- Crisis event triggering
- Multi-system communication delays
- High-Energy Beacon for data transmission

---

## 📦 PHASE 10: Cycler Shakedown — Mars Orbital Supply Delivery

**Prerequisites**: Phase 9 gate met (Phobos/Demios stations operational in strategic orbits)

**Narrative Focus**: Supply chain validation. Cyclers deliver massive material shipments from Earth/L1 stations and Luna to support Mars orbital station construction and ongoing operations. Test cycler reliability under load.

**Technical Focus**:
- Cycler manifest optimization for Mars orbital delivery
- Multi-stop routing (Earth → Luna → LEO → Mars orbit)
- Cargo transfer and docking sequencing
- Structural load validation during delivery
- Cost/fuel optimization for interplanetary supply chains

**Key Codebase Components Needed**:
- ✅ Cycler models and routing (Phase 8)
- **NEW**: Multi-stop manifest optimization
- **NEW**: Cargo transfer sequencing service
- **NEW**: Structural load simulation during delivery
- **NEW**: Interplanetary supply chain cost modeling
- **NEW**: Cycler reliability metrics and wear tracking

**Mission Profile Reference**:
- `mars_orbital_establishment_manifest_v1.json` — Complete cycler fit with Cycler Mars Constructor carrying materials for Phobos/Demios stations

**task_v2 Files for This Phase**:
- `task_cycler_mars_constructor_fuel_loading.json` (LEO fuel depot stage)
- `task_cycler_mars_constructor_cargo_loading.json` (Luna resource loading)
- `task_cycler_mars_transits_orbital_delivery.json` (multi-stop routing)
- `task_orbital_cargo_transfer_and_docking.json` (Mars orbit operations)
- `task_phobos_deimos_station_supply_integration.json` (station receiving)

**AI Manager Behavior**:
- Generates cycler manifests based on Phobos/Demios construction needs
- Optimizes routing to minimize fuel/time
- Manages cargo sequencing at multiple destinations
- Tracks cycler wear and schedules maintenance
- Monitors structural integrity during delivery

**Economics Impact**:
- Validates LEO → Mars cycler reliability
- Establishes sustainable supply rate to Mars orbital stations
- Tunes cycler base_fee_per_kg for long-haul performance

**Gate Condition**: Cycler successfully completes full manifest delivery to Mars orbit. All Phobos/Demios station supplies delivered on schedule. Cycler ready for sustained ops.

---

## 🌌 PHASE 11: Asteroid Belt Operations & Venus Orbital Conversion — FUTURE (Phase 10 Gate Met)

**Prerequisites**: Phase 10 gate met (cycler supply chains validated, Mars orbital stations operational)

**Narrative Focus**: Systematic expansion beyond Mars. Cycler fleet grows. Tug operations extend to asteroid belt. New orbital stations created at Venus using relocated asteroids.

**Technical Focus**:
- Slag management from Mars moon hollowing (byproduct processing/repurposing)
- Asteroid belt scouting (identify Phobos/Demios-sized candidates)
- Asteroid relocation mechanics (tugs move targets to Venus)
- Venus orbital conversion (repeat Mars operation with relocated asteroids)
- Cycler routing optimization (L1 → Mars → belt → Venus → L1)

**Key Codebase Components Needed**:
- ✅ Tug fleets (Phase 9)
- ✅ Cycler routing (Phase 10)
- **NEW**: Slag byproduct processing and monetization
- **NEW**: Asteroid belt prospecting service
- **NEW**: Asteroid relocation target selection algorithm
- **NEW**: Venus orbital mechanics and positioning
- **NEW**: Multi-leg cycler routing optimization (L1 → multiple destinations → L1)
- **NEW**: Operational template replication (Mars pattern → Venus)

**Mission Profile Reference**:
- `mars_orbital_establishment_profile_v1.json` serves as template for Venus operations
- New Venus mission profile: `venus_orbital_establishment_profile_v1.json` (duplicates Mars structure with Venus-specific parameters)

**task_v2 Files for This Phase**:
- `task_mars_slag_processing_and_staging.json` (convert Mars hollowing byproducts)
- `task_asteroid_belt_prospecting_survey.json` (identify candidate asteroids)
- `task_asteroid_relocation_to_venus.json` (tug operations)
- `task_venus_orbital_conversion_setup.json` (preparation for Venus stations)
- `task_venus_station_construction_phobos_equivalent.json` (manufacturing station)
- `task_venus_station_construction_demios_equivalent.json` (fuel depot)
- `task_cycler_multi_leg_routing_mars_venus.json` (L1 → Mars → Venus → L1 supply runs)

**AI Manager Behavior**:
- Executes template-based mission generation (Mars pattern replicated at Venus)
- Coordinates three-way logistics: Mars operations ongoing + Venus expansion + cycler cycles
- Optimizes slag monetization from Mars
- Routes tugs to belt for asteroid selection
- Manages cycler cargo swaps at multiple orbital nodes
- Tracks structural conversion timelines across two systems

**Economics Impact**:
- Venus supply routes: similar cost structure to Mars (distance-based adjustment)
- Slag processing: revenue stream from waste byproducts
- Multi-destination cycler ops: higher utilization = lower per-kg transport costs
- Asteroid mining: opportunity to source alternative materials vs export from Mars

**Gate Condition**: Venus orbital stations operational in strategic positioning. Cycler completes full multi-leg routing (L1 → Mars → Venus → L1) on schedule with full cargo manifest. Sustained dual-system ops proven viable.

---

---

## 🌀 PHASE 12: Cycler Steady-State Operations & Mars Surface Expansion — FUTURE (Phase 11 Gate Met)

**Prerequisites**: Phase 11 gate met (Venus stations operational, multi-leg cycler routing proven, slag processing established)

**Narrative Focus**: The cycler becomes a permanent orbital platform. No more special missions — it cycles continuously between Venus → Mars → Earth on established routes. Docking/undocking operations at each planet as they align. Sustained supply delivery enables Mars surface operations and deeper Venus atmospheric harvesting.

**Technical Focus**:
- Continuous cycler operations (Venus → Mars → Earth cycle)
- Dynamic docking/undocking sequencing (craft meet cycler at each planet)
- Sustained logistics to both orbital stations
- Mars surface descent infrastructure (landers, rovers, habitats)
- Venus atmospheric harvesting intensification (gas collection from dense atmosphere)
- Cycler-to-surface supply chains (orbital → surface → orbital)

**Key Codebase Components Needed**:
- ✅ Multi-leg cycler routing (Phase 11)
- ✅ Docking mechanics (existing)
- **NEW**: Continuous operations scheduler (cycler never stops, only docks)
- **NEW**: Dynamic rendezvous timing (craft must meet cycler at correct orbital windows)
- **NEW**: Mars surface descent sequencing (landers, landing site selection)
- **NEW**: Surface infrastructure models (habitats, rovers, ISRU on surface)
- **NEW**: Venus atmospheric harvesting intensification (gas skimming from dense atmosphere)
- **NEW**: Orbital-to-surface logistics routing

**Mission Profile Reference**:
- `mars_orbital_establishment_manifest_v1.json` extended with surface descent components
- New profile: `venus_mars_cycler_steady_state_operations_v1.json`
- New profiles for surface operations: `mars_surface_establishment_v1.json`, `venus_atmospheric_harvesting_intensive_v1.json`

**task_v2 Files for This Phase**:
- `task_cycler_continuous_venus_mars_earth_cycle.json` (ongoing operations, no endpoints)
- `task_mars_surface_lander_deployment.json` (descent to Gale Crater, Jezero, etc.)
- `task_mars_surface_habitat_construction.json` (pressurized habitats for surface)
- `task_mars_surface_isru_operations.json` (local mining/processing on surface)
- `task_venus_atmospheric_harvesting_gas_collection.json` (intensified skimming)
- `task_cycler_orbital_to_surface_supply_chains.json` (moving materials between cycler and surface)
- `task_cycler_docking_rendezvous_operations.json` (continuous dock/undock scheduling)

**AI Manager Behavior**:
- Executes never-ending cycler cycle (Venus → Mars → Earth → repeat)
- Schedules cargo transfers at each planet as cycler passes through
- Coordinates surface operations with orbital supply arrivals
- Routes surface ISRU products back to cycler
- Manages Venus gas harvesting intensity based on current oxygen/fuel needs
- Optimizes cycler fuel/cargo for 3-body equilibrium maintenance

**Economics Impact**:
- Sustained supply to Mars and Venus = settlement growth acceleration
- Surface ISRU begins producing (regolith → metals, volatiles → LOX/water)
- Venus gas becomes major fuel source (supplementing cycler transport capacity)
- Orbital station overhead reduced (no docking/undocking wait times, cargo flows continuously)

**Gate Condition**: Cycler completes first full continuous cycle (Venus → Mars → Earth → Venus) with successful dock/undock operations at all three locations. Mars surface landing successful with initial habitat pressurized. Venus atmospheric harvesting producing sustained fuel output.

---

## 🔗 ACT 3: Multi-World Colonization & Surface Operations — FUTURE (Phase 12 Gate Met)

**Narrative**: The cycler becomes civilization's backbone. Orbital stations mature into self-sufficient nodes. Surface operations begin on Mars (resource extraction, habitat expansion, scientific discovery). Venus atmospheric harvesting becomes routine. The solar system transforms from exploration phase into colonial expansion phase.

**Technical Mapping**: Phase 12+ (cycler steady-state, surface operations):
- Continuous cycler maintenance and optimization
- Surface settlement autonomy (local ISRU, local resource processing)
- Multi-body logistics equilibrium (three active settlements)
- Crisis event systems (Snap events, resource disruptions, habitat failures)
- Advanced AI Manager: scales surface operations autonomously based on orbital supply rates

---

## 🎓 PHASE 13+: AI Manager Learning & Pattern Extraction

**Narrative**: The system now teaches the AI Manager. It observes successful patterns across Luna, Mars, Venus, Ceres, Saturn/Titan expansions. Learns construction sequencing, logistics networks, market dynamics, expansion priorities, resource valuation.

**Purpose**: NOT new features. Observation and pattern extraction from working system.

**AI Learning Framework**:
- **Construction Patterns**: Worldhouse sequencing, pressurization logic, TTR modeling
- **Logistics Networks**: Cycler routing, multi-leg sequencing, cargo optimization
- **Market Dynamics**: NPC pricing, resource scarcity, transport cost evolution
- **Expansion Priorities**: Which worlds to target, settlement bootstrap order, resource abundance analysis
- **Revenue Streams**: Slag monetization, mining operations, atmospheric harvesting, ISRU production
- **Failure Modes**: Habitat pressurization failure, cycler mechanical wear, resource shortage cascades

**Technical Requirements**:
- **Pattern Storage**: Learned patterns serialized (templates, decision trees, heuristics)
- **World Evaluation Framework**: Algorithm to assess new world viability (resource data → expansion potential score)
- **Autonomous Mission Generation**: AI generates task_v2 files based on world potential and learned patterns
- **Bootstrap Logic**: How to establish first foothold on virgin world (seed resources, construction sequence)

**Outcome**: AI Manager internalized all expansion logic. Ready for autonomous operation in Phase 14+.

---

## 🚀 PHASE 14a: Autonomous Sol Expansion + Early Terraforming Experiments

**Narrative**: AI Manager expands autonomously across Sol system. Optional settlements emerge where AI determines viable (Mercury, asteroid belt, Jupiter trojans). Simultaneously, early experimental terraforming begins on Mars — testing technologies that will eventually enable planetary transformation.

**Purpose**: Two parallel tracks: (1) stress-test codebase at scale, (2) introduce terraforming mechanics before the crisis.

**AI Behavior**:
1. **World Evaluation**: Analyze each uncolonized world (resources, accessibility, ISRU potential)
2. **Settlement Bootstrap**: Decide where next footholds go (prioritize high-value resource worlds)
3. **Mission Generation**: Create task_v2 construction/mining/harvesting missions autonomously
4. **Logistics Network**: Route cyclers to new footholds, optimize supply chains
5. **Revenue Optimization**: Scale mining/harvesting based on transport capacity
6. **Expansion Cascades**: As settlements mature, evaluate new frontiers

**Early Terraforming Experiments** (New in Phase 14a):
- Small-scale atmospheric algae experiments on Mars
- Thermal plant deployment (dark carbon material to raise temps)
- Methane/ammonia concentration monitoring
- Long-term transformation projections (centuries-scale)
- Foundation for Phase 15+ intensive terraforming

**Key Difference**: Not full terraforming yet. EARLY experiments. Small installations. Baseline for measuring change.

**Optional Settlements Across Sol**:
- **Inner System**: Mercury orbital stations, Venus polar installations
- **Asteroid Belt**: Vesta, Ceres variants, Pallas, Juno (mining networks)
- **Mars Expansion**: Multiple surface settlements beyond initial bases
- **Outer System**: Jupiter Trojan asteroids, Saturn systems (Titan expanded)

**Player Experience**:
- AI discovers settlement locations organically
- Terraforming experiments visible but not transformative (early stage)
- Players observe long-term change projections
- Codebase validated at 10+ settlements

**Gate Condition**: AI successfully colonizes 5+ new worlds autonomously. Terraforming baseline established. System accumulating mass toward critical threshold.

---

## ⚠️ PHASE 14b: Critical Mass Accumulation → Natural Wormhole Snap Event

**Narrative**: Sol system reaches saturation. Infrastructure mass exceeds wormhole stability limits. The natural wormhole destabilizes catastrophically. Exit shifts to unknown destination. Initial colony systems are orphaned. Crisis era begins.

**Trigger Mechanics** (from `02_crisis_mechanics.md`):
- **Stage 1**: Core system expansion readiness (population, economy, tech, resources)
- **Stage 2**: Destination system mass accumulation (infrastructure, cargo flows, economic activity)
- **Mass Limit**: 500,000 tons × stability multiplier (Sol: 1.0 = 500k tons base)
- **Result**: Exit shifts from known destination to random deep space location

**Technical Implementation**:
- ⏳ **Maturity Calculator**: Score system readiness for snap (population, GCC reserves, infrastructure mass)
- ⏳ **Mass Accumulator**: Track cumulative infrastructure weight across all settlements
- ⏳ **Snap Trigger**: When mass threshold exceeded + maturity conditions met
- ⏳ **Exit Shift Algorithm**: Randomize new wormhole destination (Eden → ???)
- ⏳ **Orphaning Cascade**: Communication lost, trade disrupted, colonial autonomy forced

**What Happens**:
1. Wormhole destabilizes without warning
2. Exit point shifts to unknown deep space location  
3. Original colony systems (Eden, Mars, Ceres, Saturn/Titan) become isolated
4. Players lose contact with Earth
5. AI Manager forced to operate independently
6. Codebase automatically validates self-sufficiency

**Player Impact**:
- Catastrophic narrative event
- Cannot predict when it occurs
- Settlements must be self-sufficient to survive
- Communication/trade disrupted until Wormhole Transit Consortium reestablishes links

**Gate Condition**: Snap event occurs, colony systems orphaned, new wormhole exit discovered in deep space.

---

## 🌌 ACT 4: The Orphaned Era & Wormhole Discovery (Phases 15+)

**Narrative**: The snap was catastrophic accident, not planned expansion. Exotic Matter physics unknown at time of disaster. Sol-side forms Wormhole Transit Consortium to re-establish links. AI discovers Exotic Matter applications. Portal technology emerges from wormhole research. Players enter game when portal networks established.

**Technical Mapping**: Phase 15+ (crisis response, wormhole stabilization, new system exploration):
- ✅ Natural wormhole mechanics operational (triggers snap)
- **NEW**: Exotic Matter physics and applications
- **NEW**: Artificial wormhole stabilization (one-way tech)
- **NEW**: Portal technology (two-way instantaneous transport, universal deployment)
- **NEW**: Hub-based connectivity (portal networks like airports)
- **NEW**: Wormhole Transit Consortium coordination
- **NEW**: Multi-system crisis management
- **NEW**: Unknown system exploration and development

**Critical Sequence**:
1. Phase 14b: Snap event, wormhole destabilizes, orphaning cascade
2. Phase 15: AI discovers Exotic Matter physics through studying natural wormhole
3. Phase 15: Artificial wormhole stabilization developed (reconnection capability)
4. Phase 15: Portal technology reverse-engineered from stabilization tech (instantaneous transport)
5. Phase 15: Portal pairs deployed across Sol system (connecting major settlements)
6. **PLAYER ENTRY POINT**: After portal networks established, players can rapidly travel between paired locations

**Portal Hub Network** (airport-style within-system):
- **Hub Model**: Major worlds have portal bases (Earth, Mercury, Mars, Ceres, Jupiter, Saturn, Pluto)
- **Paired Connections**: Each portal pair connects two hubs (quantum entanglement 1-to-1)
- **Player Airport Experience**: Travel between major world hubs like plane connections
- **Flexible Routing**: Players hop Mercury → Mars → Ceres → Jupiter → Saturn → Pluto or any other path
- **Scalable**: Any major world/settlement can become portal hub if EM budget allows
- **EM-Powered**: Total network powered by harvested Exotic Matter from natural wormhole

**Why Portal Tech Critical**: Players cannot efficiently explore 10+ settlements without rapid transport. Portal pairs enable players to visit AI-generated settlements, trade hubs, research stations, and mining operations across Solar System by hopping between paired locations.

**Player Experience Post-Portal**:
- Rapid travel between settlements (instantaneous via portal hubs)
- Visit any AI-discovered location (Mercury, asteroids, Jupiter trojans, Pluto)
- Participate in multi-system economy and trade
- Engage with crisis response (wormhole coordination)
- Explore unknown systems via AWS portal connections

**Critical Insight**: Phases 5-14 = AI/Codebase Learning Arc. Phase 15 = Wormhole Science + Portal Tech Arc. **THEN players enter game with portal networks enabling universe-scale accessibility.**

---

## Task Generation Architecture

### Phases 5-13: Scripted Learning Pathway

```
Developer writes task_v2 files for Phases 5-13
↓
AI Manager executes missions in controlled sequence
↓
AI observes patterns (construction, logistics, market, expansion priorities)
↓
AI stores learned patterns (serialized decision trees, heuristics, templates)
↓
After Phase 13 gate: AI has internalized all expansion logic
```

**Why scripted?** Teaching phase. We design the sequence to show AI:
- What successful expansion looks like
- How logistics networks scale
- Where resource bottlenecks emerge
- What prioritization decisions matter

### Phase 14a: Emergent Expansion + Terraforming Baseline

```
AI starts with empty Sol system + world resource data + learned patterns
↓
AI evaluates each world (viability scoring based on resources + accessibility)
↓
AI autonomously generates task_v2 files (no developer pre-writing)
↓
Settlements emerge where AI determines viable
↓
Simultaneously: Early terraforming experiments begin on Mars
↓
Players discover settlements + observe long-term change baselines
```

**Why emergent?** Test phase. AI runs the show:
- Codebase stress-tested at scale (10+ simultaneous settlements)
- AI expansion logic validated against real data
- Terraforming framework established (decades/centuries-scale projections)
- Players experience procedurally-generated frontier

### Phase 14b: Critical Mass → Snap Event

```
Infrastructure mass accumulates across all settlements
↓
Population grows, GCC reserves build, tech matures
↓
When mass > 500k tons + maturity conditions met:
   Natural wormhole destabilizes
   Exit shifts to unknown destination
   Orphaning cascade begins
↓
Settlements cut off from Earth
↓
AI Manager forced to operate independently
↓
Codebase validates self-sufficiency
```

**Why catastrophic?** Crisis event. System-wide impact:
- Snap is NOT predicted or preventable (emergent from mass accumulation)
- Settlements must survive independently
- Communication/trade disrupted
- Economy rebalances without Earth anchor
- Wormhole science becomes critical

**Key Insight**: 
- Phases 5-13 = **Tutorial Arc** (learning codebase, teaching AI)
- Phase 14a = **Expansion Arc** (test codebase, procedural settlement generation)
- Phase 14b = **Crisis Arc** (Snap event, isolation, independence)
- Phase 15+ = **Survival Arc** (wormhole science, reconnection, unknown frontiers)

---

## Codebase Readiness Checklist

### Phase 5 (Current)
- ✅ Luna ISRU pipeline operational
- ✅ Market system operational
- ✅ AI Manager dispatch logic operational
- ⏳ TaskExecutionEngineV2 (task_v2 executor) — IN PROGRESS
- ⏳ Learned pattern storage/retrieval system — DESIGN PHASE

### Phase 6
- ✅ Worldhouse models exist (but no wiring)
- ⏳ WorldhouseSimulationService — DESIGN PHASE
- ⏳ Construction sequencing logic — DESIGN PHASE
- ⏳ Pressurization/TTR metrics — PARTIAL

### Phase 7+
- ⏳ DepositSpawner service — TODO
- ⏳ Dynamic TransportCostService — TODO
- ⏳ Multi-system logistics routing — TODO

### Phase 8+
- ⏳ OrbitalConstructionLogisticsService — TODO
- ⏳ Cycler route optimization — TODO

### Phase 9 (Mars Orbital Presence)
- ⏳ TugDeploymentService (moon repositioning) — TODO
- ⏳ Structural relocation simulation — TODO
- ⏳ Moon hollowing algorithms — TODO
- ⏳ Orbital mechanics solver (Phobos/Demios positioning) — TODO
- ⏳ Dual-station integration architecture — TODO

### Phase 10 (Cycler Shakedown)
- ⏳ Multi-stop manifest optimization — TODO
- ⏳ Cargo transfer sequencing service — TODO
- ⏳ Structural load simulation — TODO
- ⏳ Interplanetary supply chain cost modeling — TODO
- ⏳ Cycler reliability metrics & wear tracking — TODO

### Phase 11 (Ceres Operations & Asteroid Belt Mining Hub)
- ⏳ Ceres orbital establishment (mining outpost platform)
- ⏳ Asteroid belt prospecting service (resource identification)
- ⏳ Mars-Ceres cycler construction (separate from Venus cycle)
- ⏳ Automated mining operations (autonomous harvest and transport)
- ⏳ Slag byproduct processing and monetization
- ⏳ Multi-leg cycler routing optimization (Mars ↔ Ceres)
- ⏳ Ceres settlement manifest and profile generation

### Phase 12 (Saturn/Titan Outer System Operations)
- ⏳ Titan atmospheric harvesting infrastructure (outer system ISRU)
- ⏳ Saturn moon network coordination (Dione, Enceladus, Rhea staging)
- ⏳ Saturn orbital station construction
- ⏳ Mars-Saturn/Titan cycler construction (separate from Venus and Ceres cycles)
- ⏳ Helium-3 extraction and processing (Jupiter preparation)
- ⏳ Multi-leg cycler routing optimization (Mars ↔ Saturn/Titan)
- ⏳ Saturn system settlement manifest and profile generation

### Phase 13 (Three-Cycler Steady-State Operations)
- ⏳ Continuous operations scheduler (three simultaneous cycler networks)
- ⏳ Dynamic multi-frontier rendezvous timing (Venus, Ceres, Saturn orbital windows)
- ⏳ Mars surface descent sequencing (multiple landers, habitat construction)
- ⏳ Surface infrastructure scaling (habitats, rovers, surface ISRU at multiple sites)
- ⏳ Three-world revenue optimization (Venus gas, Ceres mining, Saturn Helium-3)
- ⏳ Orbital-to-surface logistics routing (simultaneous surface operations)
- ⏳ Colonial autonomy framework (settlements manage without Earth intervention)

### Phase 13+ (AI Learning & Pattern Extraction)
- ⏳ Pattern serialization (learned construction, logistics, market, expansion logic)
- ⏳ Heuristic storage for decision making
- ⏳ Template extraction from successful missions
- ⏳ Metrics collection (what expansion priorities did AI learn?)

### Phase 14a (Autonomous Sol Expansion + Early Terraforming)
- ⏳ **WorldEvaluationService**: Score uncolonized worlds (resources, accessibility, ISRU potential)
- ⏳ **SettlementBootstrapLogic**: How to establish first foothold (seed resources, construction sequence)
- ⏳ **AutonomousMissionGenerator**: Generate task_v2 files based on world potential + learned patterns
- ⏳ **ExpansionPrioritizer**: Decide which world to colonize next (multi-factor scoring)
- ⏳ **DynamicCyclerRouter**: Route cyclers to new footholds autonomously
- ⏳ **Early Terraforming Framework**: Small-scale Mars experiments (algae, thermal plants, monitoring)
- ⏳ **Transformation Projections**: Long-term atmospheric change modeling

### Phase 14b (Critical Mass Accumulation & Snap Event)
- ⏳ **Maturity Calculator**: Score system readiness for snap (population >50M, GCC >100B, tech mature)
- ⏳ **Mass Accumulator**: Track infrastructure weight across settlements
- ⏳ **Snap Trigger Algorithm**: When mass >500k tons + maturity met
- ⏳ **Exit Shift Mechanics**: Randomize new wormhole destination
- ⏳ **Orphaning Cascade**: Communication loss, isolation protocol
- ⏳ **Colonial Autonomy Test**: Validate all settlements can operate independently

### Phase 15+ (Orphaned Era & Wormhole Discovery — PLAYER ENTRY POINT)
- ⏳ **Exotic Matter Physics**: Foundation for wormhole stabilization and portal tech
- ⏳ **Artificial Wormhole Stabilization**: Reconnect orphaned systems to Earth
- ⏳ **Natural Wormhole EM Harvesting**: Extract Exotic Matter from natural wormhole (renewable resource)
- ⏳ **Quantum Entanglement Portal Tech**: Reverse-engineer quantum portal pairing from wormhole physics
- ⏳ **Portal Pair Deployment**: Install matching portal endpoints in strategic Sol system locations
- ⏳ **Wormhole Transit Consortium**: Multi-system coordination (uses primary natural wormhole)
- ⏳ **Unknown System Exploration**: Procedurally-generated new system via wormhole exit
- ⏳ **Intensive Terraforming**: Scale early experiments from Phase 14a
- ⏳ **System-Local Portal Network**: Enable player rapid-travel between settlements in Sol system

**Critical Gate Before Player Entry**: 
- Portal networks operational within Sol system (Mercury ↔ Mars ↔ Ceres ↔ Jupiter ↔ Saturn ↔ Pluto)
- EM harvesting from natural wormhole sustaining all portal pairs
- Wormhole exit to unknown system accessible
- Players can visit 10+ AI-discovered settlements via portal pairs
- **THEN** players enter the game



---

## Backlog Sorting Strategy

When auditing `backlog_april_2026` files, sort tasks into phases using this logic:

1. **Silently-Resolved** → Archive (code already exists)
2. **Incomplete Concept** → Flag for phase assignment decision  
3. **Correct-but-Format-Stale** → Rewrite to TASK_TEMPLATE format and assign to correct phase

**Phase Assignment Logic**:
- Does it support Luna calibration (Phase 5)? → phase5+
- Does it support lava-tube construction (Phase 6)? → phase6+
- Does it support depot/LEO infrastructure (Phase 7)? → phase7+
- Does it support shipyard/large craft (Phase 8)? → phase8+
- Does it support Mars orbital (Phobos/Demios conversion & tug repositioning)? → phase9
- Does it support first cycler shakedown and Venus-Mars-Earth supply chains (Phase 10)? → phase10
- Does it support Ceres mining operations and Mars-Ceres cycler (Phase 11)? → phase11
- Does it support Saturn/Titan outer system and Mars-Saturn/Titan cycler (Phase 12)? → phase12
- Does it support three simultaneous cycler networks, Mars surface expansion (Phase 13)? → phase13
- Does it support AI pattern learning, world evaluation, settlement bootstrap, autonomous expansion logic (Phase 14a)? → phase14a
- Does it support terraforming experiments on Mars (early-stage, baseline measurement)? → phase14a
- Does it support mass accumulation, snap event trigger, wormhole mechanics (Phase 14b)? → phase14b
- Does it support Exotic Matter physics, artificial wormhole stabilization, Wormhole Transit Consortium (Phase 15+)? → phase15+
- Does it NOT fit any phase? → phase-backlog (revisit later)

**Key Insight**: 
- Phases 5-13 = **Tutorial Arc** (learning codebase, teaching AI)
- Phase 14a = **Expansion Arc** (test codebase, procedural settlement generation)
- Phase 14b = **Crisis Arc** (Snap event, isolation, independence)
- Phase 15 = **Wormhole Science + Portal Tech Arc** (Exotic Matter discovery, portal networks)
- **After Phase 15**: **PLAYER ENTRY POINT** (portal networks established, 10+ settlements accessible, rapid-travel enabled)

---

## 🎮 Player Entry Point & Universe Accessibility

**Before Players Enter**:
- Phases 5-15 are AI/codebase learning and validation
- AI discovers and establishes 10+ settlements across Sol system
- AI learns crisis management during Snap event
- Wormhole science discovered, portal technology developed
- Portal hub networks deployed across Sol system (Earth, Mercury, Mars, Ceres, Jupiter, Saturn, Pluto)

**When Players Enter** (Post-Phase 15):
- Portal hub network operational within Sol system (airport-style rapid travel between major worlds)
- Wormhole Station (WS) operational at natural wormhole
- 10+ unique AI-discovered settlements accessible via portal hubs
- Active economy, trade routes, resource networks already running (cyclers operating)
- Crisis aftermath: settlements managing independence, rebuilding connections
- Unknown system discovered and accessible via WS

**Intra-System Travel** (Portal Hub Network):
- ✅ Instantaneous travel between portal hubs within Sol system (Earth ↔ Mercury ↔ Mars ↔ Ceres ↔ Jupiter ↔ Saturn ↔ Pluto)
- ✅ Airport-style routing: transfer through multiple hubs to reach any destination
- ✅ Fast, convenient, no travel time

**Inter-System Travel** (Wormhole Stations):
- ✅ Travel to Wormhole Station (WS - natural wormhole) or Artificial Wormhole Station (AWS)
- ✅ Board craft (ship) for transit through wormhole to destination system
- ✅ Dock at receiving station in destination system
- ✅ Access portal hub network in destination system (if established)
- ✅ Portal networks deployable in ANY system independently (each system needs local EM source)

**Player Capabilities**:
- ✅ Rapid intra-system travel via portal hubs (instantaneous between major worlds)
- ✅ Inter-system travel via WS/AWS (craft-based, time-consuming)
- ✅ Visit any established settlement in any system
- ✅ Observe cargo flows via cycler networks (bulk transport operates at all scales)
- ✅ Participate in multi-system trade and logistics
- ✅ Experience terraforming progression (Mars showing decades of change)
- ✅ Explore unknown system (accessed via WS)
- ✅ Coordinate with AI Manager and WTC on crisis response

**What Did NOT Change**:
- ✅ Cyclers still operate for bulk cargo (intra-system and inter-system)
- ✅ Large cargo, terraforming resources, industrial equipment transport via cyclers
- ✅ Players observe cycler networks running continuously in background
- ✅ Economy driven by cycler-based logistics and resource flows

**Critical Design Philosophy**: 
- **Within-system**: Portal hubs enable efficient exploration (airport-style convenience)
- **Between-system**: WS/AWS + craft travel (slower, more intentional)
- **Portal networks**: Independently deployed in any system with EM source (procedurally generated by AI)
- **Result**: Players explore AI-discovered universe, with different travel mechanics for local vs inter-system journeys

