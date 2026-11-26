# Terraforming Seeds — Technical Reference
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* Design intent specification. Code implementation pending or unverified as of audit baseline.

> **Status:** DESIGN INTENT — Seed mechanics, stages, and Bio-Nursery concepts; detailed thresholds remain unverified against code.  
> **Page role:** Possible biological deployment and development concepts. For source-verified behavior, see [Celestial-Body Sphere Models & Environmental Interactions](../sphere_models_and_interactions.md); for proposed simulation architecture, see [Biosphere Simulation](./biosphere_simulation.md).  
> **Harvest sources (frozen, non-authoritative):** `docs/architecture/biology/TERRAFORMING_SEED_AND_LIFE_DIRECTION.md`, `biology_models.md`. Owner-confirmed direction on this page and [Biology & Terraforming — Wiki Hub](./README.md) takes precedence over frozen documents.

---

## Owner-Confirmed Direction — Initial Simple-Life Use on Mars

The current planning assumption is that simple life will be found and that simple life will be used as part of Mars's initial terraforming. Treat this as an established working direction for scenario and strategic planning, not as proof that the discovery, selection, deployment, or resulting environmental effects are already implemented or validated.

The initial use of simple life has value independently of any eventual full terraforming outcome. Full planetary terraforming may never be pursued to completion, so the initial biological work must not be framed as merely the first step of an inevitable Stage 1–5 progression toward a fully transformed world. Keep the early scope practical and focused on simple organisms and their useful initial contribution.

More advanced ecosystem development, genetic engineering, hybrid organisms, and later-stage biosphere integration remain available directions. They are not prerequisites for the initial Mars use case and can be resumed when needed. Existing code, experiments, and tests should be preserved so that later work continues from the current foundation rather than being discarded or restarted.

This owner-confirmed direction does not validate the detailed stage thresholds, adaptation rates, liquid-water gates, or quantitative effects elsewhere on this page. Those remain subject to implementation review and further design confirmation.

## Framing note — stages vs initial simple-life use

The Stage 1–5 table below is historical/candidate design, not a required progression or campaign track. The initial simple-life contribution has value without completing all stages, and full planetary terraforming is not guaranteed or required. **OPEN:** whether the current Stage 1 definition, or any single stage, fully captures the intended initial simple-life use; do not assume Stage 1 is sufficient. Detailed rates, gates, and costs remain unverified design proposals unless separately confirmed against code and owner direction.

---

## 1. Structure, Use, and Terraforming-Seed Programs

A **Worldhouse is a physical structure**: an engineered, pressurized environmental volume built around or within a suitable geological feature. A **terraforming seed is a planned biological use or program**, not a competing structure type. It describes what people intend to do with suitable infrastructure and biological systems to contribute to a world's biosphere.

**ESTABLISHED INTENT — 2026-11-26:** A Worldhouse can itself host or serve a terraforming-seed program and can be mixed use. However, human habitation is not an inherent Worldhouse requirement. A Worldhouse is a sealed environmental volume whose atmospheric composition is selected for its intended operating environment.

A **human-rated Worldhouse** can combine human habitation with research, biological incubation, contained ecosystem development, and seed-program activities when its design and internal organization support them. A **non-human-rated Worldhouse** may instead use an industrial, experimental, biological, or other target atmosphere. It may be dedicated to one purpose or combine only purposes compatible with that atmosphere. Mixed use is therefore conditional on the selected environment; it does not imply that every function can coexist in one undivided volume.

### Keep the Design Layers Distinct

| Layer | What it describes | Examples |
|---|---|---|
| **Structure** | The physical asset that is constructed. | Worldhouse, another suitable enclosed facility, or a collection of facilities. |
| **Use / mission purpose** | What the structure or facility is intended to do. | Human habitation, research, biological incubation, ecosystem development, terraforming-seed program. |
| **Biological program** | The organisms and processes being hosted, studied, adapted, or prepared. | Simple-life work, adaptation, incubation, ecological development. |
| **Internal organization** | How the structure supports multiple uses safely and practically. | Shared utilities, dedicated zones, environmental separation, containment boundaries, independent controls where needed. |
| **Planetary interaction** | Whether contained activity is deliberately connected to the external environment. | Continued containment, controlled exchange, or an intentional release operation. |

These layers should not be collapsed into a single Seed/Worldhouse choice. A Worldhouse may be human-rated, non-human-rated, or configured for another target environment; it may be dedicated to one purpose or mixed use. A Seed program may use a Worldhouse, a Bio-Nursery hosted within one, another suitable structure, or multiple facilities. Not every Worldhouse has a terraforming-seed purpose, and a seed program does not inherently require a Worldhouse.

### Atmospheric Profile and Mixed-Use Worldhouses

Atmospheric composition is a selected operating profile, not an intrinsic property of a Worldhouse. The structure is defined by its sealed environmental volume; the target atmosphere is chosen according to its intended uses. A human-rated atmosphere is one possible profile, not the default.

Mixed use is an ordinary supported design possibility, not an exception or separate Worldhouse subtype. A human-rated Worldhouse may combine habitation, research, biological incubation, contained ecosystem development, and seed-program work. A non-human-rated Worldhouse may also be mixed use, but only among purposes compatible with its selected atmosphere and operating conditions; it may instead be dedicated to a single industrial, biological, experimental, or other purpose.

Functions may share structural systems, power, and environmental processing where appropriate. Where their requirements differ, the internal design may need distinct zones, environmental conditions, access rules, containment boundaries, or dedicated systems. The exact zoning model and engineering requirements remain to be established. Do not assume every function needs a fully independent life-support plant, or that all functions can safely share one undivided volume.

A Worldhouse's role should therefore be described by its target environmental profile, configured uses, and internal organization—not by assigning it one exclusive label such as "habitat" or "Seed."

### Containment and Planetary Effects

A sealed Worldhouse creates a local environment. Organisms and biological processes inside it do not automatically alter the external planetary atmosphere or open biosphere. The contained environment and the planetary biosphere must remain distinct in the model.

A seed program hosted in a Worldhouse may incubate, adapt, research, or prepare organisms for a possible later interaction with the external environment. Any deliberate release or external coupling is a separate operation with its own environmental and biosafety considerations. Mixed use does not itself imply release, and human occupancy does not automatically make a Worldhouse a terraforming project.

### Bio-Nurseries and Shared Infrastructure

A Bio-Nursery describes a biological incubation/adaptation capability and may be implemented as a standalone facility or hosted within a suitable larger structure, including a mixed-use Worldhouse. It is not automatically a separate structure class or a mandatory component of every seed program.

Structural shell, power, environmental control, life support, and containment are infrastructure capabilities that may be shared or separated according to the actual uses and risks. The exact equipment packages, zoning, facility taxonomy, costs, and boundaries remain unresolved.

For contamination and containment principles, see [Contamination & Biosafety](../../infrastructure/contamination_and_biosafety.md). For the structural and environmental boundary of Worldhouses, retain the distinction between local enclosed conditions and planetary-scale sphere changes.

## 2. Staged Progression — Seed Payload Lifecycle

The stages below are a historical/candidate design for a possible Seed payload lifecycle, not a required progression. Early stages may be used without proceeding to later stages; completing Stages 1–5 is not required to obtain initial simple-life value.

> **Proposal status:** Quantitative effects, rates, and gates in the table are unverified design proposals. Stage 5 is optional late design, not a prerequisite for initial simple-life contribution.

Terraforming Seeds are described here through a staged payload concept, where stages deploy specialized payloads that may adapt organisms and contribute to the biosphere.

### Stage Overview

| Stage | Description | Payload Type | Biosphere Effect |
|-------|-------------|--------------|------------------|
| **Stage 1 — Pioneer** | Deploy basic Earth life adapted from known minimal needs. | Cyanobacteria, nitrogen fixers, hardy lichen. | O₂ production begins; atmospheric N₂ starts enriching. Soil quality delta: +0.5–1/year. |
| **Stage 2 — Expansion** | Adapt pioneer organisms to local conditions; expand coverage. | Environmentally-adapted pioneers (simple 0→1 adaptation progress). | Increased terraforming rates; biosphere effect scales with adaptive gain. Soil quality delta: +1–2/year. |
| **Stage 3 — Diversification** | Introduce specialized functional groups (decomposers, consumers). | Decomposers, herbivores adapted to Stage 2 conditions. | Food web establishes; soil quality improves faster via organic matter cycling. Biodiversity score begins rising. |
| **Stage 4 — Stabilization** | Multi-trophic ecosystem achieves stable coverage (>30% of viable cells). | Carnivores, full decomposer networks, moisture-retaining organisms. | Biosphere reaches moderate diversity (H' ≥ 1.0); self-sustaining cycles begin. AI Manager benefit score increases significantly. |
| **Stage 5 — Integration** | Seed releases adapted organisms into the open biosphere; transitions from contained to active terraforming. | Hybrid packages (native/hybrid trait extraction available later). | Candidate late design: stronger coupling to the planetary baseline only if that path is chosen. It is not required for the initial simple-life contribution, and a full planetary outcome is not assumed. |

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

## 3. Bio-Nursery Facility Concepts

The following dome categories are historical/candidate physical-facility concepts for incubation and adaptation. They are possible infrastructure used by a seed program, not definitions of what a Seed is. A Bio-Nursery capability may be standalone or hosted within a suitable mixed-use Worldhouse. The specific facility form and environmental separation depend on the program and are not finalized.

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
3. **Stage gating (proposed/unresolved)** — The historical design proposed placing Lowland Aquifer Domes after a liquid-water trigger (Phase 4 gate), while Regolith Scrubbing Domes could be deployed before liquid water exists. This gate is not confirmed; do not treat it as blocking all simple-life applications without further review.
4. **Synergy with brute-force projects** — Volcanic Slope Domes benefit from atmospherically thickened regions near their launch points; Regolith Scrubbing Domes pair well with orbital mirror warming.

---

## 4. Adaptation Pipelines — Top-Down vs Bottom-Up

### Top-Down Pipeline (Human-Directed)

The AI Manager or a human-directed biological program **directly designs** organisms by specifying target traits:

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

The biological program evaluates which pipeline to use for each selected stage or activity:

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

The AI Manager posts market orders for the **highest-ranked project** — whether that is a biological program and its required infrastructure, a Worldhouse with one or more uses, an atmospheric intervention, or an orbital asset.

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

> **Unverified design proposal:** The historical percentage cost impacts below are retained for reference; they are not verified costs or implemented mechanics. A dedicated `contamination_and_biosafety.md` page is **OPEN** (the referenced file is not present in the active wiki). See [Planetary Protection & Environmental Governance](../../infrastructure/planetary_protection_environmental_governance.md) for the related broader governance context.

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
| **Long-term sustainability** | Possible if the biological path is continued and succeeds; not guaranteed. Initial simple-life use does not require a self-sustaining global biosphere. | Ongoing industrial and import dependence |
