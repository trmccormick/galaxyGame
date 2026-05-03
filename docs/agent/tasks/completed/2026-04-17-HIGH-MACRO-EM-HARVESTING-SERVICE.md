# 2026-04-17-HIGH-MACRO-EM-HARVESTING-SERVICE

**Layer:** MACRO (Network/Physics)
**Created:** 2026-04-17
**Priority:** HIGH
**Status:** TODO

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Requires architectural reasoning, parameterized service design, and integration with multiple systems
**Supervision Level**: watched carefully

---

## Scope
Implement a generic, parameterized Exotic Matter (EM) Harvesting Service supporting all current and future EM harvesting methods:
- Wormhole stabilization satellites (harvest ejected EM, focus it back for stability)
- Wormhole stations (Natural Wormhole Anchors, NWAs) with proper fit (capture/store EM)
- Specialized craft (e.g., Heavy Lift Transport variants, future skimmer/spacecraft) fitted for EM harvesting

The service must support event-driven, rare EM harvesting, storage, logistics, and export, with integration points for wormhole expansion, market, and AI systems. All logic must be independently testable and extensible for new craft/structure types.

## Target Files
- app/services/em_harvesting_service.rb
- app/services/ai_manager/atmospheric_harvester_service.rb (integration)
- app/services/wormhole_expansion_service.rb (integration)
- RSpec: spec/services/ai_manager/em_harvesting_spec.rb

## Acceptance Criteria
- EM harvesting logic implemented for all three methods (satellite, NWA, craft)
- Parameterized service supports new craft/structure types with minimal code changes
- Storage, logistics, and export logic shared with other resource systems
- Event-driven triggers for wormhole EM events, stabilization, and harvesting
- RSpec: harvesting simulation, storage, logistics, and integration tests
- Documentation updated for all new/changed logic

## Implementation Steps
1. Create app/services/em_harvesting_service.rb as a generic, parameterized service
2. Implement harvesting logic for:
   - Stabilization satellites (see: wormhole_stabilization_satellite_data.json)
   - NWAs (see: natural_wormhole_anchor_mk1h_data.json)
   - HLT/skimmer craft (see: heavy_lift_transport_harvester_venus/titan/mars_data.json)
3. Integrate with AIManager::AtmosphericHarvesterService for mission planning and resource allocation
4. Integrate with WormholeExpansionService for event triggers and EM consumption
5. Implement storage, logistics, and export logic (shared with other resource systems)
6. Write/extend RSpec for all harvesting, storage, and logistics scenarios
7. Document all new/changed logic and update architecture diagrams if needed

## Audit/Stop Conditions
- All three EM harvesting methods are implemented and testable
- Service is parameterized and supports future craft/structure types
- No duplication with atmospheric harvesting or other resource services
- All integration points (AI, wormhole, market) are covered
- All acceptance criteria are met and verified by RSpec

## Commit Instructions
- Commit as: "Implement generic, parameterized EM Harvesting Service (satellite, NWA, craft, integration, tests)"
- Remove this task file after successful audit and merge
