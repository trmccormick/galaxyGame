# Scenario: Super-Mars

> **Type:** Test Bench Exploration Scenario
> **Purpose:** Exercises moonless planetary colonization, asteroid interception mechanics, and orbital base staging constraints under validated spatial and physics constants.
> **Status:** Phase 3 reference scenario — use to stress-test simulation loops before UI expansion.

---

## Scenario Overview

Super-Mars is a moonless rocky planet situated at approximately 1.5 AU from its host star — just beyond the `SAFE_DISTANCE_FROM_STAR = 1.496e8 m` (1 AU) inner boundary and well within the `MAX_DISTANCE_FROM_STAR = 1.496e10 m` (100 AU) operational ceiling. With no natural satellite for orbital staging, all logistics, resource capture, and atmospheric work must originate from constructed orbital infrastructure.

This scenario is specifically designed to stress three simulation subsystems simultaneously:

1. **Moonless colonization** — all orbital staging must be player/AI built; no natural Lagrange anchor points.
2. **Asteroid interception** — active resource capture from the local belt as a primary N₂ and volatile supply chain.
3. **Orbital base staging constraints** — wormhole endpoint placement and stabilizer compliance under the full spatial ruleset.

---

## Starting Conditions

| Parameter | Value | Source Constant |
|---|---|---|
| Planet distance from star | ~1.5 AU | Within `SAFE_DISTANCE_FROM_STAR` / `MAX_DISTANCE_FROM_STAR` bounds |
| Natural satellites | 0 | Moonless constraint |
| Starting colony population | 500 persons | Baseline stress load |
| Starting GCC reserve | 500,000 GCC | `GCC_TO_USD_INITIAL = 1.0` (500k USD equivalent) |
| Atmospheric pressure (surface) | ~800 Pa | ~0.8% of `EARTH_PRESSURE = 101325 Pa` |
| Starting O₂ partial pressure | ~1.4 kPa | Below `min_oxygen_partial_pressure = 16.0 kPa` — suits required immediately |
| Surface temperature | ~210 K | Below `temperature_min = 283.15 K` — heating required |

The colony begins in a pressurized dome habitat. Open-surface operations require pressure suits from tick 1. All food, water, and energy consumption begins immediately at per-person rates: Food `= 2`, Water `= 1`, Energy `= 3` units/tick.

---

## Phase 1: Surface Establishment (Ticks 1–50)

### Life Support Priority (AI Weight: 1,000)

The AI manager's critical stack dominates early gameplay. With surface pressure at ~800 Pa (far below `min_pressure_for_survival = 33.0 kPa`), the colony cannot operate outside sealed structures.

Key targets before Tick 50:
- Internal dome pressure ≥ 33.0 kPa
- O₂ partial pressure ≥ 16.0 kPa inside habitat
- CO₂ partial pressure ≤ 1.0 kPa (long-term limit)
- Colony temperature within `283.15 K – 303.15 K`

Human life support consumption load for 500 persons:
- O₂: `500 × 0.84 kg/day = 420 kg O₂/day`
- CO₂ scrubbing: `500 × 1.0 kg/day = 500 kg CO₂/day`
- Drinking water: `500 × 2.5 L/day = 1,250 L/day`
- Total water (all uses): `500 × 50.0 L/day = 25,000 L/day`

### Earth Import Dependency

Until local extraction is online, all critical volatiles arrive via Earth import at `INITIAL_TRANSPORTATION_COST_PER_KG = 1,320.00 USD/kg`. At 420 kg O₂/day, that is **554,400 USD/day** in oxygen alone — establishing extreme economic pressure to stand up local production rapidly.

---

## Phase 2: Orbital Infrastructure (Ticks 51–150)

### Constructing the Orbital Staging Base

With no moon, the player must construct a free-orbit station. Spatial constraints apply to all orbital structures and any wormhole endpoints:

- Station must be placed beyond `SAFE_DISTANCE_FROM_STAR = 1.496e8 m` from the host star (already satisfied at 1.5 AU).
- Any wormhole endpoint associated with this system must also respect these bounds.

Wormhole generation for this system rolls at `WORMHOLE_GENERATION_CHANCE = 0.3` per eligible 24-hour cycle. The system may receive up to `MAX_WORMHOLES_PER_SYSTEM = 3`. Each wormhole must be supported by:
- `MIN_STABILIZERS_REQUIRED = 2` operational stabilizers
- Each stabilizer at `MIN_STABILIZER_POWER ≥ 25`
- Each stabilizer within `STABILIZER_EFFECTIVE_RANGE = 100.0` spatial units of the endpoint

**Habitable volume requirement for orbital station crew:**
- `DEFAULT_VOLUME_PER_CREW_M3 = 15.0 m³` per crew member
- A 20-person station crew requires minimum 300 m³ pressurized volume

### Debt Repayment Pressure (AI Weight: 800)

Construction costs default to `DEFAULT_CONSTRUCTION_PERCENTAGE = 10.0%` of material value. The AI will service debt before any expansion spending (`expansion: 100`). Players should pre-fund the orbital build before triggering the `EconomyEngine.settle_cycle` construction pass, or the AI will stall expansion in favor of debt clearance.

---

## Phase 3: Asteroid Interception (Ticks 151–300)

### Target Resource: Nitrogen (N₂)

Super-Mars's thin atmosphere is N₂-poor. The primary nitrogen supply chain is asteroid interception from the local belt. Target asteroid class: carbonaceous chondrites with ~2–5% volatile fraction.

Atmospheric engineering targets (scaled from `EARTH_ATMOSPHERE` baseline):

| Gas | Earth Baseline | Super-Mars Target | Notes |
|---|---|---|---|
| N₂ | 78.08% | 78.0% | Primary interception target |
| O₂ | 20.95% | 21.0% | Electrolytic production from H₂O ice |
| Ar | 0.93% | 0.9% | Secondary asteroid source |
| CO₂ | 0.04% | ≤ 0.5% | Greenhouse warming asset, but capped |

The atmospheric engineering calculation uses ideal gas law with `IDEAL_GAS_CONSTANT = 8.31446 J/(mol·K)` and bulk atmosphere modeling via `average_gas_constant = 287.05 J/(kg·K)`.

To reach breathable pressure (`EARTH_PRESSURE = 101325 Pa`) from ~800 Pa, total atmospheric mass must increase roughly 127×. With `EARTH_ATMOSPHERE[:mass] = 5.15e18 kg` as the reference for a full Earth atmosphere, Super-Mars (smaller planet, lower gravity) requires proportional scaling against `Earth::GRAVITY = 9.8 m/s²`.

### Interception Mechanics

Asteroid interception is a logistics operation governed by the courier contract system (see `docs/wiki/Logistics-and-Hauling.md`). Key parameters:

- Intercept contracts are posted to the NPC board with risk underwriting based on delta-v cost and transit time.
- Resource haul cost is computed against `INITIAL_TRANSPORTATION_COST_PER_KG` as a ceiling; local interception should undercut this significantly to justify the orbital infrastructure investment.
- Captured volatiles enter the storage system at `STORAGE_CAPACITY_PER_WORKER = 1,000 kg` per storage worker; with `STORAGE_WORKERS_RATIO = 0.1` (10% of population), a 500-person colony can manage 50 storage workers → **50,000 kg** orbital buffer capacity.

---

## Phase 4: Atmospheric Bootstrapping (Ticks 301+)

### Greenhouse Warming Strategy

Super-Mars surface temperature of ~210 K is 73 K below the `temperature_min = 283.15 K` survival floor. Controlled greenhouse gas introduction is the primary warming mechanism. `GREENHOUSE_FACTORS` multipliers (relative to CO₂):

| Gas | GWP Factor | Strategy |
|---|---|---|
| CO₂ | 20.0 | Primary warming agent; asteroid/comet delivery |
| CH₄ | 25.0 | Supplementary; risk of runaway if uncontrolled |
| N₂O | 298.0 | High-leverage; small quantities sufficient |
| H₂O | 12.0 | Natural feedback once liquid water exists |
| O₃ | 2,000.0 | UV shield; critical for surface habitability |

**Warning:** `AtmosphereProcessor.run_maintenance` will flag CO₂ accumulation above `0.5%` even when it is intentional during terraforming. During active greenhouse warming phases, the maintenance alert threshold should be temporarily overridden with an explicit test flag — do not suppress the alert system globally.

### Biosphere Introduction

Once temperature and pressure targets are within range, biosphere seeding begins. `BIOSPHERE_SIMULATION` baseline rates:

| Parameter | Value |
|---|---|
| Plant growth factor | 0.1 (base rate) |
| Moisture adjustment rate | 0.01/tick |
| Biome area adjustment rate | 0.05/tick |
| Temperature adjustment rate (tropical) | 0.1/tick |
| Polar adjustment factor | 0.5× (slower) |
| Max biomes (biodiversity calc) | 10 |
| Temperature suitability falloff | 20.0 K |

---

## Failure Conditions

| Condition | Trigger | AI Response |
|---|---|---|
| O₂ partial pressure < 16.0 kPa (dome) | Any tick | Critical halt; life support weight 1,000 overrides all |
| CO₂ partial pressure > 4.0 kPa | Any tick | Emergency scrubbing; construction halted |
| Morale collapse | Resource ratio < `STARVATION_THRESHOLD = 0.5` for 10+ ticks | `MORALE_DECLINE_RATE = 0.05` per tick |
| Population death | Resource ratio < 0.5 sustained | `DEATH_RATE = 0.1` applied |
| Wormhole collapse | Age > `WORMHOLE_MAX_AGE = 30.days` or stabilizer failure | Supply chain disruption; reroute required |
| Economic death spiral | Negative-margin loop detected | `EconomyEngine.settle_cycle` blocks; manual intervention required |

---

## Spec Coverage Targets

This scenario exercises the following spec domains. Ensure passing coverage before declaring the scenario stable:

- `AtmosphereProcessor` — pressure accumulation, CO₂ emergency trigger, greenhouse factor application
- `WormholeManager` — generation chance, stabilizer compliance, max-age collapse
- `EconomyEngine` — debt-before-expansion settlement order, negative-margin block
- `SimulationRunner` — AI priority stack order under critical resource shortage
- `BiosphereSimulation` — delta rate progression, biome cap enforcement
- `HumanLifeSupport` — per-person consumption under population load

---

*Last verified against: `config/initializers/game_constants.rb` — Phase 3 (Integration & Restoration)*
