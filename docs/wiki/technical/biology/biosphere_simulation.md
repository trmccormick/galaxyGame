# Biosphere Simulation Technical Reference

> **Wiki section:** Technical · Biology · **Status:** target design — simulation interface, state gates, and scoring formulas.  
> **Architectural source:** [`docs/architecture/biology/terrasim_service.md`](../../../architecture/biology/terrasim_service.md), [`biology_models.md`](../../../architecture/biology/biology_models.md).

---

## 1. Liquid Water Trigger — Phase 3 → Phase 4 State Gate

Before Terraforming Seeds or Worldhouses can operate on a planet's surface (Phase 4), liquid water must be present in the global hydrosphere model. This is the **hard biological/physical state gate** between Bio-Nursery Dome establishment (Phase 3) and active terraforming deployment (Phase 4).

### Required Conditions

| Parameter | Threshold | Notes |
|-----------|-----------|-------|
| **Surface temperature** | ≥ 273 K | At minimum pressure point; localized patches may be sufficient if globally averaged meets threshold. |
| **Surface pressure** | ≥ 611 Pa (triple-point pressure of water) | Below this, water sublimates directly from ice to vapor. |
| **Hydrosphere state distribution** | `state_distribution['liquid'] > 0` | The global hydrosphere model must report non-zero liquid fraction in at least one region. |

### Transition Logic

```
if surface_temp ≥ 273 K
   and pressure ≥ 611 Pa
   and biosphere.hydrosphere.state_distribution['liquid'] > 0
then
   planet.unlocked_phases << :terraform_seeds
   planet.unlocked_phases << :worldhouses
end
```

### Practical Implications

- A planet at 273 K but with pressure < 611 Pa (e.g., Mars highlands) has **no liquid water** and cannot progress to Phase 4.
- Orbital mirrors, atmospheric thickening (brute-force), or greenhouse gas injection are common methods to push a world past this gate.
- Once the trigger fires, the AI Manager posts market orders for Terraforming Seeds or Worldhouses via its Digital Twin ranking system.

---

## 2. BiosphereSimulationService Interface

### Purpose

`BiosphereSimulationService` simulates biosphere conditions, ecosystem interactions, food webs, and atmospheric influence from life forms at each simulation timestep (typically one game year).

### Primary Methods

```ruby
# Apply terraforming effects over a time delta (in game years)
biosphere.apply_terraforming_effects(time_delta_years:)

# Calculate habitability for a specific life form deployment
biosphere.habitability_for(life_form_deployment)

# Get current O₂ production rate (kg/year)
biosphere.oxygen_production_rate

# Get current soil quality score (0–100)
biosphere.soil_quality

# Get biodiversity index
biosphere.biodiversity_score

# Deploy a life form to this biosphere at initial coverage %
biosphere.deploy_life_form(life_form, initial_coverage:)

# Update deployment status and coverage based on habitability
deployment.update_status_and_coverage(habitability)

# Check active deployments
biosphere.life_form_deployments.active
```

### Simulation Step Order (per TerraSim tick)

1. **Geosphere** updates — terrain, elevation changes.
2. **Hydrosphere** updates — phase transitions, temperature-driven state shifts.
3. **Atmosphere** updates — gas composition, pressure changes.
4. **Biosphere** updates — life form effects applied in dependency order:
   a. Photosynthetic organisms → O₂/CO₂ exchange.
   b. Nitrogen fixers → atmospheric N₂ enrichment.
   c. Soil-forming organisms → soil quality improvement.
5. **BiomeValidator** re-runs — checks if biome placements remain valid against new environmental state.

---

## 3. Ecosystem Interaction Rules

### Food Web Dynamics

Life forms interact through **dietary requirements** and **ecological roles**:

| Role | Effect on Biosphere |
|------|---------------------|
| **Photosynthesizer** | Produces O₂, consumes CO₂; rate scales with coverage %. |
| **Nitrogen Fixer** | Converts atmospheric N₂ into bioavailable forms; improves soil quality. |
| **Decomposer** | Breaks down biomass waste; recycles nutrients to soil. |
| **Consumer (Herbivore/Omnivore)** | Requires existing producer coverage ≥ threshold%; consumes biomass at defined rate. |
| **Predator (Carnivore)** | Requires consumer coverage ≥ threshold%; controls prey populations. |

### Dependency Rules

- Consumers **cannot be deployed** until producer coverage meets their dietary requirement (e.g., herbivores require photosynthesizer coverage ≥ 10%).
- Predators **cannot be deployed** until consumer coverage meets their dietary requirement.
- If conditions no longer support a trophic level, those life forms enter the `struggling` status and eventually transition to `extinct`.

### Atmospheric Influence Per Life Form

Each deployment contributes per-year:

```ruby
{
  o2_change_kg:          life_form.o2_per_year * deployment.coverage_fraction,
  co2_change_kg:         life_form.co2_per_year * deployment.coverage_fraction,
  n2_change_kg:          life_form.n2_fixation_rate * deployment.coverage_fraction,
  soil_quality_delta:    life_form.soil_improvement_rate * deployment.coverage_fraction
}
```

---

## 4. Soil Quality Formula

Soil quality is a composite score from **0 (barren regolith) to 100 (Earth-analog fertile soil)**.

### Components

| Component | Weight | Source |
|-----------|:------:|--------|
| Organic matter content | 40% | Decomposer coverage, biomass turnover rate. |
| Nitrogen availability | 25% | Nitrogen fixer coverage, atmospheric N₂ enrichment. |
| Moisture retention | 20% | Proximity to liquid water, biome rainfall characteristics. |
| Mineral composition | 15% | Parent regolith material (geosphere base). |

### Formula

```
soil_quality = min(100, sum(components))

organic_matter  = decomposer_coverage_fraction × turnover_rate × organic_yield_factor × 0.4
nitrogen_avail  = n2_fixer_coverage_fraction × n2_conversion_rate × 0.25
moisture_retain = liquid_water_adjacent_cells / total_cells × rainfall_factor × 0.20
mineral_base    = geosphere.regolith.mineral_complexity_score × 0.15
```

### Update Rate

Soil quality changes incrementally per simulation year:

```ruby
new_soil_quality = current_soil_quality + soil_quality_delta
# Delta is clamped to ±2 per year (prevents unrealistic jumps)
soil_quality_delta = [min(2, delta), max(-2, delta)].first
```

---

## 5. Biodiversity Scoring

Biodiversity score reflects **species richness** (number of distinct life forms) weighted by **evenness** (distribution balance across the biosphere).

### Shannon Diversity Index (Simplified)

```
H' = -Σ(pi × ln(pi))

where pi = coverage_fraction of species i
      sum over all active species in the biosphere
```

### Score Mapping

| H' value | Biodiversity Score | Interpretation |
|----------|-------------------|----------------|
| 0.0 – 0.5 | Very Low | Dominated by single pioneer species (e.g., only cyanobacteria). |
| 0.5 – 1.0 | Low | Few specialists; ecosystem is fragile. |
| 1.0 – 1.8 | Moderate | Multiple trophic levels beginning to establish. |
| 1.8 – 2.5 | High | Stable multi-species ecosystem with redundancy. |
| 2.5+ | Very High | Complex, resilient biosphere (Earth-analog range). |

### Score Application in Digital Twin Projections

Biodiversity score feeds the **planetary benefit** metric in AI Manager rankings:

```
benefit_score_from_biodiversity = biodiversity_score × habitat_quality_weight
# habitat_quality_weight scales with soil quality and liquid water presence
```

Higher biodiversity → higher benefit → more attractive to AI Manager for ranking.

---

## 6. Life Form Deployment Lifecycle

### Status Transitions

| Current Status | Transition To | Trigger |
|---------------|---------------|---------|
| `thriving` | `stable` | Habitability drops below 90% threshold but remains above 70%. |
| `stable` | `thriving` | Habitability rises above 90% (environmental improvement). |
| `stable` | `struggling` | Habitability drops below 70% threshold. |
| `struggling` | `dying` | Coverage drops below 10% of initial deployment or habitability < 40%. |
| `struggling` | `thriving` | Environmental restoration pushes habitability above 90%. |
| `dying` | `extinct` | Coverage reaches 0% or habitat quality falls below survival minimum. |
| `extinct` | _(none)_ | Permanent removal from simulation (unless re-deployed). |

### Limiting Factors Tracking

Each deployment records its current limiting factors:

```ruby
{
  limiting_factors: [
    "temperature_below_minimum",
    "pressure_insufficient_for_photosynthesis",
    "soil_toxicity_too_high",
    "uv_radiation_excessive"
  ],
  adaptation_progress: 0.0..1.0,  # simple 0→1 value inside Seed stages
  coverage_percent: 5.0,          # percentage of biosphere area covered
  status: "stable"
}
```

---

## 7. BiomeValidator Integration

The BiomeValidator re-runs each simulation step to ensure biome placements remain valid against new environmental conditions.

### Validation Rules (per cell in the planetary grid)

| Condition | Required Biome Range | Action on Violation |
|-----------|---------------------|---------------------|
| Temperature | Within `biome.temperature_range` (Kelvin) | Reclassify cell to adjacent biome or set as `transitioning`. |
| Rainfall/Humidity | Within `biome.humidity_range` | Update cell biome; if crossing class boundaries (e.g., forest → plains), flag biosphere for notification. |
| Elevation | Terrain feature must be compatible with biome type | Mountains cannot host ocean biome regardless of temp/humidity. |

### Biome Transition Triggers

When terraforming effects shift a biome's viable region, the validator produces a transition:

```ruby
biome.transition! from: :desert to: :plains if
  temperature >= 280 && rainfall >= 300 && previous_biome == :desert
```

All active life form deployments on transitioning cells are flagged for `update_status_and_coverage`.

---

## 8. Random Factor — Unknown Life Events

Per the Terraforming Seeds direction document, undetected native life introduces permanent uncertainty into terraforming projections.

### Event Trigger

- Checked during each simulation step where `detection_confidence < 1.0`.
- Probability increases as `1.0 - detection_confidence` (e.g., 50% confidence → base probability scales accordingly).
- When triggered, the event runs lightweight sequencing and comparison against deployed life forms.

### Possible Outcomes

| Outcome | Effect on Biosphere | Probability Weight |
|---------|---------------------|-------------------|
| **No effect** | Native life is sterile or non-interacting. | Highest (base case). |
| **Minor planned-style change** | Native organism contributes unexpected terraforming effect (e.g., bonus N₂ fixation). | Low–Moderate. |
| **Interference** | Native life competes with deployed organisms; coverage degradation. | Moderate. |
| **Rare useful trait discovery** | Native organism provides genetic material for hybrid engineering later. | Very low. |

### Contamination Risk — Permanent Factor

- Contamination risk is **permanent and can never reach zero**.
- Can be reduced (but not eliminated) through higher-cost biosafety protocols.
- Protocol tiers are documented in `contamination_and_biosafety.md`.
- This residual factor directly reduces Digital Twin projection confidence scores.

---

## 9. Simulation State Vector (Digital Twin)

The Digital Twin maintains a **cloned state vector** of each planet for what-if projections:

| Field | Type | Description |
|-------|------|-------------|
| `temperature_grid` | `2D Array[float]` | Per-cell surface temperature in Kelvin. |
| `pressure_grid` | `2D Array[float]` | Per-cell atmospheric pressure in Pascals. |
| `hydrosphere.state_distribution` | `Hash{String => Float}` | Phase fractions: `{'ice' => 0.65, 'liquid' => 0.10, 'vapor' => 0.25}`. |
| `atmosphere.composition` | `Hash{String => Float}` | Gas fractions: `{'CO2' => 0.95, 'N2' => 0.02, 'O2' => 0.01, ...}`. |
| `soil_quality_grid` | `2D Array[float]` | Per-cell soil quality score (0–100). |
| `biome_grid` | `2D Array[Symbol]` | Per-cell biome type (e.g., `:desert`, `:plains`). |
| `life_form_deployments` | `Array<LifeFormDeployment>` | Active deployments with coverage %, status, limiting factors. |
| `detection_confidence` | `Float` | 0.0–1.0 confidence that no native life exists (sterility proof). |
| `contamination_risk_level` | `Symbol` | Current contamination risk class (Class-0 through Class-4). |
| `biodiversity_score` | `Float` | Aggregated Shannon index across the biosphere. |

This state vector is cloned and mutated during Digital Twin projections to produce cost/benefit/risk rankings for AI Manager market orders.
