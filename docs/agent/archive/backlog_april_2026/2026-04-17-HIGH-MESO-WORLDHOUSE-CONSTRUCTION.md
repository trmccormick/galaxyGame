# Worldhouse Construction (Template-Compliant Rewrite)

**Date:** 2026-04-17
**Priority:** HIGH
**Layer:** MESO (Surface Simulation)
**Status:** TODO
**Agent Assignment:** Claude (reviewed by Copilot)

---

## Context & Rationale


Worldhouse construction is the foundation for enclosed valley terraforming, planetary-scale habitat prototyping, and the conversion of asteroids or moons (e.g., Phobos, Deimos) into orbital stations or depots. Each worldhouse or orbital structure is built on a suitable feature—valley, crater, lava tube, or excavated cavity (including hollowed moons/asteroids)—divided into segments, and constructed using I-beam and panel technology. Segment-based construction enables phased progress tracking, enclosure metrics, and integration with maintenance and failure analysis systems. The same architectural and simulation logic applies to both planetary and orbital conversions.

**Canonical Use Cases:**
- Mars Phobos/Deimos conversion (see [mars_genesis_phase0_phobos_deimos_conversion.json](../../data/json-data/missions/mars_settlement/phases/mars_genesis_phase0_phobos_deimos_conversion.json), [mars_genesis_phase0_deimos_depot_construction.json](../../data/json-data/missions/mars_settlement/phases/mars_genesis_phase0_deimos_depot_construction.json))
- Generic asteroid/moon conversion (see [tasks_v2](../../data/json-data/missions/tasks_v2/))

**Key References:**
- [worldhouse_progression_system.md](./worldhouse_progression_system.md)
- [architecture/construction_system.md](../../architecture/construction_system.md)
- [app/models/structures/worldhouse.rb]
- [app/models/structures/worldhouse_segment.rb]
- [app/services/construction/worldhouse_construction_service.rb] (see orchestration logic)
- [mars_genesis_phase0_phobos_deimos_conversion.json](../../data/json-data/missions/mars_settlement/phases/mars_genesis_phase0_phobos_deimos_conversion.json)
- [mars_genesis_phase0_deimos_depot_construction.json](../../data/json-data/missions/mars_settlement/phases/mars_genesis_phase0_deimos_depot_construction.json)
- [tasks_v2](../../data/json-data/missions/tasks_v2/)

---

## Scope
- Implement and extend worldhouse construction logic, including segment status tracking, enclosure calculations, and orchestration via WorldhouseConstructionService.
- Integrate with geological feature models for suitability and segment generation.
- Ensure compatibility with covering, material/component, and job systems.
- Prepare for downstream integration with maintenance, failure analysis, and AI learning systems.

---

## Target Files
- app/models/structures/worldhouse.rb
- app/models/structures/worldhouse_segment.rb
- app/services/construction/worldhouse_construction_service.rb
- app/services/covering/segment_covering_service.rb
- app/models/structures/segment_component.rb
- spec/models/structures/worldhouse_spec.rb
- spec/models/structures/worldhouse_segment_spec.rb
- spec/services/construction/worldhouse_construction_service_spec.rb

---

## Acceptance Criteria
- [ ] Construction status tracked per segment (planned, materials_requested, under_construction, enclosed, operational)
- [ ] Enclosure and coverage metrics calculated and updated on progress
- [ ] Orchestration logic schedules segment jobs, aligns skylights, and updates feature status
- [ ] Material/component requirements calculated and requested per segment
- [ ] RSpec: construction completion, segment status, enclosure metrics, orchestration edge cases
- [ ] Documentation updated and cross-referenced

---

## Implementation Steps
1. **Segment Logic:** Add/extend construction status, area, and enclosure logic in worldhouse.rb and worldhouse_segment.rb
2. **Orchestration:** Implement/extend WorldhouseConstructionService for feature conversion, segment generation, and job scheduling
3. **Covering & Materials:** Integrate with SegmentCoveringService and component/material systems for panel/beam requirements
4. **Progress Tracking:** Ensure recalculate_progress! and enclosure metrics update as segments are completed
5. **Testing:** Write/extend RSpec for construction, enclosure, orchestration, and edge cases
6. **Documentation:** Update/expand construction system docs and worldhouse progression docs

---

## Audit/Stop Conditions
- Confirm no duplicate or obsolete worldhouse construction logic exists in other tasks or docs
- All acceptance criteria met and verified by RSpec
- Documentation updated and cross-referenced
- Commit with message: `feat: implement segment-based worldhouse construction and orchestration`

---

## Notes
- This task is the canonical actionable breakdown for worldhouse construction; maintenance and failure logic are handled in [worldhouse_progression_system.md](./worldhouse_progression_system.md) and related tasks.
- See [architecture/construction_system.md](../../architecture/construction_system.md) for methodology, dependencies, and edge cases.
