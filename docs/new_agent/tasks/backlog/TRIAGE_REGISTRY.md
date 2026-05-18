---
status: active
priority: MEDIUM
type: documentation
system_domain: OTHER
mvp_alignment: OTHER
local_worker_safe: true
---

# Master Backlog Triage Registry
**Path**: `docs/new_agent/tasks/backlog/TRIAGE_REGISTRY.md`  
**Description**: The centralized tracking sheet for converting legacy tasks into high-fidelity 0x files. Pass this file to the agent context (`@TRIAGE_REGISTRY.md`) at the start of every triage session.

---

## 📊 Triage Summary Dashboard

| Status | Count | Description |
| :--- | :--- | :--- |
| 📋 **Legacy Remaining** | 0 | Legacy backlog concepts waiting for verification and distillation. |
| ⏳ **In Triage** | 3 | Tasks currently being analyzed and structured. |
| 🚀 **Ready for Copilot** | 2 | High-fidelity 0x tasks optimized for tomorrow's code sprint. |
| 🧼 **Completed & Cleaned** | 0 | Legacy files permanently deleted from the workspace. |

---

## 🚀 Active Sprint Pipeline (Ready for Copilot Burn)
*These tasks are perfectly formatted, verified against the codebase, and ready for code generation.*

| Target 0x Task File | Legacy Source File | Domain | Target Implementation Files |
| :--- | :--- | :--- | :--- |
| `2026-02-11-HIGH-AI_MANAGER-REFAC-WORMHOLE-CONNECTION-LOGGING.md` | `2026-02-11-HIGH-AI_MANAGER-MULTI-WORMHOLE-LEARNING-EVENT.md` | AI_MANAGER | `app/services/ai_manager/wormhole_logger.rb`<br>`app/models/galaxy_system.rb` |
| `2026-02-11-HIGH-AI_MANAGER-SITE-SELECTION-ALGORITHM.md` | `2026-02-11-HIGH-AI_MANAGER-SITE-SELECTION-ALGORITHM.md` | AI_MANAGER | `app/services/ai_manager/site_selection_service.rb`<br>`app/models/galaxy_system.rb` |
| `reorganization attempt 2/2026-02/2026-02-11-HIGH-FEATURE-AI-MANAGER-RESOURCE-ALLOCATION-ENGINE.md` | `RESOURCE-ALLOCATION-ENGINE.md` | AI_MANAGER \| MANUFACTURING | `app/services/ai_manager/resource_allocator.rb`<br>`app/models/inventory_ledger.rb`<br>`app/models/allocation.rb` |

---

## ⏳ Active Triage Queue (Claude MVP Priorities)
*These files are selected from the master candidate list to complete the core AI Manager MVP loops.*

| Target 0x Task File | Priority | Domain | Core Target Concept |
| :--- | :--- | :--- | :--- |
| `2026-02-11-HIGH-FEATURE-AI-MANAGER-SERVICE-INTEGRATION.md` | HIGH | AI_MANAGER | Connecting engine blocks to Sidekiq background jobs and the game loop clock. |
| `2026-02-11-HIGH-FEATURE-AI-MANAGER-ESCALATION-DEPENDENCIES.md` | HIGH | AI_MANAGER | Handling supply shortages via Market vs. Build branching math. |
| `2026-02-15-HIGH-FEATURE-IMPLEMENT-SETTLEMENT-PATTERN-LOGIC.md` | HIGH | AI_MANAGER | Serializing successful base grid snapshots (i-beams/panels) into reusable JSON templates. |

---

## 🧼 Execution History & Cleanup Log
*Once Copilot completes a task and the old file is deleted, move the row here to keep history clean.*

| 0x Task File | Legacy Source Deleted? | Completion Date | Implementing Agent |
| :--- | :--- | :--- | :--- |
| *None yet* | *Pending sprint* | *YYYY-MM-DD* | *Agent Name* |

---

## 🤖 Instructions for the Continue/Copilot Agent
> When this file is provided in your context window via `@TRIAGE_REGISTRY.md`:
> 1. Read the **Active Sprint Pipeline** to know what features are fully designed and ready to be coded.
> 2. Read the **Active Triage Queue** to see which raw concepts are currently being infused with domain rules.