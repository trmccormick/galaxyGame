# 2026-04-03-CRITICAL-state_analyzer_resource_profile_delegation.md

**AI_MANAGER_COMMAND.md VIOLATION**: Hardcoded `resource_profile` reinvents `UnitLookupService` + `settlement.inventory`.

## Diagnostic (Run First)
```bash
grep -A10 -B2 "resource_profile" app/services/ai_manager/state_analyzer.rb
cat -n app/services/ai_manager/state_analyzer.rb | grep -A5 -B5 "metal_richness\|volatile_availability"
```

## Current Betrayal
resource_profile = system_data[:resource_profile] || {}
resource_score = (resource_profile[:metal_richness] || 0) + # HARDCODED
(resource_profile[:volatile_availability] || 0) + # HARDCODED
(resource_profile[:rare_earth_potential] || 0) # HARDCODED

text

## Surgical Fix (MANDATORY)
**REPLACE** hardcoded `resource_profile` → **UnitLookupService** delegation:

```ruby
# BEFORE (hardcoded betrayal)
resource_profile = system_data[:resource_profile] || {}
resource_score = ...

# AFTER (COMMAND.md compliant)  
isru_units = UnitLookupService.find_available_isru_units(system_data[:settlement_id])
resource_profile = isru_units.map { |unit| 
  unit.operational_data.slice('input_resources', 'output_resources', 'efficiency')
}
resource_score = isru_units.sum { |unit| unit.operational_data['resource_extraction_rate'] || 0 }
```

## Validation
```bash
# Isolated spec
docker exec -it web bash -c "unset DATABASE_URL; RAILS_ENV=test bundle exec rspec spec/services/ai_manager/state_analyzer_spec.rb"

# Related specs (no regressions)
docker exec -it web bash -c "unset DATABASE_URL; RAILS_ENV=test bundle exec rspec spec/services/ai_manager/*_spec.rb" | grep -E 'Failures|Pending'

# Command compliance
grep -q "UnitLookupService\|operational_data" app/services/ai_manager/state_analyzer.rb || echo "❌ COMMAND VIOLATION"
```

## Constraints
- **NO HARDCODED** `metal_richness`, `volatile_availability`, `rare_earth_potential`
- **MUST** delegate to `UnitLookupService.find_available_isru_units()`
- **MUST** use `unit.operational_data` JSON (training data compliance)
- **NO** file additions. Single file fix.
- **STOP** if specs regress. Escalate immediately.

**Handoff Command** (Copy after diagnostic):
Read docs/agent/README.md first, then docs/agent_tasks/active/2026-04-03-CRITICAL-state_analyzer_resource_profile_delegation.md

CRITICAL ISSUE state_analyzer.rb hardcoded resource_profile violates AI_MANAGER_COMMAND.md

Your tasks:

Run diagnostic commands → Synthesis Report → STOP

Apply surgical fix only

rspec isolation → 0 failures

rspec related → no regressions

git commit -m "refactor(ai_manager): state_analyzer resource_profile → UnitLookupService"

Report results

Priority: CRITICAL | Time: 45min | Agent: Mid-tier

text
Execution Path
Save task → docs/agent_tasks/active/2026-04-03-CRITICAL-state_analyzer_resource_profile_delegation.md

Commit/push → Version surgical scalpel

Handoff → Mid-tier agent (multi-file inference needed)

Monitor → Validate COMMAND.md compliance

89→88 complete. resource_profile betrayal terminated. First of 5 economics drift files. Economics-driven manifests unlocked.

Execute handoff? Foundation for autonomous DC expansion ready.
