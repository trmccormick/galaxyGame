# Clarify and Implement SystemOrchestrator Multi-Settlement Coordination

## Problem
The SystemOrchestrator (Phase 5) for wormhole expansion has unclear multi-settlement coordination logic. The documentation indicates it "may be part of operational_manager.rb" but the implementation is unclear and fragmented.

## Current Status
- **Phase 5 Status**: 💡 CONCEPT/PARTIAL
- **Location**: Possibly in `operational_manager.rb` but unclear
- **Issue**: Multi-settlement coordination logic is not clearly defined or implemented

## Unclear Requirements from Documentation

### Multi-Settlement Coordination Needs
- **Dependency Tracking**: How does the AI Manager track dependencies between settlements?
- **Resource Flow Management**: How are resources allocated across multiple settlements?
- **Performance Metrics Collection**: What metrics are collected and how are they used for optimization?
- **Orchestration Logic**: How does the system decide what to build where and when?

### Integration Points
- **With Existing Services**: How does SystemOrchestrator integrate with TaskExecutionEngine, ResourceAcquisitionService, ScoutLogic?
- **Pattern Application**: How are learned patterns applied across multiple settlements?
- **Economic Coordination**: How does it coordinate with the economic priority system?

## Required Changes

### Task 5.1: Define SystemOrchestrator Architecture
- Create clear specification for SystemOrchestrator responsibilities
- Define interface with existing AI Manager services
- Establish data structures for multi-settlement state tracking
- Document coordination algorithms and decision logic

### Task 5.2: Implement Multi-Settlement State Tracking
- Create settlement registry and status tracking
- Implement dependency graph for settlement relationships
- Add resource flow monitoring across settlements
- Establish performance metrics collection framework

### Task 5.3: Develop Coordination Algorithms
- Implement settlement prioritization logic
- Create resource allocation algorithms
- Develop dependency resolution for construction projects
- Add optimization logic based on performance metrics

### Task 5.4: Integrate with Existing Services
- Connect SystemOrchestrator with TaskExecutionEngine
- Integrate with ResourceAcquisitionService for economic coordination
- Link with ScoutLogic for system analysis
- Ensure pattern application works across settlements

## Technical Implementation

### Core Classes to Create/Modify
- `AiManager::SystemOrchestrator` - Main orchestration service
- `SettlementRegistry` - Tracks all settlements and their status
- `DependencyGraph` - Manages settlement interdependencies
- `ResourceFlowManager` - Handles resource allocation across settlements
- `PerformanceTracker` - Collects and analyzes metrics

### Key Methods to Implement
- `orchestrate_settlements()` - Main coordination method
- `resolve_dependencies()` - Handle settlement dependencies
- `allocate_resources()` - Distribute resources optimally
- `optimize_performance()` - Use metrics for continuous improvement

## Testing Criteria
- Multi-settlement scenarios execute without conflicts
- Dependencies are properly resolved before construction
- Resources flow correctly between settlements
- Performance metrics are collected and used for optimization
- Integration with existing services works seamlessly

## Dependencies
- Requires completion of Phases 1-4 (TaskExecutionEngine, ResourceAcquisitionService, ScoutLogic, StrategySelector)
- Needs clear understanding of settlement relationships and dependencies
- Should maintain compatibility with existing wormhole expansion patterns

## Priority
Medium - Enables full multi-settlement AI Manager autonomy, but current single-settlement operations work</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/clarify_system_orchestrator_coordination.md