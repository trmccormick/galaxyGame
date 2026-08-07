# ISRU Equipment Chain Validation — 2026-08-01

## Status: WORK IN PROGRESS
Blueprint corrections applied; tech_tree entries are incomplete/missing.

---

## Fixes Applied ✅

### 1. TEU Mk1 Blueprint — Operational Data Path
- **Issue**: Reference path `units/thermal_extraction_unit_operational.json` (non-standard)
- **Fixed to**: `units/production/extractors/thermal_extraction_unit_mk1_data.json` (mirror structure)
- **File**: [thermal_extraction_unit_mk1_bp.json](data/json-data/blueprints/units/production/extractors/thermal_extraction_unit_mk1_bp.json)
- **Status**: ✅ Verified operational_data file exists at target path

### 2. TEU, PVE Mk1/2/3 — Tech References Standardized
All four extractor blueprints updated from mixed naming to snake_case placeholders:

| Equipment | Old Tech Ref | New Tech Ref (Placeholder) | Blueprint |
|-----------|--------------|---------------------------|-----------|
| TEU Mk1 | `Thermal Processing Technology` | `thermal_volatile_extraction_tech` | [thermal_extraction_unit_mk1_bp.json](data/json-data/blueprints/units/production/extractors/thermal_extraction_unit_mk1_bp.json) |
| PVE Mk1 | `Planetary Volatiles Extraction` | `planetary_volatiles_extraction_tech` | [planetary_volatiles_extractor_mk1_bp.json](data/json-data/blueprints/units/production/extractors/planetary_volatiles_extractor_mk1_bp.json) |
| PVE Mk2 | `Advanced Volatiles Processing` | `advanced_volatiles_processing_tech` | [planetary_volatiles_extractor_mk2_bp.json](data/json-data/blueprints/units/production/extractors/planetary_volatiles_extractor_mk2_bp.json) |
| PVE Mk3 | `Extreme Environment Volatile Extraction` | `extreme_environment_volatile_extraction_tech` | [planetary_volatiles_extractor_mk3_bp.json](data/json-data/blueprints/units/production/extractors/planetary_volatiles_extractor_mk3_bp.json) |

### 3. Facility Type References Validated
- ✅ `fabrication_hangar` — used in blueprints, exists in comparable units
- ✅ `precision_assembler` — used in blueprints, exists in comparable units

---

## Operational Data Files Confirmed ✅

All extraction units have paired operational_data files:

| Unit | Blueprint | Operational Data | Path |
|------|-----------|------------------|------|
| TEU Mk1 | ✅ | ✅ | `units/production/extractors/thermal_extraction_unit_mk1_data.json` |
| PVE Mk1 | ✅ | ✅ | `units/production/extractors/planetary_volatiles_extractor_mk1_data.json` |
| PVE Mk2 | ✅ | ✅ | `units/production/extractors/planetary_volatiles_extractor_mk2_data.json` |
| PVE Mk3 | ✅ | ✅ | `units/production/extractors/planetary_volatiles_extractor_mk3_data.json` |
| Regolith Harvester (RH-400) | ✅ | ✅ | `units/crafts/harvesters/regolith_harvesting_rover_data.json` |

---

## ISRU Processing Chain Map

```
Input: Raw Regolith (surface deposit, infinite)
  ↓
[Regolith Harvesting Rover] → scrapes/buckets raw regolith → hopper feed
  ↓
[Thermal Extraction Unit Mk1] → bakes at low/mid temp → drives off H₂O, CO₂, N₂
  ↓
[Planetary Volatiles Extractor Mk1/2/3] → high-temp oxide reduction → elemental O₂
  ↓
Output A: Elemental O₂ → Tank Farm (LOX/life support/fuel)
Output B: Depleted Regolith → Workshop (3D printing, metal smelting)
```

---

## Incomplete: Tech Tree Entries ❌

**Four technologies referenced in blueprints do NOT currently exist in tech_tree files:**

| Tech ID | Blueprint | Current Status | Tier Proposal |
|---------|-----------|-----------------|---------------|
| `thermal_volatile_extraction_tech` | TEU Mk1 | MISSING | mining_resource_processing tier_2b |
| `planetary_volatiles_extraction_tech` | PVE Mk1 | MISSING | mining_resource_processing tier_2c |
| `advanced_volatiles_processing_tech` | PVE Mk2 | MISSING | mining_resource_processing tier_3 |
| `extreme_environment_volatile_extraction_tech` | PVE Mk3 | MISSING | mining_resource_processing tier_4 |

**Action Required:**
- Add tier definitions to [mining_resource_processing.json](data/json-data/tech_tree/mining_resource_processing.json)
- Ensure tech names match blueprint `required_technology` fields (snake_case, no spaces)
- Each tier should unlock the corresponding equipment unit

---

## Other Known Gaps

### Stub Units (Incomplete)
Two production units exist with placeholder operational_data (need design review):

| Unit | Blueprint | Status | Issue |
|------|-----------|--------|-------|
| AeroFab CNC Module Mk1 | ✅ | STUB | operational_data exists but specs are 1h/1 GCC placeholders |
| Volatile Systems Integrator Mk1 | ✅ | STUB | operational_data exists but specs are 1h/1 GCC placeholders |

**Decision Pending:** Are these real production units (need full specs) or intentional stubs?

---

## Next Steps (Priority Order)

1. **Add tech_tree entries** for four volatile extraction techs (mining_resource_processing.json tiers)
2. **Validate stub units** — confirm AeroFab + VSI are real units or remove stubs
3. **Git commits** — after tech_tree entries added, commit all fixes with message pattern:
   - `fix: ISRU equipment chain — blueprint/operational_data/tech_tree validation (2026-08-01)`

---

## Notes

- All blueprints now use v1.4 template compliance (updated metadata.version fields)
- Facility type references use confirmed real values from comparable infrastructure units
- Tech reference naming is now consistent (snake_case) and follows placeholder pattern for incomplete entries
- No JSON corruption remaining — all extractor blueprints validated for syntax compliance
