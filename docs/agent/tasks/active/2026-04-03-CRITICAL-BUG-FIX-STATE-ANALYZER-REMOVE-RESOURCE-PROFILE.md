# TASK: Remove Hardcoded resource_profile from state_analyzer.rb — Delegate to Live Models
**Status**: ACTIVE
**Priority**: CRITICAL
**Type**: bug-fix
**Created**: 2026-04-03
**Last Updated**: 2026-04-03

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Targeted deletion + delegation — fully specified, no inference needed.
Exact grep commands provided. Exact replacement patterns provided.
**Supervision Level**: 🔴 Watched carefully

---

## Context
`state_analyzer.rb` is the first CRITICAL target in the AI Manager 89→8 surgical refactor.
It contains a hardcoded `resource_profile` hash that invents a parallel data model
instead of reading from the live Rails settlement models.

The AI Manager's only job is to read the `Market::Order` buy order queue and decide
what to deploy or route to fill unfilled orders. It does not simulate resource yields.
It does not maintain its own resource data. All resource state lives in the settlement
models and operational data JSON.

**Mandatory reading before touching anything:**
- `docs/agent/ai_manager/AI_MANAGER_COMMAND.md` — mandatory patterns, violations = rejection
- `docs/agent/ai_manager/AI_MANAGER_ROLE.md` — player-first + EAP + crisis role
- `docs/agent/ai_manager/AI_MANAGER_DAMAGE_INVENTORY.md` — full damage classification
- `docs/agent/README.md` — project rules

**Source of truth for AI Manager decisions:**
```ruby
Market::Order.where(order_type: :buy, status: :open)  # What is needed
settlement.inventory                                    # What exists locally
settlement.celestial_body.geosphere.crust_composition  # What can be extracted
settlement.celestial_body.atmosphere.gases             # Live atmospheric state
Lookup::UnitLookupService.new.find_unit(unit_type)    # What a unit produces
```

---

## Problem Statement

`state_analyzer.rb` builds a `resource_profile` hash that hardcodes resource
availability, atmospheric composition, and extraction complexity. This data
is invented — it does not read from the live settlement, geosphere, or atmosphere
models. As a result the AI Manager makes deployment decisions based on fiction,
not the actual game state.

**Damage markers to find:**
```bash
grep -n "resource_profile\|atmosphere_composition\|extraction_complexity\|water_ice\|energy_potential" \
  app/services/ai_manager/state_analyzer.rb
```

**Current (wrong) pattern:**
```ruby
resource_profile = {
  water_ice: { available: true, quantity: 500 },           # invented
  atmosphere: { composition: { 'CO2' => 0.95 } },          # hardcoded, not live
  energy_potential: { solar: 0.8, geothermal: 0.1 }        # invented
}
```

**Correct pattern — delegate to live models:**
```ruby
def analyze_state(settlement)
  {
    unfilled_buy_orders: Market::Order.where(
                           settlement: settlement,
                           order_type: :buy,
                           status: :open
                         ).order(created_at: :asc),
    inventory_snapshot:  settlement.inventory,
    power_available:     settlement.base_units
                                   .select(&:operational?)
                                   .sum { |u| unit_power_output(u) }
  }
end
```

**Current behavior**: state_analyzer builds fictional resource_profile hash
**Expected behavior**: state_analyzer reads live settlement state and buy order queue

---

## Files Involved

### Primary Files — you will edit
| File | Purpose | Key Section |
|---|---|---|
| `app/services/ai_manager/state_analyzer.rb` | Remove resource_profile, delegate to live models | All methods referencing resource_profile |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/market/order.rb` | Buy order model — canonical signal for AI Manager |
| `app/models/settlement/base_settlement.rb` | Settlement associations |
| `app/services/lookup/unit_lookup_service.rb` | How to read unit operational data |
| `app/services/ai_manager/task_execution_engine.rb` | Proven working pattern — reference only |
| `docs/agent/ai_manager/AI_MANAGER_COMMAND.md` | Mandatory patterns |

---

## Implementation Steps

> Follow these steps exactly in order.
> Do not apply any fix before producing the Synthesis Report and receiving approval.

### Step 1 — Blast radius audit
```bash
# How many AI Manager files reference resource_profile?
grep -rl "resource_profile" app/services/ai_manager/ --include="*.rb"

# All damage markers in state_analyzer specifically
grep -n "resource_profile\|atmosphere_composition\|extraction_complexity\|water_ice\|energy_potential\|ISRU_UNITS" \
  app/services/ai_manager/state_analyzer.rb

# Who calls state_analyzer from outside ai_manager/?
grep -rn "StateAnalyzer\|state_analyzer" app/ spec/ --include="*.rb" | grep -v "ai_manager/"
```

Report every result. Do not proceed until you have read all output.

### Step 2 — Read the live model interfaces
```bash
# How buy orders are structured
grep -n "order_type\|status\|settlement\|enum" app/models/market/order.rb | head -30

# Settlement inventory interface
grep -n "def inventory\|has_one.*inventory\|belongs_to.*inventory" \
  app/models/settlement/base_settlement.rb | head -20

# Confirm UnitLookupService interface
grep -n "def find_unit\|def self" app/services/lookup/unit_lookup_service.rb | head -10
```

Report what you see. This confirms the delegation targets exist before you write code.

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Remove resource_profile (after approval)
Delete all methods in `state_analyzer.rb` that build or consume `resource_profile`.
Replace the state analysis method with delegation to live models per the pattern
in the Problem Statement above.

Rules for this step:
- Remove the invented hash entirely — do not wrap it or guard it
- Do not add new hardcoded values to replace the old ones
- If a method only existed to serve resource_profile, delete the whole method
- If a method does other useful work AND uses resource_profile, keep the useful
  work and remove only the resource_profile dependency

### Step 5 — Verify callers still work
If any callers outside `ai_manager/` call `StateAnalyzer`, check that they
compile with the new interface. Do not change callers in this task — flag
any that need updating in your completion report.

### Step 6 — Isolation run (state_analyzer spec only)
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/state_analyzer_spec.rb \
  --format documentation 2>&1 | tail -40"
```

If there is no spec file for state_analyzer, note this in your completion report
as a follow-up task. Do not create the spec file in this task.

### Step 7 — AI Manager regression check
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/ 2>&1 | tail -20"
```

Report summary line only.

---

## Synthesis Report Format
Produce this before applying ANY fix. STOP and wait for approval.

```
BLAST RADIUS
Files referencing resource_profile: [list]
External callers of StateAnalyzer: [list or "none"]

DAMAGE IN state_analyzer.rb
Methods to delete entirely: [list]
Methods to partially fix: [list with what changes]
Lines affected: [line ranges]

LIVE MODEL DELEGATION
Market::Order buy query confirmed: [yes/no]
settlement.inventory confirmed: [yes/no]
UnitLookupService confirmed: [yes/no]

PROPOSED REPLACEMENT
[one paragraph describing the new state analysis method]

RISK
[anything that could break callers]

READY TO APPLY? — waiting for approval
```

---

## What NOT to Do
- Do not add any new hardcoded resource values
- Do not add any new constants (no RESOURCE_TYPES, no DEFAULT_COMPOSITION)
- Do not create a spec file in this task — flag the gap if one is missing
- Do not touch `isru_evaluator.rb` — that is a separate task
- Do not touch any of the 8 core files listed in AI_MANAGER_ROLE.md
- Do not run the full suite — ai_manager/ regression check is sufficient

---

## Acceptance Criteria
- [ ] `resource_profile` hash removed from `state_analyzer.rb`
- [ ] `atmosphere_composition` hardcoded key removed
- [ ] `extraction_complexity` hardcoded key removed
- [ ] State analysis delegates to `Market::Order` buy queue
- [ ] State analysis delegates to `settlement.inventory`
- [ ] No new hardcoded values introduced
- [ ] Isolation run: 0 failures (or spec noted as missing in completion report)
- [ ] No regressions in `spec/services/ai_manager/`

---

## Stop Conditions — escalate immediately if:
- Blast radius shows 5+ external callers depending on resource_profile structure
- Removing resource_profile would break a currently passing spec outside ai_manager/
- `Market::Order` model does not exist or has different interface than expected
- `settlement.inventory` returns nil in test context — factory issue
- Any architectural decision is required beyond "remove invented hash, delegate to real model"

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add app/services/ai_manager/state_analyzer.rb
git commit -m "fix: state_analyzer — remove hardcoded resource_profile, delegate to Market::Order + settlement.inventory"
git push
```

---

## Dependencies
**Blocked by**: none — first surgical target
**Blocks**: `2026-04-03-HIGH-BUG-FIX-ISRU-EVALUATOR-DELEGATE-TO-UNITLOOKUPSERVICE.md`
**Related tasks**:
- `2026-04-03-HIGH-BUG-FIX-DELETE-REWRITE-ISRU-OPTIMIZER.md`
- `AI_MANAGER_BLOAT_AUDIT.md` — full 89→8 roadmap

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
