# TASK: Fix PrecursorCapabilityService — surface_resources Calls `.to_f` on Nested Hash

**Status**: BACKLOG → NEXT (first unblocked Luna MVP task)
**Priority**: HIGH
**Type**: bugfix
**Created**: 2026-05-01
**Failure Count**: 4 failures (PrecursorCapabilityService x2, MissionPlannerService x2 — MissionPlannerService calls PrecursorCapabilityService internally)
**MVP Gate**: YES — blocks AI Manager from reading any world's resources

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: 1-line fix with exact before/after shown. No architectural judgment needed.
**Supervision Level**: 🟢 Low — isolated single-line change

---

## Context

`AIManager::PrecursorCapabilityService#surface_resources` calls `.to_f` on a value that is a Hash, not a Float:

```
NoMethodError: undefined method 'to_f' for an instance of Hash
# ./app/services/ai_manager/precursor_capability_service.rb:119
#   in 'block in AIManager::PrecursorCapabilityService#surface_resources'
# ./app/services/ai_manager/precursor_capability_service.rb:118
#   in 'AIManager::PrecursorCapabilityService#surface_resources'
```

**Root cause**: `stored_volatiles` (and likely `crust_composition`) on `Geosphere` is a nested hash. For example:

```ruby
stored_volatiles = { 'H2O' => { 'polar_ice' => 5.0 }, 'He3' => { 'regolith' => 95.0 } }
```

The service iterates over this and tries `percentage.to_f > 0.01` — but `percentage` is `{ 'polar_ice' => 5.0 }` (a Hash), not a Float.

The service was written expecting a flat hash like `{ 'H2O' => 5.0 }`, but the actual data format is nested.

**Affected failures:**
- `AIManager::MissionPlannerService#initialize accepts custom parameters` (#52)
- `AIManager::MissionPlannerService#simulate with different patterns returns Venus-specific changes` (#54)
- These both fail because `MissionPlannerService#initialize` calls `PrecursorCapabilityService#local_resources` which calls `surface_resources`

---

## Files Involved

| File | Change |
|---|---|
| `app/services/ai_manager/precursor_capability_service.rb` | Fix `surface_resources` method ~line 115-125 to handle nested hash format |

---

## Implementation Steps

### Step 1 — Read the current `surface_resources` method

Read `app/services/ai_manager/precursor_capability_service.rb` lines 110-130. Understand exactly how it iterates over `stored_volatiles` and `crust_composition`.

### Step 2 — Fix the iteration to extract the numeric value from nested hash

The stored_volatiles format is:
```ruby
{ 'H2O' => { 'polar_ice' => 5.0, 'subsurface' => 3.0 }, 'He3' => { 'regolith' => 95.0 } }
```

The total amount for a material is the **sum of all location amounts** in the inner hash. Replace the `.to_f` call with a sum:

```ruby
# Before (broken):
resources << material if percentage.to_f > 0.01

# After (correct):
total_amount = if percentage.is_a?(Hash)
  percentage.values.sum.to_f
else
  percentage.to_f
end
resources << material if total_amount > 0.01
```

Apply the same fix to `crust_composition` if it uses the same pattern.

### Step 3 — Also check `extract_local_resources` (line ~79)

`surface_resources` is called from `extract_local_resources`. Verify the return value shape is what callers expect.

### Step 4 — Verify

```
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/precursor_capability_service_spec.rb spec/services/ai_manager/mission_planner_service_spec.rb'
```

---

## Acceptance Criteria
- [ ] No `NoMethodError: undefined method 'to_f' for an instance of Hash` in PrecursorCapabilityService.
- [ ] `surface_resources` correctly returns a list of material names whose total stored amount > 0.01.
- [ ] `mission_planner_service_spec.rb` initialize test passes.
- [ ] No regression in other PrecursorCapabilityService tests.

---

## Commit Instructions
`git add app/services/ai_manager/precursor_capability_service.rb`
`git commit -m "fix: precursor_capability_service — handle nested stored_volatiles hash in surface_resources"`
