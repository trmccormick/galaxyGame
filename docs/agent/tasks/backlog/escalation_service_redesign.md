# EscalationService Redesign — ISRU-First Architecture

**Status:** Backlog (blocking)
**Created:** March 5, 2026
**Owner:** GPT-4.1 (Copilot)

---

## Problem Statement

- Current EscalationService does not reflect ISRU-first design principles
- `find_nearby_settlements` queries by solar system incorrectly — Cycler route network not yet implemented
- `critical_resource?` classification is wrong — oxygen/water are always harvested locally via ISRU, never special missions
- Escalation order is incorrect per game design

---

## Correct Escalation Order (ISRU-First)

1. **ISRU Chain Expansion**
   - Can local production meet demand?
   - Expand ISRU chain if possible
2. **Deploy Robot Fleet for Local Harvesting**
   - If resource exists on celestial body, deploy robots to increase local yield
3. **Query Same-World Player and DC Settlements**
   - Check for available craft for in-system trade (same celestial body/world)
4. **Schedule Import on Next Cycler Visit**
   - Use established Cycler route network (requires future implementation)

---

## Implementation Notes

- `find_nearby_settlements` requires Cycler route network architecture before implementation — stub returns empty array for now
- `critical_resource?` method should be removed — all resources are harvested locally first per ISRU-first principle
- Escalation order must match above sequence

---

## References
- `isru_production_validation.rake`
- `lunar_base_pipeline.rake`
- `lunar_base_with_isru_pipeline.rake`
- `ai_sol_system_builder.rake`
- `docs/architecture/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md`
- `data/json-data/missions/archived_missions/lunar-precursor/initial_setup_phase_1_v1.1.json`

---

## Task Checklist
- [ ] Redesign EscalationService to follow ISRU-first escalation order
- [ ] Remove `critical_resource?` logic
- [ ] Stub `find_nearby_settlements` until Cycler network is implemented
- [ ] Update all specs to match new escalation logic
- [ ] Remove/replace any special mission triggers for oxygen/water
- [ ] Document new escalation flow in service and tests

---

**Blocking:** Correct test design and ISRU-first architecture
