# Blueprint Cost Schema Guide

**Date:** 2026-01-15

## Purpose

Provide a minimal, consistent blueprint cost schema so services (planner, manufacturing) can consume numeric GCC values without parsing freeform strings.

## Recommended Fields (Numeric GCC)

- `unit_cost_gcc` (Float): Per-unit manufacturing cost in GCC.
- `installation_cost_gcc` (Float, optional): One-time installation cost.
- `maintenance_cost_gcc_per_year` (Float, optional): Annual maintenance.
- `research_cost_gcc_per_level` (Float, optional): Cost per research level.
- `cost_notes` (String, optional): Qualitative descriptors (e.g., High/Low) or contextual remarks.

## Placement

Add a `cost_schema` block at the root of blueprint JSONs:

```json
{
  "id": "example_component",
  "name": "Example Component",
  "category": "structural",
  "cost_schema": {
    "unit_cost_gcc": 85.0,
    "installation_cost_gcc": 20.0,
    "maintenance_cost_gcc_per_year": 5.0,
    "research_cost_gcc_per_level": 150.0,
    "cost_notes": "Local ISRU materials; low installation complexity"
  }
}
```

## Examples

### Basic Regolith Panel (Local ISRU)

```json
{
  "id": "basic_regolith_panel_mk1",
  "name": "Basic Regolith Panel Mk1",
  "category": "structural",
  "cost_schema": {
    "unit_cost_gcc": 15.0,
    "installation_cost_gcc": 2.0,
    "maintenance_cost_gcc_per_year": 0.5,
    "cost_notes": "Mature ISRU; local materials; panels mount to I-beam framework"
  }
}
```

### Sealed Lava Tube Cover (Manufactured + Complex Install)

```json
{
  "unit_id": "sealed_lava_tube_cover",
  "name": "Sealed Lava Tube Cover",
  "category": "infrastructure",
  "cost_schema": {
    "unit_cost_gcc": 7000.0,
    "installation_cost_gcc": 2500.0,
    "maintenance_cost_gcc_per_year": 500.0,
    "research_cost_gcc_per_level": 600.0,
    "cost_notes": "Integrates airlocks and hangar systems; modular expansion capability"
  }
}
```

## Consumption Guidelines

- Prefer `cost_schema` numeric fields when present.
- If absent, derive costs via EAP or local ISRU (see planner economic model).
- Use qualitative `cost_notes` for UI/tooltips; do not parse them for calculations.

## Migration Notes

- Incrementally add `cost_schema` to high-impact blueprints (coverage panels, entrance systems, power modules).
- Keep existing descriptive fields (e.g., `cost_analysis`, material qualitative tiers) for human context.
- Avoid strings like "7,000 GCC" when numeric values are needed; store numbers directly.

## References

- Planner Economic Model: `docs/developer/AI_MANAGER_PLANNER.md`
- Precursor Capabilities: `docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md`
- Blueprints: `data/json-data/blueprints/`
