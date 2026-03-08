# OrbitalDepot Architecture Correction Task

**Agent**: GPT-4.1
**Priority**: MEDIUM
**Status**: 📋 PENDING - Task created, ready for execution
**Estimated Effort**: 20 minutes
**Impact**: No current failures, backlog cleanup

## Description
Fix OrbitalDepot inheritance - should be sibling of SpaceStation, not subclass. OrbitalDepot should inherit from BaseSettlement directly with appropriate modules.

## Required Change
**File**: app/models/settlement/orbital_depot.rb

**FROM**:
```ruby
class OrbitalDepot < SpaceStation
```

**TO**:
```ruby
class OrbitalDepot < BaseSettlement
  include Structures::Shell
  include Docking
```

## Documentation Updates
Add operational_data notes for different depot types:
- LEO depot: fuel/cargo storage and transfer
- L1 depot: shipyard optional, primarily fuel depot

## Validation Steps
1. Verify current inheritance structure
2. Make the inheritance change
3. Run RSpec to ensure no regressions
4. Update any operational_data documentation
5. Commit with message: "Fix OrbitalDepot inheritance - sibling of SpaceStation not subclass"

## Architecture Context
SpaceStation and OrbitalDepot are distinct settlement types that both inherit from BaseSettlement. SpaceStation includes Structures::Habitat for crew quarters, while OrbitalDepot focuses on cargo/fuel operations.