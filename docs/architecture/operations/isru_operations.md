# ISRU Operations — Agent Rules and Code Alignment
**Last Updated**: 2026-04-01
**Status**: Authoritative — read before touching any ISRU-related code

---

## The One Rule That Governs Everything

**JSON is the source of truth. Ruby is the executor.**

- Unit behavior → defined in operational data JSON (`data/json-data/operational_data/units/`)
- World yields → defined in geosphere JSON (`crust_composition`)
- Mission sequencing → defined in mission profile JSON (`data/json-data/mission_profiles/`)
- Environmental adaptations → defined in JSON modifiers

Ruby services read this data and execute it. They never reimplement it.
Any Ruby constant that duplicates JSON data is agent-generated bloat and must be removed.

---

## Existing Documentation — Read These First

The ISRU system, precursor mission sequence, and bootstrap architecture are
fully documented. Agents must read these before touching any ISRU code:

| Document | What It Covers |
|----------|---------------|
| `docs/architecture/precursor_mission_bootstrap_architecture.md` | Full bootstrap sequence, phase dependencies |
| `data/json-data/mission_profiles/planetary_precursor_1.json` | Generic world-agnostic precursor mission |
| `data/json-data/mission_profiles/npc_base_deploy_adapted_luna_system.json` | Luna-specific deployment |
| `data/json-data/mission_profiles/lunar_precursor_ai_driven.json` | AI-driven Luna precursor |
| `data/json-data/operational_data/units/` | All unit operational data — inputs, outputs, rates |

---

## Bootstrap Sequence (Summary)

Full detail in `precursor_mission_bootstrap_architecture.md`. Summary only:

1. **Power and comms** — solar/RTG deployed first. Nothing runs without power.
2. **ISRU setup** — Harvester → TEU → PVE → Shell Printer → Cryo Tanks commissioned
3. **Gas processing** — Gas Separator → Gas Conversion Unit → propellant loop
4. **Construction scales** — more tanks, more structures, settlement grows

Power is a hard gate. `ISRUEvaluator` must treat insufficient power as a
blocking condition, not a weighted score reduction.

---

## The Units and Their Roles

Each unit's operational data JSON defines exactly what it does.
Ruby code reads that data — it does not restate it.

| Unit | Input | Output | Key Point |
|------|-------|--------|-----------|
| Regolith Harvester Rover | Surface | raw_regolith | Craft, not unit. Also does logistics at bootstrap phase |
| TEU | raw_regolith | processed_regolith + mixed_volatiles | Volatiles route directly to buffer tank |
| PVE | processed_regolith | extracted_gases + extracted_water + depleted_regolith | Independent machine — does not require TEU upstream |
| Regolith Shell Printer | regolith + power | printed_shell_component | Prints around partially pressurized bladder |
| Inflatable Cryo Tank | inflatable_bladders + regolith_feedstock | (storage unit) | Requires printed shell to commission |
| Gas Separator | mixed_volatiles | O2 + CH4 + N2 | Module — runs on battery at night |
| Gas Conversion Unit | H2 + CO2 + H2O | CH4 + O2 + H2O | Sabatier reaction — closes propellant loop |

---

## Geosphere-Driven Yields

Output amounts of `0` in unit operational data are intentional.
They mean: calculate from world geosphere composition.

```
output_amount = input_amount × (crust_composition[volatile] / 100.0) × unit_efficiency
```

Access via: `settlement.celestial_body.geosphere.crust_composition`

This works on any world with survey data. No hardcoded world-specific numbers in Ruby.
The system is generic by design — new worlds work automatically once surveyed.

---

## MaterialPile — Buffer Only

`Storage::MaterialPile` in `SurfaceStorage` is a flow buffer, not a
primary storage mechanism. Regolith accumulates in piles when production
outpaces consumption or when the rover cannot route material fast enough.

Regolith is never an inventory item. It always lives in `SurfaceStorage`
as a `MaterialPile`.

---

## What Each Service Must Do

### MaterialProcessingService
```ruby
# CORRECT
def process(unit, input_material, input_amount)
  operational_data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
  # Read inputs/outputs from operational_data
  # Calculate geosphere-driven yields where output amount is 0
  # Create MaterialProcessingJob
end

# WRONG — remove this pattern
PVE_DATA = { output_gases_kg: 0.06 }  # Hardcoded world-specific number
def thermal_extraction(unit, ...)      # Unit-specific method
def volatiles_extraction(unit, ...)    # Unit-specific method
```

### ISRUEvaluator
```ruby
# CORRECT
def evaluate(settlement)
  # Load unit operational data via UnitLookupService
  # Read geosphere for yield calculations
  # Calculate throughput at each stage from operational data rates
  # Identify bottleneck
  # Check power as hard gate — not weighted score
end

# WRONG — remove this pattern
ISRU_UNITS = {
  'PLANETARY_VOLATILES_EXTRACTOR_MK1' => {
    input_rate_kg_per_hour: 5.0,  # Already in JSON
    outputs: { water: 0.30 }      # Hardcoded world yield
  }
}
```

### EscalationService
```ruby
# CORRECT
# Water escalation checks TEU and PVE unit availability
# Checks processed_regolith availability for PVE input
# Uses unit operational data to determine capability

# WRONG — remove this pattern
# Generic robots performing water/ice extraction
# Any extraction path that bypasses TEU/PVE units
```

---

## Agent Rules — Do Not Violate

1. **Never hardcode unit rates, yields, or compositions in Ruby**
   Always use `Lookup::UnitLookupService.new.find_unit(unit.unit_type)`

2. **Never hardcode world-specific numbers in Ruby**
   Always read from `settlement.celestial_body.geosphere.crust_composition`

3. **Never treat TEU → PVE as a hard dependency**
   Each unit is independent — it processes whatever input is available

4. **Never bypass the unit system with generic robots**
   ISRU extraction always uses specific units — TEU, PVE, harvester craft

5. **Never store regolith as an inventory item**
   Bulk regolith lives in `Storage::MaterialPile` via `SurfaceStorage`

6. **Always treat power as a hard gate for ISRU**
   Insufficient power = ISRU cannot run. Not a penalty. A blocker.

7. **Read existing mission profile JSON before writing any ISRU logic**
   The sequencing is already defined. Do not reinvent it in Ruby.

8. **Read existing documentation before writing new documentation**
   The architecture is documented. Read it first. Do not duplicate it.

---

## Known Deviations to Fix

Tracked in backlog tasks:

| File | Deviation | Task |
|------|-----------|------|
| `app/services/manufacturing/material_processing_service.rb` | Hardcoded constants, unit-specific methods | `2026-04-01-HIGH-BUG-FIX-RESTORE-MATERIAL-PROCESSING-SERVICE-INTENDED-DESIGN.md` |
| `app/services/ai_manager/isru_evaluator.rb` | `ISRU_UNITS` constant duplicates operational data | Pending task |
| `app/services/ai_manager/escalation_service.rb` | Generic robots for water extraction | Existing backlog task |

---

## Related Files

**Services:**
- `app/services/manufacturing/material_processing_service.rb`
- `app/services/ai_manager/isru_evaluator.rb`
- `app/services/ai_manager/isru_optimizer.rb`
- `app/services/lookup/unit_lookup_service.rb`

**Models:**
- `app/models/material_processing_job.rb`
- `app/models/storage/material_pile.rb`
- `app/models/celestial_bodies/spheres/geosphere.rb`
- `app/models/settlement/base_settlement.rb`

**Data:**
- `data/json-data/operational_data/units/` — all unit operational data
- `data/json-data/mission_profiles/` — mission sequencing
