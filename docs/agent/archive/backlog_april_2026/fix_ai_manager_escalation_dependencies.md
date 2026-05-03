# Fix AI Manager Escalation Service Dependencies

## Problem
The AI Manager escalation system has missing dependencies and implementation gaps that prevent proper emergency mission creation and atmosphere simulation.

## Current Issues

### 1. Missing EmergencyMissionService
- **Location**: `app/services/ai_manager/escalation_service.rb:162`
- **Issue**: EscalationService calls `EmergencyMissionService.create_emergency_mission()` but the service doesn't exist
- **Impact**: Escalation system cannot create emergency missions when needed

### 2. Missing Temperature Clamping in Atmosphere Model
- **Location**: `app/services/terra_sim/atmosphere_simulation_service.rb:89-93`
- **Issue**: AtmosphereSimulationService calls temperature setter methods that don't exist
- **Requirements**: Tests expect clamping between 150-400K for all temperature types
- **Impact**: Atmosphere simulations fail with undefined method errors

### 3. Missing Greenhouse Effect Capping
- **Location**: `app/services/terra_sim/atmosphere_simulation_service.rb` calculate_greenhouse_effect method
- **Issue**: Tests expect greenhouse effect capped at 2x base temperature
- **Impact**: Uncontrolled greenhouse effects in terraforming simulations

## Required Changes

### Task 1.1: Create EmergencyMissionService
- Create `app/services/ai_manager/emergency_mission_service.rb`
- Implement `create_emergency_mission()` method
- Ensure compatibility with existing SpecialMissionService patterns
- Add proper error handling and logging

### Task 1.2: Add Temperature Clamping to AtmosphereConcern
- Add temperature setter methods to `app/models/concerns/atmosphere_concern.rb`
- Implement clamping logic: `clamp(150, 400)` for all temperature types
- Add validation for temperature ranges
- Update AtmosphereSimulationService to use new setters

### Task 1.3: Implement Greenhouse Effect Capping
- Modify `calculate_greenhouse_effect` method in AtmosphereSimulationService
- Ensure greenhouse temperature doesn't exceed 2x base_temp
- Add logging for when capping occurs
- Update tests to verify capping behavior

## Testing Criteria
- EscalationService can create emergency missions without errors
- Atmosphere temperatures properly clamped to 150-400K range
- Greenhouse effects respect the 2x base temperature limit
- All TerraSim services run without undefined method errors
- Existing tests pass with new implementations

## Dependencies
- Requires understanding of existing mission service patterns
- Needs familiarity with AtmosphereConcern and TerraSim architecture
- Should maintain compatibility with existing escalation logic

## Priority
High - Blocks AI Manager escalation functionality and TerraSim atmosphere simulations</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/fix_ai_manager_escalation_dependencies.md