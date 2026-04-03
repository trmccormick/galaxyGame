# TASK: Restore MaterialProcessingService — Remove Agent Bloat, Use Existing Infrastructure
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-01
**Last Updated**: 2026-04-01

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires understanding of existing infrastructure before
touching anything. Multiple files, judgment needed on what to remove vs keep.
**Supervision Level**: 🔴 Watched carefully

---

## Context
A previous agent deviated from the intended design of `MaterialProcessingService`
by reimplementing the data layer in Ruby instead of using the infrastructure
that already existed. This task restores the service to the intended design.

**The intended design was already built:**
- `Lookup::UnitLookupService` — loads full operational data for any unit by
  `unit_type`. Returns the complete JSON hash including `input_resources`,
  `output_resources`, and `processing_capabilities` with efficiency values.
- `CelestialBodies::Spheres::Geosphere` — already has `crust_composition`
  with volatile percentages per world. Already has `extract_material`.
- `settlement.celestial_body` — already delegated via location in
  `BaseSettlement`.
- Unit operational data JSON — already defines inputs, outputs, efficiency
  for every unit. Output amounts of `0` mean geosphere-driven (by design).

**What the agent built instead (all of this is bloat — remove it):**
- `TEU_DATA` constant — duplicates what is already in the unit JSON
- `PVE_DATA` constant — duplicates what is already in the unit JSON
- `GASSES_RATIO` constant — Mars-specific data that belongs in geosphere,
  not Ruby code
- `thermal_extraction` method — unit-specific, violates generic design
- `volatiles_extraction` method — unit-specific, violates generic design
- Hardcoded `production_time_hours` values — should come from operational data

The spec (`material_processing_service_spec`) tests this bloated interface
and must be rewritten to test the correct generic interface.

**Blocker**: Test suite must be under 20 failures before starting.
Do not patch the current spec — it will be rewritten here.

---

## Problem Statement
**Current (wrong) behavior:**
```ruby
# Agent reimplemented the data layer in Ruby
PVE_DATA = { output_gases_kg: 0.06 }      # Already in PVE JSON
TEU_DATA = { input_raw_kg: 10.0 }          # Already in TEU JSON
GASSES_RATIO = { hydrogen: 0.50 }          # Belongs in geosphere data

def thermal_extraction(unit, material, amount)  # Unit-specific — wrong
def volatiles_extraction(unit, material, amount) # Unit-specific — wrong
```

**Expected (correct) behavior:**
```ruby
# Service reads existing infrastructure — no hardcoding
def process(unit, input_material, input_amount)
  operational_data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
  # Read inputs/outputs from operational_data
  # Read world composition from settlement.celestial_body.geosphere
  # Execute job using what the data says
end
```

**The two cases the service handles — driven entirely by the JSON:**

**Case A — Fixed outputs (TEU pattern):**
`output_resources` in the JSON have non-zero amounts.
Service scales those amounts to the input and applies efficiency.
No geosphere lookup needed.
```json
"output_resources": [{"id": "processed_regolith", "amount": 9.95}]
```

**Case B — Geosphere-driven outputs (PVE pattern):**
`output_resources` in the JSON have zero amounts — intentional by design.
Service looks up `settlement.celestial_body.geosphere.crust_composition`
and calculates outputs from world composition × unit efficiency.
```json
"output_resources": [
  {"id": "extracted_gases", "amount": 0},
  {"id": "extracted_water", "amount": 0},
  {"id": "depleted_regolith", "amount": 0}
]
```

**Example — PVE on Mars, 5kg input, efficiency 0.75:**
```
geosphere.crust_composition volatiles: { H2O: 2.0%, CO2: 1.5%, SO2: 0.5% }

extracted_water:     5.0 * (2.0/100) * 0.75 = 0.075kg
carbon_dioxide:      5.0 * (1.5/100) * 0.75 = 0.05625kg
sulfur_dioxide:      5.0 * (0.5/100) * 0.75 = 0.01875kg
depleted_regolith:   5.0 - all_extracted
```

---

## Files Involved

### Primary Files — you will rewrite
| File | Purpose | Change |
|------|---------|--------|
| `app/services/manufacturing/material_processing_service.rb` | Core service | Remove all bloat, implement generic process method |
| `spec/services/manufacturing/material_processing_service_spec.rb` | Spec | Rewrite to test generic interface only |

### Primary Files — you will read but may need to update
| File | Purpose | Change |
|------|---------|--------|
| `app/models/material_processing_job.rb` | Job model | Verify `complete!` delegates correctly to generic service |

### Reference Files — read, do not edit
| File | Why You Need It |
|------|----------------|
| `app/services/lookup/unit_lookup_service.rb` | How to load unit operational data |
| `app/models/celestial_bodies/spheres/geosphere.rb` | `crust_composition`, `extract_material` |
| `app/models/settlement/base_settlement.rb` | `delegate :celestial_body, to: :location` |
| TEU operational data JSON | Confirms fixed output pattern |
| PVE operational data JSON | Confirms zero output / geosphere-driven pattern |

### Find operational data files (run from Rails root on HOST):
```bash
find data/json-data/operational_data/units -name "*thermal*" -o -name "*volatiles*" | sort
```

---

## Implementation Steps

> Read ALL reference files before touching anything.
> Audit blast radius first — do not remove methods until you know what calls them.

### Step 1 — Audit blast radius
```bash
grep -rn "thermal_extraction\|volatiles_extraction\|MaterialProcessingService" \
  app/ spec/ --include="*.rb" | sort
```
Document every caller. If anything outside
`material_processing_service_spec.rb` calls `thermal_extraction` or
`volatiles_extraction` — stop and escalate. Do not remove those methods
until callers are updated.

### Step 2 — Read existing infrastructure
```bash
# Confirm UnitLookupService.find_unit works for these unit types
grep -n "find_unit\|match_unit" app/services/lookup/unit_lookup_service.rb | head -20

# Confirm geosphere chain
grep -n "geosphere\|celestial_body" app/models/settlement/base_settlement.rb | head -10
```

### Step 3 — Read both operational data files
Find and read TEU and PVE JSON files. Confirm:
- TEU: `output_resources` has non-zero `amount`
- PVE: `output_resources` has zero `amount` (by design)
- Both: `processing_capabilities.geosphere_processing.efficiency` is present

### Step 4 — Produce Synthesis Report and STOP

```
BLAST RADIUS
Callers of thermal_extraction: [list]
Callers of volatiles_extraction: [list]
Safe to remove unit-specific methods: [yes/no]

OPERATIONAL DATA CONFIRMED
TEU outputs: [fixed/zero]
PVE outputs: [fixed/zero]
Efficiency fields: [present/missing]

PROPOSED SERVICE INTERFACE
[one paragraph describing what process() will do]

SPEC REWRITE APPROACH
[what the new spec will test]

READY TO APPLY? — waiting for approval
```

### Step 5 — Rewrite service (after approval)

```ruby
module Manufacturing
  class MaterialProcessingService
    def initialize(settlement)
      @settlement = settlement
    end

    def process(unit, input_material, input_amount)
      operational_data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
      return { error: "Unit operational data not found" } unless operational_data

      unless @settlement.inventory.has_item?(input_material, input_amount)
        return { error: "Insufficient #{input_material}" }
      end

      MaterialProcessingJob.create!(
        settlement: @settlement,
        unit: unit,
        processing_type: determine_processing_type(operational_data),
        input_material: input_material,
        input_amount: input_amount,
        status: :pending,
        production_time_hours: determine_production_time(operational_data),
        operational_data: { 'unit_type' => unit.unit_type }
      )
    end

    def complete_job(job)
      operational_data = Lookup::UnitLookupService.new.find_unit(job.unit.unit_type)
      outputs = calculate_outputs(operational_data, job.input_amount)

      @settlement.inventory.remove_item(
        job.input_material, job.input_amount, @settlement, {}
      )
      outputs.each do |resource_id, amount|
        next unless amount > 0
        @settlement.inventory.add_item(resource_id, amount, @settlement, {})
      end
    end

    private

    def calculate_outputs(operational_data, input_amount)
      output_resources = operational_data['output_resources'] || []
      efficiency = operational_data.dig(
        'processing_capabilities', 'geosphere_processing', 'efficiency'
      ) || 1.0
      base_input = operational_data.dig('input_resources', 0, 'amount') || input_amount
      scale = input_amount / base_input.to_f

      outputs = {}
      output_resources.each do |resource|
        if resource['amount'].to_f > 0
          outputs[resource['id']] = resource['amount'].to_f * scale * efficiency
        else
          outputs.merge!(
            geosphere_outputs(resource['id'], input_amount, efficiency)
          )
        end
      end
      outputs
    end

    def geosphere_outputs(resource_type, input_amount, efficiency)
      geosphere = @settlement.celestial_body&.geosphere
      return {} unless geosphere

      volatiles = geosphere.crust_composition&.dig('volatiles') || {}

      case resource_type
      when 'extracted_water'
        pct = volatiles['H2O'].to_f / 100.0
        { 'extracted_water' => input_amount * pct * efficiency }
      when 'extracted_gases'
        volatiles.except('H2O').each_with_object({}) do |(compound, pct), h|
          h[compound_to_resource(compound)] = input_amount * (pct.to_f / 100.0) * efficiency
        end
      when 'depleted_regolith'
        total_pct = volatiles.values.sum.to_f / 100.0
        { 'depleted_regolith' => input_amount * (1.0 - total_pct * efficiency) }
      else
        {}
      end
    end

    def compound_to_resource(compound)
      {
        'CO2' => 'carbon_dioxide',
        'SO2' => 'sulfur_dioxide',
        'CO'  => 'carbon_monoxide',
        'N2'  => 'nitrogen',
        'CH4' => 'methane'
      }.fetch(compound, compound.downcase)
    end

    def determine_processing_type(operational_data)
      types = operational_data.dig(
        'processing_capabilities', 'geosphere_processing', 'types'
      ) || []
      types.include?('volatile_extraction') ? :volatiles_extraction : :thermal_extraction
    end

    def determine_production_time(operational_data)
      # Use maintenance_interval as proxy for cycle time, or default 24hrs
      # TODO: add explicit processing_time_hours field to operational data JSON
      operational_data.dig('operational_properties', 'maintenance_interval_hours') || 24.0
    end
  end
end
```

### Step 6 — Rewrite spec
Test the generic `process` interface only. No references to
`thermal_extraction` or `volatiles_extraction`.

The spec needs a settlement with a celestial body that has a geosphere
with known `crust_composition`. Check if the factory chain already supports
this or if a trait needs to be added to the celestial body factory.

```bash
grep -rn "celestial_body\|geosphere" spec/factories/ | head -20
```

### Step 7 — Verify isolation
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/manufacturing/material_processing_service_spec.rb \
  --format documentation 2>&1 | tail -40"
```

### Step 8 — Regression check
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/manufacturing/ spec/models/ 2>&1 | tail -20"
```

---

## Acceptance Criteria
- [ ] `TEU_DATA`, `PVE_DATA`, `GASSES_RATIO` constants removed
- [ ] `thermal_extraction`, `volatiles_extraction` methods removed
- [ ] `process` method works for any unit type via `UnitLookupService`
- [ ] Fixed outputs (TEU) use operational data amounts directly
- [ ] Geosphere outputs (PVE) use `crust_composition` × efficiency
- [ ] `production_time_hours` comes from operational data, not hardcoded
- [ ] Spec tests generic interface — no unit-specific method names
- [ ] Isolation run: 0 failures
- [ ] No regressions in manufacturing or model specs
- [ ] 35-minute runtime issue resolved

---

## Note on `production_time_hours`
The operational data JSON does not currently have an explicit
`processing_time_hours` field. The implementation above uses
`maintenance_interval_hours` as a temporary proxy. Flag this in your
completion report — a `processing_time_hours` field should be added to
the operational data template and all processing unit JSON files.

---

## Stop Conditions — escalate immediately if:
- Blast radius shows callers of `thermal_extraction` or `volatiles_extraction`
  outside the spec file — do not remove until those are updated
- `UnitLookupService.find_unit` returns nil for TEU or PVE unit types
  in the test environment — factory or path issue, stop and report
- Geosphere `crust_composition` returns nil or unexpected structure
- Any integration spec references the old interface

---

## Dependencies
**Blocked by**: Test suite under 20 failures
**Blocks**: nothing directly
**Related tasks**:
- `2026-03-31-HIGH-REFACTOR-MATERIAL-PROCESSING-GEOSPHERE-DRIVEN-YIELDS.md`
  — superseded by this task, move to completed when this is done

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add app/services/manufacturing/material_processing_service.rb \
        spec/services/manufacturing/material_processing_service_spec.rb \
        app/models/material_processing_job.rb
git commit -m "fix: restore MaterialProcessingService to intended design — remove agent bloat, use UnitLookupService + geosphere data"
git push
```

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
