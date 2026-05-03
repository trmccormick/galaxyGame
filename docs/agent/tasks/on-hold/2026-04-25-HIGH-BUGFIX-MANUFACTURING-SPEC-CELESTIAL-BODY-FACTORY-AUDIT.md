# TASK: Factory Graph Audit — Celestial Body Identifier Hardcoding
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-25
**Last Updated**: 2026-04-25

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires reasoning across a 20+ file factory graph, judgment
about which fixes are safe vs. risky, and architectural awareness of the
DatabaseCleaner preserved tables interaction. Too much inference required for
a 0x agent.
**Supervision Level**: 🟢 Autonomous OK for audit and recommendations. 
🔴 Watched carefully for any factory edits.

---

## Context

The `Manufacturing::Service` specs (and potentially others) fail during setup
because `create(:base_settlement)` triggers an identifier uniqueness collision
somewhere in its association chain. A full diagnostic session on 2026-04-25
traced the chain through:

```
create(:base_settlement)
  → association :location, factory: :celestial_location
    → association :celestial_body
      → collision on identifier field
```

The base `:celestial_body` factory uses `sequence(:identifier) { |n| "CBODY-#{n}" }`
which is safe. However the `celestial_bodies` table is in the DatabaseCleaner
`except` list — it is never cleaned between examples or suite runs. This means
any celestial body created outside of a transaction (or whose transaction was
not rolled back) persists and can cause collisions on subsequent runs.

Additionally, 20+ factory files reference `identifier` — some using sequences,
some using hardcoded values. The `:luna` trait hardcodes `identifier { "LUNA-01" }`
and is referenced by at least 4 spec files. This is the known fragile case but
may not be the only one.

**Read before starting:**
- `docs/agent/README.md` — architectural rules
- `spec/support/database_cleaner.rb` — current DatabaseCleaner configuration
- Review the `except` list carefully before recommending any changes to it

---

## Problem Statement

**Error output (exact):**
```
Failure/Error: let(:settlement) { create(:base_settlement, owner: player) }
ActiveRecord::RecordInvalid:
  Validation failed: Identifier has already been taken
```

**Current behavior**: `create(:base_settlement)` fails with identifier
uniqueness collision. The collision source was not fully isolated during the
2026-04-25 session. It is somewhere in the celestial body factory chain,
interacting with the DatabaseCleaner preserved `celestial_bodies` table.

**Expected behavior**: `create(:base_settlement)` succeeds in any spec,
regardless of what other specs have run before it, without depending on
database state from seed data or other examples.

**Root cause hypothesis**: One or more factories in the celestial body chain
use hardcoded identifier values. Because `celestial_bodies` is excluded from
DatabaseCleaner cleanup, these records persist and collide on the second
factory call within the same suite run or across runs.

---

## Files Involved

### Audit Targets — read all, edit only what is necessary
| File | Known Issue |
|---|---|
| `spec/factories/celestial_bodies/celestial_bodies.rb` | `:luna` trait hardcodes `identifier { "LUNA-01" }` at line 98 |
| `spec/factories/celestial_bodies/planets/rocky_planets.rb` | Unknown — has identifier references |
| `spec/factories/celestial_bodies/planets/gaseous/ice_giants.rb` | Unknown |
| `spec/factories/celestial_bodies/planets/gaseous/hot_jupiters.rb` | Unknown |
| `spec/factories/celestial_bodies/planets/ocean/ocean_planets.rb` | Unknown |
| `spec/factories/celestial_bodies/planets/ocean/hycean_planets.rb` | Unknown |
| `spec/factories/celestial_bodies/satellites/moons.rb` | Unknown |
| `spec/factories/celestial_bodies/satellites/ice_moons.rb` | Unknown |
| `spec/factories/celestial_bodies/satellites/large_moons.rb` | Unknown |
| `spec/factories/celestial_bodies/satellites/satellites.rb` | Unknown |
| `spec/factories/celestial_bodies/satellites/small_moons.rb` | Unknown |
| `spec/factories/celestial_bodies/brown_dwarfs.rb` | Unknown |
| `spec/factories/celestial_bodies/minor_bodies/asteroids.rb` | Unknown |
| `spec/factories/celestial_bodies/stars.rb` | Unknown |
| `spec/factories/solar_systems.rb` | Uses sequence — likely safe |
| `spec/factories/galaxies.rb` | Unknown |
| `spec/factories/terrestrial_planets.rb` | Unknown |
| `spec/factories/gas_giants.rb` | Unknown |
| `spec/factories/dwarf_planets.rb` | Unknown |
| `spec/factories/protoplanets.rb` | Unknown |
| `spec/factories/organizations.rb` | Unknown |
| `spec/factories/logistics_providers.rb` | Unknown |
| `spec/factories/colonies.rb` | Unknown |
| `spec/factories/missions.rb` | Unknown |
| `spec/factories/units/units.rb` | Unknown |
| `spec/factories/units/computer.rb` | Unknown |
| `spec/factories/modules/modules.rb` | Unknown |
| `spec/support/database_cleaner.rb` | `celestial_bodies` and `locations` in except list |

### Files That Reference LUNA-01 — do not break these
| File | Reference |
|---|---|
| `spec/models/item_spec.rb:279,300` | Asserts `luna.identifier == 'LUNA-01'` |
| `spec/factories/items.rb:22` | `source_body: "LUNA-01"` |
| `spec/controllers/game_controller_spec.rb:54` | Creates luna with explicit `identifier: 'LUNA-01'` |
| `spec/controllers/celestial_bodies_spec.rb:20` | Creates with `identifier: "LUNA-01"` |

### Migration
- [ ] No migration needed — factory and spec changes only

---

## Implementation Steps

> This is an audit-first task. Produce a full report before touching anything.
> Claude 1x: use judgment throughout. Flag anything uncertain before editing.

### Step 1 — Audit all factory files for hardcoded identifiers

Run on host:
```bash
grep -rn "identifier {" /Users/tam0013/Documents/git/galaxyGame/galaxy_game/spec/factories/
```

For each result, classify it as:
- **SAFE**: uses `sequence(:identifier)` — no action needed
- **HARDCODED**: uses a string literal — collision risk, needs evaluation
- **CONDITIONAL**: uses logic or trait — needs manual review

Produce a table in your report.

### Step 2 — Trace the base_settlement association chain

Map exactly which factory the collision comes from when
`create(:base_settlement)` is called with no overrides:

```
:base_settlement
  → association :owner, factory: :development_corporation
      → does this create a celestial body? trace it.
  → association :location, factory: :celestial_location
      → association :celestial_body (no trait specified)
          → what is the default? does it hit any hardcoded identifier?
```

Check whether `:celestial_body` default (no trait) uses the sequence or
defaults to something with a hardcoded identifier.

### Step 3 — Check DatabaseCleaner except list impact

The `except` list currently preserves:
- `celestial_bodies`
- `locations`

Answer these questions:
1. Is there a seed file that creates a `LUNA-01` record before the suite runs?
2. If yes — which specs are failing because the factory tries to create Luna
   again on top of the seeded record?
3. Would removing `celestial_bodies` from the except list break any spec that
   depends on seeded celestial body data?

```bash
find /Users/tam0013/Documents/git/galaxyGame/galaxy_game/db -name "seeds.rb" -o -name "*.seeds.rb" | xargs grep -l "LUNA\|celestial" 2>/dev/null
```

### Step 4 — Produce Audit Report and STOP

```
FACTORY AUDIT REPORT — 2026-04-25

HARDCODED IDENTIFIERS FOUND:
| File | Line | Value | Risk |
|---|---|---|---|
| [file] | [N] | "[value]" | HIGH/MEDIUM/LOW |

COLLISION SOURCE — base_settlement chain:
[trace the exact factory chain that causes the collision]

DATABASE CLEANER IMPACT:
Seed data creates LUNA-01: YES/NO
If YES — which specs depend on seeded Luna record?
Removing celestial_bodies from except list: SAFE/RISKY — reason

RECOMMENDED FIXES (in priority order):
1. [specific change — file, line, before, after]
2. [specific change]
...

LUNA-01 PROTECTION STRATEGY:
The 4 files referencing LUNA-01 must not break. Recommended approach:
[use find_or_create_by | keep trait but add guard | explicit override in specs]

ESTIMATED SCOPE:
Files to edit: N
Risk level: LOW/MEDIUM/HIGH
Estimated time: X minutes

READY TO PROCEED? — waiting for approval
```

Do not edit any file until the report is approved.

### Step 5 — Apply approved fixes

Apply only the fixes approved in the report. Work file by file.
After each file: run a targeted spec that uses that factory to confirm
no regression.

### Step 6 — Verify base_settlement collision is resolved

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/service_spec.rb 2>&1 | grep "example"'
```

Expected: pending count drops, 0 setup failures.

Then remove the `xit` markers from `service_spec.rb` lines 57, 120, 151, 226, 293
and re-run to confirm the underlying specs now pass or reveal their real failures.

### Step 7 — Run broader suite check

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ spec/services/ spec/controllers/ 2>&1 > log/rspec_factory_audit_$(date +%s).log'
```

Report summary line only. Flag any new failures.

---

## Acceptance Criteria
- [ ] All factory files audited — hardcoded identifiers documented
- [ ] Collision source in `base_settlement` chain identified and fixed
- [ ] `create(:base_settlement)` succeeds in isolation and in suite
- [ ] LUNA-01 references in 4 spec files continue to pass
- [ ] `manufacturing/service_spec.rb` xit markers removed — specs pass or reveal real failures
- [ ] No regressions introduced

---

## Stop Conditions — escalate to human immediately if:
- Removing a hardcoded identifier breaks a spec that asserts on that exact value
- DatabaseCleaner except list change causes seed-dependent specs to fail
- The collision source is in application code (model callback), not factory
- More than 5 files need editing — scope has grown beyond estimate

---

## Commit Instructions

Run git commands on **host**, not inside container:
```bash
git add [specific factory files only]
git commit -m "fix: factory graph audit — replace hardcoded celestial body identifiers with sequences"
git push
```

Separate commit for DatabaseCleaner changes if any:
```bash
git commit -m "fix: database_cleaner — update except list after factory identifier audit"
```

---

## Documentation
- [ ] Flag doc gap: factory conventions doc does not exist — all factories should
  use sequences for identifier fields. Do not create the doc, add to backlog.

---

## Dependencies
**Blocked by**: none
**Blocks**: `manufacturing/service_spec.rb` — 5 examples currently marked xit
**Related tasks**: `2026-04-23-HIGH-BUGFIX-MANUFACTURING-SERVICE-SPECS-LEGACY-JOB-EXPECTATIONS.md` (completed/superseded)
**Coordination note**: `spec/factories/construction_job.rb` will be deleted by `2026-05-01-HIGH-REFACTOR-JOB-MODEL-UPDATE-FACTORIES-AND-SPECS.md`. If that task runs first, the `material_request` factory will already be updated — do not touch `spec/factories/material_request.rb` in this task if so.

---

## Background — What Was Already Tried (2026-04-25)

Do not repeat these approaches:

1. **Adding `identifier { nil }` to `:base_settlement` factory** — FAILED.
   `identifier=` is not a writable attribute on `Settlement::BaseSettlement`.
   `NoMethodError: undefined method 'identifier='`

2. **Changing `setup_initial_housing` to use `SecureRandom.hex(4)` suffix** — REVERTED.
   The housing unit identifier was not the collision source. The collision
   happens during `create(:base_settlement)` association chain before
   `setup_initial_housing` runs. Change was reverted to restore original:
   `identifier: "#{name}_housing_1"`

3. **Changing `:luna` trait to use sequence** — NOT ATTEMPTED but ruled out.
   4 spec files assert on `"LUNA-01"` explicitly. Breaking Luna would cause
   regressions in `item_spec`, `game_controller_spec`, `celestial_bodies_spec`.

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
-

### Issues discovered


### Follow-up tasks needed


### Lessons learned
