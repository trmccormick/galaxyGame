# Wormhole Expansion Plan - Executive Summary

## Core Philosophy

The Wormhole Expansion system is built on a **data-driven, system-agnostic architecture** that enables AI-powered colonization of any discovered star system. The core principles are:

- **All logic is data-driven**: No hardcoded assumptions about specific systems (except Sol as the origin)
- **System-agnostic design**: Patterns learned from Sol can be applied to any star system
- **Reusable mission profiles**: Luna, Mars, Venus, and Titan patterns serve as templates for any compatible system
- **AI learns and adapts**: The system analyzes Sol's colonization patterns and applies them universally

## Story Arc and Lore

### Key Terms & Acronyms
- **EM (Exotic Matter)**: Specialized resource harvested from natural wormholes, primary energy source for Artificial Wormhole Stations.
- **ISRU (In-Situ Resource Utilization)**: Core philosophy prioritizing local materials over Earth imports for cost efficiency.
- **GCC (Galactic Crypto Currency)**: Primary inter-system currency, initially coupled to USD, eventually independent.
- **LDC (Lunar Development Corporation)**: Industrial corporation specializing in material production and station building.

### The Story Arc
**Act 1: Pattern Learning (Tutorial Phase)** - AI learns deployment patterns from Sol systems (Luna, Venus, Mars, Titan), mastering techniques through hands-on application.

**Act 2: Wormhole Discovery (Application Phase)** - AI applies learned patterns to wormhole-discovered systems, using ScoutLogic for analysis and pattern selection.

**Act 3: The Snap, Consortium Formation & Dual-Link Solution (Crisis Phase)** - Natural wormhole destabilizes, forcing formation of Wormhole Transit Consortium for artificial links. Dual-link model stabilizes networks with lower EM requirements.

**Act 4: Network Mastery (Late Game)** - AI manages wormhole networks, balancing EM budgets, optimizing logistics, and making ROI-based expansion decisions.

### The Crisis: The "Snap" & Exit-Shift
- **Trigger**: Natural wormhole snaps when mass-limit exceeded, shifting exit to new location, orphaning colonies.
- **Reconnection Drive**: Crisis forces Consortium formation for stable artificial links.
- **Analogy**: Like a rubber band snapping and flicking away.
- **Controlled Snap Expansion**: AI uses high-mass capacity for seeding, then triggers snaps for new systems, deploying stabilization satellites and Artificial Wormhole Stations.

### Institutional Framework: The Consortium
- **Founders**: AstroLift (Logistics) and LDC (Construction) combine for infrastructure and transit.
- **Gamble**: Corporations fund builds via Route Proposals, receiving dividends from transit fees.
- **Structure**: Consortium owns stations/depots; settlements are users/customers.

### Physics & Topology: The Brown Dwarf Hub
- **Role**: Brown Dwarfs as "Logistics Batteries" with high mass but low radiation, ideal for stable L3 Lagrange anchors.
- **Siphon**: Rich in volatiles (H/N), processed into EM fuel.
- **Strategic Importance**: Primary siphons for network EM, enabling deeper expansion.

## Key Components

### ProbeDeploymentService ✅
**Status**: Complete and operational
- Deploys autonomous probes through wormholes for intelligence gathering
- Collects comprehensive system data (planets, moons, asteroids, resources)
- Provides real-time telemetry and analysis
- Supports multiple probe types and mission configurations

### ScoutLogic 🔄
**Status**: Currently being refactored for system-agnostic operation
- Originally hardcoded for Alpha Centauri system
- Being refactored to work with any star system
- Handles resource discovery and prioritization
- Integrates with pattern matching for settlement opportunities

### SettlementPlanGenerator ✅
**Status**: Complete with asteroid tug integration
- Uses pattern matching to identify settlement opportunities
- Maps planetary characteristics to proven mission profiles
- Integrates asteroid relocation tugs for moon/asteroid targets
- Generates complete colonization plans with ROI analysis

### WormholeScoutingService 📋
**Status**: Core service exists, needs integration testing
- Orchestrates full wormhole scouting missions
- Creates artificial wormholes for system access
- Coordinates probe deployment and data collection
- Evaluates systems for colonization potential

### Mission Profiles ✅
**Status**: Comprehensive library of proven colonization patterns
- **Luna Pattern**: Large moon surface operations and resource extraction
- **Mars Pattern**: Asteroid capture & conversion with orbital depot network
- **Venus Pattern**: REFACTORED - Asteroid station deployment for high-pressure atmosphere operations
- **Jupiter Pattern**: Outer gas giant with radiation management and helium-3 harvesting
- **Saturn Pattern**: Ringed gas giant operations with moon-based infrastructure
- **Titan Pattern**: Hydrocarbon moon processing and fuel production
- **Neptune Pattern**: Ice giant deep space operations with cryovolcanic resources
- **Generic Pattern**: Fallback for non-matching systems

## Complete Pattern Library

### Pattern Application Examples
- **Large moon + resources** → Luna Pattern (Earth's Moon model)
- **2+ small moons + asteroid belt** → Mars Pattern (Mars/Phobos/Deimos model)
- **Dense atmosphere, no surface access** → Venus Pattern (asteroid stations, not surface)
- **Massive gas giant + radiation** → Jupiter Pattern (radiation-hardened infrastructure)
- **Ringed gas giant** → Saturn Pattern (ring mining + moon network)
- **Hydrocarbon-rich moon** → Titan Pattern (fuel production hub)
- **Distant ice giant** → Neptune Pattern (deep space research hub)

## Integration Flow

```
Wormhole Discovered → Deploy Probes → Analyze System →
Match Pattern → Generate Plan → Execute Deployment
```

### Detailed Process:
1. **Wormhole Discovery**: Natural or artificial wormhole detected
2. **Probe Deployment**: WormholeScoutingService deploys probe fleet
3. **System Analysis**: Probes gather comprehensive celestial data
4. **Pattern Matching**: SettlementPlanGenerator analyzes for known patterns
5. **Plan Generation**: AI creates customized colonization strategy
6. **Resource Allocation**: Tug deployment for moon/asteroid targets
7. **Mission Execution**: Coordinated deployment of cyclers and infrastructure

## Current Status

### ✅ Completed Components
- **Probe System**: Full probe deployment and data collection capability
- **Settlement Planning**: Pattern matching with tug integration complete
- **Complete Sol Pattern Library**: 7 major patterns + generic fallback available
- **Asteroid Tugs**: Relocation system integrated with settlement planning

### 🔄 In Progress
- **ScoutLogic Refactor**: Converting from Alpha Centauri-specific to system-agnostic
- **Pattern Validation**: Testing pattern matching across different system types

### 📋 Pending Integration
- **WormholeScoutingService**: Full integration with settlement planning
- **End-to-End Testing**: Complete mission flow validation
- **Procedural System Testing**: Validation with generated star systems

## Next Steps

### Immediate Priorities (Next Sprint)
1. **Complete ScoutLogic Refactor**
   - Remove Alpha Centauri hardcoding
   - Implement system-agnostic resource discovery
   - Integrate with pattern matching engine

2. **WormholeScoutingService Integration**
   - Connect with SettlementPlanGenerator
   - Implement full mission orchestration
   - Add error handling and recovery

### Medium-term Goals (Next Month)
3. **End-to-End Testing**
   - Test complete flow with procedural systems
   - Validate pattern detection accuracy
   - Performance optimization

4. **Pattern Expansion**
   - Add new patterns for exotic system types
   - Machine learning integration for pattern discovery
   - ROI optimization across different system classes

### Long-term Vision (Next Quarter)
5. **Multi-System Operations**
   - Simultaneous colonization of multiple systems
   - Inter-system resource optimization
   - Advanced AI decision making

## Developer Quickstart

### Prerequisites
- Ruby on Rails 7.0 environment
- Docker container with Galaxy Game codebase
- Access to star system data and mission profiles

### Key Files to Understand
- `app/services/ai_manager/wormhole_scouting_service.rb` - Mission orchestration
- `app/services/ai_manager/settlement_plan_generator.rb` - Pattern matching
- `app/services/ai_manager/probe_deployment_service.rb` - Intelligence gathering
- `app/services/ai_manager/scout_logic.rb` - Resource discovery (being refactored)

### Mission Profile Locations
- `app/data/missions/mars_settlement/` - Mars colonization pattern
- `app/data/missions/venus_settlement/` - Venus cloud city pattern
- `app/data/missions/titan-resource-hub/` - Hydrocarbon extraction pattern
- `app/data/missions/wormhole_expansion/` - Wormhole transit operations

### Testing Commands
```bash
# Test probe deployment
docker exec -it web bash -c "cd /home/galaxy_game && rails runner 'AIManager::ProbeDeploymentService.new.deploy_probes_to_system(\"alpha_centauri\")'"

# Test settlement planning
docker exec -it web bash -c "cd /home/galaxy_game && rails runner 'AIManager::SettlementPlanGenerator.new(system_analysis, target_system).generate_settlement_plan'"

# Test wormhole scouting
docker exec -it web bash -c "cd /home/galaxy_game && rails runner 'AIManager::WormholeScoutingService.new.execute_scouting_mission(\"proxima_centauri\")'"
```

## Risk Assessment

### Technical Risks
- **Pattern Matching Accuracy**: Ensuring AI correctly identifies settlement opportunities
- **System Compatibility**: Validating patterns work across diverse stellar environments
- **Integration Complexity**: Coordinating multiple AI services in real-time

### Mitigation Strategies
- **Comprehensive Testing**: Extensive testing with procedural star systems
- **Fallback Logic**: Default patterns for unrecognized system configurations
- **Modular Architecture**: Independent service testing and gradual integration

## Success Metrics

- **Pattern Detection Rate**: >95% accuracy in identifying viable colonization targets
- **Mission Success Rate**: >85% successful wormhole scouting missions
- **ROI Achievement**: >80% of colonization projects meeting projected returns
- **System Coverage**: Support for all major stellar classification types

---

*This executive summary provides a high-level overview of the wormhole expansion system. For detailed technical documentation, see the individual service documentation in `docs/ai_manager/` and `docs/crafts/`.*