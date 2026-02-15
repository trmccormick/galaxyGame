# Implement System Orchestrator

## Problem
AI Manager can manage single settlements autonomously but cannot coordinate operations across multiple celestial bodies. The system needs a SystemOrchestrator to enable multi-settlement coordination with resource sharing, priority arbitration, and inter-body logistics.

## Current State
- **StrategySelector enables autonomous decisions** for individual settlements
- **No multi-body coordination** - settlements operate independently
- **Missing resource allocation across bodies** - cannot share resources between Mars and Luna
- **No priority arbitration** - cannot resolve competing settlement needs
- **Limited strategic planning** - cannot optimize system-wide operations

## Required Changes

### Task 4.1: Design System Orchestrator Architecture
- Create SystemOrchestrator service for multi-body coordination
- Implement system-wide resource tracking and allocation
- Design priority arbitration framework for competing needs
- Build inter-body logistics and communication systems

### Task 4.2: Implement Multi-Settlement Resource Allocation
- Create system-wide resource inventory and tracking
- Implement resource allocation algorithms based on priorities
- Add resource transfer coordination between bodies
- Build resource balancing and optimization logic

### Task 4.3: Develop Priority Arbitration System
- Create settlement priority levels (CRITICAL, HIGH, MEDIUM, LOW)
- Implement conflict resolution for competing resource demands
- Add priority escalation for emergency situations
- Build fair allocation algorithms for shared resources

### Task 4.4: Build Inter-Body Logistics Coordination
- Implement transport cost calculation and optimization
- Create resource transfer scheduling and routing
- Add delivery timing coordination and tracking
- Build logistics efficiency optimization algorithms

### Task 4.5: Add System-Wide Strategic Planning
- Implement system-level evaluation and planning
- Create coordinated expansion planning across bodies
- Add infrastructure build coordination between settlements
- Build economic development balancing across the system

### Task 4.6: Define Coordination Logic and Rules
- Establish settlement priority level definitions and triggers
- Create resource allocation rules based on priority levels
- Implement logistics optimization guidelines
- Build strategic planning frameworks and objectives

## Success Criteria
- [ ] SystemOrchestrator successfully tracks multiple settlements
- [ ] Resources allocated appropriately across Mars and Luna
- [ ] Priority arbitration resolves conflicts correctly
- [ ] Inter-body logistics coordinates resource transfers
- [ ] System-wide strategic planning enables coordinated operations
- [ ] Mars + Luna settlements work together autonomously

## Files to Create/Modify
- `galaxy_game/app/services/ai_manager/system_orchestrator.rb` (new)
- `galaxy_game/app/services/ai_manager/resource_allocator.rb` (new)
- `galaxy_game/app/services/ai_manager/priority_arbitrator.rb` (new)
- `galaxy_game/app/services/ai_manager/logistics_coordinator.rb` (new)
- `galaxy_game/app/services/ai_manager/strategic_planner.rb` (new)
- `galaxy_game/spec/services/ai_manager/system_orchestrator_spec.rb` (new)

## Testing Requirements
- SystemOrchestrator tracks and coordinates Mars + Luna settlements
- Resource conflicts resolved with proper priority arbitration
- Coordinated expansion works when both settlements are ready
- Resource sharing functions (Mars surplus to Luna deficit)
- Priority changes redirect resources appropriately (Mars crisis pauses Luna work)
- Inter-body logistics optimizes transport costs and timing

## Dependencies
- **Test suite <50 failures** (grinder complete - RSpec conflicts with test database)
- **Task 3 (StrategySelector) complete** - need autonomous decisions for coordination
- **Cannot run during grinding** - requires RSpec test execution</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/implement_system_orchestrator.md