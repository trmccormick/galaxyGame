# Player Emergency Missions
## docs/architecture/ai_manager/PLAYER_EMERGENCY_MISSION.md
## Status: Authoritative — March 15, 2026


## Overview

When the AI Manager cannot procure critical resources through normal channels,
it creates **Special Missions** for players. These are high-value, time-limited
opportunities that arise from genuine settlement distress — not manufactured
scarcity.

Emergency missions are the **last resort** in the resource acquisition chain.
They only trigger after all prior options have been exhausted.


## Resource Acquisition Order (Before Emergency Mission)

```
1. Local production (robot workforce + ISRU) — zero GCC cost
2. Side-effect resources from ongoing operations — zero GCC cost
3. Normal NPC buy orders (player supply chain) — GCC spent
4. NPC import from established suppliers — GCC spent
5. ── EMERGENCY MISSION TRIGGERS HERE ──
   Normal procurement failed AND resource is survival-critical
```

Emergency missions are not posted if:


## Trigger Conditions

All three conditions must be true simultaneously:

1. **Normal procurement failed** — no suppliers found, imports unavailable,
   local production insufficient for immediate need
2. **Resource is survival-critical** — O2, H2O, Food only. Non-critical
   shortages use normal buy orders, not emergency missions.
3. **Settlement has sufficient GCC** — reward must be fundable. If
   `account_negative?` is true, AI Manager cannot post emergency missions.
   This creates a dangerous compounding failure state — no GCC means no
   emergency procurement means life support at risk. DC financial health
   monitoring (`account_negative?` priority) is designed to prevent reaching
   this state.


## Mission Properties

| Property | Value | Notes |
|---|---|---|
| Base Reward | EAP × quantity × 1.5 | 50% premium over Earth import cost |
| Urgency Bonus | 2.0x multiplier | Applied when life support is actively failing |
| Expiration | 24 hours | Short window to create urgency |
| Visibility | All players | Displayed prominently in mission board |
| Priority Tag | CRITICAL | Highest visual prominence |
| GCC Escrow | Full reward amount | Locked at mission creation, released on delivery |


## Reward Calculation

```
base_reward = EAP_price(resource) × quantity × 1.5
urgency_multiplier = life_support_failing? ? 2.0 : 1.0
total_reward = base_reward × urgency_multiplier
```

EAP pricing via `Financial::Tier1PriceModeler`. See
`docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md` for EAP calculation.

**Example:**
```
URGENT: Oxygen Crisis at Mars Base Alpha
```


## Player Incentive Design

Emergency missions create the highest per-unit GCC returns in the game.
This is intentional:

  respond to emergencies that other players cannot
- Creates a niche for "emergency response" player corporations

---

## Failure State — No GCC for Emergency Missions

If a DC reaches the state where:
- Life support resource is critical
- Normal procurement has failed
- GCC account is negative (can't fund reward)

The AI Manager has limited options:
- Request emergency capital transfer from LDC (sponsoring DC)
- Attempt local production even if slow (survival mode)
- Reduce non-critical power consumption to extend life support duration

This is the most dangerous failure state in the game. The `debt_repayment`
priority in `AIManager::PriorityHeuristic` is specifically designed to
prevent DC accounts from going negative before reaching this point.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
Section 5 (The Dependency Chain) for cascade failure implications.

---

## Implementation Files

| File | Purpose |
|---|---|
| `app/services/ai_manager/escalation_service.rb` | Emergency mission creation |
| `app/models/special_mission.rb` | Mission record |
| `app/services/ai_manager/priority_heuristic.rb` | Trigger condition evaluation |
| `spec/integration/ai_manager/escalation_integration_spec.rb` | Integration tests |

---

## Related Documents
- `docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md` — EAP calculation
- `docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md` — Priority tiers
- `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` — DC financial model
