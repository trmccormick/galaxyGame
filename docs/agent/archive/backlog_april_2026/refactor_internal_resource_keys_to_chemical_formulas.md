# Backlog Task: Refactor Internal Resource Keys to Chemical Formulas

## Problem
Internal resource keys use display names ("iron", "oxygen") instead of chemical formulas (Fe, O2), violating project convention. Internal logic should use chemical formulas via MaterialLookupService for consistency.

## Goals
- Standardize internal resource representation to chemical formulas
- Leverage existing MaterialLookupService infrastructure
- Separate internal formulas from UI display names
- Ensure consistency across codebase

## Steps
1. Global search for display names in internal logic: grep -r "iron|oxygen|water|nitrogen|carbon_dioxide|methane" app/ spec/ --exclude-dir=app/views --exclude-dir=app/helpers
2. Replace pattern: display_name → LookupService.find_material(chemical_formula)
3. Update factories: use material_id and formula instead of name
4. Add RSpec verification (8 examples) in spec/services/resource_naming_spec.rb
5. Mechanical search/replace in affected files: factories, models, services, hardcoded arrays/case statements

## Acceptance Criteria
- Internal logic uses chemical formulas (Fe, O2, H2O, N2, CO2, CH4)
- MaterialLookupService used consistently for resource mapping
- UI display names remain unchanged
- New RSpec spec validates formula usage
- No display names in internal code paths

## Technical Details
**Target Files**:
- spec/factories/*.rb
- app/models/resource*.rb
- app/services/escalation*.rb
- app/services/order*.rb
- hardcoded arrays/case statements

**Current Pattern**:
```ruby
# Wrong: display names in internal logic
resource = "iron"
oxygen_level = 0.21
```

**Correct Pattern**:
```ruby
# Right: chemical formulas via service
resource = MaterialLookupService.find_material("Fe")
oxygen_level = MaterialLookupService.find_material("O2").percentage
```

**Expected Impact**:
- 15-25 test failures from string matching → service calls
- Perfect separation of internal formulas vs UI display names
- Consistent with project convention

**Verification**:
- Add spec/services/resource_naming_spec.rb with 8 examples
- Test formula lookup for all common resources
- Verify no display names in internal code

---

Created: 2026-03-08
Priority: MEDIUM (Standardizes internal representation)
Estimated Effort: 90 minutes
Dependencies: Manufacturing pipeline stability, Courier Phase 1 completion
Agent Assignment: GPT-4.1 (mechanical search/replace) or Gemini 2.5 Flash (implementation)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/refactor_internal_resource_keys_to_chemical_formulas.md