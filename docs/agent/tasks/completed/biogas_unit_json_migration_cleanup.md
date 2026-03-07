# BiogasUnit JSON Migration Cleanup
**Priority**: CRITICAL
**Status**: PENDING - Ready for execution
**Estimated Time**: 25 minutes
**Agent Assignment**: GPT-4.1 (JSON creation + spec refactor)
**Architecture Review**: Perplexity (data-driven unit architecture validation)

## Description
Migrate biogas_generator + biogas_unit → BaseUnit JSON processing. Eliminate duplicate hardcoded models → data-driven architecture.

**Current State**:
- ❌ biogas_generator-2.rb + biogas_unit-3.rb = duplicate legacy code
- ✅ BaseUnit.operate() = generic input/output processing ready

## Actions Required

### 1. READ TEMPLATES:
- `templates/unit_operational_data_v1.2.json`
- `templates/unit_blueprint_v1.3.json`

### 2. CREATE JSON FILES:
- `data/json-data/blueprints/units/specialized/biogas_generator.json`
- `data/json-data/operational_data/units/specialized/biogas_generator.json`

### 3. JSON STRUCTURE:
```json
{
  "input_resources": [
    {"id": "biomass", "amount": 10},
    {"id": "organic_waste", "amount": 5}
  ],
  "output_resources": [
    {"id": "biogas", "amount": 6},
    {"id": "fertilizer", "amount": 4}
  ],
  "power_requirements": {
    "operational_power_kw": 2.5
  },
  "energy_cost": 2.5
}
```

### 4. DELETE LEGACY MODELS:
- `rm app/models/units/biogas_generator.rb`
- `rm app/models/units/biogas_unit.rb`

### 5. UPDATE SPEC:
- `biogas_generator_spec.rb` → test BaseUnit JSON processing

### 6. VERIFY:
- `rspec spec/models/biogas_generator_spec.rb` (4→0 failures)

### 7. COMMIT:
- "Migrate biogas units to JSON-driven BaseUnit (4 specs green)"

## Success Criteria
- ✅ 2 JSON files created
- ✅ 2 legacy models deleted
- ✅ biogas_generator_spec.rb 4/4 GREEN
- ✅ GalaxyGame::Paths loads new unit data

## RSpec Impact
221 → 217 failures (4 specs eliminated)

## Architecture Benefits
BaseUnit + JSON = ZERO custom unit models needed

## Coordination Notes
- **GPT-4.1**: Execute the migration steps
- **Perplexity**: Review JSON structure and architecture decisions
- **Planner**: Task creation and documentation updates

## Risk Assessment
- **Low Risk**: JSON migration is reversible, specs will catch issues
- **Dependencies**: BaseUnit.operate() must be functional (confirmed ready)
- **Fallback**: Can restore legacy models if issues arise

## Next Steps After Completion
- Update TASK_OVERVIEW.md with completion
- Move task to /completed/
- Consider similar migrations for other duplicate unit models</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/critical/biogas_unit_json_migration_cleanup.md