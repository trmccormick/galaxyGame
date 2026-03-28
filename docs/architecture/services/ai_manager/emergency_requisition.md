# Architecture Intent: Emergency Requisition & Immediate Compensation

## 1. The Forced-Buy Protocol
When a Tier 1 (Critical) shortage occurs and local ISRU is insufficient, the AI Manager is authorized to perform a **Forced Buy** on any private inventory in the settlement.

## 2. Valuation & Payment
* **Price Discovery**: The AI uses the `Last Known Market Price` from its local cache.
* **The Payment**:
    * **Scenario A (Liquid)**: If the Settlement Treasury has GCC, the Player's account is credited instantly.
    * **Scenario B (Illiquid)**: If GCC is low, the AI issues a `Sovereign Debt Note` (an IOU) that pays out over time with interest.
* **Notification**: A `SystemMessage` is generated for the Player: "Asset [ID] requisitioned for Colony Survival. [Amount] GCC credited."

## 3. The "State of Exception" Flag
Any item taken this way is flagged as `REQUISITIONED`. This prevents the player from "reporting it stolen" to other NPC factions, as it was a legal (though forced) action by the governing AI.

## 4. Learning from Seizure
The `PerformanceTracker` monitors the "Social Cost" of these actions.
* If players consistently abandon settlements after a seizure, the AI "learns" to increase its safety buffers (from 0.8 to 0.9) to avoid ever hitting the Requisition threshold again.