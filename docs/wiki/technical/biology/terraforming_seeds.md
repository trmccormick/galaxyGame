# Terraforming Seeds — Technical Reference

> **Wiki section:** Technical · Biology · **Status:** target design — Seed mechanics, stages, and Bio-Nursery Dome categories.  
> **Architectural source:** [`TERRAFORMING_SEED_AND_LIFE_DIRECTION.md`](../../../architecture/biology/TERRAFORMING_SEED_AND_LIFE_DIRECTION.md) (authoritative intent), `biology_models.md` (data model).

---

## 1. Core Distinctions — Seed vs Worldhouse

Both Terraforming Seeds and Worldhouses share **construction technology** (shell structure, power generation, life-support systems) but serve fundamentally different purposes and cost tiers.

### Comparison Table

| Attribute | Terraforming Seed | Worldhouse |
|-----------|-------------------|------------|
| **Purpose** | Active surface inoculation — adapt basic life and gradually affect the planetary biosphere. | High-control human-rated habitat — support desired life under local gravity. |
| **Primary effect on planet** | Changes planetary baseline (atmosphere, soil, temperature) over time. | Does not primarily change the planetary baseline; operates within existing conditions. |
| **Cost tier** | Cheaper than even a small Worldhouse. Lowest-cost terraforming entry point. | High-cost construction project for human settlement or complex biosphere containment. |
| **Size** | Small construction project footprint; minimal shell volume. | Larger engineered habitat with full environmental control. |
| **Gravity adaptation** | Respects local gravity (no artificial gravity assumed); operates within gravity constraints. | Respects local gravity; adapted for human-rated operations under same constraint. |
| **Surface access** | Designed to eventually release/adapt organisms into the open biosphere. | Sealed habitat; life remains contained within dome. |
| **Deployment speed** | Faster construction due to smaller scale and shared payload systems. | Longer construction timeline due to full environmental control requirements. |
| **Player interaction** | Background-facing; visible via AI Manager market orders and settlement options. | Background-facing; visible via AI Manager market orders. |
| **Biosphere integration** | Actively contributes terraforming effects each simulation step (O₂ production, soil improvement). | Passive from planetary perspective; contains life but does not modify biosphere directly. |

### Shared Construction Components

Both structures use overlapping infrastructure:

| Component | Seed Use | Worldhouse Use |
|-----------|----------|----------------|
| Structural shell panels | Yes — smaller variant. | Yes — full-scale. |
| Power generation array | Yes — scaled down. | Yes — full capacity for human-rated systems. |
| Life-support modules | Yes — basic (atmosphere recirculation, minimal habitat). | Yes — full life support for crew and complex biosphere. |
| Thermal regulation system | Yes — simpler variant. | Yes — precise temperature control required. |

### When to Use Each

- **Choose a Terraforming Seed** when: the planet has liquid water (Phase 4 gate passed), the goal is gradual atmospheric/soil improvement, or budget constraints require the lowest terraforming cost entry point.
- **Choose a Worldhouse** when: human-rated containment habitat is needed, complex life must be protected from harsh local conditions, or planetary baseline cannot yet support open biosphere deployment.

---

## 2. Staged Progression — Seed Payload Lifecycle

Terraforming Seeds operate through **staged progression**, where each stage deploys specialized payloads that adapt organisms and contribute increasingly to the biosphere.

### Stage Overview

| Stage | Description | Payload Type | Biosphere Effect |
|-------|-------------|--------------|------------------|
| **Stage 1 — Pioneer** | Deploy basic Earth life adapted from known minimal needs. | Cyanobacteria, nitrogen fixers, hardy lichen. | O₂ production begins; atmospheric N₂ starts enriching. Soil quality delta: +0.5–1/year. |
| **Stage 2 — Expansion** | Adapt pioneer organisms to local conditions; expand coverage. | Environmentally-adapted pioneers (simple 0→1 adaptation progress). | Increased terraforming rates; biosphere effect scales with adaptive gain. Soil quality delta: +1–2/year. |
| **Stage 3 — Diversification** | Introduce specialized functional groups (decomposers, consumers). | Decomposers, herbivores adapted to Stage 2 conditions. | Food web establishes; soil quality improves faster via organic matter cycling. Biodiversity score begins rising. |
| **Stage 4 — Stabilization** | Multi-trophic ecosystem achieves stable coverage (>30% of viable cells). | Carnivores, full decomposer networks, moisture-retaining organisms. | Biosphere reaches moderate diversity (H' ≥ 1.0); self-sustaining cycles begin. AI Manager benefit score increases significantly. |
| **Stage 5 — Integration** | Seed releases adapted organisms into the open biosphere; transitions from contained to active terraforming. | Hybrid packages (native/hybrid trait extraction available later). | Full terraforming effect on planetary baseline; atmospheric changes accelerate; biome transition triggers fire across cells. |

### Per-Stage Adaptation Tracking

Inside each Seed stage, adaptation progress is tracked as a **simple 0→1 value**:

```ruby
seed.adaptation_progress = 0.0..1.0
# 0.0 = organism matches baseline Earth template
# 1.0 = organism fully adapted to local conditions
# Progress driven by environmental stepping: each simulation year where
#   the organism survives in-place, adaptation progress increments by a small amount.
```

Environmental stepping means the organism experiences incremental local condition changes (temperature fluctuations, pressure shifts, radiation exposure) that accumulate toward full adaptation.

---

## 3. Bio-Nursery Dome Categories

Bio-Nursery Domes are the **physical infrastructure** where Seed payloads are incubated and adapted before release. Each category is optimized for a specific planetary environment.

### Category Definitions

| Dome Type | Optimal Environment | Terraforming Rate Multiplier | Specialized Payloads |
|-----------|---------------------|------------------------------|----------------------|
| **Lowland Aquifer Dome** | Region with existing `state_distribution['liquid']` concentration (subsurface or surface aquifers). | ×1.5 for all terraforming effects in that region. | Moisture-dependent organisms, photosynthesizers, decomposers. |
| **Volcanic Slope Dome** | High-elevation volcanic terrain; warm substrate despite thin atmosphere. | ×1.2 for temperature-sensitive adaptations (speeds Stage 1→2). | Thermophilic organisms, heat-resistant pioneers, mineral-processing microbes. |
| **Regolith Scrubbing Dome** | Barren regolith regions with no liquid water; focuses on soil preparation. | ×1.0 baseline; specializes in pre-biotic soil generation (pre-livestock terraforming). | Chemoautotrophs, regolith-breaking organisms, CO₂ concentrators. |

### Selection Logic for AI Manager

The Digital Twin evaluates which dome type to construct based on:

1. **Available regions** matching the dome's environmental criteria (liquid water presence, elevation/terrain class, regolith composition).
2. **Cost efficiency** — each dome type has a different GCC cost; the AI Manager compares cost-per-tile-of-terraforming-effect.
3. **Stage gating** — Lowland Aquifer Domes can only be placed after the liquid water trigger fires (Phase 4 gate). Regolith Scrubbing Domes can be deployed before liquid water exists.
4. **Synergy with brute-force projects** — Volcanic Slope Domes benefit from atmospherically thickened regions near their launch points; Regolith Scrubbing Domes pair well with orbital mirror warming.

---

## 4. Adaptation Pipelines — Top-Down vs Bottom-Up

### Top-Down Pipeline (Human-Directed)

The AI Manager **directly designs** organisms by specifying target traits:

```ruby
# Example: engineer a custom organism for Mars conditions
mars_organism = Biology::LifeForm.engineer_from_template(
  template: Biology::LifeFormLibrary.nitrogen_fixers,
  modifications: {
    name: "Mars-Optimized Nitrogen Fixer",
    designer: "Human Terraforming Corps",
    n_multiplier: 3.0,           # 3x nitrogen fixation rate
    min_temp: 90.0,              # Survives Titan/Mars cold
    max_temp: 200.0,
    required_gases: ['N2', 'CH4']  # Adapted for thin atmosphere with methane traces
  }
)
```

**When used:** Targeted terraforming of specific regions, overcoming known limiting factors (temperature, gas composition, soil toxicity).  
**Speed:** Faster adaptation because traits are pre-specified.  
**Cost:** Higher due to design and engineering overhead.  
**Risk:** Lower — the AI Manager knows exactly what it is deploying.

### Bottom-Up Pipeline (Environmental Selection)

Organisms are deployed with baseline Earth properties and **adapt naturally** through environmental pressure over time:

```ruby
# Example: deploy basic cyanobacteria at a Seed; let adaptation happen naturally
cyano = Biology::LifeFormLibrary.cyanobacteria
deployment = biosphere.deploy_life_form(cyano, initial_coverage: 5.0)

# Each simulation year where the organism survives:
#   deployment.life_form.adaptation_progress += environmental_stepping_rate
#   terraforming_rates *= (1 + adaptation_progress * local_condition_benefit_factor)
```

**When used:** Broad exploration of what can survive, cost-sensitive deployments, initial Seed stages.  
**Speed:** Slower — depends on environmental stepping accumulation inside the Seed (simple 0→1 value).  
**Cost:** Lower — no engineering overhead; organisms are off-the-shelf library entries.  
**Risk:** Higher — adaptation outcomes are uncertain; some populations may die before adapting.

### Pipeline Choice in Digital Twin Projections

The AI Manager evaluates which pipeline to use for each Seed stage:

| Criterion | Top-Down Preferred | Bottom-Up Preferred |
|-----------|-------------------|---------------------|
| Known limiting factors | ✅ Yes (targeted fix) | ❌ No (blind adaptation) |
| Budget constraint | ❌ Higher cost | ✅ Lower cost |
| Time urgency | ✅ Faster adaptation | ❌ Slower, gradual |
| Uncertain environment | ❌ Risk of mis-specification | ✅ Discovers viable traits organically |
| Later stages (4–5) | ✅ Trait refinement for stabilization/integration | ❌ Not efficient at scale |

---

## 5. AI Manager Digital Twin — Seed Projection Output

When the AI Manager runs a Digital Twin projection for a Terraforming Seed, it produces the following output per candidate project:

| Output Field | Type | Description |
|-------------|------|-------------|
| `resource_cost_over_time` | `Hash{year => GCC}` | Yearly resource/GCC cost breakdown. |
| `energy_cost_over_time` | `Hash{year => energy_units}` | Yearly energy demand breakdown. |
| `timeline_to_milestones` | `Array<Struct{name:, year:}>` | Predicted years for each seed stage milestone (Stage 1 complete, Stage 2 adaptation ≥0.5, etc.). |
| `planetary_benefit_score` | `Float` | Weighted score from atmospheric change, soil improvement, biodiversity gain, and habitability increase. |
| `residual_risk` | `Struct{undetected_life:, contamination:, adaptation_uncertainty:}` | Three-component risk assessment for the projection. |
| `contamination_class_at_completion` | `Symbol` | Projected final contamination class (Class-0 through Class-4) if Seed proceeds to release. |
| `confidence` | `Float` | 0.0–1.0 confidence in the projection reliability (decreases with detection_confidence < 1.0 and contamination_risk_level). |

### Ranking Logic

Projects are ranked by:

```
rank_score = planetary_benefit_score / resource_cost_over_time['total']
# Higher benefit per GCC spent = higher rank

# Adjusted by risk and confidence:
rank_score *= (1 - residual_risk.undetected_life_weight)
rank_score *= (1 - residual_risk.contamination_weight)
rank_score *= confidence
```

The AI Manager posts market orders for the **highest-ranked project** — whether that is a Terraforming Seed, Worldhouse, atmospheric intervention, or orbital asset.

---

## 6. Uncertainty & Containment Framework

### Sterility Proof and Residual Risk

Sterility of a planet can **never be proven**, only assessed with confidence:

| Detection Confidence | Residual Undetected Life Risk | Implication |
|---------------------|-------------------------------|-------------|
| 0% (no detection attempted) | Maximum — all projections penalized heavily. | AI Manager defaults to brute-force or high-cost containment. |
| 25–75% (moderate survey) | Moderate — proportional penalty on benefit scores. | Seed projects compete with brute-force under same GCC/timeline criteria. |
| 75–95% (extensive survey) | Low–Moderate — manageable risk factor in rankings. | Seeds become more competitive against brute-force. |
| 95–100% (comprehensive survey) | Near-zero but **never zero** — permanent contamination floor. | Seeds strongly favored for terraforming projects. |

### Contamination Risk Reduction

Contamination risk is permanent and can only be **reduced** (not eliminated):

| Protocol Tier | Cost Impact | Risk Reduction | Description |
|--------------|-------------|----------------|-------------|
| Class-0 (minimal) | None | Baseline — no reduction. | Default; no containment beyond standard operational protocols. |
| Class-1 (basic) | Low (+5–10% Seed cost) | Minor reduction in contamination probability. | Standard biosafety seals, sterilization of all incoming materials. |
| Class-2 (enhanced) | Moderate (+15–25% Seed cost) | Moderate reduction; suitable for early Seed stages. | Full sterilization, HEPA filtration, positive pressure maintenance. |
| Class-3 (strict) | High (+30–40% Seed cost) | Significant reduction; required before Stage 4+ release. | Isolation chambers, genetic screening of all payloads. |
| Class-4 (maximum) | Very high (+50–60% Seed cost) | Maximum achievable reduction — **not zero**. | Complete hermetic containment, independent life-support per organism batch. |

> **Key principle:** No protocol tier reduces contamination risk to zero. The permanent uncertainty factor always applies as a downward adjustment to Digital Twin confidence scores and planetary benefit projections.

---

## 7. Brute-Force vs Biological Terraforming Trade-Off

The AI Manager must compare biological (Seed) and brute-force options under the same GCC, timeline, benefit, and residual-risk criteria:

| Factor | Seed Path (Biological) | Brute-Force Path |
|--------|----------------------|------------------|
| **Upfront cost** | Low (per-order gas/material buys) | High (mass drivers, CNT plants, cracking arrays) |
| **Ongoing cost** | Continuous GCC drain for recurring orders | Lower per-unit cost after infrastructure built |
| **Speed of effect** | Gradual, ongoing across Seed stages | Rapid pulses once operational |
| **Adaptation timeline** | Required (0→1 adaptation inside Seeds) | Not applicable |
| **Residual biological risk** | Present — contamination, undetected life, adaptation uncertainty | Absent (no biological agents deployed) |
| **Planning flexibility** | Stage gates provide checkpoint visibility | Binary: not built / operational |
| **Long-term sustainability** | Self-sustaining biosphere eventually reduces dependency | Ongoing industrial and import dependence |
