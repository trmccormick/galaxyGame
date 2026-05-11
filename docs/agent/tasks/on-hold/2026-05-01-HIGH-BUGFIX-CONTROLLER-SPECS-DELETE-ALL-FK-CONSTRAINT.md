# TASK: Fix Controller Specs — CelestialBodies::CelestialBody.delete_all FK Constraint
**Phase**: 3 — Promote to backlog ~May 15

**Status**: BACKLOG
**Priority**: HIGH
**Type**: bugfix
**Created**: 2026-05-01
**Failure Count**: 10 failures

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Spec-only fix, no production code changes.
**Supervision Level**: 🟢 Unsupervised

---

## Context

10 controller specs fail when their `before` block calls `CelestialBodies::CelestialBody.delete_all`:

```
ActiveRecord::InvalidForeignKey:
  PG::ForeignKeyViolation: ERROR: update or delete on table "celestial_bodies"
  violates foreign key constraint ...
```

`delete_all` issues a raw SQL `DELETE` that bypasses ActiveRecord callbacks and FK cascade rules. Other tables (locations, settlements, etc.) have foreign keys pointing to `celestial_bodies`, so the delete fails.

**Affected specs:**
- `spec/controllers/game_controller_spec.rb` — 7 failures (all `GET #index` examples)
- `spec/controllers/celestial_bodies_spec.rb` — 3 failures (`GET #map`, `GET #geological_features` x2)

These specs need to control which celestial bodies are visible to the controller, so they try to wipe the table first and seed their own test data.

**Root issue**: `delete_all` cannot be used on a table with outgoing FK references. The DatabaseCleaner `except` list includes `celestial_bodies` and `locations` (they're preserved between examples), which is why leftover seed data interferes with the count assertions.

---

## Files Involved

| File | Change |
|---|---|
| `spec/controllers/game_controller_spec.rb` | Replace `delete_all` strategy |
| `spec/controllers/celestial_bodies_spec.rb` | Replace `delete_all` strategy |

---

## Implementation Steps

### Step 1 — Read the full before block in each spec

Read `spec/controllers/game_controller_spec.rb` around the failing examples. Understand what the spec is trying to achieve (e.g., "ensure only 5 celestial bodies exist" or "wipe and re-seed a known state").

### Step 2 — Choose the correct replacement strategy

**Option A** — If the spec only needs to count "newly created" bodies, scope the assertion to the bodies created within the test rather than asserting a total count:

```ruby
# Instead of asserting exact count, assert on the test-created subset
expect(assigns(:celestial_bodies_count)).to be >= created_bodies.count
```

**Option B** — If the spec truly needs an isolated empty table, wrap the `before` block in a transaction using DatabaseCleaner deletion strategy for that block:

```ruby
before(:all) do
  DatabaseCleaner.strategy = :deletion
  DatabaseCleaner.clean
  # ... create test data
end
```

**Option C** — Replace `CelestialBodies::CelestialBody.delete_all` with a scoped delete that only removes test-created records:

```ruby
# In after block
@test_bodies.each(&:destroy)
```

**Recommended approach**: Option C or A. Do NOT use `delete_all` or `destroy_all` on the full table — world constants must remain.

### Step 3 — Check what counts are being asserted

For `game_controller_spec.rb`:
- Failure says `expected: 5, got: 21` for `:celestial_bodies_count` — this means 21 real bodies exist and the spec expects 5
- The spec needs to be rewritten to work with real seed data rather than a cleared table

For `celestial_bodies_spec.rb`:
- Similar mismatch — the spec expects specific bodies that don't exist after the `delete_all` fails

### Step 4 — Rewrite assertions to work with real seed data

Instead of wiping the table, the specs should:
1. Scope assertions to objects they created (not the full table count)
2. OR use `find_by` to look up the specific seeded bodies they need

### Step 5 — Verify

```
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/game_controller_spec.rb spec/controllers/celestial_bodies_spec.rb'
```

Expected: 0 failures.

---

## Progress (as of 2026-05-08)

### Current Status
- Controller spec FK constraint bugfix is **on hold**; not actively fixing at this time.
- Recent controller spec runs show **no ActiveRecord::InvalidForeignKey errors**.
- `delete_all` is still present in test logs for `game_states` and `solar_systems`, but does **not cause FK constraint errors**.
- All controller actions and DB operations complete without error; specs fail for other reasons (not FK constraints).
- No evidence of unhandled FK constraint violations in recent output.

### Findings
- The original issue (FK constraint error from `delete_all` on `celestial_bodies`) is **not currently reproducible** in recent runs.
- Test data setup/teardown uses `delete_all` for some tables, but this does not break FK constraints in the current schema/data.
- All controller specs return 200 OK or 302 Found as expected.
- No further action required unless the FK constraint error reappears or requirements change.

### Next Steps
- Leave task in BACKLOG until/unless FK constraint errors return or spec requirements change.
- If reactivated: follow Implementation Steps above, focusing on scoping assertions and avoiding table-wide `delete_all`.

---

## Acceptance Criteria
- [ ] No `ActiveRecord::InvalidForeignKey` errors in controller specs.
- [ ] `delete_all` removed from all controller spec `before` blocks.
- [ ] Spec assertions either scope to test-created data or use world constants correctly.
- [ ] 10 previously failing examples pass.

---

## Commit Instructions
`git add spec/controllers/game_controller_spec.rb spec/controllers/celestial_bodies_spec.rb`
`git commit -m "fix(specs): replace CelestialBody.delete_all with scoped cleanup in controller specs"`
