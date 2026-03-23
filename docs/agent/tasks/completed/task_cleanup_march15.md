# Task: Active & Backlog Task Cleanup — March 15, 2026
## Assignee: GPT-4.1
## Priority: Medium (housekeeping)
## Branch: regional-view-phase2

---

## Objective
Review and clean up the active and backlog task directories. Move completed tasks
to done, archive stale tasks, and verify uncertain ones against CURRENT_STATUS.md
and recent git history before touching them.

---

## Step 1 — Read CURRENT_STATUS.md first
Before moving anything, read the full contents of CURRENT_STATUS.md to understand
what has been completed, what is in progress, and what is pending.

---

## Step 2 — Definite moves to DONE
Move these from `docs/agent/tasks/active/` to `docs/agent/tasks/done/`:

- `base_unit_operational_shell_printing_fix.md` — completed today March 15
- `resume_rspec_grinding.md` — superseded by current grind workflow
- `resume_test_suite_grinding.md` — superseded by current grind workflow
- `test_suite_restoration_continuation.md` — superseded by current workflow

---

## Step 3 — Definite archive
Move these from `docs/agent/tasks/active/` to `docs/agent/tasks/archive/`
(create the directory if it doesn't exist):

- `design_phase_4b_ui_enhancements.md.old.md` — already marked .old, stale

---

## Step 4 — Verify before moving
For each of these active tasks, check CURRENT_STATUS.md AND run a targeted
git log search to determine if the work was completed. If completed, move to
done. If still pending or in progress, leave in active. Document your finding
as a one-line comment at the top of each file:

- `implement_maturity_based_snap_triggers.md`
- `implement_terrainforge_layer.md`
- `phase4b_task_breakdown.md`
- `planetary-view-phase1.md`
- `test_ai_manager_mvp.md`

Use this git command to check for relevant commits:
```bash
git log --oneline --all | grep -i "<keyword from task name>"
```

---

## Step 5 — Backlog tasks completed today
Move these from `docs/agent/tasks/backlog/` to `docs/agent/tasks/done/`:

- `geosphere_initializer_architecture_backlog.md` — Part 1 (spec fix) completed
  today. Part 2 (architecture) remains as reference — copy the architecture
  section into a NEW backlog file called
  `geosphere_initializer_procedural_architecture.md` before moving the original
  to done.

---

## Step 6 — New backlog tasks to CREATE
Create the following new backlog task files:

### `priority_heuristic_spec_account_fix.md`
```
# Task: Fix priority_heuristic_spec — settlement.account nil failures
## Priority: High (12 failures in overnight run)
## Root cause: Same pattern as assembly_service_spec fix — settlement.account
  returns nil because no GCC-specific account exists. Fix uses
  find_or_create_for_entity_and_currency with GCC currency instead of
  settlement.account throughout the spec.
## Affected file: spec/services/ai_manager/priority_heuristic_spec.rb
## Pattern: Replace all settlement.account.update!(balance: X) with:
  gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
  account = Financial::Account.find_or_create_for_entity_and_currency(
    accountable_entity: settlement,
    currency: gcc_currency
  )
  account.update!(balance: X)
## Verify: docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test
  bundle exec rspec spec/services/ai_manager/priority_heuristic_spec.rb
  --format documentation 2>&1 | tail -20'
## Note: This is a systemic issue — has_one :account on BaseSettlement is
  misleading. Settlements are multi-currency. Consider adding a gcc_account
  convenience method. Separate task.
```

### `settlement_gcc_account_convenience_method.md`
```
# Task: Add gcc_account convenience method to BaseSettlement
## Priority: Low
## Problem: settlement.account is ambiguous and fragile — returns nil or wrong
  account when multiple currency accounts exist. Specs keep breaking because
  they use settlement.account instead of find_or_create_for_entity_and_currency.
## Fix: Add convenience method to Settlement::BaseSettlement:
  def gcc_account
    Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: self,
      currency: Financial::Currency.find_by!(symbol: 'GCC')
    )
  end
## Also consider: similar method for player model
## Note: Do not remove has_one :account — may be used elsewhere. Just add
  the convenience method alongside it.
```

---

## Step 7 — Update CURRENT_STATUS.md
After all moves and creates are done, update CURRENT_STATUS.md to reflect:
- Tasks moved to done today
- New backlog tasks added
- Current active task count

---

## Do NOT
- Do not move any task to done without verifying against CURRENT_STATUS.md
  or git history first
- Do not delete any task files — move to done or archive only
- Do not modify the content of task files when moving them
- Do not touch `PHASE_2_REGIONAL_VIEW_IMPLEMENTATION.md` — still active
- Do not touch `strategy_selector_scoring_spec_fixes.md` — Gemini Flash assigned
