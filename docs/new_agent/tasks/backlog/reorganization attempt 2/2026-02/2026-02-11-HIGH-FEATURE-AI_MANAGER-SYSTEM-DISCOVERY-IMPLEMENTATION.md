# AI System Discovery Implementation

**Agent**: 0.33x (Grok)

**Priority**: HIGH

**Type**: FEATURE

**Name**: AI_MANAGER-SYSTEM-DISCOVERY-IMPLEMENTATION

## Context
The AI Manager needs real system discovery logic to replace mock data with actual star system database queries, wormhole network analysis, and strategic evaluation for autonomous expansion.

## Problem
AI system discovery was using mock data instead of real database queries - StateAnalyzer returned fake system IDs like 'nearby_system_1' instead of querying actual star systems and evaluating them based on real characteristics.

## Solution
Implement comprehensive system discovery system with:
- Real star system database queries within wormhole range
- Multi-factor strategic evaluation (TEI, resources, connectivity)
- Wormhole topology and pathfinding logic
- Integration with StateAnalyzer for scouting opportunities
- TEI calculation based on magnetic moment, atmospheric pressure, volatiles, and solar flux

## Files to Modify
- `galaxy_game/app/services/ai_manager/system_discovery_service.rb` - Core discovery engine
- `galaxy_game/app/services/ai_manager/state_analyzer.rb` - Replace mock logic with real queries
- `galaxy_game/spec/services/ai_manager/system_discovery_service_spec.rb` - Comprehensive tests

## Implementation Steps
1. **Database Integration** - Query star_systems table for systems within wormhole range
2. **TEI Calculation** - Implement 4-factor TEI scoring (magnetic moment, pressure, volatiles, solar flux)
3. **Resource Assessment** - Analyze metal richness, volatile availability, rare earth potential
4. **Wormhole Analysis** - Query active connections, calculate distances, assess network centrality
5. **Strategic Evaluation** - Multi-factor scoring for expansion prioritization
6. **StateAnalyzer Integration** - Replace mock opportunities with real system analysis

## Acceptance Criteria
- [x] SystemDiscoveryService queries real star systems database
- [x] TEI calculation uses actual planetary characteristics (magnetic moment, atmosphere, etc.)
- [x] Wormhole connectivity properly analyzed for expansion planning
- [x] StateAnalyzer returns real system opportunities, not mock data
- [x] Strategic evaluation accurately prioritizes systems for colonization
- [x] All RSpec tests pass (3 examples, 0 failures)

## Stop Condition
AI system discovery provides real strategic opportunities based on actual database systems and wormhole networks.

## Commit Message
feat: Implement AI system discovery with real database queries and TEI calculation

- Add SystemDiscoveryService for querying star systems within wormhole range
- Implement TEI calculation using magnetic moment, atmospheric pressure, volatiles, and solar flux
- Add resource assessment and wormhole topology analysis
- Replace StateAnalyzer mock logic with real system discovery
- Integrate strategic evaluation for expansion prioritization
- Add comprehensive testing for all discovery algorithms