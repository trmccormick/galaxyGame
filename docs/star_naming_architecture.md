# Star Naming Architecture

This document describes the star naming and identification architecture for the galaxyGame simulation. The system is designed to ensure robust, scalable, and context-aware star identification across multiple galaxies and solar systems.

## ID-Primary Design
- **Primary Key:** Each star is assigned a unique, immutable ID as its primary identifier.
- **Purpose:** Guarantees system-wide uniqueness and enables efficient referencing in code, data, and user interfaces.

## Alias Support
- **Aliases:** Stars may have one or more aliases (alternative names).
- **Usage:** Aliases support historical, cultural, and user-defined naming conventions.
- **Resolution:** All aliases map to the primary star ID for consistency.

## Scoped Uniqueness by Solar System
- **Constraint:** Star names (including aliases) are unique within the scope of their `solar_system_id`.
- **Implication:** Duplicate names are permitted across different solar systems, but not within the same system.
- **Validation:** Name assignment and lookup routines enforce scoped uniqueness.

## Sol Valid in Multiple Galaxies
- **Special Case:** The name "Sol" is permitted in multiple galaxies, reflecting real-world conventions and simulation requirements.
- **Implementation:**
  - "Sol" is treated as a valid alias or primary name in any solar system where appropriate.
  - Uniqueness is enforced only within the local solar system context.

---

**Implementation Note:**
All star naming, aliasing, and uniqueness logic is enforced at the data model and service layer. The architecture is locked and reflected in all related simulation, lookup, and user-facing systems.

**Document Status:** Architecture decisions finalized. Implementation complete. Documentation reflects current system behavior.
