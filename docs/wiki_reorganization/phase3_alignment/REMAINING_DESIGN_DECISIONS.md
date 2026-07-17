# Phase 3 Remaining Genuine Design Decisions

**Created**: 2026-07-16  
**Purpose**: List only true unresolved game design decisions that require project owner input. Excludes documentation issues, implementation gaps, and resolved blockers.  
**Filter**: If canonical intent resolves it → NOT a genuine decision. If it's a documentation issue → NOT a genuine decision. Only items where the game design itself is ambiguous.

---

## Genuine Design Decisions

### 1. TL-to-MK Relationship

**Question**: Is blueprint MK generation independent of Technology Level (two orthogonal axes), or derived from Technology Level?

**Current State**: 
- `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` explicitly states this is an "open question"
- The 2026-07-15 analysis session suggests they are related but distinct: MK represents engineering iteration within a tech tier, while Technology Level represents the civilization's overall capability
- This implies a two-dimensional system (Tech Level × MK) rather than a one-to-one mapping

**Why It's Genuine**: No canonical intent statement addresses this. The Art Bible explicitly marks it unresolved. The data model design and visual asset generation depend on this decision.

**Options**:
1. **Two-axis system**: Tech Level (civilization capability) and MK (engineering iteration) are independent axes. A TL3 settlement can produce MK1, MK2, or MK3 blueprints based on engineering progress.
2. **Derived system**: MK is derived from Tech Level (e.g., MK = Tech Level - 1, capped at minimum). This creates a one-to-one mapping.
3. **Hybrid**: MK is partially derived from Tech Level with some independent progression (e.g., MK can be up to 1 tier below Tech Level, but engineering progress can push it higher).

**Recommendation**: Option 1 (two-axis system) based on the analysis session's interpretation. This provides more gameplay depth and aligns with the design principle that "Technology Level describes what the civilization can manufacture" while "Blueprint Generation describes how much the engineering design itself has improved."

**Impact**: Affects data model design for blueprints, visual asset generation, and tech tree progression logic.

---

## Items Considered But Excluded

### Not a Genuine Decision: Colony vs Settlement
- **Why excluded**: Canonical intent #1-2 explicitly defines this hierarchy. Code already implements it correctly. No ambiguity remains.

### Not a Genuine Decision: AI Manager Scope
- **Why excluded**: Canonical intent #8 explicitly says AI Manager is expected to grow into many services. No design question — just documentation housekeeping.

### Not a Genuine Decision: Template Version Drift
- **Why excluded**: Canonical intent #6 explicitly says templates are design documents, not runtime assets. Version drift is documentation housekeeping, not a design decision.

### Not a Genuine Decision: OrbitalDepot Namespace
- **Why excluded**: Canonical intent #4 says multiple Ruby models are not automatically a conflict. Code evidence shows the root-level file is retired. No ambiguity remains.

### Not a Genuine Decision: Multiple Gameplay Loops
- **Why excluded**: Canonical intent #9 explicitly states multiple interconnected gameplay loops are intentional. No design question.

### Not a Genuine Decision: NPC Economy / Player Automation
- **Why excluded**: Canonical intent #10 explicitly states NPCs create initial economy and player automation always has opportunity. No design question.

### Not a Genuine Decision: Transportation Costs
- **Why excluded**: Canonical intent #11 explicitly states imports are expensive, transportation/fuel never free, time and distance have value. No design question.

---

## Summary

**Total genuine design decisions**: 1 (TL-to-MK relationship)

This is the only item from all Phase 1 and Phase 2 analysis that remains a true unresolved game design question requiring project owner input. All other "blockers" were either:
- Documentation issues (resolved by canonical intent)
- Implementation gaps (not design decisions)
- False blockers (canonical intent resolved them)
