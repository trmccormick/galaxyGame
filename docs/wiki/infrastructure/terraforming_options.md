# Terraforming Options

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-05  
> *Audit Summary:* DRAFT extracted from a Gemini terraforming chat. Not yet reviewed by the owner or verified against code or frozen docs.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-05  
**Related**: [surface_habitat_options.md](surface_habitat_options.md), [power_options.md](power_options.md), [ai_manager_economic_loops.md](../logistics/ai_manager_economic_loops.md), settlement and logistics pages

This page is the wiki home for planetary-scale atmosphere modification options. Multiple pathways exist. A fast raw-gas pressure rise is primarily a **protection** measure for population and infrastructure. Traditional terraforming (climate and biosphere goals) and refined composition control are separate, later choices. Softer longer-horizon approaches remain available.

All content is **DIRECTION** or **OPEN** unless marked otherwise.

---

## Design Principles

1. Full traditional terraforming is optional and gated. Early footholds and surface habitats do not require a finished planetary atmosphere.
2. Raising ambient pressure can be pursued first as a protection and risk-reduction measure for people and infrastructure.
3. Multiple sourcing strategies exist. The AI Manager (and players) evaluate cost, time, capital, and risk.
4. Venus pressure relief and Mars volatile deficit form a natural pairing, but other sources (Titan, KBOs, local extraction) remain available.
5. Realistic logistics apply: boil-off, transit loss, alignment windows, fuel for skimmers, and infrastructure bootstrapping all matter.
6. Trade remains bidirectional even when mass flow is heavily one-way.

---

## Raw Atmospheric Gas Transfer (Pressure-First Protection)

**DIRECTION**

A faster path whose primary purpose is **protection of population and infrastructure**, not traditional terraforming.

Raising ambient surface pressure reduces a set of environmental hazards (thermal extremes, dust mobility, suit/habitat differential stress, and related operational risk). Composition tuning, greenhouse optimization, and full climate/biosphere terraforming remain later optional stages.

### Pipeline
1. Skimmers harvest raw Venusian atmosphere (primarily CO₂ + N₂ mix) in the upper benign layers.
2. Gas is processed only as far as needed for mass-driver launch (compression / liquefaction or dense packaging).
3. Mass drivers fire the raw or minimally processed gas payloads toward Mars on alignment windows.
4. Artificial magnetosphere (or L1 shield) must already be active so the injected gas is not stripped by solar wind.
5. Gas is captured into the Martian atmosphere, raising total pressure.

### Characteristics
- Lower processing complexity on Venus than the refined O₂/N₂ + CNT method.
- Faster pressure gains once mass drivers and magnetosphere are online.
- Primary goal is protective pressure, not immediate Earth-like composition or climate.
- Composition is “whatever Venus supplies” initially; later stages can tune ratios, add greenhouse agents, or adjust oxygen fraction if traditional terraforming is chosen.
- Still requires the same magnetosphere prerequisite and mass-driver infrastructure.
- Venus excess pressure still makes losses tolerable.

This option lets a settlement reach useful protective pressure thresholds without committing to full terraforming.

---

## Refined Brute-Force Venus → Mars Method (O₂/N₂ + CNT Shells)

**DIRECTION** — higher-processing, higher-control option that can support traditional terraforming goals.

### End-to-End Pipeline

1. **Atmospheric harvesting**  
   Automated skimmers operate in the upper Venusian atmosphere (roughly the 1–2 bar region: near room temperature and Earth-like pressure).

2. **Depot processing**  
   Harvested gas is delivered to an orbital or high-altitude depot for separation.

3. **CNT shell manufacturing**  
   The CO₂ fraction is used as feedstock to manufacture carbon-nanotube (CNT) thermal-ablation shells.

4. **Payload preparation**  
   Frozen O₂ and N₂ are packed inside the CNT shells.

5. **Mass-driver launch**  
   When Venus and Mars are in proper orbital alignment, mass drivers fire the payloads onto ballistic trajectories toward Mars.

6. **Magnetic shield prerequisite**  
   An artificial magnetosphere (or L1 solar shield) must already be active at Mars.

7. **Reentry and release**  
   CNT shells ablate and burn up in the Martian atmosphere, releasing the O₂ and N₂ directly into the building atmosphere.

### Economic Characteristics

- **Venus-side cost dominance**: Heavy capital for liquefaction, freezing, CNT lines, and mass drivers is weighted toward Venus because of its structural need to shed excess pressure.
- **Low marginal regret**: Venus overabundance means lost canisters carry near-zero economic penalty (“firehose” economics).
- **Fuel still required**: Skimmers, platforms, and local transport need CH₄ or H₂.
- **No expensive interplanetary propellant for the gas itself**: Electromagnetic launch replaces chemical rockets for the Venus→Mars leg.

### Bootstrapping Dependency

Venus cannot easily produce the heavy metals and structural materials needed for mass drivers and high-throughput plants. External entities (Mars, Luna, or other hubs) must seed the initial capital and machinery. Once operational, Venus pays back that investment through the continuous volatile stream and continues to import heavy metals.

### Early Luna Involvement

- Luna manufactures and dispatches the first automated skimmers.
- Luna needs CO₂ and N₂ for its own growth.
- Luna has PSR water ice and can synthesize methane, closing an early fuel loop.
- Once volume scales, **cyclers** take over the heavy Venus–Luna leg; direct skimmer runs to Luna stop.

### Bidirectional Trade

- Venus exports: volatile payloads (and other industrial products).
- Venus imports: heavy metals, refractory materials, and goods it cannot produce locally.

---

## Softer / Longer-Horizon Options

**DIRECTION / OPEN**

These trade time and lower CapEx for slower atmospheric gains. They may be chosen when protective pressure is not urgent or when capital is constrained.

### Gradual Venus Siphon
Steady, low-intensity upper-atmosphere extraction without immediate mass-driver build-out. Venus slowly sheds pressure while feeding a manageable trickle of CO₂/N₂ into the inner-system network.

### Titan Long-Lead
- Primary volatiles: hydrocarbons (CH₄) and N₂.
- Strengths: large stable inventory of organics and nitrogen.
- Limits: long transit, cryogenic holding losses, weaker as a bulk CO₂ mass source for rapid pressure building.
- Best treated as a baseline organic/fuel provider rather than a rapid pressure or atmosphere-builder.

### Kuiper Belt Object (KBO) Slow-Boat
- Low-thrust or gravity-assist trajectories bring ice-rich bodies inward over decades.
- Clean water and volatiles with minimal surface damage on arrival.
- Extreme lead times; high value for pure water inventory once the logistics are paid for.

### Local / Hybrid
Continued reliance on Martian polar CO₂, subsurface ice, and industrial greenhouse-gas production, possibly combined with modest imports. Lower throughput, lower external dependency.

---

## AI Manager Decision Framing

**DIRECTION**

The AI Manager evaluates pathways as capital projects against EAP, timeline pressure, and available industrial capacity:

- Need rapid protective pressure, magnetosphere already online → favor raw-gas mass-driver transfer.
- Need controlled O₂/N₂ composition for longer-term terraforming goals → favor refined CNT-shell pipeline.
- Low CapEx + long timeline → favor gradual siphon, Titan trickle, or KBO slow-boat.
- Bootstrapping cost of Venus infrastructure is a real gate; external heavy-industry support is required before high-throughput methods can run.

Sol is the training ground. Once the AI Manager can balance these loops inside Sol, the same first-principles scoring (volatile inventory, delta-V, insolation, bootstrap potential) is applied to extrasolar candidates.

---

## Open Questions / Future Work

- Exact protective pressure targets (what millibar ranges meaningfully reduce operational risk for population and infrastructure).
- Processing and packaging requirements for the raw-gas transfer path.
- Feedstock ratios for the refined CNT path (CO₂ mass per unit shell vs. frozen O₂/N₂ payload).
- Mass-driver launch cadence and alignment-window scheduling for both methods.
- Artificial magnetosphere / L1 shield power and construction requirements.
- Transit and boil-off loss models for any non-mass-driver legs.
- How the AI Manager scores time-versus-cost trade-offs and when it switches strategies.
- Data structures for multi-body capital investment and payback tracking.
- Survey heuristics and scoring matrix for prime candidates beyond Sol.

All numerical values and ownership models remain **OPEN**.
