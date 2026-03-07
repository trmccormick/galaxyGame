# JSON Data Creation Guide for Blueprints & Operational Data

## Overview
This guide standardizes the creation and maintenance of JSON files for unit blueprints and operational data in GalaxyGame. It ensures all files are discoverable, template-compliant, and compatible with lookup and simulation services.

---

## Naming & Directory Conventions
- **Blueprints:**
  - Filename: `<unit>_bp.json`
  - Location: `data/json-data/blueprints/units/<category>/`
- **Operational Data:**
  - Filename: `<unit>_data.json`
  - Location: `data/json-data/operational_data/units/<category>/`

---

## Required Structure
- **Blueprints:**
  - Use the latest `unit_blueprint` template (see `templates/unit_blueprint_v1.3.json`).
  - Required fields: `id`, `name`, `description`, `category`, `item_produced`, `required_materials`, `production_data`, `cost_data`, `byproducts`, `aliases`, `metadata`, etc.
  - Add a `cost_schema` block at the root for numeric cost fields (see `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md`).
  - Reference operational data via `operational_data_reference.file`.

- **Operational Data:**
  - Use the latest `unit_operational_data` template (see `templates/unit_operational_data_v1.2.json`).
  - Required fields: `id`, `name`, `unit_type`, `category`, `description`, `processing_capabilities`, `input_resources`, `output_resources`, `storage`, `operational_properties`, `maintenance`, `metadata`, etc.

---

## Creation Workflow
1. **Start from the latest template.**
2. **Populate all required fields**—use defaults or empty values if needed.
3. **Use clear, numeric values** for costs and quantities.
4. **Place files in the correct directory** and use the correct naming convention.
5. **Reference operational data** from the blueprint.
6. **Validate with lookup services and specs** to ensure discoverability and correctness.

---

## References
- Cost schema: `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md`
- Blueprint/operational templates: `data/json-data/templates/`
- Example blueprints: `data/json-data/blueprints/units/specialized/`
- Example operational data: `data/json-data/operational_data/units/specialized/`

---

## Best Practices
- Always update to the latest template version when creating new files.
- Keep all fields present, even if not used (set to null, 0, or empty as appropriate).
- Use descriptive, human-readable values for `description`, `aliases`, etc.
- Validate JSON structure before committing.
- Document any non-obvious field usage in the file or in this guide.

---

_Last updated: 2026-03-06_
