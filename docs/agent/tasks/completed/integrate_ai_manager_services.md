# Integrate AI Manager Services

## Problem
AI Manager services exist and work individually but don't communicate effectively through Manager.rb orchestration. The system needs proper service integration to enable coordinated autonomous operations across multiple services.

## Current State
- **Services exist and work individually** - TaskExecutionEngine, ResourceAcquisitionService, ScoutLogic functional
- **Manager.rb exists** but has limited orchestration capability
- **No service-to-service communication** - services operate in isolation
- **Missing integration layer** - no shared context or event notifications
- **Data flow issues** - services can't share state or coordinate actions

## Required Changes

### Task 2.1: Connect Manager.rb to TaskExecutionEngine
- Implement proper integration between Manager.rb and TaskExecutionEngine
- Enable Manager.rb to pass mission profiles to the engine
- Add execution status monitoring and completion callbacks
- Implement mission queue management through Manager.rb

### Task 2.2: Connect Manager.rb to ResourceAcquisitionService
- Integrate Manager.rb with ResourceAcquisitionService for economic decisions
- Enable resource availability queries and allocation requests
- Add resource flow tracking and status monitoring
- Implement economic decision coordination through Manager.rb

### Task 2.3: Connect Manager.rb to ScoutLogic
- Link Manager.rb with ScoutLogic for system evaluation and scouting
- Enable scouting request submission and report reception
- Add target prioritization coordination
- Implement scouting result integration with other services

### Task 2.4: Implement Service-to-Service Communication Framework
- Create shared context/state management system
- Implement event notification system between services
- Add data passing protocols and interfaces
- Build service coordination and synchronization mechanisms

### Task 2.5: Add Integration Testing and Validation
- Create comprehensive integration tests for service communication
- Implement end-to-end service coordination validation
- Add monitoring and debugging capabilities for service interactions
- Verify data consistency across integrated services

## Success Criteria
- [ ] Manager.rb successfully calls and coordinates TaskExecutionEngine
- [ ] Manager.rb successfully calls and coordinates ResourceAcquisitionService
- [ ] Manager.rb successfully calls and coordinates ScoutLogic
- [ ] Services can communicate and share context appropriately
- [ ] Integration tests pass for all service combinations
- [ ] No service isolation issues remain

## Files to Create/Modify
- `galaxy_game/app/services/ai_manager/service_coordinator.rb` (new)
- `galaxy_game/app/services/ai_manager/manager.rb` (modify - add service integration)
- `galaxy_game/app/services/ai_manager/shared_context.rb` (new)
- `galaxy_game/spec/services/ai_manager/integration_spec.rb` (new)
- `galaxy_game/spec/services/ai_manager/manager_integration_spec.rb` (new)

## Testing Requirements
- Manager.rb can instantiate and call all core services
- Services can communicate with each other through shared interfaces
- Data flows correctly between Manager.rb and all services
- End-to-end integration scenarios work without orphaned operations
- Service coordination maintains state consistency

## Dependencies
- **Test suite <50 failures** (grinder complete - RSpec conflicts with test database)
- **Task 1 (Discovery) complete** - need assessment results to guide integration
- **Cannot run during grinding** - requires RSpec test execution</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/integrate_ai_manager_services.md