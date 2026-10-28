> **Wiki section:** Player · **Status:** design + constants-oriented — confirm constants and processors against current code

# Atmospheric Harvesting

> **Cross-link:** For the pre-player-era infrastructure routing that governs *how* harvested volatiles reach settlements, see **[Station Construction & Logistics Pipeline (Pre-Player Era)](./infrastructure/pre_player_era_logistics_pipeline.md)**. All transport routes are gated behind the Mars cycler hub network; Titan-analog atmospheric delivery to Luna/Earth is not supported.

> **Cross-link:** All atmospheric extraction yields and rates are bounded by planetary protection classes defined in **[Planetary Protection & Environmental Governance](./planetary_protection_environmental_governance.md)**. Specifically: Class-1 bodies (e.g., Titan) enforce a 5% total volatile extraction cap relative to initial atmospheric/surface mass; Class-2 bodies (e.g., Venus Option B) are uncapped but subject to standard market limits and physical Δv constraints. These caps are **TARGET DESIGN INTENT ONLY** — no runtime enforcement currently exists in the codebase.

> **Scope:** Extraction and transport economics for harvesting atmospheric gases from off-world sources (Venusian nitrogen, CO₂ splitting, O₂/CNT synthesis, noble gases, volatiles) and integrating them into colony atmospheric engineering pipelines. All figures derived from `EARTH_ATMOSPHERE` baseline composition and `GREENHOUSE_FACTORS` scaling indices.

---

## Design Philosophy

Atmospheric harvesting is the long-game supply chain — the alternative to perpetual Earth imports at `INITIAL_TRANSPORTATION_COST_PER_KG = 1,320.00 USD/kg`. For nitrogen-poor colonies (Super-Mars, deep-belt outposts), establishing a **Venusian-analog** or **Mars-cycler-hub-terminated** harvesting pipeline is the primary path to economic independence and terraforming viability.

The goal is always to drive the effective cost-per-kg of atmospheric gas below the Earth import ceiling while maintaining breathability targets relative to `EARTH_ATMOSPHERE` baselines.

---

## Earth Atmosphere Baseline Reference

All atmospheric engineering targets scale against the following canonical composition from `EARTH_ATMOSPHERE`:

### Full Composition (Planet Generation Reference)

| Gas | Symbol | Earth % | Common Name | Notes |
|---|---|---|---|---|
| Nitrogen | N₂ | 78.08% | Nitrogen | Primary harvesting target |
| Oxygen | O₂ | 20.95% | Oxygen | Electrolytic or photosynthetic production |
| Argon | Ar | 0.93% | Argon | Noble gas; asteroid/comet source |
| Carbon Dioxide | CO₂ | 0.04% | Carbon Dioxide | Greenhouse agent; tightly managed |
| Water Vapor | H₂O | 0.25% | Water Vapor | Variable; surface liquid water dependent |

### Simplified Engineering Mix

For bulk atmospheric calculations (gas injection volumes, pressure targets, transport loads):

| Gas | Fraction |
|---|---|
| N₂ | 0.78 |
| O₂ | 0.21 |
| Ar | 0.01 |

### Physical Reference Parameters

| Parameter | Value | Unit |
|---|---|---|
| Total atmospheric mass (Earth) | 5.15 × 10¹⁸ | kg |
| Surface pressure | 101,325 | Pa |
| Scale height | 8.5 | km |
| Average gas constant | 287.05 | J/(kg·K) |

---

## Breathability Constraints

Harvested gas injections must be managed to maintain colony atmosphere within safe breathability bounds:

| Parameter | Minimum | Maximum | Unit |
|---|---|---|---|
| O₂ percentage | 19.5% | 23.5% | % |
| CO₂ percentage | — | 0.5% | % (long-term) |
| CO percentage | — | 0.0035% | % |
| O₂ partial pressure (human survival) | 16.0 | — | kPa |
| CO₂ partial pressure (long-term limit) | — | 1.0 | kPa |
| CO₂ partial pressure (emergency limit) | — | 4.0 | kPa |
| Minimum total pressure (no suit) | 33.0 | — | kPa |

> **Critical:** Any automated harvesting injection script must run atmospheric balance checks against these constraints before committing gas to the colony atmosphere. Breaching `max_co2_partial_pressure = 1.0 kPa` triggers `AtmosphereProcessor` emergency scrubbing; breaching `emergency_co2_limit = 4.0 kPa` halts all non-life-support AI tasks.

---

## Gas Source Profiles

### Mars-Cycler-Hub Volatile Source (Primary N₂ Supply)

Volatile deliveries to the Mars cycler hub (Phobos/Deimos relay stations) from outer-system sources provide the richest accessible nitrogen and methane feeds for deep-space colonies. Harvesting profile:

| Parameter | Value |
|---|---|
| Primary yield | N₂ (~95% purity pre-processing, post-cycler separation) |
| Secondary yield | CH₄ (processed out or used as greenhouse agent) |
| Delivery method | Mars cycler hub routing only — no direct Titan-to-Luna/Earth transport |
| Hub separation point | Outer-world volatiles enter the hub; N₂ and CH₄ fractions split at Phobos relay |
| Gravity (cycler-interface) | Phobos: ~0.003 m/s²; Deimos: ~0.002 m/s² (negligible) |

**Economic profile:** Low extraction delta-v from outer-system sources, but significant transport cost per kg due to distance. Mars cycler hub transit cycles amortize tanker construction costs over 3–5 runs before reaching break-even against Earth import (`1,320.00 USD/kg`). Once the cycler network locks (Phase 4), marginal transport cost declines.

**Greenhouse risk:** CH₄ fraction in raw outer-world harvest has `GREENHOUSE_FACTORS` weight of `25.0`. Scrub before injection or account for warming contribution explicitly. Uncontrolled CH₄ injection during cold-start terraforming can be intentional; during breathable-atmosphere maintenance it is a liability.

---

### Venusian-Analog Source (N₂ + CO₂ Mix — Self-Sufficiency Baseline)

Venusian-analog bodies have dense, hot atmospheres with high CO₂ fractions. Harvesting is more complex but provides the **critical carbon and nitrogen** feeds that Luna cannot produce on its own. Under the self-sufficiency baseline, Venus operations serve three integrated pathways:

1. **CO₂ splitting (electrolytic or thermochemical):** Releases O₂ for life support and leaves elemental carbon for CNT/slag composite structures.
2. **Sabatier methanation with Lunar H₂:** Venusian CO₂ is shipped to Lunar PSR refineries where it combines with hydrogen extracted from water ice via the Sabatier reaction: `CO₂ + 4H₂ → CH₄ + 2H₂O`. The resulting **Methalox (CH₄/LOX) propellant** fuels the early HLT fleet and fills LEO/L1 depot networks.
3. **N₂ extraction for life support:** Atmospheric skimming captures trace N₂ (~3.5% of Venusian atmosphere); combined with O₂ from CO₂ splitting it provides breathable gas mixes for Lunar and orbital habitats.

Saturn-derived H₂ import may supplement or replace Lunar PSR hydrogen in later phases, but **all Carbon feedstock must originate from Venusian atmospheric skimming** — no Titan-analog carbon delivery is permitted under the self-sufficiency baseline.

| Parameter | Value |
|---|---|
| Primary yield | CO₂ (~96%) + N₂ (~3.5%) raw mix; O₂ via post-harvest splitting |
| Surface pressure | ~90× `EARTH_PRESSURE` = ~9,000,000 Pa |
| Surface temperature | ~735 K (far above `temperature_max = 303.15 K`) |
| Extraction method | High-altitude aerostatic platforms; atmospheric skimming |
| Processing requirement | CO₂/N₂ separation → O₂ release → Sabatier methanation with Lunar H₂ |

**Economic profile:** Extreme extraction complexity. Suitable only for colonies with established orbital infrastructure and aerostatic platform technology. The CO₂ yield, however, has a `GREENHOUSE_FACTORS` multiplier of `20.0` — making Venusian-analog CO₂ the most cost-effective planetary warming agent when injected deliberately into a cold target world.

**Separation cost:** Processing raw Venusian-analog gas to usable N₂ purity adds significant overhead. Model at 2–3× the base `INITIAL_TRANSPORTATION_COST_PER_KG` for processed N₂ until orbital separation plants reach scale.

---

### Asteroid/Comet Volatile Source (Ar, H₂O, CO₂, trace gases)

Carbonaceous chondrites and cometary bodies provide the broadest volatile mix. Best used for:
- Argon (Ar) injection to reach the `0.93%` Earth baseline (inert buffer gas)
- H₂O ice (surface delivery for liquid water seeding, electrolysis O₂ production)
- CO₂ (supplementary greenhouse warming)

| Gas | `GREENHOUSE_FACTORS` Weight | Harvesting Priority |
|---|---|---|
| CO₂ | 20.0 | High — warming + pH buffering |
| CH₄ | 25.0 | Medium — warming only; scrub for breathable phase |
| N₂O | 298.0 | Low volume, high leverage — precise dosing required |
| H₂O | 12.0 | High — liquid water precursor + natural feedback |
| O₃ | 2,000.0 | Trace only — UV shield; photochemical production preferred |

---

## Transport Economics

### Cost Benchmark

| Supply Source | Effective Cost vs. Earth Import | Notes |
|---|---|---|
| Earth Import | `1,320.00 USD/kg` (baseline ceiling) | `INITIAL_TRANSPORTATION_COST_PER_KG` |
| Mars-cycler-hub N₂ (processed at relay) | ~400–800 USD/kg (established pipeline) | Distance-dependent; amortizes over transit cycles through hub |
| Venusian-analog N₂ (processed) | ~2,640–3,960 USD/kg | Only viable for CO₂ harvest; N₂ is byproduct |
| Asteroid volatile haul | ~200–600 USD/kg | Highly variable by delta-v and belt proximity |
| Local electrolytic O₂ (from H₂O ice) | ~50–150 USD/kg equivalent | Best long-term O₂ source; power-limited |

> **GCC/USD note:** All costs denominated in USD. At `GCC_TO_USD_INITIAL = 1.0`, GCC values are 1:1 during the bootstrap phase. As the in-game economy develops, the exchange rate will drift; all long-term supply contracts should be denominated in GCC with a USD floor clause.

### Storage Capacity Constraints

Harvested gas enters colony storage before atmospheric injection. Storage is worker-limited:

- `STORAGE_WORKERS_RATIO = 0.1` — 10% of population allocated to storage operations
- `STORAGE_CAPACITY_PER_WORKER = 1,000 kg` per worker

**Example — 1,000-person colony:**
- 100 storage workers
- Maximum buffer: **100,000 kg** of harvested gas before atmospheric processing

For large-scale terraforming injection events (bulk N₂ dumps from a tanker delivery), temporary storage overflow must be routed directly to atmospheric injection — bypassing the standard storage buffer with an explicit override. Do not let tanker deliveries queue behind the standard `EconomyEngine.settle_cycle` storage settlement.

---

## Atmospheric Injection Calculations

### Ideal Gas Law Reference

All injection volume calculations use:

```
PV = nRT
```

Where:
- `P` = pressure (Pa)
- `V` = volume (m³)
- `n` = moles of gas
- `R` = `IDEAL_GAS_CONSTANT = 8.31446 J/(mol·K)`
- `T` = temperature (K); default colony interior `DEFAULT_TEMPERATURE = 288.15 K`

For bulk atmosphere mass calculations:

```
P = ρ × R_specific × T
```

Where `R_specific = EARTH_ATMOSPHERE[:average_gas_constant] = 287.05 J/(kg·K)` for Earth-composition air. Adjust proportionally for non-Earth mix ratios.

### Standard Conditions Reference

| Parameter | Value | Constant |
|---|---|---|
| Standard temperature | 293.15 K (20°C) | `STANDARD_TEMPERATURE` |
| Standard pressure | 101,325 Pa | `STANDARD_PRESSURE_PA` |
| Standard pressure | 1.0 atm | `STANDARD_PRESSURE_ATM` |
| Standard pressure | 101.3 kPa | `STANDARD_PRESSURE_KPA` |

Use `IDEAL_GAS_CONSTANT_L_ATM = 0.0821 L·atm/(mol·K)` when working in liters and atmospheres (some legacy atmospheric calculation paths use this unit set).

---

## Greenhouse Warming Integration

When harvested gases are used for terraforming warming rather than breathable atmosphere composition, the `GREENHOUSE_FACTORS` weights determine dosing precision:

| Gas | GWP × CO₂ | Dosing Implication |
|---|---|---|
| CO₂ | 20.0 | Large-volume injection; bulk tanker delivery |
| CH₄ | 25.0 | Moderate volume; monitor for breathable-phase crossover |
| N₂O | 298.0 | Micro-dose only; 1 kg N₂O ≡ 298 kg CO₂-equivalent warming |
| H₂O | 12.0 | Self-regulating once liquid water cycle exists |
| O₃ | 2,000.0 | Photochemical production preferred over direct injection |

> **Phase boundary rule:** Greenhouse injection protocols must switch from *warming-phase* to *breathable-maintenance-phase* parameters before the colony transitions from pressure suits to open-environment operations. `AtmosphereProcessor.run_maintenance` enforces breathability constraints at all times — temporary terraforming overrides must be logged with an explicit phase flag, not suppressed silently.

---

## Integration with AI Priority Stack

Atmospheric harvesting supply chain expenditure falls under:

- **`resource_procurement: 500`** — acquisition of gas feedstock (contracts, tanker missions)
- **`atmospheric_maintenance: 900`** — emergency top-up of life support gases (near-critical override)
- **`expansion: 100`** — new harvesting platform construction (lowest priority; always deferred during critical states)

The AI will not authorize new harvesting platform construction (`expansion: 100`) while any life support metric (`life_support: 1000`) or atmospheric maintenance metric (`atmospheric_maintenance: 900`) is in a degraded state. Players should pre-fund platform construction before triggering any resource shortage that elevates the critical priority stack.

---

*Last verified against: `config/initializers/game_constants.rb` — Phase 3 (Integration & Restoration)*
