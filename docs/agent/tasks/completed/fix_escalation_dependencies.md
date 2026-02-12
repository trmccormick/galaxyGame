# Fix Escalation Service Dependencies

## Task Overview
Fix missing dependencies and implementation gaps in the AI Manager escalation system.

## Specific Issues Found

### 1. Missing EmergencyMissionService
**Problem**: EscalationService calls `EmergencyMissionService.create_emergency_mission()` but this service doesn't exist.

**Location**: `app/services/ai_manager/escalation_service.rb:162`

**Solution**: Either:
- Create EmergencyMissionService with create_emergency_mission method
- Change to use existing SpecialMissionService.generate_critical_mission()
- Remove special mission escalation if not needed

### 2. Missing Temperature Clamping in Atmosphere Model
**Problem**: AtmosphereSimulationService calls `atmosphere.set_effective_temp()`, `set_greenhouse_temp()`, etc., but these methods don't exist in the Atmosphere model.

**Tests Expect**: Temperature clamping between 150-400K for all temperature types

**Location**: `app/services/terra_sim/atmosphere_simulation_service.rb:89-93`

**Solution**: Add temperature setter methods to AtmosphereConcern with clamping logic:
```ruby
def set_effective_temp(temp)
  self.effective_temp = [[temp, 150.0].max, 400.0].min
end
```

### 3. Missing Greenhouse Effect Capping
**Problem**: Tests expect greenhouse effect capped at 2x base temperature, but implementation may not enforce this.

**Location**: `app/services/terra_sim/atmosphere_simulation_service.rb` calculate_greenhouse_effect method

**Solution**: Ensure greenhouse temperature doesn't exceed 2x base_temp.

## Expected Outcome
- EscalationService can create special missions without errors
- Atmosphere temperatures are properly clamped to 150-400K range
- Greenhouse effects respect the 2x base temperature limit

## Dependencies
- Escalation system implementation
- TerraSim service tests

## Success Criteria
- No method missing errors in escalation service
- Temperature clamping works as expected in tests
- All TerraSim services run without undefined method errors