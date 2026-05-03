# TASK: LavaTube + ExcavatedCavity — Polymorphic belongs_to :settlement
**Status**: BACKLOG
**Priority**: LOW
**Type**: bug-fix
**Created**: 2026-04-12
**Last Updated**: 2026-04-12

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Two files, surgical single-line change each, fully
specified. No inference required.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`LavaTube` and `ExcavatedCavity` are geological features of celestial
bodies. They can be occupied by settlements. Both currently hardcode
the settlement association to `Settlement::BaseSettlement` only.

This breaks for converted small body settlements (Phobos, Deimos,
captured asteroids) which are `Settlement::OrbitalSettlement` — the
primary access mode is docking, not landing, so they are orbital
settlements inhabiting an excavated cavity.

Architecture decision confirmed 2026-04-12: a converted Phobos
shipyard is an `OrbitalSettlement` whose structure uses the
`ExcavatedCavity` as its physical hull. A Luna lava tube base is a
`BaseSettlement`. The feature association must support both.

---

## Problem Statement

**Current behavior**:
```ruby
# Both files have:
belongs_to :settlement, class_name: 'Settlement::BaseSettlement', optional: true
```

**Expected behavior**:
```ruby
# Both files should have:
belongs_to :settlement, polymorphic: true, optional: true
```

---

## Files Involved

### Primary Files — you will edit these
| File | Change |
|---|---|
| `app/models/celestial_bodies/features/lava_tube.rb` | Make belongs_to polymorphic |
| `app/models/celestial_bodies/features/excavated_cavity.rb` | Make belongs_to polymorphic |

### Migration
- [ ] Migration needed: add `settlement_type` string column to features
  table to support polymorphic association.

```bash
docker exec -it web bash -c 'bundle exec rails generate migration \
  AddSettlementTypeToFeatures settlement_type:string'
```

Check schema first to confirm the features table name:
```bash
grep -A 5 "create_table.*features" db/schema.rb
```

---

## Implementation Steps

### Step 1 — Read current files and schema
```bash
grep -n "belongs_to :settlement" \
  app/models/celestial_bodies/features/lava_tube.rb \
  app/models/celestial_bodies/features/excavated_cavity.rb
grep -A 10 "create_table.*features" db/schema.rb
```

### Step 2 — Check if settlement_type column exists
If the features table already has `settlement_type` string column,
no migration needed. If not, generate and run migration.

### Step 3 — Update both files
In each file replace:
```ruby
belongs_to :settlement, class_name: 'Settlement::BaseSettlement', optional: true
```
With:
```ruby
belongs_to :settlement, polymorphic: true, optional: true
```

### Step 4 — Run migration if needed
```bash
docker exec -it web bash -c 'unset DATABASE_URL && \
  bundle exec rails db:migrate'
docker exec -it web bash -c 'unset DATABASE_URL && \
  RAILS_ENV=test bundle exec rails db:migrate'
```

### Step 5 — Run specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && \
  RAILS_ENV=test bundle exec rspec \
  spec/models/celestial_bodies/ \
  2>&1 | grep "examples"'
```

---

## Acceptance Criteria
- [ ] Both files use polymorphic belongs_to
- [ ] Migration run if needed
- [ ] Celestial body specs pass
- [ ] No regressions in models suite

## Stop Conditions
- Features table has no `settlement_type` column AND migration fails
- Any existing spec hardcodes `BaseSettlement` for feature settlement
  association — flag before changing

---

## Commit Instructions
```bash
git add app/models/celestial_bodies/features/lava_tube.rb
git add app/models/celestial_bodies/features/excavated_cavity.rb
git add db/migrate/[migration_file] # if migration needed
git add db/schema.rb # if migration needed
git commit -m "fix: make geological feature settlement association polymorphic — supports OrbitalSettlement for converted bodies"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing directly
**Related**:
- `2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md` — completed
