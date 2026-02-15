# AI Manager Service Integration

## Problem
The AI Manager system has 30+ service files implementing various aspects of autonomous settlement expansion, but there's a critical disconnect between the documented phases and actual code organization. The Manager.rb orchestrator doesn't properly connect to TaskExecutionEngine and other core services, preventing true autonomous operation.

## Current State
- **Service Disconnect**: Manager.rb doesn't integrate with TaskExecutionEngine, ResourceAcquisitionService, or ScoutLogic
- **Missing StrategySelector**: No service implements the documented StrategySelector phase for autonomous decision making
- **Fragmented Implementation**: Services exist but aren't coordinated through a central orchestrator
- **Phase Mismatch**: Documentation describes 6 phases but code uses different service names and organization

## Required Changes

### Task 1.1: Connect Manager.rb to Core Services
- Integrate Manager.rb with TaskExecutionEngine for mission execution
- Connect ResourceAcquisitionService for economic decision making
- Link ScoutLogic for system evaluation and opportunity identification
- Establish service communication protocols and data flow

### Task 1.2: Implement StrategySelector Service
- Create StrategySelector service for autonomous decision prioritization
- Implement mission selection algorithms based on system state and goals
- Add strategic planning for multi-phase operations (settlement → industrialization → expansion)
- Integrate with economic parameters and resource availability

### Task 1.3: Create Service Orchestration Layer
- Build orchestration layer to coordinate service interactions
- Implement service dependency management and execution ordering
- Add error handling and recovery for service failures
- Create service health monitoring and performance tracking

### Task 1.4: Update Phase Documentation Alignment
- Align documentation with actual service names and organization
- Update wh-expansion.md to reflect TaskExecutionEngine instead of "MissionExecutor"
- Document StrategySelector implementation and integration points
- Create service interaction diagrams and data flow documentation

## Success Criteria
- Manager.rb successfully coordinates all AI Manager services
- StrategySelector enables autonomous mission prioritization
- Services communicate effectively through orchestration layer
- Documentation matches actual code implementation

## Files to Create/Modify
- `galaxy_game/app/services/ai_manager/strategy_selector.rb` (new)
- `galaxy_game/app/services/ai_manager/manager.rb` (modify - add service integration)
- `galaxy_game/app/services/ai_manager/service_orchestrator.rb` (new)
- `galaxy_game/spec/services/ai_manager/strategy_selector_spec.rb` (new)
- `galaxy_game/spec/services/ai_manager/service_orchestrator_spec.rb` (new)

## Testing Requirements
- Integration tests for Manager.rb with all core services
- StrategySelector decision-making validation
- Service orchestration error handling tests
- End-to-end autonomous operation simulation tests</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/ai_manager_service_integration.md