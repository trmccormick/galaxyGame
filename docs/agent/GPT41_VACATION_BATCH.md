# GPT-4.1 Vacation Week Batch
**Prepared**: 2026-05-11
**Runs**: May 20–27 (vacation week — zero premium burn)
**Agent**: GPT-4.1 (0x — free tier)
**Supervision**: None during vacation. Each task is fully self-contained.
**Rule**: One task at a time. Complete, commit, move to next. No parallel RSpec runners.

---

## Pre-vacation Checklist (complete before May 20th)

- [ ] Grok synthesis report returned and approved (Unit Model Refactor)
- [ ] This batch file committed to `docs/new_agent/tasks/active/`
- [ ] GPT-4.1 has been given Task 1 handoff command
- [ ] Baseline confirmed: 23 failures before vacation starts

---

## Task Execution Order

Work through these in order. Do not skip ahead.
After each task: run full suite, log result, commit, move to next.

---

## Task 1 — geosphere String/Float fix
**Spec**: `spec/services/game_spec.rb:66` + `spec/integration/shell_printing_game_loop_spec.rb:160`
**Failures cleared**: potentially 3 (game_spec + 2 shell_printing)
**Effort**: 30 minutes

### Handoff Command
```
Read docs/agent/README.md first, then this task.

BEFORE DOING ANYTHING ELSE — prove you read the README.
Your first response must contain ONLY this confirmation block:

  README READ CONFIRMATION
  Rule 1 (Docker): [paste verbatim]
  Rule 7 (RSpec Output): [paste verbatim]
  Rule 10 (Host vs Docker paths): [paste verbatim]

Do not proceed until confirmed.

---

HIGH: geosphere.rb — String/Float comparison crash in calculate_volatile_release

The issue:
File: app/models/celestial_bodies/spheres/geosphere.rb line ~251
Error: ArgumentError: comparison of String with 0 failed
Line: next if amount.nil? || amount <= 0
Cause: amount is arriving as a String instead of a Float.
       Volatile data in stored_volatiles has string values instead of numerics.

Stack trace origin:
  geosphere.rb:251 in calculate_volatile_release
  → volatile_phase_transition_service.rb:15
  → geosphere_simulation_service.rb:370
  → game.rb:54 advance_by_days

Your tasks:
1. Read geosphere.rb lines 240-260
2. Read the stored_volatiles data structure for the affected body
3. Run:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/game_spec.rb:66 2>&1 | tail -20'
4. Produce Synthesis Report — identify whether fix belongs in:
   a) geosphere.rb (coerce amount to Float before comparison), OR
   b) The JSON/seed data (values stored as strings instead of numbers)
   STOP and wait for approval.
5. Apply approved fix
6. Run:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/game_spec.rb spec/integration/shell_printing_game_loop_spec.rb 2>&1 | tail -20'
7. Confirm failures cleared. Run full suite tail.
8. Commit from host:
   git add [specific files only]
   git commit -m "fix: geosphere calculate_volatile_release — coerce amount to Float before comparison"
9. Report back with before/after failure count.

Priority: HIGH
Estimated time: 30 minutes
Do not apply anything before Synthesis Report is approved.
```

---

## Task 2 — WormholeConsortiumFormationService factory fix
**Spec**: `spec/services/wormhole_consortium_formation_service_spec.rb:8,19`
**Failures cleared**: 2
**Effort**: 20 minutes

### Handoff Command
```
Read docs/agent/README.md first, then this task.

README READ CONFIRMATION required (same format as above).

---

MEDIUM: wormhole_consortium_formation_service_spec — Member must be a corporation

The issue:
Error: ActiveRecord::RecordInvalid: Validation failed: Member must be a corporation
File: spec/services/wormhole_consortium_formation_service_spec.rb lines 8, 19
Cause: Factory is not creating members with corporation type.
       ConsortiumMembership validates member must be a corporation.

Your tasks:
1. Read spec/services/wormhole_consortium_formation_service_spec.rb lines 1-30
2. Read spec/factories/ — find the factory used for consortium members
3. Run:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/wormhole_consortium_formation_service_spec.rb 2>&1 | tail -20'
4. Produce Synthesis Report — identify:
   a) Which factory is used for members in the spec
   b) Whether it has a :corporation trait
   c) Whether the spec needs to use that trait
   STOP and wait for approval.
5. Apply fix (factory trait or spec update — do not change the validation)
6. Run spec in isolation — confirm 0 failures
7. Commit from host:
   git commit -m "fix: wormhole_consortium_spec — use corporation trait for member factory"
8. Report back.

Priority: MEDIUM
Estimated time: 20 minutes
```

---

## Task 3 — GameDataGenerator missing fixture file
**Spec**: `spec/services/generators/game_data_generator_spec.rb:22`
**Failures cleared**: 1
**Effort**: 20 minutes

### Handoff Command
```
Read docs/agent/README.md first, then this task.

README READ CONFIRMATION required.

---

MEDIUM: game_data_generator_spec — missing fixture file

The issue:
Error: RuntimeError: Template file not found: /home/galaxy_game/spec/fixtures/sample_template.json
Cause: Spec expects a fixture file that does not exist.
       Generator loads template from spec/fixtures/sample_template.json

Your tasks:
1. Read spec/services/generators/game_data_generator_spec.rb lines 1-35
2. Read app/services/generators/game_data_generator.rb — understand template format
3. Run:
   docker compose exec web bash -c 'ls spec/fixtures/'
4. Produce Synthesis Report:
   a) What structure does sample_template.json need to have
   b) Does spec/fixtures/ directory exist
   c) Confirm fix is: create the missing fixture file (not change the generator)
   STOP and wait for approval.
5. Create spec/fixtures/sample_template.json with minimum valid structure
6. Run spec in isolation — confirm 0 failures
7. Commit from host:
   git add spec/fixtures/sample_template.json
   git commit -m "fix: game_data_generator_spec — add missing sample_template.json fixture"
8. Report back.

Priority: MEDIUM
Estimated time: 20 minutes
```

---

## Task 4 — MaterialLookupService JSON error logging
**Spec**: `spec/services/lookup/material_lookup_service_spec.rb:251`
**Failures cleared**: 1
**Effort**: 30 minutes

### Handoff Command
```
Read docs/agent/README.md first, then this task.

README READ CONFIRMATION required.

---

MEDIUM: material_lookup_service_spec — Rails.logger.error not called on JSON parse failure

The issue:
Error: expected Rails.logger to have received :error with /Invalid JSON in file:/
       received: 0 times
File: spec/services/lookup/material_lookup_service_spec.rb:258
Cause: Service is not calling Rails.logger.error when JSON parsing fails.
       Either the rescue block is missing the log call, or the error
       is not being rescued at the right level.

Your tasks:
1. Read app/services/lookup/material_lookup_service.rb — find JSON parsing and rescue blocks
2. Read spec/services/lookup/material_lookup_service_spec.rb lines 240-265
3. Run:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/material_lookup_service_spec.rb:251 2>&1 | tail -20'
4. Produce Synthesis Report:
   a) Where does JSON parsing happen in the service
   b) Is there a rescue block — what does it do
   c) Is Rails.logger.error called anywhere in the rescue
   d) Exact line to add/fix
   STOP and wait for approval.
5. Apply fix — add Rails.logger.error("Invalid JSON in file: #{...}") in rescue block
6. Run spec in isolation — confirm 0 failures
7. Run related specs — confirm no regressions:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/ 2>&1 | tail -10'
8. Commit from host:
   git commit -m "fix: material_lookup_service — log error on JSON parse failure"
9. Report back.

Priority: MEDIUM
Estimated time: 30 minutes
```

---

## Task 5 — BaseUnit store_on_surface spy mismatch
**Spec**: `spec/models/units/base_unit_spec.rb:249`
**Failures cleared**: 1
**Effort**: 45 minutes

### Handoff Command
```
Read docs/agent/README.md first, then this task.

README READ CONFIRMATION required.

---

MEDIUM: base_unit_spec — add_pile spy receives 0 calls

The issue:
Error: expected settlement_with_storage.surface_storage to have received :add_pile
       received: 0 times
File: spec/models/units/base_unit_spec.rb:254
Cause: The spy is set on settlement_with_storage.surface_storage but
       store_on_surface may be calling add_pile on a different object
       (reloaded from DB, different association path).

Your tasks:
1. Read spec/models/units/base_unit_spec.rb lines 240-260
2. Read app/models/units/base_unit.rb — find store_on_surface method
3. Run:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/units/base_unit_spec.rb:249 2>&1 | tail -30'
4. Produce Synthesis Report:
   a) What object does the spec spy on (exact variable)
   b) What object does store_on_surface actually call add_pile on
   c) Are these the same object or different instances
   d) Fix direction: reload association in spec OR memoize in model
   STOP and wait for approval.
5. Apply approved fix
6. Run spec in isolation — confirm 0 failures
7. Run full unit specs — confirm no regressions:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/units/ 2>&1 | tail -10'
8. Commit from host:
   git commit -m "fix: base_unit_spec — align spy target with store_on_surface association path"
9. Report back.

Priority: MEDIUM
Estimated time: 45 minutes
```

---

## Task 6 — MissionPlannerService pattern-specific keys
**Spec**: `spec/services/ai_manager/mission_planner_service_spec.rb:80,90,98`
**Failures cleared**: 3
**Effort**: 1-2 hours

### Handoff Command
```
Read docs/agent/README.md first, then this task.

README READ CONFIRMATION required.

---

HIGH: mission_planner_service — missing pattern-specific planetary change keys

The issue:
Spec expects:
  Mars pattern    → planetary_changes has key :temperature
  Venus pattern   → planetary_changes has key :cloud_layer
  Titan pattern   → planetary_changes has key :methane_harvest
Got: generic planetary_changes hash with none of these keys

File: app/services/ai_manager/mission_planner_service.rb
Spec: spec/services/ai_manager/mission_planner_service_spec.rb lines 80-102

Your tasks:
1. Read the full spec file lines 70-110
2. Read mission_planner_service.rb — find where planetary_changes is built
3. Run:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb 2>&1 | tail -30'
4. Produce Synthesis Report:
   a) Where does the service determine the pattern (mars/venus/titan)
   b) Where does it build planetary_changes hash
   c) What keys does it currently return
   d) What conditional logic is needed to add pattern-specific keys
   STOP and wait for approval.
5. Apply fix — add pattern-specific keys to the planetary_changes builder
6. Run spec in isolation — confirm 0 failures
7. Commit from host:
   git commit -m "fix: mission_planner_service — add pattern-specific planetary change keys for Mars/Venus/Titan"
8. Report back.

Priority: HIGH
Estimated time: 1-2 hours
Do not infer what the keys should contain — read the spec expectations exactly.
```

---

## Task 7 — BiosphereSimulationService moisture levels
**Spec**: `spec/services/terra_sim/biosphere_simulation_service_spec.rb:158`
**Failures cleared**: 1
**Effort**: 30 minutes

### Handoff Command
```
Read docs/agent/README.md first, then this task.

README READ CONFIRMATION required.

---

MEDIUM: biosphere_simulation_service — balance_biomes not differentiating moisture

The issue:
Error: expected tropical_biome.moisture_level > arid_biome.moisture_level
       got: tropical: 1, arid: 1 (identical)
File: app/services/terra_sim/biosphere_simulation_service.rb
Spec: spec/services/terra_sim/biosphere_simulation_service_spec.rb:178

Your tasks:
1. Read spec lines 155-185
2. Read balance_biomes method in biosphere_simulation_service.rb
3. Run:
   docker compose exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terra_sim/biosphere_simulation_service_spec.rb:158 2>&1 | tail -20'
4. Produce Synthesis Report:
   a) How does balance_biomes currently set moisture_level
   b) Does it check climate_type to differentiate
   c) What change makes tropical > arid
   STOP and wait for approval.
5. Apply fix
6. Run spec in isolation — confirm 0 failures
7. Commit from host:
   git commit -m "fix: biosphere_simulation_service — balance_biomes differentiates moisture by climate type"
8. Report back.

Priority: MEDIUM
Estimated time: 30 minutes
```

---

## Task 8 — new_agent infrastructure migration
**Source**: `docs/new_agent/tasks/active/2026-05-11-CRITICAL-ARCHITECTURE-INITIALIZE-NEW-AGENT-INFRASTRUCTURE.md`
**Failures cleared**: 0 (scaffolding task)
**Effort**: 30 minutes

### Handoff Command
```
This is a file system task — no Docker, no RSpec.
All commands run on HOST (Mac terminal).

---

CRITICAL: Populate new_agent rules and migrate backlog files

Your tasks:

1. Populate docs/new_agent/rules/DECISIONS.md
   Copy the file at docs/new_agent/rules/DECISIONS.md — it has already been
   populated by the Session Strategist. Verify it exists and is not empty.
   If empty, flag immediately — do not proceed.

2. Populate docs/new_agent/rules/GUARDRAILS.md
   Read docs/agent/README.md — extract Rules 1, 7, and 10 verbatim.
   Append them to docs/new_agent/rules/GUARDRAILS.md under a new section:
   ## Legacy Rules (from docs/agent/README.md)

3. Temporal migration — backlog files
   Run on host:
   ls docs/agent/tasks/backlog/

   Create directories:
   mkdir -p docs/new_agent/tasks/backlog/2026_04
   mkdir -p docs/new_agent/tasks/backlog/2026_05

   Move files starting with 2026-04 to docs/new_agent/tasks/backlog/2026_04/
   Move files starting with 2026-05 to docs/new_agent/tasks/backlog/2026_05/
   Do NOT move active/ or completed/ files — backlog only.

4. Verify
   ls docs/new_agent/tasks/backlog/2026_04/
   ls docs/new_agent/tasks/backlog/2026_05/
   Report file counts.

5. Fill in completion report in the active task file.

6. Move task file to completed/:
   mv docs/new_agent/tasks/active/2026-05-11-CRITICAL-ARCHITECTURE-INITIALIZE-NEW-AGENT-INFRASTRUCTURE.md \
      docs/new_agent/tasks/completed/

7. Commit from host:
   git add docs/new_agent/
   git commit -m "chore: new_agent — populate rules, migrate backlog to temporal folders"

Report back with file counts and any issues found.

Priority: CRITICAL
Estimated time: 30 minutes
No synthesis report needed — this is mechanical. Flag and stop if DECISIONS.md is empty.
```

---

## End of Batch

**Target**: 23 failures → ~13 failures after Tasks 1-7
**Scaffolding**: Task 8 completes new_agent infrastructure

After vacation (May 28-31):
- Claude reviews GPT-4.1 output
- Premium Review Gate #2 assessment
- Plan June scope
