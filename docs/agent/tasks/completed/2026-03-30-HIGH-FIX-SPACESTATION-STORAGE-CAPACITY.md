# TASK: SpaceStation#calculate_storage_capacity ignores non-storage units
**Status**: ACTIVE  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-03-30  
**Last Updated**: 2026-03-30  

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Single model method, explicit paths/commands, no architectural inference needed  
**Supervision Level**: 🔴 Watched carefully  

---

## Context
SpaceStation aggregates storage capacity across attached units. Some units lack `storage_capacity` method/attribute causing sum to fail. Spec expects correct total ignoring non-storage units.

**Relevant Architecture Docs**:
- `docs/architecture/settlement.md` — unit capacity delegation patterns
- `docs/developer/practical_testing_guide.md` — model aggregation testing

---

## Problem Statement
`#calculate_storage_capacity` crashes/returns wrong sum when non-storage units present.

**Current behavior**: `NoMethodError` or includes nil values  
**Expected behavior**: Filter non-storage units before summing valid capacities  

---

## Files Involved

### Primary Files
| File | Purpose | Key Method |
|---|---|---|
| `app/models/settlement/space_station.rb` | Storage logic | `#calculate_storage_capacity` |
| `spec/models/settlement/space_station_spec.rb` | Failing test | line 422 |

### Reference Files
| File | Why |
|---|---|
| `app/models/units/base_unit.rb` | Unit capacity methods |

---

## Implementation Steps

### Step 1 — Diagnostics (run these exactly)
```bash
docker exec -it web bash -c 'grep -n "calculate_storage_capacity\\|storage_capacity" app/models/settlement/space_station.rb'
docker exec -it web bash -c 'grep -A10 -B5 "422" spec/models/settlement/space_station_spec.rb'
```

### Step 2 — Synthesis Report and STOP

### Step 3 — Fix
```ruby
# BEFORE
def calculate_storage_capacity
  units.sum(&:storage_capacity)
end

# AFTER  
def calculate_storage_capacity
  units.select { |u| u.respond_to?(:storage_capacity) }.sum(&:storage_capacity)
end
```

---

## Testing Sequence
1. **Isolation**: `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/space_station_spec.rb'`
2. **Settlement specs**: `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/settlement/'`

---

## Acceptance Criteria
- [ ] Isolation spec: 0 failures
- [ ] No settlement spec regressions

## Commit
```bash
git add app/models/settlement/space_station.rb
git commit -m "fix: SpaceStation#calculate_storage_capacity — filter non-storage units"
git push
```