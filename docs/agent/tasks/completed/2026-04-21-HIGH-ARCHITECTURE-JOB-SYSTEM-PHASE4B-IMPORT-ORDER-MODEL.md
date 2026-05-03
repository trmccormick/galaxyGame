# TASK: Job System Phase 4b — Build ImportOrder Model and Migrate Logistics Call Sites
**Status**: COMPLETED
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-21
**Last Updated**: 2026-04-23

---

## Completion Summary
This task is fully complete. All logistics call sites (`earth_import`, `scheduled_import`, `contracted_harvesting`) have been migrated from `ResourceJob` to the new `ImportOrder` model. The model, migration, factory, and specs are present and green. Earth and AstroLift are seeded. No legacy logistics references remain in resource or AI manager services. See commit logs for details.

---

[Original task content omitted for brevity.]
