# TASK: ISRUEvaluator#inventory_isru_units wrong operational count
**Status**: ACTIVE  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-03-30  

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why**: Service method, filtering/enum pattern  
**Supervision**: 🔴 Watched carefully  

## Problem Statement
`#inventory_isru_units` fails to count operational ISRU units by type correctly.

**Current**: Wrong count (likely includes offline/down units)  
**Expected**: Count only operational units per ISRU type  

## Implementation Steps

### Step 1 — Diagnostics
```bash
docker exec -it web bash -c 'grep -n "inventory_isru_units\\|isru_units" app/services/ai_manager/isru_evaluator.rb'
docker exec -it web bash -c 'grep -A10 -B5 "197" spec/services/ai_manager/isru_evaluator_spec.rb'
docker exec -it web bash -c 'grep -n "operational\\|status\\|active" app/models/units/base_unit.rb'
```

### Step 2 — Synthesis Report + STOP

### Step 3 — Likely Fix Pattern
```ruby
# BEFORE (probably)
def inventory_isru_units
  units.select { |u| u.isru_type.present? }.group_by(&:isru_type)
end

# AFTER
def inventory_isru_units  
  units.select { |u| u.operational? && u.isru_type.present? }
       .group_by(&:isru_type)
       .transform_values(&:count)
end
```

## Testing
1. `rspec spec/services/ai_manager/isru_evaluator_spec.rb`
2. `rspec spec/services/ai_manager/`

## Commit
```bash
git commit -m "fix: ISRUEvaluator#inventory_isru_units — count operational only"
```