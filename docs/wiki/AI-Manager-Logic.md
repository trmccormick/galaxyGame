# 🤖 AI Manager Core Logic & Behavioral Matrices

## 1. Component/System Mapping
- **Source Reference:** `GameConstants::AI_PRIORITIES`, `GameConstants::HUMAN_LIFE_SUPPORT`
- **Core System Code:** `AiManager::PriorityEvaluationService`, `AiTaskDelegatorJob`
- **Related Documentation:** `docs/architecture/SIMEARTH_ADMIN_VISION.md`

## 2. Behavioral Priority Matrix
The AI Manager acts as a resource-conscious governor, making systemic choices based on a dynamic weight scoring engine. When resources run thin or colonies expand, tasks are evaluated against the baseline priority integers defined in the engine configuration:

### Static Urgency Weights

| Category | System Vector | Priority Score | Engine Execution Response |
| :--- | :--- | :--- | :--- |
| **Critical** | `life_support` | **1000** | Halts all non-essential consumption; routes all active logistics lines to transport oxygen/water. |
| **Critical** | `atmospheric_maintenance` | **900** | Prioritizes greenhouse gas adjustment and atmospheric pressure stabilizing. |
| **Critical** | `debt_repayment` | **800** | Forces local market liquidation or commodity trading to service outstanding corporate debt. |
| **Operational** | `resource_procurement` | **500** | Orchestrates standard industrial extraction pipelines (e.g., raw regolith processing). |
| **Operational** | `construction` | **300** | Triggers infrastructure building loops (crater dome covers, shell assembly). |
| **Operational** | `expansion` | **100** | Deploys automated deep space scout craft or initializes wormhole stabilization scans. |

### Multiplier Adjustments
The engine applies standard tuning multipliers to shift weights globally during testing phases via `AI_PRIORITY_MULTIPLIERS` (defaulting to `1.0`).

---

## 3. Human Life Support Boundary Sweeps
When managing colony nodes, the AI continuously monitors metabolic consumption against environmental parameters. The simulation triggers critical alerts if the colony dips below the survival fences:

- **Metabolic Intakes:** Every population unit consumes exactly `2` Food, `1` Water, and `3` Energy per tick.
- **Oxygen Thresholds:** Requires a minimum oxygen partial pressure of `16.0 kPa` inside habitats.
- **CO2 Management:** Accumulates `1.0 kg` of CO2 per person per day. If local carbon dioxide partial pressure crosses the long-term exposure limit of `1.0 kPa`, morale begins its standard decline rate (`0.05`). Exceeding the short-term emergency limit of `4.0 kPa` activates the `DEATH_RATE` loop (`0.1`).
- **Thermal Range:** The optimal habitat baseline is set to `294.15 K` (21°C). The absolute survival boundary forces the AI manager into emergency heating/cooling interventions if local temperatures drift outside the `283.15 K` (10°C) to `303.15 K` (30°C) envelope.

---

## 4. Gaps & Task Cleanup Items
- **Dynamic Priorities:** Implement a system where `AI_PRIORITIES` weights shift dynamically based on faction status or localized emergency events rather than remaining entirely static.
- **Debt Liquidation Loops:** Review how the `debt_repayment` value of `800` interacts with local station market sell order books to ensure it doesn't cause fire-sale market collapses during low-liquidity cycles.