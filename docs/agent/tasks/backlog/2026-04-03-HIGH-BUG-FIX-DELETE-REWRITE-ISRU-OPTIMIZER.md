# TASK: Delete and Rewrite IsruOptimizer — Buy Order Driven Deployment Planning
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-03
**Last Updated**: 2026-04-03

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Architectural rewrite — must reason about buy order queue,
deployment sequencing, and correct delegation to UnitLookupService.
**Supervision Level**: 🔴 Watched carefully

---

## Context
The current `app/services/ai_manager/isru_optimizer.rb` is completely disconnected
from the Rails application. It was built by an agent that invented a fictional
`target_system` hash with `:resource_profile` and `:environmental_data` keys that
do not exist anywhere in the live models. It uses hardcoded GCC cost values, invented
phase timelines, and has zero connection to the buy order queue, settlement inventory,
geosphere, or atmosphere models.

**This is a delete and rewrite — not a refactor.** Nothing in the current file is
worth keeping except the concept of phase-based deployment planning, which must be
rebuilt from scratch against canonical data sources.

**Complete these tasks first:**
1. `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md`
2. `2026-04-03-HIGH-BUG-FIX-ISRU-EVALUATOR-DELEGATE-TO-UNITLOOKUPSERVICE.md`

**Mandatory reading before touching anything:**
- `docs/agent/ai_manager/AI_MANAGER_COMMAND.md` — mandatory patterns
- `docs/agent/ai_manager/AI_MANAGER_ROLE.md` — player-first + EAP role
- `docs/architecture/operations/isru_operations.md` — ISRU agent rules
- `docs/agent/README.md` — project rules

---

## Problem Statement

The current `IsruOptimizer` takes a `target_system` hash and `settlement_plan` hash
as inputs. Neither of these exist in the application. Example of the invented interface:

```ruby
# WRONG — these hashes do not exist in Rails models
def analyze_local_resources(target_system)
  resources = target_system[:resource_profile] || {}
  environmental = target_system[:environmental_data] || {}
  water_ice: { quantity: resources[:water_ice] || 0 }   # invented
  atmosphere: { composition: environmental[:atmosphere_composition] || {} }  # not live
end

# WRONG — hardcoded GCC costs with no basis in market data
def estimate_implementation_cost(opportunity)
  { water_extraction: 50000, oxygen_generation: 75000 }[opportunity]
end

# WRONG — invented percentage reduction per "opportunity"
def calculate_import_reduction(isru_roadmap)
  implemented_opportunities * 0.15  # made up
end
```

**What the optimizer should actually do:**

The AI Manager checks the buy order queue. If there are unfilled buy orders for
resources that ISRU can produce, and the right ISRU units are not deployed, the
optimizer determines the correct deployment sequence to fill those orders.

For Luna water specifically:
```
Unfilled buy order: water @ Luna base
  → Are TEU units deployed and operational? NO → deploy TEU first
  → Are PVE units deployed and operational? NO → deploy PVE second
  → Water is a byproduct of regolith processing — order fills as units run
  → Are units deployed but order still unfilling? → check power gate, check regolith supply
```

The optimizer does NOT calculate yields. Unit operational data JSON already defines
what each unit produces. The optimizer just sequences the deployment decisions.

**Current behavior**: Operates on fictional hash data, completely disconnected from game
**Expected behavior**: Reads buy order queue, recommends unit deployment sequence

---

## Files Involved

### Primary Files — you will delete and recreate
| File | Action |
|---|---|
| `app/services/ai_manager/isru_optimizer.rb` | Delete entirely, replace with new implementation |
| `spec/services/ai_manager/isru_optimizer_spec.rb` | Delete if exists, create new spec |

### Reference Files — read, do not edit
| File | Why You Need It |
|---|---|
| `app/models/market/order.rb` | Buy order model — primary signal |
| `app/services/ai_manager/isru_evaluator.rb` | Already restored — use its interface |
| `app/services/lookup/unit_lookup_service.rb` | Unit operational data |
| `app/models/settlement/base_settlement.rb` | Settlement associations |
| `app/models/units/base_unit.rb` | `operational?`, `unit_type` |
| `app/services/ai_manager/task_execution_engine.rb` | Proven pattern — orchestration only |
| `docs/architecture/operations/isru_operations.md` | TEU→PVE→gas chain rules |

---

## Implementation Steps

> Do not write a single line of the new file until the Synthesis Report is approved.

### Step 1 — Confirm the current file is orphaned
```bash
# Who calls IsruOptimizer from outside ai_manager/?
grep -rn "IsruOptimizer\|isru_optimizer" app/ spec/ --include="*.rb" \
  | grep -v "ai_manager/" | grep -v "_spec.rb"

# Who calls it within ai_manager/?
grep -rn "IsruOptimizer\|isru_optimizer" app/services/ai_manager/ --include="*.rb" \
  | grep -v "isru_optimizer.rb"

# Confirm spec file exists or not
ls spec/services/ai_manager/isru_optimizer_spec.rb 2>/dev/null && echo "EXISTS" || echo "NO SPEC"
```

### Step 2 — Read the buy order interface and ISRUEvaluator output
```bash
# Buy order fields
grep -n "enum\|order_type\|status\|resource_type\|quantity\|settlement" \
  app/models/market/order.rb | head -30

# ISRUEvaluator public interface (after its fix is complete)
grep -n "def assess_capabilities\|def should_use_isru\|def compare_isru" \
  app/services/ai_manager/isru_evaluator.rb

# Confirmed ISRU unit types and their capabilities
grep -n "geosphere_processing\|processing_capabilities" \
  app/services/lookup/unit_lookup_service.rb | head -10
```

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Delete the current file (after approval)
```bash
# Confirm no callers before deleting
rm app/services/ai_manager/isru_optimizer.rb
```

If a spec file exists:
```bash
rm spec/services/ai_manager/isru_optimizer_spec.rb
```

### Step 5 — Write the new IsruOptimizer

The new optimizer has one job: given unfilled buy orders at a settlement, return
an ordered deployment plan for ISRU units that would produce those resources.

**Correct interface:**
```ruby
module AIManager
  class IsruOptimizer
    def initialize(settlement)
      @settlement     = settlement
      @evaluator      = AIManager::ISRUEvaluator.new(settlement)
      @lookup_service = Lookup::UnitLookupService.new
    end

    # Primary method: returns ordered list of unit types to deploy
    # to fill unfilled buy orders for ISRU-producible resources.
    # Returns [] if ISRU is not the right answer or orders are already filling.
    def deployment_plan
      unfilled_orders = unfilled_isru_orders
      return [] if unfilled_orders.empty?

      capabilities = @evaluator.assess_capabilities
      return [] if capabilities[:status] == :blocked

      plan = []
      unfilled_orders.each do |order|
        plan.concat(units_needed_for(order, capabilities))
      end

      plan.uniq.compact
    end

    private

    def unfilled_isru_orders
      Market::Order.where(
        settlement: @settlement,
        order_type: :buy,
        status: :open
      ).select { |order| isru_can_produce?(order.resource_type) }
    end

    def isru_can_produce?(resource_type)
      # Reads from UnitLookupService to determine if any ISRU unit
      # produces this resource type — no hardcoded resource lists
      @lookup_service.units_producing(resource_type).any?
    end

    def units_needed_for(order, capabilities)
      # For each unfilled order, determine which unit types are missing
      # that would produce that resource.
      # Reads from UnitLookupService — no hardcoded unit type lists.
      needed = []
      producers = @lookup_service.units_producing(order.resource_type)
      producers.each do |unit_type|
        next if capabilities.dig(:units_available, unit_type, :count).to_i > 0
        needed << unit_type
      end
      needed
    end
  end
end
```

**Important:** If `UnitLookupService` does not have a `units_producing` method,
do not add hardcoded unit lists. Instead flag this in your synthesis report as
a prerequisite — that method needs to be added to `UnitLookupService` first.
This task should not proceed past approval if that method is missing.

### Step 6 — Write the new spec
The spec must test:
- Settlement with unfilled buy order for water → returns TEU + PVE deployment plan
- Settlement with all ISRU orders filled → returns empty plan
- Settlement with power blocked → returns empty plan
- Different resource orders produce different unit recommendations
- No hardcoded unit type strings in the spec assertions — use `UnitLookupService`
  to look up what should be recommended

### Step 7 — Isolation run
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/isru_optimizer_spec.rb \
  --format documentation 2>&1 | tail -40"
```

### Step 8 — AI Manager regression check
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/ 2>&1 | tail -20"
```

---

## Synthesis Report Format
```
ORPHAN CONFIRMED
External callers of IsruOptimizer: [list or "confirmed none"]
Internal callers within ai_manager/: [list or "confirmed none"]
Safe to delete: [yes/no]

PREREQUISITE CHECK
UnitLookupService.units_producing method exists: [yes/no]
  → If NO: stop here, flag as prerequisite, do not proceed
ISRUEvaluator.assess_capabilities new interface available: [yes/no]
Market::Order buy query confirmed: [yes/no]

NEW INTERFACE DESIGN
deployment_plan inputs: [settlement only — confirm]
deployment_plan output: [ordered array of unit_type strings]
isru_can_produce? delegates to: [UnitLookupService — confirm]
units_needed_for delegates to: [UnitLookupService — confirm]

HARDCODED VALUES
Any new hardcoded GCC costs proposed: [must be "none"]
Any new hardcoded unit type lists proposed: [must be "none"]
Any new hardcoded resource type lists proposed: [must be "none"]

READY TO APPLY? — waiting for approval
```

---

## What NOT to Do
- Do not keep any logic from the current `isru_optimizer.rb` — it is all wrong
- Do not add hardcoded GCC cost values
- Do not add hardcoded unit type lists (no ISRU_UNITS repeat)
- Do not add hardcoded resource type lists
- Do not accept `target_system` or `settlement_plan` hashes as parameters
- Do not calculate yields — that is `UnitLookupService`'s job
- Do not touch `isru_evaluator.rb` — separate completed task
- Do not touch `state_analyzer.rb` — separate completed task
- Do not touch any of the 8 core files in `AI_MANAGER_ROLE.md`
- Do not run the full suite

---

## Acceptance Criteria
- [ ] Old `isru_optimizer.rb` deleted
- [ ] New `isru_optimizer.rb` accepts only `settlement` as input
- [ ] `deployment_plan` reads from `Market::Order` buy queue
- [ ] `isru_can_produce?` delegates to `UnitLookupService` — no hardcoded resource list
- [ ] `units_needed_for` delegates to `UnitLookupService` — no hardcoded unit type list
- [ ] No hardcoded GCC costs
- [ ] No `target_system` or `settlement_plan` hash parameters
- [ ] Isolation run: 0 failures
- [ ] No regressions in `spec/services/ai_manager/`

---

## Stop Conditions — escalate immediately if:
- External callers depend on the old `IsruOptimizer` interface
- `UnitLookupService` does not have `units_producing` method — stop, flag as prerequisite
- `ISRUEvaluator` task is not yet complete — wait for it
- You find yourself adding any hardcoded unit type or resource type — stop and escalate

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add app/services/ai_manager/isru_optimizer.rb \
        spec/services/ai_manager/isru_optimizer_spec.rb
git commit -m "fix: IsruOptimizer — delete fictional hash-based implementation, rewrite as buy-order-driven deployment planner via UnitLookupService"
git push
```

---

## Dependencies
**Blocked by**:
- `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md`
- `2026-04-03-HIGH-BUG-FIX-ISRU-EVALUATOR-DELEGATE-TO-UNITLOOKUPSERVICE.md`
**Blocks**: `2026-04-03-MEDIUM-AI-MANAGER-BLOAT-DELETE-81-FILES.md` (next task)
**Related tasks**:
- Escalation service rewrite (TEU+PVE chain for Luna water)
- `2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md` (downstream)

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
