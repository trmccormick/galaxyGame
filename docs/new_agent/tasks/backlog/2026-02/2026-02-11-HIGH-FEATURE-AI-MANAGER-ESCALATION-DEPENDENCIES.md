---
status: SPRINT_READY
priority: HIGH
type: feature
system_domain: AIManager | MANUFACTURING
mvp_alignment: LUNA_MARKET_BOOTSTRAP
local_worker_safe: false
---

# TASK: Implement AI Manager Supply Escalation & Dependencies
**Status**: SPRINT_READY
**Priority**: HIGH
**Type**: feature
**Last Updated**: 2026-05-17

---

## Context & Critical Domain Rules
When the `AIManager::TaskExecutionEngineV2` processing pipeline hits an infrastructure build requirement but local settlement stocks are insufficient, the system must execute a standardized evaluation loop rather than failing silently.

When implementing, the agent must embed these explicit codebase behaviors:
1. **Module Namespace**: Wrap all logic inside the strict uppercase module wrapper: `module AIManager`.
2. **Market Evaluation Calculus**: Missing asset costs must be evaluated additively against the base commodity pricing parameters. Apply the exact transaction fee schema to the calculated gross (`Base Price * Quantity`):
   - **SCC Surcharge**: +0.5% (`0.005`)
   - **Broker Fee**: +0.3% (`0.003`)
   - **Sales Tax**: +3.37% (`0.0337`)
3. **Infrastructure Pivot Fallback**: If market prices render purchasing unprofitable or if the settlement lacks liquid funds, the handler must flag a data-driven dependency lock, freeze the active step in `TaskExecutionEngineV2`, and shift queue priorities to build local raw extraction infrastructure (e.g., modular panels or atmospheric harvesters).

---

## Files Involved

### Primary Files to Create or Edit
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/market_calculator.rb` | Handle isolated trading overhead calculus | `def self.calculate_total_cost` |
| `app/services/ai_manager/escalation_handler.rb` | Coordinate shortages, checking asset margins vs build pivots | `def resolve_shortage!` |
| `spec/services/ai_manager/escalation_handler_spec.rb` | Integration spec validating market thresholds and infrastructure shifts | Full test coverage |

### Reference Files — Read Only
| File | Why You Need It |
|---|---|
| `app/services/ai_manager/task_execution_engine_v2.rb` | Parameterized manifest execution engine driving the build loop |
| `app/services/ai_manager/manager.rb` | Main orchestration baseline |

---

## Technical Blueprint

### Market Calculator Isolation Layer
```ruby
module AIManager
  module MarketCalculator
    SCC_SURCHARGE = 0.005
    BROKER_FEE    = 0.003
    SALES_TAX     = 0.0337

    def self.calculate_total_cost(base_price, quantity)
      gross_base = base_price * quantity
      
      scc    = gross_base * SCC_SURCHARGE
      broker = gross_base * BROKER_FEE
      tax    = gross_base * SALES_TAX

      (gross_base + scc + broker + tax).round(4)
    end
  end
end