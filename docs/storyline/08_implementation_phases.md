# Implementation Phases

## Phase 1: MissionExecutor Service (Foundation)
- AI Manager reads and executes mission profile JSONs (system-agnostic)
- Removes hardcoded deployment logic
- Proves patterns are reusable and data-driven

## Phase 2: ResourceAcquisition Intelligence (Economics)
- AI Manager makes smart, data-driven sourcing decisions
- Prioritizes player market, then NPC, then Earth
- Implements buy order pricing, timeout/fallback logic, and tracks metrics

## Phase 3: ScoutLogic - System Analysis (Intelligence)
- AI Manager analyzes any celestial body/system and generates a standardized profile
- **EM Detection & Analysis**: Scans for residual Exotic Matter (EM) signatures indicating previous wormhole activity or natural EM sources
- **Wormhole Location Memory**: When natural wormholes are detected, stores precise location coordinates for future artificial wormhole targeting
- **Historical Data Integration**: Cross-references current scans with historical survey data to identify EM-rich systems or previously mapped wormhole locations
- All analysis is data-driven (no hardcoded system logic)
- Outputs comprehensive system profile including EM potential and wormhole history for pattern selection

## Phase 4: StrategySelector - Pattern Matching (Intelligence)
- AI Manager maps system profile to appropriate deployment pattern
- Uses data-driven logic to select and apply patterns
- Handles edge cases and phased deployment planning

## Phase 5: SystemOrchestrator (Integration)
- AI Manager orchestrates multi-settlement development using all learned patterns
- Tracks dependencies and manages resource flows
- Collects performance metrics for optimization

## Phase 6: Wormhole Integration (Expansion)
- Applies proven patterns to wormhole-discovered systems
- **Artificial Wormhole Targeting**: Uses stored natural wormhole location data to precisely target artificial wormhole creation to known EM-rich locations
- **EM Opportunity Assessment**: Prioritizes systems with detected residual EM for artificial wormhole development
- Manages wormhole network, Snap events, and economic decisions
- All logic is pattern-based and system-agnostic

## Phase 7: Wormhole Scouting Probe Development (New Addition)
- Develop a comprehensive series of probes for surveying systems discovered through wormholes
- Create base probe platform (generic_probe) similar to generic_satellite for satellites
- Develop specialized wormhole scouting probes:
  - **System Survey Probe**: Comprehensive reconnaissance with multi-spectrum sensors
  - **EM Detection Probe**: Specialized for Exotic Matter signature detection
  - **Atmospheric Probe**: Atmospheric analysis and entry capabilities (updated to use correct base_craft template)
- All probes use proper `base_craft` blueprint template and `craft_operational_data` operational template
- **EM Detection Integration**: EM Detection Probes feed data directly into AI Manager's memory systems for wormhole location mapping and EM resource assessment
- Probes are designed for AI Manager autonomous deployment and data collection
- Enable data-driven decision making for new system colonization and expansion

## Phase 8: The Snap Event & Dual-Link Reconnection (Crisis)
- Handles wormhole crisis and reconnection protocol
- **Phased Stabilization Process**:
  - **Phase 1 - Immediate Stabilization**: Deploy orbiting stabilization satellites that gather expelled EM and refocus it at the wormhole throat to maintain temporary stability
  - **Phase 2 - Permanent Infrastructure**: Construct Artificial Wormhole Stations (AWS) to replace temporary satellites
  - **Phase 3 - Counterbalance Enhancement**: Build additional AWS on opposite side of system (L3 Lagrange point) for gravitational counterbalance, similar to Jupiter stabilizing Sol's wormhole
- Implements EM harvesting, Artificial Wormhole Station construction, and dual-link counterbalance logic
- Dual-link model: Artificial Wormhole Station is deployed to counterbalance a natural (or another artificial) wormhole, reducing EM requirements and stabilizing the network
- Brown Dwarfs can serve as secondary anchors for additional stability
- All logic is data-driven and adapts to system metadata

## Phase 9: Inter-System Network Management (Topology)
- AI Manager splits traffic based on link properties and system data
- Maintains gravitational tension and EM budgets using real-time metrics
- Integrates Brown Dwarf Hubs as logistics batteries and gateways
- All network management is pattern-based and system-agnostic

## Phase 10: Consortium Integration (Governance)
- Implement Consortium formation upon first Snap event
- Add voting system for Route Proposals
- Implement dividend distribution from transit fees
- Enable player and NPC participation in network governance

---

*These phases provide a structured rollout for the wormhole expansion system.*