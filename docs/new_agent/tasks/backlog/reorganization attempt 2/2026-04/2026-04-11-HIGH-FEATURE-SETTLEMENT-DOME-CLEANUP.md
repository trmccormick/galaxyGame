# 2026-04-11-HIGH-FEATURE-SETTLEMENT DOME CLEANUP

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** FEATURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task: Settlement Model Cleanup & Dome Removal
## Assignee: GPT-4.1
## Priority: HIGH (critical directory)
## Branch: regional-view-phase2
## Estimated time: 25-30 minutes

---

## Original Content

# Task: Settlement Model Cleanup & Dome Removal
## Assignee: GPT-4.1
## Priority: HIGH (critical directory)
## Branch: regional-view-phase2
## Estimated time: 25-30 minutes

---

## Objective

Remove obsolete settlement STI subclasses and the dead Dome model. These
cause test failures and architectural confusion. Expected outcome: ~3-5
fewer failures in the next overnight run.

---

## Background

`BaseSettlement` uses an enum for settlement types. Several empty STI
subclass files exist that duplicate enum values or reference non-existent
tables. These should never have been created as separate model files.

`Settlement::Dome` references a table that doesn't exist and has 3 failing
specs testing a dead model.

---

## Step 1 — Verify before deleting

Run these checks FIRST before touching any files:

```bash
# Check for any live references to these models
grep -r "Settlement::Dome\|Settlement::Colony\|Settlement::Outpost\|Settlement::Habitat\|Settlement::City\|Settlement::Settlement" /home/galaxy_game/app /home/galaxy_game/spec --include="*.rb" | grep -v "_spec.rb" | grep -v ".old"
```

```bash
# Check dome table existence
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "puts ActiveRecord::Base.connection.table_exists?(:domes)"'
```

```bash
# Check current dome spec failures
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/dome_spec.rb --format documentation 2>&1 | tail -20'
```

If grep finds live references to any of these models in non-spec, non-old
files — STOP and report before proceeding.

---

## Step 2 — Files to DELETE

Only delete after Step 1 confirms no live references:

```bash
# Settlement STI subclasses (empty/obsolete)
rm /home/galaxy_game/app/models/settlement/dome.rb
rm /home/galaxy_game/app/models/settlement/colony.rb
rm /home/galaxy_game/app/models/settlement/outpost.rb
rm /home/galaxy_game/app/models/settlement/habitat.rb
rm /home/galaxy_game/app/models/settlement/settlement.rb
rm /home/galaxy_game/app/models/settlement/city.rb

# Dead controller
rm /home/galaxy_game/app/controllers/domes_controller.rb

# Dead spec
rm /home/galaxy_game/spec/models/dome_spec.rb
```

---

## Step 3 — Do NOT delete

These must remain untouched:
- `app/models/colony.rb` — root level, government layer, 6/6 green
- `app/models/settlement/base_settlement.rb` — core model
- `app/models/settlement/space_station.rb` — live STI subclass
- `app/models/settlement/orbital_depot.rb` — live STI subclass

---

## Step 4 — Clean up any remaining references

After deletion, search for any remaining references and remove them:

```bash
grep -r "Settlement::Dome\|Settlement::Colony\|Settlement::Outpost\|Settlement::Habitat\|Settlement::City\|DomesController" /home/galaxy_game/app /home/galaxy_game/spec --include="*.rb" 2>/dev/null
```

For each reference found:
- If in a spec file — remove the reference or the example
- If in a route file — remove the route
- If in a view or controller — remove the reference
- Report what was found and what action was taken

Check routes specifically:
```bash
grep -n "dome\|Dome" /home/galaxy_game/config/routes.rb
```

---

## Step 5 — Verify

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ --format progress 2>&1 | tail -20'
```

```bash
docker exec web bash -c 'ruby -c /home/galaxy_game/app/models/settlement/base_settlement.rb 2>&1'
```

The models spec run should show fewer failures than before. No new failures
should appear.

---

## Step 6 — Commit atomically

```bash
git add -A
git commit -m "refactor: remove obsolete settlement STI subclasses and dead Dome model

- Removed Settlement::Dome, Colony, Outpost, Habitat, Settlement, City
- Removed DomesController (referenced dead model)
- Removed dome_spec.rb (testing dead model)
- Settlement types managed via BaseSettlement enum
- Reduces test failures by ~3"
```

Update CURRENT_STATUS.md with:
- Files removed
- Failure count before and after
- Any references found and cleaned up

---

## Do NOT
- Do not touch `app/models/colony.rb` — different from `settlement/colony.rb`
- Do not touch `app/models/settlement/base_settlement.rb`
- Do not touch `space_station.rb` or `orbital_depot.rb`
- Do not delete anything without running Step 1 verification first
- Do not proceed if live non-spec references are found — report to user first

