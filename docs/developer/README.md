# Developer Docs Index

**Date:** 2026-01-15  
**Last Updated:** 2026-01-17 (Testing infrastructure fixes)

## 🚨 Critical - Read First

**If you're running tests or the Grinder Protocol:**
- **[CRITICAL_TESTING_FIXES.md](CRITICAL_TESTING_FIXES.md)** - DATABASE_URL fix, correct test commands, deadlock recovery
- **[GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)** - Complete automation protocols with pre-flight checks

## Quick Links

- AI Manager Economic Alignment Review: `docs/developer/AI_MANAGER_ECONOMIC_ALIGNMENT_REVIEW.md`
- AI Manager Planner (Economic Model section included): `docs/developer/AI_MANAGER_PLANNER.md`
- Precursor Infrastructure Capabilities: `docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md`
- Blueprint Cost Schema Guide: `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md`
- Cost Schema Consumption Guide: `docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md`

## Testing & Recovery

- **[CRITICAL_TESTING_FIXES.md](CRITICAL_TESTING_FIXES.md)** - Correct test commands, DATABASE_URL fix (2026-01-17)
- **[GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md)** - Grinder protocols, pre-flight checks, schema evolution tracking
- **[spec_stabilization.md](spec_stabilization.md)** - Spec fixing progress and patterns

## Economic Systems

- AI Manager Economic Alignment Review: `docs/developer/AI_MANAGER_ECONOMIC_ALIGNMENT_REVIEW.md`
- AI Manager Planner (Economic Model section included): `docs/developer/AI_MANAGER_PLANNER.md`
- Precursor Infrastructure Capabilities: `docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md`
- Blueprint Cost Schema Guide: `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md`
- Cost Schema Consumption Guide: `docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md`

## Recent Updates (2026-01-17)

- ✅ Fixed DATABASE_URL override causing tests to run against development DB
- ✅ Updated PrecursorCapabilityService for schema evolution (Geosphere/Hydrosphere)
- ✅ Created start_grinder.sh for reliable overnight test automation
- ✅ Documented schema changes: crust_composition, stored_volatiles, water_bodies
- 📊 Test failures: 393 (down from 420)

## Notes

- The planner now has a documented economic model (EAP, transport, ISRU multipliers, NPC pricing).
- Precursor docs formalize local-first sourcing policy and environment-aware capabilities.
- Blueprints may include mixed cost representations; prefer `cost_schema` when present.
