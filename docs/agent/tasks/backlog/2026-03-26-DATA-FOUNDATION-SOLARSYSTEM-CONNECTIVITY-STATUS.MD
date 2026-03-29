# TASK: Data Foundation — SolarSystem Connectivity Status
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-03-26
**Last Updated**: 2026-03-26

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single model, single migration, fully specified — no inference required
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agent: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context
The Mission Planner needs to know whether a solar system is connected to the wider network (Earth/Sol imports available) or orphaned (cut off from external supply). This is a system-level property — if a system is orphaned, every settlement in it loses access to Network Import (Tier 3 sourcing). This task adds the data foundation only. No service or UI logic is included here.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/systems/asteroid_conversion_physics.md` — background on orphaned system constraints
- `docs/architecture/systems/survey_and_handshake_protocol.md` — context on system connectivity

> Do not create any documentation during this task.
> Flag any gaps in your completion report.

---

## Problem Statement
`SolarSystem` has no `connectivity_status` field. The Mission Planner cannot determine whether a system is connected, distressed, or orphaned. This blocks all Tier 3 sourcing logic.

**Current behavior**: `SolarSystem` has no connectivity awareness.
**Expected behavior**: `SolarSystem` has a `connectivity_status` string column with enum values `:connected`, `:distressed`, `:orphaned`, defaulting to `:connected`.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/models/solar_system.rb` | SolarSystem model | add enum + scope |
| `db/migrate/[timestamp]_add_connectivity_status_to_solar_systems.rb` | Migration | new file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `db/schema.rb` | Verify column added correctly after migration |
| `spec/factories/solar_systems.rb` | Check factory needs updating with default status |

### Migration
- [ ] Migration needed: add `connectivity_status` string column to `solar_systems` table with default `'connected'`
```bash
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rails generate migration AddConnectivityStatusToSolarSystems connectivity_status:string'
```

Review generated migration before running. Ensure it includes `default: 'connected', null: false`. Then run:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rails db:migrate'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

---

## Implementation Steps

> Follow these steps exactly in order.

### Step 1 — Review generated migration
Open the generated migration file. Confirm it reads:
```ruby
def change
  add_column :solar_systems, :connectivity_status, :string,
    default: 'connected', null: false
end
```

Add `default` and `null: false` if the generator omitted them. Run migration as shown above.

### Step 2 — Add enum to SolarSystem model
In `app/models/solar_system.rb`, add after existing validations:
```ruby
enum connectivity_status: {
  connected: 'connected',
  distressed: 'distressed',
  orphaned: 'orphaned'
}, _prefix: :connectivity

scope :orphaned_systems, -> { where(connectivity_status: 'orphaned') }
scope :connected_systems, -> { where(connectivity_status: 'connected') }
```

Use string-based enum values to match the string column — do NOT use integer values.

### Step 3 — Update factory if needed
Check `spec/factories/solar_systems.rb`. If the factory exists, confirm it either omits `connectivity_status` (letting the DB default handle it) or explicitly sets `connectivity_status { 'connected' }`.

### Step 4 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/solar_system_spec.rb'
```

---

## Synthesis Report Format
Before applying any fix, produce a report in this format and **stop**:
```
THE TASK
Migration generated: [yes/no]
Default and null: false confirmed: [yes/no]
Factory update needed: [yes/no — reason]

PROPOSED IMPLEMENTATION
[list each change with file and line]

RISKS
[any other models or specs that reference SolarSystem that could be affected]

READY TO APPLY? — waiting for approval
```

Do not apply anything until the user explicitly approves.

---

## Testing Sequence

1. **Isolation run**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/solar_system_spec.rb'
```

2. **Related specs**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/'
```

3. **Full suite** — only after steps 1 and 2 are green:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] Migration runs cleanly on dev and test databases
- [ ] `schema.rb` shows `connectivity_status` string column with default `'connected'`
- [ ] `SolarSystem` enum responds to `.connected`, `.distressed`, `.orphaned`
- [ ] `SolarSystem` responds to `connectivity_status_before_type_cast`
- [ ] Scopes `orphaned_systems` and `connected_systems` return correct results
- [ ] `solar_system_spec.rb` passes with 0 failures
- [ ] No regressions in `spec/models/`

---

## Stop Conditions — escalate to user immediately if:
- Migration generates unexpected schema changes
- `solar_system.rb` already has a `connectivity_status` field under a different name
- Factory changes cause failures in other specs
- Any architectural decision required beyond what is specified here

---

## Commit Instructions
```bash
git add app/models/solar_system.rb
git add db/migrate/[timestamp]_add_connectivity_status_to_solar_systems.rb
git add db/schema.rb
git add spec/factories/solar_systems.rb  # only if modified
git commit -m "feature: solar_system — add connectivity_status enum (connected/distressed/orphaned)"
git push
```

---

## Documentation
- [ ] No doc changes needed for this task — doc creation is part of Task 2

---

## Dependencies
**Blocked by**: none
**Blocks**: `2026-03-26-HIGH-FEATURE-MISSION-PLANNER-ORPHANED-LOGIC.md`
**Related tasks**: none

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned