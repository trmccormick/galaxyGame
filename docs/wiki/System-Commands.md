# System Commands

> **Scope:** Technical reference for the four core Rails console commands that orchestrate Galaxy Game's primary simulation loops. Each command must be invoked deliberately — never chained blindly or automated without explicit test coverage confirming the current spec baseline.

---

## Documentation Mandate

All simulation-driving commands are subject to the project's contribution guardrails:

- **No blind `git add .`** before or after running simulation commands that alter seed/state data.
- Console outputs that reveal new constant drift or unexpected state transitions **must be documented** before committing.
- If a command exposes a regression in the ~393 failing specs, open a tracking issue immediately — do not paper over it with a seed reset.

---

## Command Reference

### 1. `SimulationRunner.tick`

**Purpose:** Advances the game world by one simulation tick. This is the heartbeat of the entire engine — atmospheric models, biosphere deltas, AI decision trees, and logistics queues all evaluate against the current tick.

**Invocation:**
```ruby
SimulationRunner.tick
```

**What it orchestrates:**
- Evaluates `AI_PRIORITIES` weight matrix against current colony state (Life Support → Atmospheric Maintenance → Debt Repayment → Resource Procurement → Construction → Expansion)
- Applies `MORALE_DECLINE_RATE = 0.05` and `DEATH_RATE = 0.1` if resource thresholds fall below `STARVATION_THRESHOLD = 0.5`
- Advances biosphere state via `BIOSPHERE_SIMULATION` delta rates (plant growth, moisture, biome area, temperature)
- Triggers wormhole age checks against `WORMHOLE_MAX_AGE = 30.days`

**Guardrails:**
- Will not run if `MIN_RESOURCE_THRESHOLD = 0.8` is unmet and life support priority (`1000`) cannot be satisfied — simulation halts with a logged critical alert.
- Emits a warning if any colony's oxygen partial pressure approaches `min_oxygen_partial_pressure = 16.0 kPa`.

---

### 2. `WormholeManager.generate_cycle`

**Purpose:** Executes one wormhole generation cycle for all eligible solar systems. Runs on a `WORMHOLE_GENERATION_INTERVAL = 24.hours` cadence in production; call manually in console for testing.

**Invocation:**
```ruby
WormholeManager.generate_cycle
```

**What it orchestrates:**
- Iterates eligible systems and rolls `WORMHOLE_GENERATION_CHANCE = 0.3` (30%) per system
- Caps new wormholes at `MAX_NEW_WORMHOLES_PER_CYCLE = 5` globally per cycle
- Enforces `MAX_WORMHOLES_PER_SYSTEM = 3` hard ceiling
- Assigns destination type: `NEW_SYSTEM_PROBABILITY = 0.4` (40% intra-galaxy new system), `NEW_GALAXY_PROBABILITY = 0.2` (20% inter-galaxy)
- Validates that generated wormhole endpoints satisfy spatial constraints:
  - Must be beyond `SAFE_DISTANCE_FROM_STAR = 1.496e8 m` (1 AU)
  - Must be within `MAX_DISTANCE_FROM_STAR = 1.496e10 m` (100 AU)

**Guardrails:**
- Wormholes older than `WORMHOLE_MAX_AGE = 30.days` are flagged for collapse before new ones generate.
- Stabilizer checks: `MIN_STABILIZERS_REQUIRED = 2`, each operating above `MIN_STABILIZER_POWER = 25` and within `STABILIZER_EFFECTIVE_RANGE = 100.0` spatial units of the wormhole endpoint.

---

### 3. `AtmosphereProcessor.run_maintenance`

**Purpose:** Runs the scheduled atmospheric maintenance pass across all active colonies. Corresponds to the AI priority weight `atmospheric_maintenance: 900` — second only to life support in the criticality stack.

**Invocation:**
```ruby
AtmosphereProcessor.run_maintenance
```

**What it orchestrates:**
- Recalculates atmospheric composition deltas against `EARTH_ATMOSPHERE` baselines:
  - Target O₂ band: `19.5% – 23.5%`
  - CO₂ ceiling: `0.5%` (long-term), emergency trigger at `max_co2_partial_pressure = 1.0 kPa`
- Applies `GREENHOUSE_FACTORS` scaling to any greenhouse gas accumulation:
  - CO₂ × 20.0, CH₄ × 25.0, N₂O × 298.0, H₂O × 12.0, O₃ × 2000.0
- Uses `IDEAL_GAS_CONSTANT = 8.31446 J/(mol·K)` for pressure-volume-temperature calculations
- References `EARTH_ATMOSPHERE[:average_gas_constant] = 287.05 J/(kg·K)` for bulk atmosphere modeling
- Checks colony pressure against `min_pressure_for_survival = 33.0 kPa` floor

**Guardrails:**
- If CO₂ partial pressure exceeds `emergency_co2_limit = 4.0 kPa`, the processor raises a critical alert and halts non-essential construction AI tasks (priority weight: `300`).
- Temperature must remain within `temperature_min = 283.15 K` to `temperature_max = 303.15 K`; optimal target is `294.15 K (21°C)`.

---

### 4. `EconomyEngine.settle_cycle`

**Purpose:** Runs the financial settlement pass — processes courier contract payouts, NPC board procurement, debt servicing, and GCC/USD accounting. Corresponds to `debt_repayment: 800` in the AI priority stack.

**Invocation:**
```ruby
EconomyEngine.settle_cycle
```

**What it orchestrates:**
- Settles all open courier contracts (see `docs/wiki/Logistics-and-Hauling.md` for contract lifecycle detail)
- Posts Earth import transactions at `INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00 USD/kg`
- Applies current GCC/USD exchange rate (bootstrapped at `GCC_TO_USD_INITIAL = 1.0`)
- Runs the negative-margin verification hook — any AI trading routine that would produce a negative-margin outcome is blocked and logged before settlement

**Guardrails:**
- Debt repayment is processed before any operational procurement (`resource_procurement: 500`) or construction (`construction: 300`) expenditure.
- Settlement will not execute if the verification hook detects a negative-margin loop; the cycle errors out with a full trade log for inspection.
- Resource consumption rates per person are validated against: Food `= 2 units`, Water `= 1 unit`, Energy `= 3 units` per tick before cost settlement.

---

## Maintenance Intervals Summary

| Command | Production Cadence | Manual Console Trigger |
|---|---|---|
| `SimulationRunner.tick` | Per game tick | `SimulationRunner.tick` |
| `WormholeManager.generate_cycle` | Every 24 hours | `WormholeManager.generate_cycle` |
| `AtmosphereProcessor.run_maintenance` | Every 1 hour | `AtmosphereProcessor.run_maintenance` |
| `EconomyEngine.settle_cycle` | Per financial period | `EconomyEngine.settle_cycle` |

> The `WORMHOLE_MAINTENANCE_INTERVAL = 1.hour` stabilizer health check runs independently of `generate_cycle` and does not create new wormholes — it only validates existing stabilizer power and range compliance.

---

*Last verified against: `config/initializers/game_constants.rb` — Phase 3 (Integration & Restoration)*
