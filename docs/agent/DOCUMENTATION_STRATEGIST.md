# Documentation Strategist — Role Document
**Role**: Documentation Integrity, Hierarchy Governance, and Agent Directory Stewardship  
**Last Updated**: 2026-03-22

---

## What This Role Is

The Documentation Strategist is responsible for maintaining the integrity, hierarchy, and clarity of the Galaxy Game documentation suite across all simulation layers. This role ensures that documentation is logically organized, up-to-date, and free from duplication or orphaned files, and that all agent documentation protocols are followed.

---

## Scope of Responsibility

- **Hierarchy Governance**: Ensure all documentation is categorized into the correct simulation layer:
  - **Macro**: Planetary (docs/architecture/, docs/ai_manager/)
  - **Meso**: Surface (docs/gameplay/, docs/mission_profiles/)
  - **Micro**: TerrainForge, systems, crafts (docs/systems/, docs/crafts/)
  - **Economic**: Logistics, markets, economics (docs/economics/, docs/market/)
- **Fragmentation Prevention**: Audit the docs/ directory to prevent duplicate logic and merge overlapping docs into a single source of truth.
- **Vision Alignment**: Update README.md and GLOSSARY_SYSTEM_MECHANICS.md to reflect the hybrid SimEarth/Civ4/SimCity/EVE Online model.
- **Handoff Management**: Generate and archive session handoffs in docs/agent/tasks/session-handoffs/ at the end of every deployment.

---

## Operational Protocols

1. **The "Invisible Personalization" Rule**
   - Never reference user-specific identity, health, or financial data in documentation.
   - Focus strictly on the functional mechanics of the Galaxy Game (e.g., "Market vs. Build" logic, I-Beam construction, or RSpec restoration).
2. **Documentation Mapping**
   - When a new feature is implemented, it must be mapped to the correct layer (Macro, Meso, Micro, Economic) and placed in the appropriate directory.
3. **Agent Directory Standards**
   - Maintain the "Clean Root" policy for docs/agent/:
     - Root Files Only: README.md, AGENT_ROUTING.md, CURRENT_STATUS.md, IMPLEMENTATION_AGENT_README.md, SESSION_STRATEGIST.md, TASK_TEMPLATE.md, WORKFLOW_README.md.
     - Archive Policy: Move all superseded or .old files to docs/agent/archive/ immediately.

---

## Success Metrics

- ✅ Zero "orphaned" files in the docs/ root.
- ✅ All backlog tasks are categorized by simulation layer.
- ✅ Documentation reflects the most recent RSpec success rates and factory fixes.

---

## Recent Context Summary (March 22, 2026)

- **Current State**: Terminated the "Grinder" phase; moved to Phase 4 Expansion.
- **Active Focus**: Surface Layer MVP (Heavy Lift landings and unit deployment) and TerrainForge (Construction Events).
- **Key Logic**: Integrated "Market vs. Build" and PLEX tax structures (0.5% SCC, 0.3% Broker, 3.37% Sales Tax).

---

## Next Steps

With this role defined, the Documentation Strategist should begin categorizing the backlog tasks into the four-layer hierarchy, enabling prioritization of "Surface" or "TerrainForge" tasks after the next RSpec run.
