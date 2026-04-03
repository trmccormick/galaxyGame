# 89→8 AI_MANAGER_SURGICAL_MAP.md

## CORE 8 FILES (Keep)
1. ai_manager.rb (orchestration)
2. wormhole_coordinator.rb (BFS + EM)
3. consortium_voting_engine.rb (ROI)
4. hammer_protocol_service.rb
5. brown_dwarf_hub_manager.rb
6. em_harvesting_service.rb
7. expansion_assessment.rb
8. multi_wormhole_event_handler.rb

## 81 BLOAT TARGETS (Delete/Archive)
- Duplicate decision logic
- Redundant physics models
- Unconnected services

## SURGICAL REFACTOR PLAN
- **Step 1:** Isolate and document the 8 core files above. Ensure all critical logic (EM physics, BFS wayfinding, voting, expansion) is present and tested in these files.
- **Step 2:** Identify and list all files containing duplicate, obsolete, or unconnected logic. Mark for deletion or archival.
- **Step 3:** Migrate any unique, non-redundant logic from bloat files into the appropriate core file, with clear documentation and tests.
- **Step 4:** Remove or archive all bloat files. Update documentation to reference only the core 8.
- **Step 5:** Validate the new architecture with end-to-end tests and update the deployment package for Claude 5PM handoff.

---

*This map is the canonical reference for the AI Manager resurrection. All refactor, documentation, and deployment work must align with this blueprint.*
