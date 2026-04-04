# TASK: Rewire IsruOptimizer — Remove Invented Hash Interface, Wire to Market::Order
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-03
**Last Updated**: 2026-04-03

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Architectural reasoning required — must understand buy order
queue, deployment sequencing, and correct delegation to UnitLookupService.
**Supervision Level**: 🔴 Watched carefully

---

## Context
`IsruOptimizer` was written by an agent that understood the concept of
phase-based ISRU deployment planning but invented a fictional data interface
to drive it. The opportunity scoring, phase sequencing, and priority logic
are conceptually correct game mechanics. The problem is the input — it
reads from invented `target_system` and `settlement_plan` hashes that
don't exist in the Rails application.

**This is a REWIRE, not a rewrite from scratch.**
- Keep the phase-based deployment planning concept
- Keep the opportunity scoring structure
- Remove the invented hash interfaces
- Wire inputs to `Market::Order` buy queue and real settlement models

**Complete these tasks first:**
1. `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md` ✅ DONE
2. `2026-04-03-HIGH-BUG-FIX-REWIRE-ISRU-EVALUATOR.md`

**Mandatory reading before touching anything:**
- `galaxyGame/docs/architecture/ai_manager/AI_MANAGER_COMMAND.md`
- `galaxyGame/docs/architecture/ai_manager/AI_MANAGER_ROLE.md`
- `galaxyGame/docs/architecture/operations/isru_operations.md`
- `galaxyGame/docs/agent/README.md`

**Also read before starting:**
- `app/services/ai_manager/isru_evaluator.rb` — just rewired, use its interface
- `app/services/ai_manager/resource_flow_simulator.rb` — RESOURCE_CHAINS
  contains the TEU→PVE dependency chain this optimizer should use for
  phase sequencing. Read this before touching anything.

---

## Problem Statement

The optimizer takes invented hashes as input and has no connection to
the real application. The fix is to replace the input interface while
preserving the planning logic.

### The Invented Interface (Wrong)
```ruby
# WRONG — these hashes do not exist in Rails models
def optimize_isru_priorities(target_system, settlement_plan)
  resources = target_system[:resource_profile] || {}
  environmental = target_system[:environmental_data] || {}
  water_ice: { quantity: resources[:water_ice] || 0 }  # invented
end

def estimate_implementation_cost(opportunity)
  { water_extraction: 50000, oxygen_generation: 75000 }[opportunity]  # hardcoded GCC
end
```

### The Correct Interface
```ruby
# CORRECT — reads from real application signals
def optimize_isru_priorities(settlement)
  unfilled_orders = Market::Order.where(
    settlement: settlement,
    order_type: :buy,
    status: :open
  )
  capabilities = AIManager::ISRUEvaluator.new(settlement).assess_capabilities
  # Phase sequencing based on what orders exist and what units are missing
end
```

### What the Optimizer Should Actually Do
Given a settlement with unfilled buy orders, return a phased deployment
plan for ISRU units that would produce those resources. Phase sequencing
should follow the dependency chain:

```
Phase 1 — Power (hard gate)
  → Solar panels or RTG must be deployed first
Phase 2 — Regolith harvesting
  → Regolith Harvester Rover
Phase 3 — Thermal extraction
  → TEU (thermal_extraction_unit_mk1) — heats regolith, releases volatiles
Phase 4 — Volatile separation
  → PVE (planetary_volatiles_extractor_mk1) — separates water, gases
Phase 5 — Gas processing (if needed)
  → Sabatier reactor for methane from CO2 + H2
  → CO2 splitter for Venus atmosphere processing
```

Water is a byproduct of Phase 4, not a primary extraction target.
The optimizer sequences the phases needed to fill the specific unfilled orders.

---

## Files Involved

### Primary Files — you will edit
| File | Change |
|---|---|
| `app/services/ai_manager/isru_optimizer.rb` | Replace invented hash inputs with Market::Order + settlement models |
| `spec/services/ai_manager/isru_optimizer_spec.rb` | Update to test real interface |

### Read Before Starting — do not edit
| File | Why |
|---|---|
| `app/services/ai_manager/resource_flow_simulator.rb` | RESOURCE_CHAINS TEU→PVE logic — phase sequencing reference |
| `app/services/ai_manager/isru_evaluator.rb` | Just rewired — use its assess_capabilities output |
| `app/models/market/order.rb` | Buy order model — primary input |
| `app/services/lookup/unit_lookup_service.rb` | Unit operational data |
| `app/models/settlement/base_settlement.rb` | Settlement associations |
| `app/services/ai_manager/task_execution_engine.rb` | Proven orchestration pattern |
| `galaxyGame/docs/architecture/operations/isru_operations.md` | TEU→PVE chain rules |

---

## Implementation Steps

> Read ALL reference files before writing anything.
> Do not apply any fix before Synthesis Report is approved.

### Step 1 — Read resource_flow_simulator RESOURCE_CHAINS
```bash
cat galaxy_game/app/services/ai_manager/resource_flow_simulator.rb
```
Document the full TEU→PVE dependency chain. This is the phase sequencing
logic the optimizer needs. It should be rewired here, not in resource_flow_simulator.

### Step 2 — Read current isru_optimizer fully
```bash
cat galaxy_game/app/services/ai_manager/isru_optimizer.rb
```
Identify every method. Classify each as:
- Logic worth keeping (rewire inputs)
- Logic to remove (hardcoded costs, invented scores)

### Step 3 — Blast radius audit
```bash
grep -rn "IsruOptimizer\|isru_optimizer" galaxy_game/app/ galaxy_game/spec/ \
  --include="*.rb" | grep -v "ai_manager/" | grep -v "_spec.rb"

grep -n "target_system\|settlement_plan\|resource_profile\|water_ice\|energy_potential" \
  galaxy_game/app/services/ai_manager/isru_optimizer.rb
```

### Step 4 — Check UnitLookupService for units_producing method
```bash
grep -n "def units_producing\|def find_units\|def self" \
  galaxy_game/app/services/lookup/unit_lookup_service.rb
```
If `units_producing(resource_type)` does not exist, flag this in your
Synthesis Report. The optimizer needs to know which unit types produce
which resources without hardcoding the list.

### Step 5 — Produce Synthesis Report and STOP

### Step 6 — Rewire optimizer (after approval)

**Remove:**
- `target_system` and `settlement_plan` hash parameters from all methods
- All hardcoded GCC cost estimates
- All invented percentage reduction calculations
- `analyze_local_resources` — replaces with live model reads
- `calculate_economic_impact` — hardcoded GCC, remove or stub with TODO

**Keep and rewire:**
- Phase sequencing concept → driven by TEU→PVE dependency chain
- Opportunity scoring structure → driven by unfilled buy orders
- `generate_isru_roadmap` → keep concept, replace invented phase logic
  with dependency chain phases from resource_flow_simulator

**New primary method signature:**
```ruby
def optimize_isru_priorities(settlement)
  unfilled_orders = Market::Order.where(
    settlement: settlement,
    order_type: :buy,
    status: :open
  )
  return { phases: [], reason: :no_unfilled_orders } if unfilled_orders.empty?

  capabilities = AIManager::ISRUEvaluator.new(settlement).assess_capabilities
  return { phases: [], reason: capabilities[:reason] } if capabilities[:status] == :blocked

  generate_deployment_phases(unfilled_orders, capabilities, settlement)
end
```

**Phase generation from dependency chain:**
```ruby
def generate_deployment_phases(unfilled_orders, capabilities, settlement)
  phases = []

  # Phase 1: Power gate — always first
  phases << { phase: 1, action: :deploy_power_units } unless power_sufficient?(capabilities)

  # Phase 2-5: Follow TEU→PVE chain based on what orders need filling
  # Read chain from resource_flow_simulator RESOURCE_CHAINS logic
  # Do not hardcode — derive from UnitLookupService operational data
  unfilled_orders.each do |order|
    phases.concat(phases_needed_for(order.resource_type, capabilities))
  end

  phases.uniq.sort_by { |p| p[:phase] }
end
```

### Step 7 — Update spec
Test the rewired interface:
- Settlement with unfilled buy order for water → returns TEU + PVE phases
- Settlement with no unfilled orders → returns empty phases
- Settlement with power insufficient → returns blocked
- Phase ordering follows TEU before PVE dependency

### Step 8 — Isolation run
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/isru_optimizer_spec.rb \
  --format documentation 2>&1 | tail -40"
```

### Step 9 — AI Manager regression check
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/ 2>&1 | tail -20"
```

---

## Synthesis Report Format
```
RESOURCE_FLOW_SIMULATOR CHAIN
TEU→PVE dependency chain found: [yes/no]
Chain content: [describe phases and dependencies]
How to incorporate into optimizer: [description]

CURRENT ISRU_OPTIMIZER
Methods worth keeping (rewire inputs): [list]
Methods to remove (hardcoded costs/scores): [list]
Lines with target_system/settlement_plan: [line numbers]

BLAST RADIUS
External callers: [list or "confirmed none"]
Safe to change public interface: [yes/no]

UNITLOOKUPSERVICE
units_producing method exists: [yes/no]
  → If NO: describe workaround or flag as prerequisite

REWIRE PLAN
New primary method signature: [confirm]
Phase sequencing source: [resource_flow_simulator chain / UnitLookupService]
Hardcoded GCC costs: remove or stub with TODO [which]

READY TO APPLY? — waiting for approval
```

---

## What NOT to Do
- Do not rewrite from scratch — rewire the existing logic
- Do not add hardcoded GCC cost values
- Do not add hardcoded unit type lists
- Do not add hardcoded resource type lists
- Do not keep `target_system` or `settlement_plan` hash parameters
- Do not calculate yields — that is UnitLookupService's job
- Do not duplicate logic from ISRUEvaluator — call it instead
- Do not touch `state_analyzer.rb` or `isru_evaluator.rb`
- Do not run the full suite

---

## Acceptance Criteria
- [ ] `target_system` hash parameter removed from all methods
- [ ] `settlement_plan` hash parameter removed from all methods
- [ ] Primary method accepts `settlement` as input
- [ ] Reads unfilled buy orders from `Market::Order`
- [ ] Delegates capability assessment to `ISRUEvaluator`
- [ ] Phase sequencing follows TEU→PVE dependency chain
- [ ] No hardcoded GCC cost estimates
- [ ] No hardcoded unit type lists
- [ ] No hardcoded resource type lists
- [ ] Isolation run: 0 failures
- [ ] No regressions in `spec/services/ai_manager/`

---

## Stop Conditions — escalate immediately if:
- External callers depend on `target_system`/`settlement_plan` interface
- `UnitLookupService` has no way to query units by output resource type
- `ISRUEvaluator` task is not yet complete — wait for it
- TEU→PVE chain logic in resource_flow_simulator is more complex than
  expected — flag before incorporating

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add galaxy_game/app/services/ai_manager/isru_optimizer.rb \
        galaxy_game/spec/services/ai_manager/isru_optimizer_spec.rb
git commit -m "fix: IsruOptimizer — rewire to Market::Order buy queue + ISRUEvaluator, remove invented hash interface, phase sequencing from TEU→PVE chain"
git push
```

---

## Dependencies
**Blocked by**:
- `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md` ✅ DONE
- `2026-04-03-HIGH-BUG-FIX-REWIRE-ISRU-EVALUATOR.md`
**Blocks**: Escalation service rewrite
**Related tasks**:
- `resource_flow_simulator.rb` archival (extract TEU→PVE chain first)
- Escalation service rewrite (TEU+PVE chain for Luna water)

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
