# Development Roadmap - AI Manager Pattern Learning and Expansion

**Purpose**: Clarify the actual development sequence for Sol system buildout, AI Manager pattern learning, and wormhole expansion to Prize systems.

**Philosophy**: Build and test in Sol first, learn patterns, then expand autonomously through wormholes. **Players are NOT part of this phase** - this is pure AI Manager testing and development.

**Last Updated**: 2026-01-18

---

## 🎯 Actual Development Sequence

### Phase 1: Sol System NPC Buildout (CURRENT - Testing Phase)

**Goal**: Build complete Sol system infrastructure using mission profiles to establish proven patterns

**What AI Manager Learns**:
1. **Luna Pattern** - Surface ISRU (regolith → I-beams, panels)
2. **L1 Depot Pattern** - Orbital manufacturing (ship construction, refueling)
3. **Mars (Phobos) Pattern** - Small moon conversion (Luna + L1 hybrid)
4. **Venus Pattern** - Atmospheric harvesting (no surface access)
5. **Titan Pattern** - Fuel production (methane, ethane processing)
6. **Jupiter/Saturn/Uranus/Neptune Patterns** - Gas giant systems (helium-3, atmospheric siphoning, moon depot networks)

**NPC Infrastructure Built** (see [NPC_INITIAL_DEPLOYMENT_SEQUENCE.md](NPC_INITIAL_DEPLOYMENT_SEQUENCE.md)):
- Luna → L1 → LEO → Mars/Phobos → Venus (artificial moons) → Titan → Jupiter → Saturn → Uranus → Neptune
- All depots, stations, atmospheric harvesting operational
- GCC markets established (NPC-to-NPC Virtual Ledger trading)
- Early terraforming active (Mars CO2/N2 import, Venus gas extraction)

**Player Status**: **NO PLAYERS** - This is testing/development only
- Player UI exists in vision documents but NOT implemented
- No player accounts, no player contracts, no player UI
- NPCs trade via Virtual Ledger (internal accounting, no player interaction)

**Success Criteria**:
- ✅ All 10-phase NPC deployment completes successfully
- ✅ AI Manager can execute mission profiles autonomously
- ✅ Patterns validated and documented
- ✅ Economic systems operational (GCC markets, Virtual Ledger, USD imports)

---

### Phase 2: Pattern Learning and Generalization (NEXT)

**Goal**: AI Manager extracts reusable patterns from Sol deployment and prepares for new system application

**AI Manager Development**:
1. **ScoutLogic** - Analyze new systems, generate standardized profiles (TEI scores, EM detection, resource assessment)
2. **StrategySelector** - Map system profile to appropriate pattern (Luna-like, Venus-like, Mars-like, hybrid)
3. **MissionExecutor** - Execute mission profiles autonomously without hardcoded logic
4. **ResourceAcquisition** - Prioritize local ISRU → NPC trade → Earth imports (economic intelligence)
5. **SystemOrchestrator** - Manage multi-settlement development, track dependencies

**Pattern Library Established**:
- Luna Pattern: Rich regolith, large moon → surface ISRU + L1 depot
- Venus Pattern: Dense atmosphere, no surface → orbital assembly + atmospheric harvesting
- Mars Pattern: Small moons, moderate resources → moon conversion (Phobos/Deimos)
- Titan Pattern: Thick atmosphere, surface lakes → fuel production hub
- Gas Giant Pattern: Atmospheric siphoning, helium-3 extraction, moon depot networks
- Hybrid Patterns: Mix elements based on system characteristics

**Success Criteria**:
- ✅ AI Manager can analyze ANY system (procedural or vetted)
- ✅ AI Manager selects appropriate pattern without human intervention
- ✅ AI Manager executes deployment autonomously
- ✅ Patterns are data-driven and system-agnostic (no hardcoded logic)

---

### Phase 3: Wormhole Expansion - Prize System Deployment (AOL-732356)

**Goal**: AI Manager applies learned patterns to first wormhole-discovered system (Prize World)

**AOL-732356 System Profile** (see [docs/systems/aol-732356.md](../systems/aol-732356.md)):
- **System Type**: Prize World (high TEI score ~0.88)
- **Key Features**:
  - Magnetic moment: 0.82 (excellent radiation shielding)
  - Atmospheric pressure: Near 1.0 atm (habitable baseline)
  - Volatiles: N2, CH4 present (no long-range supply needed)
  - Gas Giant 18: Mass $5.72 \times 10^{27}$ kg at 4.226 AU (gravitational anchor)
  - Asteroid XXXV: Mass $2.44 \times 10^{19}$ kg (Phobos pattern candidate)

**AI Manager Deployment** (autonomous):
1. **Wormhole Discovery**: Natural wormhole to AOL-732356 detected (EM signatures)
2. **Scout Probes Deployed**: EM Detection Probe, System Survey Probe, Atmospheric Probe
3. **ScoutLogic Analysis**: TEI > 80% → Prize World flag → high priority
4. **StrategySelector**: Maps to hybrid pattern (Luna + Mars + Gas Giant elements)
5. **Cycler Deployment**: 
   - Fit cycler with seed equipment (ISRU, fabricators, construction drones)
   - Transit through natural wormhole
   - Deploy to best candidate body (Super-Earth equivalent)
6. **Pattern Execution**:
   - Apply Luna pattern to solid bodies (regolith ISRU)
   - Apply Mars pattern to Asteroid XXXV (relocate to Gas Giant 18 L3 for depot anchor)
   - Apply Gas Giant pattern to Gas Giant 18 (helium-3, atmospheric siphoning)
7. **Infrastructure Buildout**:
   - Surface base on habitable world (Luna pattern)
   - L1-equivalent depot at Gas Giant 18 L3 (Mars pattern with asteroid anchor)
   - Atmospheric harvesting at Gas Giant 18 (Gas Giant pattern)
8. **Equipment Transfer**: Cycler transfers seed equipment to permanent infrastructure
9. **Kinetic Hammer Return**: Cycler loads resources + satellites, triggers controlled Snap to return to Sol

**Wormhole Lifecycle**:
- **Natural Anomaly**: Initial EM detection and mapping
- **Harvesting Site**: Temporary stabilization satellites for EM extraction
- **Permanent Anchor**: Artificial Wormhole Station (AWS) construction (MK1-H first interstellar structure)
- **Dual-Link Stabilization**: AWS at Gas Giant 18 L3 counterbalances natural wormhole, reducing EM requirements

**Player Status**: **STILL NO PLAYERS**
- This is AI Manager testing expansion to new systems
- No player participation in wormhole discovery or deployment
- NPCs manage all operations autonomously

**Success Criteria**:
- ✅ AI Manager successfully scouts and analyzes AOL-732356
- ✅ AI Manager selects appropriate hybrid pattern
- ✅ AI Manager deploys and builds infrastructure autonomously
- ✅ Wormhole stabilization (temporary satellites → permanent AWS) works
- ✅ Cycler equipment transfer and kinetic hammer return successful

---

### Phase 4: "The Snap" Crisis Event (Testing Wormhole Network Mechanics)

**Goal**: Test controlled wormhole destabilization, orphaning, and reconnection protocols

**Crisis Scenario**:
1. **Mass Limit Exceeded**: Cycler + cargo exceeds 500k ton mass limit on SOL-AOL-732356 link
2. **Wormhole Snaps**: Exit point shifts from AOL-732356 to new random system (System B)
3. **AOL-732356 Orphaned**: No longer connected to Sol via natural wormhole
4. **AWS Activation**: Pre-built Artificial Wormhole Station activates to reconnect AOL-732356 → Sol
5. **Dual-Link Network**: Sol now has:
   - Natural wormhole → System B (new discovery)
   - Artificial wormhole ← AOL-732356 (reconnection)

**AI Manager Response** (autonomous):
- **Phase 1 - Immediate Stabilization**: Deploy orbiting stabilization satellites at new wormhole exit (System B)
- **Phase 2 - Permanent Infrastructure**: Begin AWS construction at System B
- **Phase 3 - Network Management**: Balance EM budgets across dual-link network

**Consortium Formation** (if testing governance):
- Major logistics corporations form Wormhole Transit Consortium
- Vote on Route Proposals (which systems to keep connected)
- AWS construction funded by member corporations
- Transit fees generate dividends for members

**Player Status**: **POTENTIALLY INTRODUCE PLAYERS HERE** (optional)
- Crisis creates urgency and interesting economy
- Players could participate in Consortium (vote on routes, earn dividends)
- Players could fulfill logistics contracts (resource transport between systems)
- **BUT**: This is still testing phase - players optional, not required

**Success Criteria**:
- ✅ Wormhole Snap mechanics work correctly (exit shifts to new system)
- ✅ Orphaned system (AOL-732356) successfully reconnects via AWS
- ✅ AI Manager manages dual-link network (natural + artificial)
- ✅ EM budget balancing works (system doesn't run out of fuel)
- ✅ New system (System B) scouting and deployment begins

---

### Phase 5: Multi-System Network Expansion (Optional - Far Future)

**Goal**: AI Manager manages growing wormhole network across multiple systems

**Network Topology**:
```
Sol (Hub)
 ├─ Natural WH → System B (new Prize World)
 │   ├─ Deploy Luna + Mars patterns
 │   └─ Build AWS for reconnection
 │
 ├─ Artificial WH ← AOL-732356 (reconnected)
 │   ├─ Established infrastructure operational
 │   └─ Exports resources to Sol
 │
 ├─ Natural WH → System C (Brown Dwarf Siphon)
 │   ├─ Deploy Gas Giant pattern (EM harvesting)
 │   └─ Build L3 anchor for network fuel
 │
 └─ Branching Hub (System B has 2nd natural WH)
     └─ Natural WH → System D (parallel expansion)
```

**AI Manager Capabilities**:
- **Route Optimization**: Prioritize Prize Worlds vs Siphon systems
- **EM Budget Management**: Balance fuel production (Brown Dwarfs) vs consumption (all links)
- **Traffic Splitting**: Natural WH for bulk cargo, Artificial WH for high-value logistics
- **Kinetic Hammer Strategy**: Controlled Snaps to discover new systems
- **Economic Intelligence**: Minimize Earth dependency, maximize ISRU and NPC self-sufficiency

**Player Status**: **IF PLAYERS EXIST** (still optional)
- Players participate in network economy (transport contracts, market trading)
- Players join Consortium (vote on routes, invest in AWS construction)
- Players specialize (logistics, manufacturing, exploration contracts)
- Players experience "living universe" (NPCs already established, infrastructure operational)

**Success Criteria**:
- ✅ AI Manager manages 5+ systems simultaneously
- ✅ Network remains stable (EM production ≥ consumption)
- ✅ Economic systems scale (GCC markets, Virtual Ledger, NPC trading)
- ✅ AI Manager makes data-driven expansion decisions (Prize vs Siphon prioritization)

---

## 🎮 Player Integration (Future - NOT Current Development)

### When Players Enter (IF AT ALL)

**Earliest Possible Entry**: After Phase 4 (Snap Crisis)
- Sol system already built (all depots, stations operational)
- AOL-732356 infrastructure established (first wormhole expansion complete)
- Crisis creates economic opportunities (resource transport, logistics optimization)

**What Players Would Experience**:
- **Living Universe**: NPCs have built everything, economy operational
- **Active Markets**: GCC trading, contracts available, baseline pricing established
- **Tutorial Missions**: Simple delivery contracts (Luna → L1, Venus → Mars)
- **Progression**: Reputation unlocks better contracts, access to wormhole network
- **Consortium Participation**: Vote on routes, earn dividends, invest in AWS construction

**What Players Would NOT Do** (AI Manager handles):
- Building initial Sol infrastructure (NPCs already did this)
- Discovering first wormhole (AI Manager scouting probes)
- Deploying to AOL-732356 (AI Manager cycler missions)
- Managing network EM budgets (AI Manager economic intelligence)

**Player Role**:
- **Participants** in existing economy (not builders of initial infrastructure)
- **Optimizers** (find profitable niches NPCs miss)
- **Specialists** (logistics, manufacturing, exploration)
- **Stakeholders** (Consortium members with voting power)

### Player UI Status (See [PLAYER_UI_VISION.md](PLAYER_UI_VISION.md))

**Current State**: Vision documents exist, NO implementation
- ❌ Player dashboard (no code)
- ❌ Contract board (backend exists, no UI)
- ❌ Market interface (no code)
- ❌ Ship/cargo management (no code)
- ❌ Tutorial system (no code)

**Implementation Priority**: AFTER test suite green (<50 failures)
- Phase 4.1: Core contracts (dashboard, contract board, ship management)
- Phase 4.2: Economic depth (market trading, reputation system)
- Phase 4.3: Strategic tools (system map, economic forecasting)
- Phase 4.4: Social systems (corporations, contract sharing)

---

## 📊 Current Development Focus (Jan 2026)

### What We're Actually Doing Now

**Active Work**:
1. ✅ **Test Suite Restoration** - Fix 393 failures to get code baseline stable
2. ✅ **Database Fixes** - Resolved deadlock issues (deletion strategy working)
3. ✅ **Documentation** - Clarifying NPC deployment, AI Manager vision, player UI plans
4. **Mission Profile Validation** - Ensure Sol patterns work correctly
5. **AI Manager Foundation** - MissionExecutor, ResourceAcquisition, ScoutLogic services

**NOT Doing Now**:
- ❌ Player UI implementation (vision only, no code)
- ❌ Wormhole expansion (patterns first, expansion later)
- ❌ Consortium governance (after wormhole mechanics proven)
- ❌ Player contracts/markets (NPCs only via Virtual Ledger)

### Next Milestones

**Milestone 1: Test Suite Green** (Priority 1)
- Get RSpec failures < 50
- Database and model specs passing
- Service specs working
- Integration tests stable

**Milestone 2: Sol System Validation** (Priority 2)
- Execute NPC deployment sequence (Luna → L1 → LEO → Mars → Venus → Titan → outer planets)
- Validate all 10 phases complete autonomously
- Confirm GCC markets operational
- Verify NPC Virtual Ledger trading works

**Milestone 3: Pattern Extraction** (Priority 3)
- Generalize Luna, L1, Venus, Mars, Titan, Gas Giant patterns
- Implement ScoutLogic (system analysis, TEI scoring, EM detection)
- Implement StrategySelector (pattern matching for new systems)
- Test pattern selection with procedural systems

**Milestone 4: AOL-732356 Deployment** (Priority 4)
- Scout Prize World with AI Manager probes
- Select hybrid pattern autonomously
- Deploy cycler with seed equipment
- Build infrastructure using pattern library
- Execute kinetic hammer return

**Milestone 5: Wormhole Network** (Priority 5)
- Test Snap mechanics (exit shift)
- Implement AWS construction and activation
- Test dual-link stabilization (natural + artificial)
- Validate EM budget management

**Player Integration**: **UNKNOWN** - Maybe after Milestone 5, maybe never (testing focus)

---

## 🔬 Testing Philosophy

### Why No Players Yet?

1. **Complexity**: AI Manager pattern learning is complex enough without player interactions
2. **Data-Driven**: Need proven patterns before players can meaningfully participate
3. **Stability**: Test suite must be green before adding player UI complexity
4. **Economics**: NPC Virtual Ledger must work before introducing GCC player markets
5. **Patterns First**: Sol deployment proves patterns work, then apply to new systems

### What We're Testing

**AI Manager Autonomy**:
- Can AI Manager execute mission profiles without hardcoded logic?
- Can AI Manager analyze new systems and select appropriate patterns?
- Can AI Manager make economic decisions (ISRU vs import)?
- Can AI Manager manage multi-settlement dependencies?

**Pattern Generalization**:
- Do Luna, Venus, Mars, Titan patterns work on similar systems?
- Can patterns be mixed (hybrid approach)?
- Does pattern selection logic handle edge cases?
- Are patterns truly data-driven (no hardcoding)?

**Wormhole Mechanics**:
- Does mass tracking work correctly?
- Do Snap events trigger at right threshold?
- Does AWS construction and activation work?
- Does dual-link stabilization reduce EM consumption?
- Can network handle multiple systems?

### Success Definition

**Development Success**: 
- AI Manager builds Sol system autonomously ✓
- AI Manager applies patterns to AOL-732356 autonomously ✓
- Wormhole network remains stable (EM production ≥ consumption) ✓
- Economic systems scale without Earth dependency ✓

**Player Success** (if/when introduced):
- Players can complete contracts and earn GCC ✓
- Players find profitable niches NPCs don't optimize ✓
- Players participate in Consortium governance ✓
- 60%+ retention after first week ✓

---

## 📖 Related Documentation

### Core Architecture
- [wh-expansion.md](../../wh-expansion.md) - AI Manager training, wormhole expansion, pattern learning
- [GUARDRAILS.md](../GUARDRAILS.md) - Anchor Law, ISRU mandate, economic priorities
- [NPC_INITIAL_DEPLOYMENT_SEQUENCE.md](NPC_INITIAL_DEPLOYMENT_SEQUENCE.md) - Sol system 10-phase buildout
- [SIMEARTH_ADMIN_VISION.md](SIMEARTH_ADMIN_VISION.md) - Digital Twin simulation, pattern learning UI

### Systems and Expansion
- [docs/systems/aol-732356.md](../systems/aol-732356.md) - Prize World reference implementation
- [docs/storyline/07_procedural_generation.md](../storyline/07_procedural_generation.md) - System generation, TEI scoring
- [docs/storyline/10_implementation_phases.md](../storyline/10_implementation_phases.md) - AI Manager development phases

### Player Integration (Future)
- [PLAYER_UI_VISION.md](PLAYER_UI_VISION.md) - Player dashboard, contracts, markets (vision only, no implementation)
- [docs/developer/AI_MANAGER_PLANNER.md](../developer/AI_MANAGER_PLANNER.md) - Admin mission planner (existing UI)

---

**Last Updated**: 2026-01-18  
**Status**: Development roadmap - clarifies AI Manager testing focus, no player implementation yet  
**Next Review**: After Milestone 1 (test suite green) or Milestone 2 (Sol validation complete)
