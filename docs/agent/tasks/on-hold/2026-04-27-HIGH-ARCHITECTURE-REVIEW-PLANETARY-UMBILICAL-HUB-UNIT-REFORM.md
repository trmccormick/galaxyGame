# TASK: Review and Redesign Planetary Umbilical Hub as Precursor Power Grid Unit
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: architecture  
**Created**: 2026-04-27  
**Last Updated**: 2026-05-01 (corrected file references and scope)  

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x  
**Why This Agent**: Requires architectural reasoning and cross-domain review across model, service, and data layers. Multiple file path errors in original task — agent must audit actual state before any changes.  
**Supervision Level**: 🔴 Watched carefully — produce Synthesis Report and wait for approval before editing any file.

---

## Context
The Planetary Umbilical Hub is currently implemented as a Ruby model (`Structures::PlanetaryUmbilicalHub < BaseStructure`) with live business logic in `resource/transfer.rb`. There are NO blueprint or operational data JSON files for it in the current codebase — only in `data/old-code/` which has it as a **unit** (`blueprints/units/infrastructure/planetary_umbilical_hub_bp.json`).

The architectural question is: should the hub be a **unit** (deployable, owned by an entity, has operational_data) or a **structure** (belongs to a settlement, built by a construction job)? The old-code treated it as a unit. The current live code treats it as a structure. This task exists to resolve that ambiguity and align code + data accordingly.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/isru/README.md` — ISRU and early infrastructure deployment
- `docs/architecture/power/README.md` — Power grid and interconnection logic
- `data/old-code/galaxyGame-01-08-2026/galaxy_game/data/json-data/blueprints/units/infrastructure/planetary_umbilical_hub_bp.json` — old unit blueprint (read for reference only)
- `data/old-code/galaxyGame-01-08-2026/galaxy_game/data/json-data/operational_data/units/infrastructure/planetary_umbilical_hub_data.json` — old unit operational data (read for reference only)

---

## Problem Statement

**Current behavior**:
- Hub is a Ruby structure model: `app/models/structures/planetary_umbilical_hub.rb`
- `app/services/resource/transfer.rb` queries the hub via `settlement.structures.where(type: 'PlanetaryUmbilicalHub')`
- No JSON blueprint or operational data files exist for the hub in the current `data/json-data/` tree
- Old-code (pre-refactor) had the hub as a unit with full JSON data files

**Expected behavior**: Hub's role (unit vs structure) is clearly decided, the live code reflects that decision, and JSON data files exist to support it.

**Architecture decision required before any code change:**  
Is the hub a deployable unit (arrives via mission manifest, has `operational_data`, can exist without a settlement) or a built structure (created via construction job, belongs to a settlement's structure list)?  
The answer affects: blueprint system, mission manifests, `resource/transfer.rb` query logic, and factory/spec setup.

---

## Files Involved

### Actual Current Files — audit these first, edit only after approval
| File | Current State | Issue |
|---|---|---|
| `app/models/structures/planetary_umbilical_hub.rb` | Structure model, live | May need to move to units/ or stay |
| `app/services/resource/transfer.rb` | 15+ umbilical references, queries hub as structure | Must be updated if hub becomes a unit |
| `app/models/concerns/has_external_connections.rb` | References umbilical_ports | Low-risk, verify only |

### Reference Files from Old-Code — read only, do not edit
| File | Why You Need It |
|---|---|
| `data/old-code/galaxyGame-01-08-2026/galaxy_game/data/json-data/blueprints/units/infrastructure/planetary_umbilical_hub_bp.json` | Old unit blueprint — use as template if unit decision is made |
| `data/old-code/galaxyGame-01-08-2026/galaxy_game/data/json-data/operational_data/units/infrastructure/planetary_umbilical_hub_data.json` | Old unit operational data |
| `data/old-code/galaxyGame-01-08-2026/galaxy_game/data/json-data/missions/npc-base-deploy/infrastructure_construction_phase_3_v1.2.json` | How old missions referenced the hub |

### New Files to Create (only after approval)
| File | Purpose |
|---|---|
| `data/json-data/blueprints/units/infrastructure/planetary_umbilical_hub_bp.json` OR `data/json-data/blueprints/structures/landing_infrastructure/planetary_umbilical_hub_bp.json` | New blueprint — path depends on decision |
| `data/json-data/operational_data/units/infrastructure/planetary_umbilical_hub_data.json` OR equivalent structure path | New operational data |

### Migration
- [ ] No migration needed — hub uses polymorphic structure table, no schema change if it stays a structure
- [ ] Migration may be needed if hub moves to a units table

---

## Implementation Steps

> ⚠️ STOP after Step 2. Produce Synthesis Report. Wait for approval before touching any file.

### Step 1 — Audit current state

Run on host:
```bash
grep -rn "PlanetaryUmbilicalHub\|umbilical_hub" galaxy_game/app/ galaxy_game/spec/
```

For each reference, note:
- Is it querying by structure type or unit type?
- What does it expect back — a structure or a unit instance?

Also check:
```bash
ls galaxy_game/data/json-data/blueprints/units/infrastructure/
ls galaxy_game/data/json-data/operational_data/units/infrastructure/
```

Confirm: no current `planetary_umbilical_hub` JSON files exist in the live data tree.

### Step 2 — Produce Synthesis Report and STOP

```
PLANETARY UMBILICAL HUB SYNTHESIS REPORT

CURRENT STATE:
- Ruby model location: [structure or unit?]
- JSON data files present: YES/NO
- Live code references: [N files, summary of how they use it]
- resource/transfer.rb queries hub as: [structure/unit — exact query]

ARCHITECTURE DECISION:
Recommended: [UNIT / STRUCTURE] — reason in 2-3 sentences
If UNIT: [what changes in resource/transfer.rb?]
If STRUCTURE: [what blueprint/data files need to be created?]

FILES TO CHANGE (after approval):
| File | Change |
|---|---|

RISK:
[any shared concerns or base classes affected]

ESTIMATED SCOPE: N files, ~X minutes

READY TO PROCEED? — waiting for approval
```

Do not edit any file until the report is approved.

### Step 3 — Apply approved changes (after approval)

- Create or update JSON data files as directed
- Update model location if moving to units/
- Update `resource/transfer.rb` query if hub type changes
- Run:
  ```bash
  grep -rn "PlanetaryUmbilicalHub\|umbilical_hub" galaxy_game/app/ galaxy_game/spec/
  ```
  Confirm all references use the correct class/query pattern.

### Step 4 — Run specs

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/ -t umbilical 2>&1 | tail -10'
```

If no tag matches, run:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/resource/ 2>&1 | tail -10'
```

Expected: 0 failures in affected specs.

---

## Acceptance Criteria
- [ ] Architecture decision made: hub is explicitly a unit OR structure
- [ ] JSON blueprint and operational data files exist for the hub
- [ ] `resource/transfer.rb` queries hub consistently with its type
- [ ] No regressions in related specs
- [ ] No dead structure model code if hub becomes a unit

---

## Stop Conditions — escalate to user immediately if:
- `resource/transfer.rb` has more than 20 references requiring change
- Hub type change requires a database migration
- The architecture decision is unclear after audit
- Any spec asserts on `PlanetaryUmbilicalHub` class name directly

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add [specific files only]
git commit -m "refactor: planetary_umbilical_hub — [unit/structure decision] with blueprint and operational data"
git push
```

---

## Documentation
- [ ] Update `docs/architecture/isru/README.md` and `docs/architecture/power/README.md` to document the decision
- [ ] Flag doc gap: no unit/structure distinction guide exists for blueprint authors

---

## Dependencies
**Blocked by**: none  
**Blocks**: none  
**Related tasks**: none  

---

## Completion Report
*To be filled by the implementing agent upon completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `[file]` — [description of change]

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]
