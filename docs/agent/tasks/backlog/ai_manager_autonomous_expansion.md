# AI Manager Autonomous System Expansion

## Problem
The AI Manager currently lacks the capability to autonomously expand into new star systems without player intervention. The system needs to be able to discover, evaluate, and establish presence in new systems through the wormhole network.

## Current State
- **No Autonomous Discovery**: AI cannot find or evaluate new systems independently
- **Manual Expansion**: All system expansion requires player decisions
- **Limited Intelligence**: AI lacks strategic reasoning for system selection and resource allocation
- **No Foothold Logic**: Missing automated foothold establishment in new systems

## Required Changes

### Task 1.1: Implement System Discovery and Evaluation
- Create AI system scanning and evaluation algorithms
- Implement strategic value assessment (resources, position, threats)
- Add system priority ranking for expansion decisions
- Integrate with wormhole network topology

#### Sub-Task 1.1.1: Real System Discovery Logic
**Priority:** HIGH
**Estimated Time:** 4-6 hours
**Problem:** StateAnalyzer uses mock scouting opportunities instead of real system database queries
**Solution:** 
- Query star_systems table for unexplored systems within wormhole range
- Implement distance calculations from current settlements
- Add system metadata analysis (planet count, resource indicators, habitability hints)
- Create discovery probability based on probe/scouting investment

#### Sub-Task 1.1.2: Strategic Value Assessment Algorithm  
**Priority:** HIGH
**Estimated Time:** 6-8 hours
**Problem:** No algorithm for evaluating system strategic importance
**Solution:**
- Implement multi-factor scoring: resource potential, strategic position, habitability, wormhole connectivity
- Add threat assessment (hostile environments, resource competition)
- Create comparative ranking against current system capabilities
- Integrate with economic forecasting for long-term value assessment

### Task 1.2: Develop Autonomous Foothold Establishment
- Design foothold creation logic (initial colony sites, resource claims)
- Implement automated resource allocation for new footholds
- Create foothold expansion triggers and milestones
- Add foothold defense and maintenance systems

#### Sub-Task 1.2.1: Planetary Site Selection Algorithm
**Priority:** HIGH  
**Estimated Time:** 6-8 hours
**Problem:** No automated colony site selection logic
**Solution:**
- Analyze celestial bodies for habitability (atmosphere, hydrosphere, biosphere)
- Evaluate resource availability and extraction potential
- Assess strategic positioning (defense, expansion corridors, logistics)
- Implement site scoring and ranking with risk assessment

#### Sub-Task 1.2.2: Foothold Resource Allocation Engine
**Priority:** HIGH
**Estimated Time:** 4-6 hours  
**Problem:** No automated resource allocation for new settlements
**Solution:**
- Create initial resource requirements calculation based on site characteristics
- Implement resource transport planning from parent settlements
- Add bootstrap resource packages (energy, life support, construction materials)
- Integrate with logistics coordinator for supply chain establishment

### Task 1.3: Create Expansion Mission Generation
- Build mission templates for system exploration and colonization
- Implement AI-driven mission prioritization and scheduling
- Add mission success prediction and risk assessment
- Create mission adaptation based on system characteristics

### Task 1.4: Integrate with Wormhole Network Strategy
- Develop wormhole network expansion planning
- Implement strategic chokepoint identification and control
- Add network vulnerability assessment and defense
- Create expansion corridor optimization

#### Sub-Task 1.4.1: Wormhole Topology Integration
**Priority:** HIGH
**Estimated Time:** 4-6 hours
**Problem:** Expansion decisions don't consider wormhole network connections
**Solution:**
- Query active wormhole connections and ranges
- Implement pathfinding algorithms for multi-hop expansion routes
- Add wormhole stability and capacity considerations
- Create network centrality calculations for strategic positioning

### Task 1.5: Implement Multi-Task Management Tuning
- Tune AI logic for concurrent operations: DC base construction, resource management, logistics coordination, and universe economy balancing
- Implement priority weighting for competing objectives during expansion
- Add resource allocation algorithms across multiple systems
- Create economic impact assessment for expansion decisions
- Integrate logistics optimization with wormhole retargeting costs

## Post-MVP Expansion Features

### Task 2.1: TerraGen Consortium Integration
**Priority:** LOW (Post-MVP)
**Estimated Time:** 8-12 hours
**Problem:** AI doesn't recognize or adapt to TerraGen consortium formation
**Solution:**
- Add consortium formation detection triggers (post-snap events)
- Implement shared resource pool coordination
- Create consortium mission generation (pre-hammer resource windows)
- Add cooperative terraforming planning across member corporations

### Task 2.2: Eden System Prioritization
**Priority:** LOW (Post-MVP)  
**Estimated Time:** 6-8 hours
**Problem:** No special logic for prioritizing Eden system planets
**Solution:**
- Add Eden system recognition and metadata loading
- Implement superior terraforming target detection (> Earth quality)
- Create predictable testing environment for AI training
- Add Eden-specific expansion patterns and strategies

### Task 2.3: Inter-System Resource Coordination
**Priority:** LOW (Post-MVP)
**Estimated Time:** 8-10 hours
**Problem:** No cross-system resource allocation and optimization
**Solution:**
- Implement multi-system resource flow optimization
- Add inter-settlement trade automation
- Create system-wide economic balancing algorithms
- Integrate with wormhole logistics for efficient resource routing

## Success Criteria
- AI can autonomously discover and evaluate new star systems
- Automated foothold establishment in promising systems
- Strategic expansion through wormhole network
- Balanced resource allocation across expanding empire
- AI effectively manages concurrent tasks during expansion (DC bases, resources, logistics, economy)

## Implementation Approach

### Sol-Centric Training Foundation
**Current Focus:** Sol system as training ground with known patterns and established infrastructure
- **Known Systems:** Leverage Earth's biosphere patterns and Mars resource extraction mechanics
- **Established Networks:** Build on existing wormhole connections and logistics
- **Predictable Environment:** Test autonomous expansion in well-understood solar system

### Eden System Integration (Post-MVP)
**Strategic Purpose:** First system outside Earth with superior terraforming targets
- **Training Environment:** Predictable generated system for AI testing and pattern development
- **Quality Benchmark:** Ensure new systems have better terraforming potential than Earth
- **Progressive Complexity:** Move from known Sol patterns to generated system challenges

### Technical Architecture
- **StateAnalyzer Enhancement:** Replace mock opportunities with real system database queries
- **StrategySelector Extension:** Add system value assessment algorithms
- **ExpansionService Integration:** Connect foothold establishment with settlement creation
- **Wormhole Topology:** Real-time network analysis for expansion planning

## Files to Create/Modify
- `galaxy_game/app/services/ai_manager/system_expansion_service.rb` (new)
- `galaxy_game/app/models/ai_manager/expansion_plan.rb` (new)
- `galaxy_game/app/services/ai_manager/foothold_manager.rb` (new)
- `galaxy_game/spec/services/ai_manager/system_expansion_service_spec.rb` (new)

## Testing Requirements
- Test autonomous system discovery and evaluation
- Validate foothold establishment logic
- Test expansion mission generation
- Verify wormhole network integration

## Dependencies
- Requires working AI Manager mission system
- Assumes wormhole network infrastructure exists
- Needs celestial body database with system data
- Depends on wormhole documentation update and logic adjustments</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/ai_manager_autonomous_expansion.md