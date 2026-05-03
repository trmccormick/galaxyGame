# Phase 4 Preparation: Digital Twin Database Schema Implementation

## Problem Description
Phase 4 requires database schema for Digital Twin simulation capabilities, but only planning documents exist. The schema needs to be implemented to support transient simulation cloning and result caching.

## Current Status
- **Planning Complete**: Database schema design documented in `PHASE_4_DATABASE_SCHEMA.md`
- **Stubs Exist**: Basic controller stubs in place
- **Blocker**: Test suite failures prevent Phase 4 implementation
- **Opportunity**: Database schema work can proceed independently

## Required Implementation

### Task 1: Create DigitalTwin Model
**File**: `galaxy_game/app/models/digital_twin.rb` (new)
**Schema**:
```ruby
create_table :digital_twins do |t|
  t.references :celestial_body, null: false
  t.string :simulation_type, null: false  # 'terraforming', 'industrial', etc.
  t.jsonb :cloned_data, null: false        # Atmosphere, hydrosphere, geosphere clone
  t.datetime :created_at, null: false
  t.datetime :expires_at, null: false      # Auto-cleanup after simulation
end
```

**Features**:
- Clone celestial body sphere data (atmosphere, hydrosphere, geosphere)
- Transient storage with automatic cleanup
- JSONB storage for flexible simulation parameters

### Task 2: Create SimulationRun Model
**File**: `galaxy_game/app/models/simulation_run.rb` (new)
**Schema**:
```ruby
create_table :simulation_runs do |t|
  t.references :digital_twin, null: false
  t.string :pattern_name, null: false       # 'mars-terraform', 'venus-industrial'
  t.integer :duration_years, null: false
  t.jsonb :parameters, null: false          # Budget, tech level, priority
  t.string :status, null: false, default: 'running'  # running, completed, failed
  t.datetime :started_at, null: false
  t.datetime :completed_at
  t.jsonb :results                         # Simulation outcomes
end
```

**Features**:
- Track simulation execution and parameters
- Store results for analysis and export
- Support for different simulation patterns

### Task 3: Create SimulationResult Model
**File**: `galaxy_game/app/models/simulation_result.rb` (new)
**Schema**:
```ruby
create_table :simulation_results do |t|
  t.references :simulation_run, null: false
  t.string :result_type, null: false        # 'economic', 'environmental', 'timeline'
  t.jsonb :data, null: false               # Result data (GCC flows, biosphere changes, etc.)
  t.integer :year, null: false             # Simulation year
  t.datetime :created_at, null: false
end
```

**Features**:
- Time-series data storage for simulation results
- Multiple result types (economic, environmental, timeline)
- Efficient querying for visualization

### Task 4: Create Migration File
**File**: `galaxy_game/db/migrate/[timestamp]_create_digital_twin_models.rb` (new)
**Content**: Migration to create all three tables with proper indexes and constraints

### Task 5: Update DigitalTwinService Stub
**File**: `galaxy_game/app/services/digital_twin_service.rb` (exists as stub)
**Enhancement**: Implement basic clone_celestial_body method using new models

## Testing Requirements
- Migration runs without errors
- Models can be instantiated and saved
- Basic DigitalTwinService.clone_celestial_body works
- Foreign key constraints enforced

## Validation Steps
- [ ] Migration created and runnable
- [ ] All three models defined with correct associations
- [ ] DigitalTwinService can clone basic celestial body data
- [ ] Schema matches planning document specifications
- [ ] No test dependencies (can be implemented before test suite is fixed)

## Files to Create/Modify
1. `galaxy_game/db/migrate/[timestamp]_create_digital_twin_models.rb` (new)
2. `galaxy_game/app/models/digital_twin.rb` (new)
3. `galaxy_game/app/models/simulation_run.rb` (new)
4. `galaxy_game/app/models/simulation_result.rb` (new)
5. `galaxy_game/app/services/digital_twin_service.rb` (enhance stub)

## Commit Message
"feat: implement Phase 4 Digital Twin database schema and basic service"</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/phase_4_digital_twin_schema.md