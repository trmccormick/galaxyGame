# Manufacturing System Overview

> **Status:** Draft / Stub (2026-04-27)

---

## Purpose

This document provides a canonical overview of the manufacturing system for complex items, units, and craft. It defines the intent, design philosophy, naming/data standards, and the full production chain, referencing all relevant source files and documentation.

---

## 1. System Intent & Philosophy
- Enable modular, scalable, and realistic manufacturing of all in-game items, units, and craft.
- Prioritize canonical naming and data standards to avoid duplication and confusion.
- Ensure all blueprints, components, and materials are traceable to a single source of truth.

## 2. Manufacturing Chain Overview
- **Raw Materials** → **Processed Materials** → **Components** → **Blueprints** → **Assembly** → **Units/Craft**
- Each stage references canonical JSON/data files (see Reference section).

## 3. Naming & Data Standards
- All ids must be unique, descriptive, and checked for existing usage before creation.
- New terms/components require an audit of existing ids and a reference to the canonical source.
- Deprecated/legacy terms must be clearly marked and reference their replacement.
- Use v1.3-compliant templates for all new blueprints and items.

## 4. Rules for Contributors
- Before adding a new material/component/blueprint, search for existing ids and review this document.
- Reference the canonical file or doc section when duplicating or extending data.
- Document all new ids/terms in the Reference section below.

## 5. Example Manufacturing Chain (Stub)
- **Example:**
  - Aluminum Ore (raw) → Aluminum (processed) → Electronics (component) → Electronics Blueprint → Assembled in Fabricator → Installed in Tug Craft

---

## Reference Section
- **Blueprint Cost Schema:** [docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md](../../developer/BLUEPRINT_COST_SCHEMA_GUIDE.md)
- **Component Production Logic:** [docs/architecture/operations/component_production_logic.md](../operations/component_production_logic.md)
- **ISRU Chain:** [docs/architecture/isru/README.md](../isru/README.md)
- **Asteroid Tug Construction:** [docs/crafts/asteroid_relocation_tug_guide.md](../../crafts/asteroid_relocation_tug_guide.md)
- **Materials Organization:** [docs/api/materials.md](../../api/materials.md)
- **Blueprint Example:** [data/json-data/blueprints/components/electronics/electronics_bp.json](../../../data/json-data/blueprints/components/electronics/electronics_bp.json)

---

## To Do / Stubs
- [ ] Add diagrams for manufacturing chain
- [ ] Expand with real examples for units/craft
- [ ] Add section on versioning and template compliance
- [ ] Link to all canonical JSON/data files for each stage
- [ ] Add FAQ and troubleshooting

---

> _For any new additions, always reference the canonical file or doc section here._
