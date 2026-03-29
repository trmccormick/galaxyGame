# Logistics: Precursor Supply Tether (Earth-to-Luna)

## 1. The Earth-Launch Constraint
During the Precursor Mission and early Phase 1 (Work Camp), the settlement is 100% dependent on Earth-side manufacturing for high-complexity components.

## 2. Component Tiers
| Tier | Source | Examples | Logic |
| :--- | :--- | :--- | :--- |
| **Tier 1** | Local (ISRU) | Regolith, O2, H2O, I-Beams | Produced by `BaseRig` using Rake tasks. |
| **Tier 2** | Regional (Sol) | Refined Alloys, Glass | Future orbital trade via L1/Depot. |
| **Tier 3** | Earth (Launch) | `ruggedized_electronics`, `high_strength_actuators` | Hard-coded import requirement. |

## 3. Economic Multipliers
- **Transport Cost**: 5.0x Earth baseline (as defined in `lunar-precursor-ai_profile_v1.json`).
- **Currency**: Transactions for Earth-sourced parts are settled in **USD**, not GCC.
- **Maintenance Manifest**: Every `CAR-300` deployment must include a "Maintenance Crate" containing at least 250kg of Tier 3 spares to survive the transition to Phase 2.

## 4. Strategic Goal: Tether Severance
The primary objective of the AI Manager is to decrease the "USD Import Ratio" by transitioning as many Tier 2/3 requirements to local Tier 1 production before the initial Earth-funded maintenance crate is exhausted.