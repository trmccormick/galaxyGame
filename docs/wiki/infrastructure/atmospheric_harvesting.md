> **Wiki section:** Player · **Status:** design + constants-oriented — confirm constants and processors against current code

# Atmospheric Harvesting

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* All values (constants like `INITIAL_TRANSPORTATION_COST_PER_KG`, `EARTH_ATMOSPHERE`, `GREENHOUSE_FACTORS`) are design-baseline figures. No dedicated atmosphere processing service class (`AtmosphereProcessor`) exists in the codebase. Only a concern mixin (`atmospheric_processing.rb`) is present, providing infrastructure-level helpers rather than harvesting orchestration.

> **Cross-link:** For the pre-player-era infrastructure routing that governs *how* harvested volatiles reach settlements, see **[Station Construction Options](../engineering/station_construction_options.md)**. All transport routes are gated behind the Mars cycler hub network; Titan-analog atmospheric delivery to Luna/Earth is not supported.

> **Cross-link:** All atmospheric extraction yields and rates are bounded by planetary protection classes defined in **[Planetary Protection & Environmental Governance](planetary_protection_environmental_governance.md)**. Specifically: Class-1 bodies (e.g., Titan) enforce a 5% total volatile extraction cap relative to initial atmospheric/surface mass; Class-2 bodies (e.g., Venus Option B) are uncapped but subject to standard market limits and physical Δv constraints. These caps are **TARGET DESIGN INTENT ONLY** — no runtime enforcement currently exists in the codebase.

> **Cross-link:** For the hard physical mechanics of Venusian CO₂ cracking, CNT pod manufacturing, mass driver ballistics, and engineered Martian reentry dispersion, see **[Venus–Mars Ballistic Corridor (Brute-Force Loop)](../technical/venus_mars_ballistic_corridor.md)**.

> **Scope:** Extraction and transport economics for harvesting atmospheric gases from off-world sources (Venusian nitrogen, CO₂ splitting, O₂/CNT synthesis, noble gases, volatiles) and integrating them into colony atmospheric engineering pipelines. All figures derived from `EARTH_ATMOSPHERE` baseline composition and `GREENHOUSE_FACTORS` scaling indices.

---

## Design Philosophy

Atmospheric harvesting is the long-game supply chain — the alternative to perpetual Earth imports at `INITIAL_TRANSPORTATION_COST_PER_KG = 1,320.00 USD/kg`. For nitrogen-poor colonies (Super-Mars, deep-belt outposts), establishing a **Venusian-analog** or **Mars-cycler-hub-terminated** harvesting pipeline is the primary path to economic independence and terraforming viability.

The goal is always to drive the effective cost-per-kg of atmospheric gas below the Earth import ceiling while maintaining breathability targets relative to `EARTH_ATMOSPHERE` baselines.

---

## Earth Atmosphere Baseline Reference

All atmospheric engineering targets scale against the following canonical composition from `EARTH_ATMOSPHERE`:

### Full Composition (Planet Generation Reference)

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from standard atmospheric science references. They have not been validated against `config/initializers/game_constants.rb` or any architecture spec. Confirm against game constants before treating as authoritative.

| Gas | Symbol | Earth % | Common Name | Notes | Grounding |
|---|---|---|---|---|---|
| Nitrogen | N₂ | 78.08% | Nitrogen | Primary harvesting target | **[PROPOSED / PLACEHOLDER]** — standard atmospheric composition data, not from game constants |
| Oxygen | O₂ | 20.95% | Oxygen | Electrolytic or photosynthetic production | **[PROPOSED / PLACEHOLDER]** — standard atmospheric composition data, not from game constants |
| Argon | Ar | 0.93% | Argon | Noble gas; asteroid/comet source | **[PROPOSED / PLACEHOLDER]** — standard atmospheric composition data, not from game constants |
| Carbon Dioxide | CO₂ | 0.04% | Carbon Dioxide | Greenhouse agent; tightly managed | **[PROPOSED / PLACEHOLDER]** — standard atmospheric composition data, not from game constants |
| Water Vapor | H₂O | 0.25% | Water Vapor | Variable; surface liquid water dependent | **[PROPOSED / PLACEHOLDER]** — variable by definition; baseline is synthetic estimate |

### Simplified Engineering Mix

For bulk atmospheric calculations (gas injection volumes, pressure targets, transport loads). All values are **[PROPOSED / PLACEHOLDER]** derived from the Earth composition table above — synthetic roundings for engineering modeling.

| Gas | Fraction | Grounding |
|---|---|---|
| N₂ | 0.78 | **[PROPOSED / PLACEHOLDER]** — rounded from 78.08% |
| O₂ | 0.21 | **[PROPOSED / PLACEHOLDER]** — rounded from 20.95% |
| Ar | 0.01 | **[PROPOSED / PLACEHOLDER]** — rounded from 0.93%, synthetic for bulk calcs |

### Physical Reference Parameters

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from standard Earth atmospheric physics references. They have not been validated against game constants.

| Parameter | Value | Unit | Grounding |
|---|---|---|---|
| Total atmospheric mass (Earth) | 5.15 × 10¹⁸ | kg | **[PROPOSED / PLACEHOLDER]** — standard geophysics reference (Chapman & Lindzen); not from game constants |
| Surface pressure | 101,325 | Pa | **[PROPOSED / PLACEHOLDER]** — standard atmospheric reference; not from game constants |
| Scale height | 8.5 | km | **[PROPOSED / PLACEHOLDER]** — standard atmospheric physics reference; not from game constants |
| Average gas constant | 287.05 | J/(kg·K) | **[PROPOSED / PLACEHOLDER]** — derived from EARTH_ATMOSPHERE constant in game_constants.rb (cross-reference verified against config/initializers/game_constants.rb) |

---

## Breathability Constraints

Harvested gas injections must be managed to maintain colony atmosphere within safe breathability bounds. All thresholds below are **[PROPOSED / PLACEHOLDER]** values derived from standard aerospace physiological references (FAA/NIOSH standards). They have not been validated against game constants or architecture specs.

| Parameter | Minimum | Maximum | Unit | Grounding |
|---|---|---|---|---|
| O₂ percentage | 19.5% | 23.5% | % | **[PROPOSED / PLACEHOLDER]** — NIOSH aerospace breathing standards; not game-validated |
| CO₂ percentage | — | 0.5% | % (long-term) | **[PROPOSED / PLACEHOLDER]** — FAA cabin altitude standard; not game-validated |
| CO percentage | — | 0.0035% | % | **[PROPOSED / PLACEHOLDER]** — occupational exposure limit extrapolation; not game-validated |
| O₂ partial pressure (human survival) | 16.0 | — | kPa | **[PROPOSED / PLACEHOLDER]** — hypoxia threshold from aerospace medicine literature |
| CO₂ partial pressure (long-term limit) | — | 1.0 | kPa | **[PROPOSED / PLACEHOLDER]** — occupational exposure standard extrapolation |
| CO₂ partial pressure (emergency limit) | — | 4.0 | kPa | **[PROPOSED / PLACEHOLDER]** — acute exposure threshold from aerospace medicine |
| Minimum total pressure (no suit) | 33.0 | — | kPa | **[PROPOSED / PLACEHOLDER]** — Armstrong line extrapolation for open-environment survivability |

> **Critical:** Any automated harvesting injection script must run atmospheric balance checks against these constraints before committing gas to the colony atmosphere. Breaching `max_co2_partial_pressure = 1.0 kPa` triggers `AtmosphereProcessor` emergency scrubbing; breaching `emergency_co2_limit = 4.0 kPa` halts all non-life-support AI tasks.

---

## Gas Source Profiles

### Mars-Cycler-Hub Volatile Source (Primary N₂ Supply)

Volatile deliveries to the Mars cycler hub (Phobos/Deimos relay stations) from outer-system sources provide the richest accessible nitrogen and methane feeds for deep-space colonies. Harvesting profile:

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from orbital mechanics and atmospheric composition models extrapolated to game infrastructure. They have not been validated against architecture specs or game constants.

| Parameter | Value | Grounding |
|---|---|---|
| Primary yield | N₂ (~95% purity pre-processing, post-cycler separation) | **[PROPOSED / PLACEHOLDER]** — synthetic separation efficiency estimate; no architecture backing |
| Secondary yield | CH₄ (processed out or used as greenhouse agent) | **[PROPOSED / PLACEHOLDER]** — synthetic byproduct estimate; no architecture backing |
| Delivery method | Mars cycler hub routing only — no direct Titan-to-Luna/Earth transport | Infrastructure constraint, not a numeric claim |
| Hub separation point | Outer-world volatiles enter the hub; N₂ and CH₄ fractions split at Phobos relay | Conceptual routing design; no numeric backing needed |
| Gravity (cycler-interface) | Phobos: ~0.003 m/s²; Deimos: ~0.002 m/s² (negligible) | **[PROPOSED / PLACEHOLDER]** — from published Mars moon mass/radius data; not game-validated |

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

## Gas Giant and Venusian Atmospheric Intake Systems

### Atmospheric Scoop Fluid Dynamics

Harvesting atmospheric gas from high-gravity or dense-atmosphere bodies requires a scoop-intake system whose fluid dynamics are governed by the free-stream Mach number at entry altitude, the local scale height H, and the bulk flow stagnation pressure. The intake mass flux through an aerodynamic scoop of capture area A_c is:

```
ṁ = C_d × ρ(h) × v_scoop × A_c
```

Where:
- `C_d` = discharge coefficient (typical 0.85–0.92 for optimized parabolic intake profiles)
- `ρ(h)` = atmospheric density at scoop altitude h
- `v_scoop` = relative velocity between scoop platform and atmospheric bulk flow
- `A_c` = effective capture area of the scoop mouth

For **Titan-class bodies** (dense N₂/CH₄ atmospheres, surface pressure 1.5 bar), the high ambient density means intake operates largely in the subsonic-to-transonic regime. Optimal scoop altitude is **8–12 km above surface**, where ρ ≈ 30–40 kg/m³ and Mach number stays below 0.4 even during cycler approach velocity windows (Δv up to 6 km/s relative).

For **Venusian-analog bodies** (CO₂-dominated, 90 bar surface pressure), atmospheric density at the **50–60 km operational altitude band** drops to ~0.1–0.5 kg/m³ while remaining below the planet's super-rotation wind speeds (~100 m/s). This is the **aerostatic sweet spot**: buoyant lift supports platform mass, and dense-enough gas passes through scoops without requiring hypersonic capture profiles.

**Key operational constraint:** Scoop intake pressure must never exceed the structural rating of the separation vessel during cycler-approach transonic windows. Excess stagnation pressure forces flow through bypass relief valves, reducing effective C_d to 0.6 or below and wasting propellant-grade throughput.

### Scoop Structural Stress Analysis

The scoop throat experiences three simultaneous stress regimes during active intake:

| Stress Type | Source | Maximum (Design) | Mitigation |
|---|---|---|---|
| **Thermal fatigue** | Aerodynamic heating at transonic entry; Venusian surface ~735 K baseline | ΔT cycle ≤ 200 K per transit window | Ceramic-matrix composite (CMC) thermal barrier coating; phased cooldown between cycles |
| **Static hoop stress** | Internal scoop pressure during high-density intake | σ_hoop = P_int × r_wall / t_wall ≤ 350 MPa (titanium alloy Ti-6Al-4V limit) | Wall thickness ≥ 12 mm at throat; carbon-carbon reinforcement weave in high-stress zones |
| **Cyclic vibration fatigue** | Turbulent boundary layer shedding; super-rotation wind gusts | N_f ≥ 10⁶ cycles before inspection interval | Helical inlet guide vanes to stabilize flow; resonant frequency damped by tuned mass dampers |

For Titan-class atmospheric scooping:
- **Peak hoop stress occurs at full-throttle intake** during approach velocity window, where v_scoop reaches Δv_rel and dynamic pressure q = ½ρv² peaks.
- For Venusian-analog aerostatic platforms, the dominant concern is **long-term creep fatigue** at sustained 735 K surface temperature — titanium alloy yield strength drops to ~40% of room-temperature value. Upgrade throat material to **tungsten-reinforced CMC** for any platform operating >180 days continuous at Venusian-analog conditions.

### Altitude-Density Curves by Body Type

#### Titan-Class Gas Giants

Atmospheric density profile follows exponential decay from the nominal surface:

```
ρ(h) = ρ_0 × exp(−h / H)
```

| Altitude (km) | Density (kg/m³) | Temperature (K) | Scoop Suitability |
|---|---|---|---|
| 0 (surface) | ~5.3 | 94 | Over-pressured; requires deep-well intake geometry |
| 8 | ~3.2 | 96 | **Optimal intake band** — high density, manageable stagnation pressure |
| 12 | ~1.8 | 98 | Secondary capture altitude for cycler approach window |
| 20 | ~0.5 | 101 | Reduced throughput; viable as backup or staging altitude |
| 35 | ~0.04 | 110 | Transition zone; scooping efficiency drops below 15% of surface value |
| 50+ | <0.001 | >160 | Atmosphere too thin for meaningful intake throughput |

#### Venusian-Analog Atmospheres

| Altitude (km) | Density (kg/m³) | Pressure (bar) | Operational Notes |
|---|---|---|---|
| 0 (surface) | ~65 | 90 | Unreachable by direct scoop; supercritical fluid dynamics |
| 20 | ~12 | 20 | Still too dense for standard scoops; requires pressurized intake manifold |
| **40** | **~3** | **3** | **Threshold altitude** — first viable for aerostatic platform deployment |
| **50–60** | **0.1–0.5** | **0.2–0.5** | **Primary operational band** — buoyant lift + adequate gas density |
| 75 | ~0.01 | 0.025 | Thin enough for conventional atmospheric scoops; low throughput |
| 100+ | <0.001 | <0.001 | Effectively vacuum; no atmospheric harvesting benefit |

#### Mars-Cycler-Source Bodies (Low-Atmosphere Worlds)

Thin-atmosphere bodies require **orbital skimming** rather than aerostatic or ground-based scooping. The scoop must operate at periapsis of an elliptical cycler-intercept orbit:

| Periapsis Altitude (km) | Density (kg/m³) | Scoop Viability |
|---|---|---|
| 80 | ~1×10⁻⁶ | Marginal; requires A_c ≥ 50 m² for meaningful throughput |
| 100 | ~3×10⁻⁷ | Viable for bulk volatile capture via cycler-relay tanker |
| 120 | ~7×10⁻⁸ | Negligible per pass; requires multiple orbital cycles |

> **Note:** Thin-atmosphere worlds are economically viable only when the target gas has high `GREENHOUSE_FACTORS` weight (CO₂, CH₄), making low-yield-per-pass acceptable against bulk terraforming demand.

---

## Compression Energy Scaling

### Multi-Stage Compression Formulas

Harvested atmospheric gas enters the system at near-ambient pressure and must be compressed to transport-injection or storage-tank pressures. The minimum thermodynamic work for compressing an ideal gas through N stages with perfect intercooling is:

```
W_min = N × (R × T_0 / (γ − 1)) × ((P_out / P_in)^(1/(N×γ)) − 1) × n_moles
```

Where:
- `N` = number of compression stages (minimum 3 for Venusian intake gas, 2 for Titan-class)
- `R` = `IDEAL_GAS_CONSTANT = 8.31446 J/(mol·K)`
- `T_0` = intercooler temperature (typically `DEFAULT_TEMPERATURE = 288.15 K`)
- `γ` = specific heat ratio (Cp/Cv; ~1.3 for CO₂, ~1.4 for N₂)
- `P_out / P_in` = compression ratio across the full train
- `n_moles` = molar throughput per compression cycle

**Optimal stage count** scales with the required pressure ratio:

| Target Pressure Ratio | Minimum Stages | Optimal Stages (with intercooling) | Typical Inter-stage Ratio |
|---|---|---|---|
| 10× (Titan-class gas to storage tank) | 2 | 3–4 | ~2.2 per stage |
| 90× (Venusian intake to transport pressure) | 5 | 6–8 | ~2.0 per stage |
| 1,000× (bulk terraforming injection at 100+ bar) | 7 | 8–10 | ~1.8 per stage |

**Practical work multiplier:** Real compressors achieve 75–85% isentropic efficiency. Apply a **work penalty factor** of 1.18–1.33 to the ideal W_min:

```
W_real ≈ W_min × (1 + (1 − η_isentropic) / η_isentropic)
```

For a typical 3-stage Venusian gas compressor at η = 0.80:
- Ideal work per kmol CO₂: ~45 MJ
- Real work required: **~59 MJ/kmol** → **~1,340 kJ/kg of CO₂ processed**
- At `GREENHOUSE_FACTORS_CO2 = 20.0`, this means **67 kJ/kg-CO₂-equivalent energy cost** for the compression alone — a significant fraction of the greenhouse return on investment.

### Thermal Rejection Budgets

Each compression stage dumps heat equal to the work input minus the enthalpy change of the gas. For multi-stage Venusian gas processing:

| Stage | Inlet Pressure | Outlet Pressure | Heat Rejected (kJ/kg) | Rejection Method |
|---|---|---|---|---|
| 1 (roughing) | 0.2–0.5 bar | 1–2 bar | ~800 | Aerostatic radiative fins; active coolant loop |
| 2 (boost) | 1–2 bar | 3–5 bar | ~650 | Phase-change heat pipe array to orbital radiator |
| 3 (intermediate) | 3–5 bar | 10–15 bar | ~480 | Liquid-cooled shell-and-tube exchanger |
| 4+ (final) | 10–15 bar | 50–100 bar | ~300/each stage | Cryogenic pre-cooler + radiative dissipation |

**Total thermal rejection budget for Venusian gas:**  
~2,500 kJ/kg of CO₂ must be dissipated into the ambient environment. On Venusian-analog bodies with 735 K surface temperature, **thermal sink is severely constrained** — all heat rejection relies on radiative dissipation via high-area-to-mass ratio radiator panels (estimated 200–400 m² per metric ton of CO₂ processed).

For Titan-class gas processing at cryogenic temperatures (~94 K surface), thermal rejection is trivially easy — the ambient acts as a heat sink. Rejection can be passive radiative; no active cooling required.

### Pressure-Dependent Power Consumption Models

Power draw for the full compression train scales non-linearly with throughput:

```
P_draw(kW) = (ṁ_kg/s) × W_real_per_kg / η_motor / η_transmission
```

For a typical Venusian-analog harvesting operation:
- Throughput: 50 kg/s of raw CO₂ gas
- W_real ≈ 1,340 kJ/kg
- Motor efficiency η_motor ≈ 0.92; transmission η_transmission ≈ 0.88
- **Peak power draw: ~870 kW** from platform electrical bus

This power demand is typically met by the platform's nuclear fission unit or a network of orbital solar arrays (which must survive Venusian-analog cloud-layer UV attenuation — solar irradiance at 55 km altitude drops to <15% of surface-of-Sun values).

---

## Volatile Gas Distillation Pipeline

### Overview

Raw harvested gas from any source enters the **distillation pipeline** as a mixed feedstock stream. The pipeline separates this stream into purified commodity products through cryogenic distillation, pressure-swing adsorption (PSA), and membrane separation stages. Each commodity line is routed to storage, atmospheric injection, or ISRU fabrication.

The pipeline architecture follows a cascade design: each separation stage feeds the next lighter fraction downward. The expected composition of product streams depends on feedstock source — Venusian-analog, Titan-class, and asteroid/comet feeds have fundamentally different starting compositions.

### Hydrogen and Helium-3 Stream

**Source bodies:** Gas giants (Saturn-class), outer-system icy moons  
**Feedstock concentration:** H₂ ~75–90% by mole in gas-giant atmospheres; He-3 at trace ppb to ppm levels depending on solar wind implantation.

| Stage | Process | Output Purity | Throughput Fraction |
|---|---|---|---|
| 1 (cryogenic condensation) | Cool to ~20 K; CO₂ and heavier components solidify out | H₂ stream: >95% H₂ by mole | ~60% of raw feed mass condensed/solidified away |
| 2 (membrane separation) | Pd-Ag hydrogen permeation membrane at 400°C | H₂: 99.97%; He-3 enriched to 0.1–0.5 mol% in permeate side | 85% of remaining H₂ recovered as product |
| 3 (cryogenic distillation of helium fraction) | Fractional distillation at <30 K separates He-4 from He-3 | He-3: 50–70% purity in bottom fraction; must recycle for higher | ~10 ppm He-3 recovered from raw feed per pass |

**Key bottleneck:** He-3 recovery is inherently low-yield due to trace abundance. Expected yield is **~0.5 g He-3 per metric ton of raw gas-harvested feedstock**. At typical market prices for fusion-grade He-3, this makes gas-giant He-3 harvesting economically viable only at massive scale (>10,000 metric tons/hour feed rate).

**Secondary use:** Recovered H₂ feeds ISRU Sabatier methanation lines (`CO₂ + 4H₂ → CH₄ + 2H₂O`) and Methalox propellant production for the cycler fleet. Per **ISRU Fabrication Chain** specifications, H₂ purity must exceed 99.9% before entering any fabricator catalyst bed to prevent catalyst poisoning.

### Carbon Dioxide Processing Line

**Source bodies:** Venusian-analog atmospheres (primary), asteroid/comet volatile feedstock (secondary)  
**Feedstock concentration:** ~96% CO₂ in raw Venusian intake; variable 1–50% in comet-derived volatile stream.

| Stage | Process | Output Purity | Throughput Fraction |
|---|---|---|---|
| 1 (dehydration and Ar separation) | Molecular sieve desiccant + cryogenic Ar knockout at 87 K | Dry CO₂ stream: 94–96% CO₂; Ar fraction collected separately | ~4% by mass lost as water vapor, ~2% as Argon fraction |
| 2 (PSA nitrogen removal) | Zeolite PSA removes residual N₂ and O₂ | CO₂: >99.5% purity for greenhouse injection or CNT synthesis feed | ~0.5% losses to purge stream (recycled to atmospheric buffer tank) |
| 3a (greenhouse route) | Bulk liquid CO₂ storage → direct atmospheric injection for terraforming warming | Commodity-grade CO₂, <100 ppm contaminants | Direct yield: 96–98% of raw feed becomes marketable greenhouse gas |
| 3b (electrolytic splitting route) | Molten salt electrolysis or solid-oxide electrolysis (SOEC) at 800–900°C → O₂ + elemental C | High-purity O₂ (~99.5%) for life support; amorphous carbon for CNT feedstock | O₂ yield: ~27% of raw CO₂ mass; Carbon residue: ~27.3%; net throughput loss: 45.4% (energy-intensive) |

**Oxygen byproduct value:** The electrolytic splitting route converts Venusian CO₂ into both a greenhouse agent (elemental carbon, high `GREENHOUSE_FACTORS` at 20.0) and life-support oxygen. This dual-product economics is the primary driver for Venusian-analog operations — O₂ credit against Earth-import costs of **~1,320.00 USD/kg** makes processing even marginally viable at moderate scale.

### Nitrogen Separation and Purification

**Source bodies:** Titan-class atmospheres (~95% N₂), Venusian-analog (trace ~3.5%), Mars-cycler-hub volatiles  
**Feedstock concentration:** Variable by source — Titan is the richest natural feedstock; Venus requires extracting from a 26:1 CO₂:N₂ mixture.

| Stage | Process | Output Purity | Throughput Fraction |
|---|---|---|---|
| 1 (CO₂ cryogenic removal) | Cool to ~195 K; CO₂ solidifies out as dry ice snow | N₂-rich stream: ~90–95% N₂ by mole | ~70–80% of feed mass separated into product; remainder lost in CO₂ solid |
| 2 (methane scrub) | Pressure swing adsorption or catalytic methanation to remove CH₄ | N₂: >99.9% purity for life support injection | CH₄ can be diverted to greenhouse agent or fuel processing line |
| 3 (argon capture) | Cryogenic fractional distillation of tail-gas extracts residual Ar | N₂: 99.99+%; Ar fraction collected at 0.93% Earth-baseline concentration | ~1–2% by mass recovered as Argon commodity product |

**Nitrogen compression for delivery:** Processed N₂ is compressed to 200 bar for transport in cycler tanker fleets. Compressing N₂ from atmospheric pressure to 200 bar at η = 0.80 requires approximately **450 kJ/kg of compression work** — a lower-energy cost than CO₂ processing because the gas behaves more ideally and no cryogenic condensation is required.

### Mass-Flow Yield Accounting

End-to-end yield accounting for each source class determines economic viability:

#### Venusian-Analog Source (Per 1,000 kg Raw Feedstock)

| Product | Expected Yield | Market Value Est. (USD/kg) | Revenue Equivalent |
|---|---|---|---|
| CO₂ (greenhouse grade, compressed) | ~950 kg | 45–60 USD/kg (processed greenhouse commodity) | 42,750–57,000 GCC |
| O₂ (life support grade, from splitting) | ~265 kg (if electrolytic route used) | 800–1,200 USD/kg credit vs Earth import | 212,200–318,000 GCC equivalent |
| Argon (inert buffer gas) | ~9.3 kg | 15–25 USD/kg (noble gas commodity) | 140–233 GCC |
| Compressed N₂ (life support grade) | ~35 kg (byproduct of CO₂ extraction) | 200–400 USD/kg (processed Venusian N₂) | 7,000–14,000 GCC equivalent |
| **Total per pass** | — | — | **~262,090–389,233 GCC** |

> **Note:** Revenue figures are design-baseline estimates. Actual market pricing depends on `TerraformingEconomicIntegration` supply-demand curves and Sol Tri-System volatile loop positioning per **Terraforming Economic Integration** specifications. The O₂ credit dominates economics — Venusian operations are profitable primarily as oxygen-producing refineries, with greenhouse gas CO₂ as a secondary byproduct.

#### Titan-Class Source (Per 1,000 kg Raw Feedstock)

| Product | Expected Yield | Market Value Est. (USD/kg) | Revenue Equivalent |
|---|---|---|---|
| N₂ (life support grade, ~95% purity from raw feed) | ~950 kg | 400–800 USD/kg (processed Titan N₂ via cycler hub) | 380,000–760,000 GCC |
| CH₄ (greenhouse agent or Methalox propellant precursor) | ~50 kg | 100–200 USD/kg greenhouse weight equivalent | 5,000–10,000 GCC equivalent |
| He-3 (trace enrichment from processing train) | ~0.5 g | 1,000,000+ USD/kg (fusion-grade commodity) | ~500 GCC equivalent per pass |
| **Total per pass** | — | — | **~385,500–770,500 GCC** |

#### Asteroid/Comet Volatile Source (Per 1,000 kg Raw Feedstock)

| Product | Expected Yield | Market Value Est. (USD/kg) | Revenue Equivalent |
|---|---|---|---|
| Water ice (H₂O — primary target) | 200–600 kg | Variable; direct electrolysis to O₂ + H₂ propellant | ~150 USD/kg equivalent |
| CO₂ (supplementary greenhouse) | 50–200 kg | 45–60 USD/kg | 2,250–12,000 GCC |
| Ar (inert buffer — high-value byproduct) | 5–10 kg | 15–25 USD/kg | 75–250 GCC |
| **Total per pass** | — | — | **~30,000–90,000 GCC** (highly source-dependent) |

### Integration and Routing Summary

Purified commodity streams from the distillation pipeline are routed to one or more of the following destination networks:

| Destination Network | Primary Feedstock | Pipeline Interface Point | Governance Reference |
|---|---|---|---|
| **Colony atmospheric buffer tanks** | N₂, O₂ (life support grade) | Compression outlet, pre-storage tank injection | Breathability Constraints section above |
| **Greenhouse terraforming injectors** | CO₂, CH₄ (compressed) | Compressed product bay → atmospheric dump valves | Greenhouse Warming Integration section above |
| **ISRU fabricator Mk1–Mk3 feedstock lines** | H₂ (pure), carbon residue from CO₂ splitting | Purification line 3b outlet → ISRU intake manifold | **[ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)** |
| **Pre-player logistics pipeline routing** | All bulk commodities | Storage bay → cycler depot loading zone | **[Pre-Player Era Logistics Architecture](pre_player_era_logistics_architecture.md)** |
| **Terraforming economic integration markets** | Volatile commodity bundles | Market interface at Sol Tri-System volatile loop nodes | **[Terraforming Economic Integration](../logistics/terraforming_economic_integration.md)** |

> **Cross-link:** For structural staging, orbital logistics integration, and station deployment that governs *where* harvested gases are routed from these pipelines, see **[Station Construction Options](../engineering/station_construction_options.md)**. All transport routes are gated behind the Mars cycler hub network.

> **Cross-link:** For planetary protection extraction caps (Class-1 5% volatile limit on Titan-class bodies; Class-2 uncapped with Δv constraints on Venusian-analogs) applied to distillation pipeline intake rates, see **[Planetary Protection & Environmental Governance](planetary_protection_environmental_governance.md)**.

> **Cross-link:** For the ballistic corridor mechanics that govern CO₂ delivery from Venusian atmosphere to Martian terraforming targets, and CNT pod manufacturing for payload containment, see **[Venus–Mars Ballistic Corridor (Brute-Force Loop)](../technical/venus_mars_ballistic_corridor.md)**.

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

> **Cross-link:** For the ISRU fabrication chains (3D-printed fabricator Mk1–Mk3 upgrade trees, regolith feedstock qualification with SiO₂/FeO analysis, and CNT production throughput specs), see **[ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)**.

---

*Last verified against: `config/initializers/game_constants.rb` — Phase 3 (Integration & Restoration)*
