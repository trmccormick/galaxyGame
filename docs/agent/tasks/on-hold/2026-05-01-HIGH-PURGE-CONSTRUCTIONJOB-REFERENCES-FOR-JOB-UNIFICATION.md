# TASK: Audit and Correct Wrong ConstructionJob Usages — Model is Permanent
**Phase**: 4 — Promote to backlog ~May 22

**Status**: ON-HOLD — Phase 3 (May week 3)
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-05-01
**Last Updated**: 2026-05-03 (unification plan CANCELLED — ConstructionJob is a permanent separate model; task scope adjusted: this is now an audit-and-correct task, not a step toward unification)

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Mechanical grep-and-replace with exact substitution rules.
**Supervision Level**: 🔴 Watched carefully — read scope section before starting

---

## CRITICAL SCOPE — READ FIRST

**`ConstructionJob` the model is NOT being deleted. It must stay.**

Per `docs/architecture/systems/job_system_mechanics_spec.md`:
- `ConstructionJob` = surface construction (skylight covers, shell printing, worldhouse sealing, crater domes). Progress-tracked, can pause mid-build, settlement-owned. Correct.
- `Job` (unified) = all small manufacturing (ISRU processing, I-beams, smelting, components). Timer-based, no pause. Correct.
- `OrbitalConstructionProject` = orbital/large construction. Already correct, don't touch.

**What this task purges**: Places in the codebase where `ConstructionJob` was INCORRECTLY used for work that should use the unified `Job` model. These are wrong-model references, not valid construction job usages.

**What stays as `ConstructionJob`** (do NOT touch these):
- `task_execution_engine.rb` lines 326, 332, 617, 622, 643, 648 — skylight/airlock construction ✅ correct
- `production_manager.rb` lines 275, 295, 314, 336 — these need individual review before touching
- `builder.rb` line 83 — needs individual review
- Any spec testing `ConstructionJob` for construction job_types ✅ keep

---

## Context

50 files reference `ConstructionJob`. The majority are correct. A subset uses it
for jobs that are actually small manufacturing (should be `Job` model) or for
legacy standalone models (`ShellPrintingJob`, `SealPrintingJob`) that `ConstructionJob`
already absorbed.

---

## Steps

1. Run grep and produce the full reference list:
   ```
   grep -rn "ConstructionJob\|construction_job" galaxy_game/app/ galaxy_game/spec/ | grep -v ".rb~"
   ```
2. For each reference, classify as:
   - ✅ CORRECT — valid construction job usage (keep)
   - ❌ WRONG — should be `Job` model (flag for replacement)
   - 🔁 LEGACY — references to `ShellPrintingJob`/`SealPrintingJob` standalone models (these are already absorbed into `ConstructionJob` per spec — remove the standalone model references)
3. Produce a **Synthesis Report**: full classified list, exact proposed replacements for WRONG ones only
4. **STOP for review** — do not apply changes until synthesis is reviewed

---

## Acceptance Criteria
- Synthesis report produced with all 50 references classified
- WRONG usages identified with exact `Job.create!` replacement (must include owner, settlement, job_type, output_type, completes_at)
- No valid construction job usages touched
- No model files deleted in this task (table/model drop is a separate task)

---

## Steps

1. Full grep for `ConstructionJob` and `construction_job` in app/ and spec/.
2. List all files/lines with references (complete list).
3. Propose exact delete/replace commands for each (targeted, no mass sed).
4. Synthesis Report and STOP for review.

---

## Acceptance Criteria
- [ ] No `ConstructionJob` or `construction_job` references remain in app/ or spec/ (except allowed historical/migration/data files).
- [ ] Synthesis report delivered for review before any destructive changes.

---

## Commit Instructions
- Commit each change with a clear message referencing this task file.

---

## Blockers
- None (task is now active)

---

## Completion Report
*To be filled after review and approval of synthesis report.*
