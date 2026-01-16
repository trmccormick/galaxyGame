# Cost Schema Consumption Guide

**Date:** 2026-01-15

## Goal

Standardize how services consume blueprint costs: prefer numeric `cost_schema` fields; fallback to EAP/local ISRU when absent.

## Consumption Order

1. **Blueprint `cost_schema` (preferred):**
   - Use `unit_cost_gcc`, `installation_cost_gcc`, `maintenance_cost_gcc_per_year`, `research_cost_gcc_per_level` when present.
2. **Derived Costs (fallback):**
   - **Earth Anchor Price (EAP):** `(earth_spot_price × refining_factor) + transport_cost`.
   - **Local ISRU:** `earth_spot_price × maturity_multiplier` or configured local costs (e.g., `water: 2 GCC/kg`).
3. **Qualitative Fields:**
   - Use `cost_notes` for UI only; do not parse for calculations.

## Suggested Helper (docs-only outline)

```ruby
module CostSchemaHelper
  def self.extract_costs(blueprint)
    schema = blueprint['cost_schema'] || {}
    return {
      unit_cost_gcc: schema['unit_cost_gcc'],
      installation_cost_gcc: schema['installation_cost_gcc'],
      maintenance_cost_gcc_per_year: schema['maintenance_cost_gcc_per_year'],
      research_cost_gcc_per_level: schema['research_cost_gcc_per_level'],
      source: 'blueprint'
    } if schema['unit_cost_gcc']

    # Fallback: derive via EAP or local ISRU
    {
      unit_cost_gcc: derive_unit_cost(blueprint),
      source: 'derived'
    }
  end

  def self.derive_unit_cost(blueprint)
    # Example heuristic: use category/resource to pick cargo type & refining
    # Actual implementation should call EconomicConfig + TransportCostService
    base = EconomicConfig.earth_spot_price('components') || 100.0
    refining = EconomicConfig.refining_factor('components_assembly') || 4.0
    base * refining
  end
end
```

## Integration Guidance

- **Manufacturing Services:** Read blueprint via `BlueprintLookupService`, then pass to `CostSchemaHelper` for costs; fallback to EAP/ISRU if schema missing.
- **Planner:** When costing manufactured items, prefer blueprint `cost_schema`; otherwise use EAP + transport model.

## Testing Notes

- Add unit tests that validate consumption order and fallback behavior.
- Mock `EconomicConfig` and `Logistics::TransportCostService` for derived costs.

## References

- Planner Economic Model: `docs/developer/AI_MANAGER_PLANNER.md`
- Alignment Review: `docs/developer/AI_MANAGER_ECONOMIC_ALIGNMENT_REVIEW.md`
- Blueprint Cost Schema Guide: `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md`
- Lookup Service: `galaxy_game/app/services/lookup/blueprint_lookup_service.rb`
