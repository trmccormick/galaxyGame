# Fix EscalationService Water Harvesting Logic Task

**Agent**: GPT-4.1
**Priority**: HIGH
**Status**: 📋 PENDING - Task created, ready for execution
**Estimated Effort**: 10 minutes
**Impact**: 8 failures → 0 in escalation_integration_spec.rb

## Description
Fix water harvesting logic in EscalationService to check for water in geosphere materials (ice deposits) in addition to liquid hydrosphere mass. This addresses failures where water harvesting is incorrectly rejected for bodies with ice but no liquid water.

## Required Change
**File**: `app/services/ai_manager/escalation_service.rb`

**Method**: `can_harvest_locally?`

**Change the 'water' case from:**
```ruby
when 'water'
  celestial_body.hydrosphere&.total_liquid_mass&.positive?
```

**To:**
```ruby
when 'water'
  celestial_body.hydrosphere&.total_liquid_mass&.positive? ||
    celestial_body.materials.where(location: 'geosphere', name: 'water').exists? ||
    celestial_body.materials.where(location: 'hydrosphere', name: 'water').exists?
```

## Verification Command
```bash
docker exec -it web bash -c 'unset DATABASE_URL && \
  RAILS_ENV=test bundle exec rspec \
  spec/integration/ai_manager/escalation_integration_spec.rb \
  --format progress 2>&1 | tail -5'
```

## Expected Results
- ✅ 8 failures reduced to 0
- ✅ Water harvesting correctly identifies bodies with ice deposits
- ✅ No regressions in other harvesting logic

## Success Criteria
- ✅ Command executes successfully
- ✅ Test output shows 0 failures for escalation_integration_spec.rb
- ✅ Water harvesting works for bodies with geosphere ice deposits
- ✅ Liquid hydrosphere water detection still works

## Commit Message
"Fix water harvesting — check geosphere materials for ice not just liquid hydrosphere"

## Architecture Context
This fix ensures AI Manager can harvest water from ice deposits in planetary crusts/geospheres, not just liquid surface water. Critical for Mars and other ice-rich bodies.