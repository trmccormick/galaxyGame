# 89→8_EXECUTION_PLAN.md

## 89→8 AI Manager Refactor: Step-by-Step

### 1. Preparation
- **Backup**: Commit all current changes and push to remote.
- **Reference**: Open [89→8_SURGICAL_MAP.md](89→8_SURGICAL_MAP.md) for the canonical list of 8 core files and 81 bloat targets.

### 2. Remove Bloat (81 Targets)
- Use the following command to remove all bloat files (edit the list as needed):
  ```bash
  git rm path/to/bloat_file1.rb path/to/bloat_file2.rb ...
  # Or, for bulk removal:
  xargs git rm < bloat_file_list.txt
  ```
- Double-check that only the 8 core files remain in ai_manager/.

### 3. Add/Refactor Core Files (8 Keep)
- Ensure the following files exist and are up to date:
  - ai_manager.rb
  - wormhole_coordinator.rb
  - consortium_voting_engine.rb
  - hammer_protocol_service.rb
  - brown_dwarf_hub_manager.rb
  - em_harvesting_service.rb
  - expansion_assessment.rb
  - multi_wormhole_event_handler.rb
- For any missing or outdated files, add or update using:
  ```bash
  git add path/to/core_file.rb
  ```

### 4. Wire Orchestration
- Follow [AI_MANAGER_ARCHITECTURE.md](AI_MANAGER_ARCHITECTURE.md) to connect all services and logic flows.
- Implement [CONSORTIUM_VOTING_ENGINE.md](CONSORTIUM_VOTING_ENGINE.md) logic in consortium_voting_engine.rb.

### 5. Commit and Push
- Commit all changes:
  ```bash
  git commit -am "89→8 AI Manager refactor: core files, bloat removal, orchestration wired"
  git push origin main
  ```

### 6. Test and Validate
- Run the full test suite:
  ```bash
  rspec spec/services/ai_manager
  ```
- Confirm **0 failures**. If any fail, debug using the supporting docs.

### 7. Final Review
- Cross-check with [FINAL_VALIDATION.md](FINAL_VALIDATION.md) before handoff.

---

*This plan guarantees a clean, reproducible 89→8 transition. Follow each step for a flawless Claude 5PM deployment.*
