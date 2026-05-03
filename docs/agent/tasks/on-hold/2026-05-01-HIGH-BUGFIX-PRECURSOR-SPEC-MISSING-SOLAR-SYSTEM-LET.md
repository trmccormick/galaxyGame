# TASK: Fix PrecursorCapabilityService Spec — Missing `let(:solar_system)` Definition
**Phase**: 3 — Promote to backlog ~May 15

**Status**: BACKLOG
**Priority**: HIGH
**Type**: bugfix
**Created**: 2026-05-01
**Failure Count**: 18 failures

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single-line spec fix, no production code changes.
**Supervision Level**: 🟢 Unsupervised

---

## Context

All 18 failures in `spec/services/ai_manager/precursor_capability_service_spec.rb` fail with:

```
NameError: undefined local variable or method 'solar_system'
for #<RSpec::ExampleGroups::AIManagerPrecursorCapabilityService::...>
```

The spec creates a `titan` body using `solar_system:` as an association parameter, but `solar_system` is never defined as a `let`. The `let!(:mars)` and `let!(:luna)` definitions use `find_by!(identifier:)` to look up world constants, so they don't define a solar system — but `titan` tries to reference `solar_system` which doesn't exist in scope.

**From spec (line ~11):**
```ruby
let!(:mars) { CelestialBodies::CelestialBody.find_by!(identifier: 'MARS-01') }
let!(:luna) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }

let!(:titan) do
  body = create(:celestial_body,
    solar_system: solar_system,  # ← NameError: 'solar_system' is undefined
    ...
  )
end
```

---

## Files Involved

| File | Change |
|---|---|
| `spec/services/ai_manager/precursor_capability_service_spec.rb` | Add `let(:solar_system)` definition |

---

## Implementation Steps

### Step 1 — Add `let(:solar_system)` before the `titan` let

Insert before the `let!(:titan)` block:
```ruby
let(:solar_system) { mars.solar_system }
```

Mars is a seeded world constant and has an associated solar system. Reusing it for Titan avoids creating an unnecessary extra solar system.

### Step 2 — Verify

```
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/precursor_capability_service_spec.rb'
```

Expected: 0 failures.

---

## Acceptance Criteria
- [ ] All 18 examples in `precursor_capability_service_spec.rb` pass (or the NameError is eliminated — other failures may persist for unrelated reasons).
- [ ] No new failures introduced.

---

## Commit Instructions
`git add spec/services/ai_manager/precursor_capability_service_spec.rb`
`git commit -m "fix(specs): add missing let(:solar_system) to precursor_capability_service_spec"`
