---
status: SPRINT_READY
priority: HIGH
type: feature
system_domain: AI_MANAGER | CONTROLLERS
mvp_alignment: AI_MANAGER_LUNA_SETTLEMENT
local_worker_safe: true
---

# TASK: AI Manager Service Integration Infrastructure
**Status**: SPRINT_READY
**Priority**: HIGH
**Type**: feature
**Created**: 2026-02-11
**Last Updated**: 2026-05-17

---

## Context & Critical Domain Rules
The AI Manager requires an integration harness to safely connect its standalone engine classes (`SiteSelectionService`, `ResourceAllocator`) to the broader game loop without executing direct, blocking database transactions inside HTTP controller requests. 

When implementing, the agent must embed these Rails integration paradigms:
1. **Asynchronous Processing**: Wrap core evaluation runs inside an active Sidekiq worker layer (`AiManager::TickExecutionWorker`).
2. **State Decoupling**: Ensure background jobs serialize minimal ActiveRecord identifiers (e.g., `lunar_map_id`, `inventory_ledger_id`) rather than passing heavy complex data objects through Redis.
3. **Idempotency**: Multiple background job ticks executing simultaneously must not double-allocate resources or create overlapping framework sites.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/workers/ai_manager/tick_execution_worker.rb` | Sidekiq integration worker for backend ticks | `def perform` |
| `app/services/ai_manager/orcheSTRATOR.rb` | Coordinate selection and allocation execution sequence | `def execute_tick` |
| `spec/workers/ai_manager/tick_execution_worker_spec.rb` | Verify asynchronous orchestration and error logging | Job queuing specs |

---

## Implementation Blueprint Reference

```ruby
# app/workers/ai_manager/tick_execution_worker.rb
module AiManager
  class TickExecutionWorker
    include Sidekiq::Worker
    sidekiq_options queue: :industry, retry: 3

    def perform(lunar_map_id, inventory_ledger_id)
      lunar_map = LunarMap.find_by(id: lunar_map_id)
      ledger = InventoryLedger.find_by(id: inventory_ledger_id)
      return unless lunar_map && ledger

      # Orchestrate service sequence asynchronously
      AiManager::Orchestrator.new(lunar_map, ledger).execute_tick
    end
  end
end