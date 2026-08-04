# Planetary Terraforming SOP — Universal Framework

## Overview

This document defines the **standard operating procedure (SOP)** for planetary settlement and terraforming across all star systems in Galaxy Game. The SOP was developed and perfected in the Sol System by AI Managers before the wormhole era, then deployed universally to every world encountered through the artificial wormhole network.

**Key Principle**: Every celestial body follows the same 5-phase pipeline regardless of system location. Local variables (gravity, radiation, regolith chemistry, native life) determine execution details, not the framework itself.

---

## The 5-Phase Universal SOP

### Phase 1: Orbital Protection & Logistics

**Objective**: Secure the system and establish high-orbit staging infrastructure.

| Step | Action | Commodity Inputs |
|------|--------|-----------------|
| 1a | Deploy Sun-World L1 Magnetic Shield | Magnet coils, nuclear/fusion cores, heavy structural alloys |
| 1b | Convert orbital moons/asteroids to Depots & Stations (Phobos/Deimos Pattern) | Structural I-beams, sealant polymers, life support scrubbers |
| 1c | Establish Artificial Wormhole Station (AWS) anchor | Station modules, active gravitational dampeners, energy-discharge arrays |

**AWS Anchoring Patterns**:

- **Pattern A — Planetary Counterbalance**: Single AWS placed in opposing orbit relative to a large planetary mass (e.g., Jupiter). Uses the planet's gravitational well as the natural counterbalance vector. Cost-effective: one station per endpoint.
- **Pattern B — Paired Artificial Balance**: Two AWS stations constructed in the same system in opposing orbital vectors. Used in systems lacking an appropriately sized gas giant or anchor planet.

**Completion Gate**: L1 shield active + at least one operational orbital depot + AWS link stabilized (100% stable, no snap risk).

---

### Phase 2: Sub-Surface Human Habitation

**Objective**: Establish human presence with zero surface exposure.

| Step | Action | Commodity Inputs |
|------|--------|-----------------|
| 2a | Survey lava tubes / subterranean features | — |
| 2b | Seal and pressurize lava tube base | Structural I-beams, sealing polymers, life-support scrubbers |
| 2c | Install internal paneling, support beams, radiation shielding | Transparent/silicate panels, structural mounts |

**Design Rationale**: Overlying meters of rock eliminate the need for massive surface shielding. Crews remain safely sheltered while monitoring early atmospheric changes and serving as the surface control center for mining and volatiles extraction.

**Completion Gate**: At least one lava tube base sealed, pressurized, and operational with crew capacity > 0.

---

### Phase 3: Bio-Nursery Seed Domes & Adaptation Pipelines

**Objective**: Inoculate raw regolith and evolve adapted strains in localized structures.

#### Deployment

Prefab bio-nursery domes are deployed over raw local regolith at key sites (equatorial lowlands, deep impact basins, volcanic slopes). Each dome is sealed to minimum viable temperature/pressure for the target organisms.

**Dome Types**:
- **Lowland Aquifer Domes**: Deep basins where ambient external pressure is naturally highest. Focus: liquid-water algae and cyanobacteria.
- **Volcanic Slope Domes**: Geothermal gradients for heat-tolerant lithotrophs.
- **Regolith Scrubbing Domes**: Breeding fungal/bacterial strains that break down toxic soil compounds (e.g., perchlorates).

#### Multi-Pipeline Adaptation Ramp

Each dome runs one or more of these parallel pipelines:

| Pipeline | Method | Upfront Cost | Risk | Primary Yield |
|----------|--------|-------------|------|---------------|
| **A — Top-Down Decay** | Start at Earth baseline (1 atm, 15°C), step down temp/pressure to test natural limits of Earth organisms | High (heavy volatile shipments) | High loss rates | Resilient multi-cellular plants & mosses |
| **B — Bottom-Up Stress** | Start at minimal viability (50–100 mb, −30°C to −10°C), deploy gene-spliced strains for raw toxic regolith | Low (minimal gas pressure) | Targeted failure (specific gene traits fail) | Powerful regolith scrubbers & soil builders |
| **C — Native Splicing** | Extract local extremophile DNA (if endemic life exists), splice into Earth chassis | High (requires advanced bio-labs) | Medium (genetic stability verification) | Shortcut decades of trial-and-error adaptation |

**Adaptation Index**: Each dome tracks an internal score based on the delta between interior conditions and external ambient conditions, plus time spent in dome. Higher adaptation = higher survival/expansion rate when unsealed.

**Completion Gate**: At least one dome with active biomes + adaptation index > threshold for target world's current ambient conditions.

---

### Phase 4: Geological Megaprojects (Worldhouses)

**Objective**: Scale up to regional biomes over craters, canyons, and rift valleys.

| Step | Action | Commodity Inputs |
|------|--------|-----------------|
| 4a | Anchor I-beam structural grids over geological features | Heavy I-beams (local mining or orbital depot stocks) |
| 4b | Install multi-type panel networks | Transparent panels, photovoltaic panels, ruggedized/armor panels |
| 4c | Pressurize with imported volatile buffer gases | Nitrogen ($N_2$), methane ($CH_4$), $CO_2$ (gas skimmers, cyclers) |

**Panel Types**:
- **Transparent Panels**: Radiation-filtering polymer/silicate layers admitting solar radiation for photosynthesis.
- **Solar Integrated Panels**: Photovoltaic layers woven into the roof system to power life support and atmosphere conditioning.
- **Ruggedized/Armor Panels**: Solid, heavily shielded panels for structural anchor points or rockfall-prone areas.

**Terraforming Seeds**: Once a Worldhouse reaches pressurized status with liquid water present, terraforming seed structures can be deployed inside. These contain engineered biomes that begin regolith-to-soil conversion and accelerated eco-evolution.

**Completion Gate**: At least one Worldhouse sealed, pressurized, with active biomes.

---

### Phase 5: Planet-Wide Unsealing

**Objective**: Equalize internal and external atmosphere; release adapted ecosystems planet-wide.

| Step | Action | Trigger Condition |
|------|--------|------------------|
| 5a | Monitor external atmospheric pressure/temperature vs. Worldhouse interiors | Delta < threshold across all active Worldhouses |
| 5b | Retract Worldhouse roofs / unseal panels | External conditions match or exceed internal conditions |
| 5c | Release pre-adapted "System-Native" ecosystems | Adaptation Index of source domes > threshold |

**Result**: Fully acclimatized ecosystems spill out to colonize the open surface. The planet transitions from contained biomes to open biosphere.

**Completion Gate**: External atmosphere reaches habitable threshold across sufficient surface area for self-sustaining ecosystem expansion.

---

## Bio-Nursery & Terraforming Seed Mechanics

### Liquid Water Trigger

The appearance of stable liquid water on a celestial body's surface is the **primary gate** between Phase 3 (Bio-Nursery Domes) and Phase 4 (Terraforming Seeds / Worldhouses). When hydrosphere `state_distribution['liquid']` exceeds a minimum threshold AND atmospheric pressure + temperature are within the liquid water window, the trigger fires.

This trigger enables:
- Deployment of terraforming seed structures in low-lying basins
- Inoculation of surface waterways with baseline pioneer strains (algae, mosses, engineered extremophiles)
- Accelerated eco-evolution inside Worldhouses

### Regolith-to-Soil Conversion Inside Domes

Engineered strains perform active bioremediation:

| Strain Type | Genetic Focus | Primary Impact |
|-------------|--------------|----------------|
| Perchlorate Scrubbers | Engineered bacterial/fungal consortia | Consumes toxic perchlorates, releases chloride ions and free $O_2$ |
| Lithotrophic Bio-Crushers | Cyanobacteria & lichen hybrids | Breaks down basaltic rock, extracts phosphorus/iron for bio-organic soil |
| Cold-Hardy Nitrogen Fixers | Rhizobial/alpine plant strains | Converts trace nitrogen into nitrates, fertilizes regolith |
| Low-Pressure Halophiles | Deep-sea / salt-tolerant extremophiles | Thrives in high-salinity brines and shallow sub-surface pools |

### Native Life Discovery Pathway

If endemic life is discovered on a target world:
1. Extract and sequence native extremophile genomes
2. Isolate high-value genetic markers (perchlorate metabolism, hypobaric cell integrity, UV shielding, cold enzymes)
3. Splice into Earth chassis organisms for hybrid strains
4. Deploy hybrids to Bio-Nursery Domes for stability verification

**Strategic Choice**: Hybridization accelerates terraforming but risks displacing native life. Preservation zones can be established to protect pure Martian strains.

---

## Wormhole & Counterbalance Physics

### The Snap Event

The natural wormhole on the Eden side reached its mass throughput limit during heavy industrial transport. Without stabilization tech and without a Jupiter-class gravitational anchor, the throat warped exponentially until it snapped — severing Eden from Sol and unexpectedly exposing System B via a wild spatial rupture.

Sol's wormhole endpoint was positioned opposite Jupiter in a similar orbit, leveraging gravitational counterbalance for relative stability. But even this was only **marginally stable** — stabilization tech makes wormholes **completely stable**.

### Wormhole Stability Progression

| Stage | Anchor Type | Stability | Notes |
|-------|------------|-----------|-------|
| Natural (Unanchored) | None | Fragile | Ultra-sensitive to mass; collapsed in Snap Event |
| Natural (Mass-Anchored) | Jupiter-class body | Marginally Stable | High tolerance but still vulnerable to extreme overload |
| Artificial Pair (Stabilized) | Paired AWS stations | 100% Stable | Active field dampening; zero reliance on natural bodies |

### Artificial Wormhole Station (AWS) Rules

- AWS stations are created opposite correctly-sized large planets **or** in pairs within the same system to provide counterbalance.
- A single AWS is cost-effective when a Jupiter-type body exists in the system.
- Paired AWS is required in terrestrial-only or small-body systems.
- Once activated, an AWS pair creates a permanent, 100% stable link — no further snap risk.

### The Controlled Snap Expansion Loop

```
[Sol Anchor (Natural/Jupiter Assisted)]
       │
       ▼  Controlled Snap (Temporary / Volatile Line)
[Target System Probed via AI Manager Scout]
       │
       ▼  NPC Corps Rush Construction
[Paired Artificial Wormhole Station Deployed & Activated]
       │
       ▼
[PERMANENT, 100% STABLE LINK ESTABLISHED]
       │
       ▼
Industrial SOP Pipeline Begins (Phases 1-5)
```

---

## Macro Economy & AI Manager ROI Layer

### Three-Layer Architecture

```
+----------------------------------+     +----------------------------------+
|   ADMIN OVERSIGHT LAYER          |     | Sets macro priorities, weights, |
| - Regional priority multipliers  |     | budget controls, scarcity rules |
| - Budget & rate controls         |     | (cannot micromanage)            |
+----------------------------------+     +----------------------------------+
                        │
                        ▼
+----------------------------------+     +----------------------------------+
|   AI MANAGER ENGINE (ROI)        |     | Data-driven evaluation of:      |
| - Evaluates celestial bodies     |     | Distance, resources, CapEx,     |
| - Selects optimal SOP template   |     | payoff horizon                  |
| - Posts contracts via NPC Corps  |     | Adaptive pattern selection       |
+----------------------------------+     +----------------------------------+
                        │
                        ▼
+----------------------------------+     +----------------------------------+
|   PLAYER CONTRACT MARKET         |     | Haul, mine, skim, craft, trade  |
| - Dynamic market orders          |     | Fulfills NPC corp demands        |
| - Cross-system arbitrage         |     | Drives economic cycles           |
+----------------------------------+     +----------------------------------+
```

### AI Manager ROI Evaluation Factors

When evaluating a newly scouted system:

1. **Accessibility Cost**: Transit distance, wormhole jump counts, fuel/cycler requirements
2. **In-Situ Resource Availability**: Can the target provide its own metals for I-beams and silicates for panels, or must they be imported?
3. **Terraforming Capital Expenditure (CapEx)**: Cost to deploy L1 shield vs. building Bio-Nursery Domes vs. imported gas volumes for Worldhouses
4. **Payoff Horizon**: Expected long-term return on trade hub value, population capacity, and raw material output once Phase 4/5 is reached

### Terraforming Stage → Market Demand Mapping

| SOP Phase | Primary Market Drivers | Player Opportunities |
|-----------|----------------------|---------------------|
| Phase 1 | Structural alloys, station modules, magnet coils, reactor cores | Haul heavy components to orbital depots |
| Phase 2 | Structural I-beams, life-support scrubbers, sealing polymers | Deliver to lava tube construction sites |
| Phase 3 | Prefab dome kits, bio-seed payloads, trace nutrients | Transport specialized biological starter cultures |
| Phase 4 | Massive I-beam orders, paneling (transparent/solar/rugged), volatile gas shipments | Gas skimming runs, bulk structural component delivery |
| Phase 5 | Agricultural inputs, industrial maintenance, consumer goods | Sustained trade hub operations |

### Supply Chain Arbitrage

- **Gas Logistics**: Terraforming worlds require immense volumes of nitrogen that local regolith cannot provide. Players profit by skimming gas from Venusian-style atmospheres or Titan-like icy moons and hauling through cyclers/wormholes.
- **Structural Components**: Players choose between mining/crafting locally near the frontier vs. buying cheaper in mature Sol core hubs and hauling long-distance.
- **Local Sourcing vs. Import**: NPC Corporations evaluate ROI — if player haulers bring cheaper imported volatiles or components, the AI Manager buys from players rather than spending high CapEx on local extraction.

---

## Sol Tri-System Volatile Loop

The Sol System operates a closed-loop volatile chemistry network that supplies the foundational gases for Mars terraforming and Venus industrial processing. This loop is the **industrial backbone** of the pre-wormhole era — all three systems participate in a continuous material exchange that drives market demand and enables Phase 3/4 terraforming triggers.

### Saturn Harvester Operations

Saturn's gas giant atmosphere provides $\text{H}_2$ (hydrogen) as the foundational light-gas input for inner-system chemistry:

| Operation | Output | Destination |
|-----------|--------|-------------|
| Orbital skimming of Saturnian upper atmosphere | Raw $\text{H}_2$ | Hauled to Venus Sabatier plants and Mars direct-use facilities |
| Compression & purification | Processed $\text{H}_2$ fuel | Stored at orbital depots for on-demand delivery |

**Commodity Chain**: Gas skimmers → compression stations → cycler transport → inner-system depots.

### Venus Sabatier Synthesis

Venus receives Saturnian $\text{H}_2$ and reacts it with native $\text{CO}_2$ via the Sabatier process:

$$\text{CO}_2 + 4\text{H}_2 \rightarrow \text{CH}_4 + 2\text{H}_2\text{O}$$

| Output | Use | Impact |
|--------|-----|--------|
| Methane ($\text{CH}_4$) | Fuel for industrial operations; greenhouse gas for Mars atmospheric thickening | Reduces Venus's need to import fuel from Sol |
| Water ($\text{H}_2\text{O}$) | Electrolyzed to $\text{O}_2$ for export to Mars; direct use in terraforming | Creates Venusian $\text{O}_2$ supply chain |

**Strategic Impact**: This loop accelerates Venusian pressure reduction (by converting atmospheric $\text{CO}_2$ into storable/exportable products) while simultaneously decreasing Venus's fuel imports from Sol.

### Martian Sabatier Processing

Mars utilizes imported Saturnian $\text{H}_2$ reacted with **native Martian $\text{CO}_2$** via local Sabatier plants:

$$\text{CO}_2 + 4\text{H}_2 \rightarrow \text{CH}_4 + 2\text{H}_2\text{O}$$

| Output | Use | Terraforming Phase Link |
|--------|-----|------------------------|
| Methane ($\text{CH}_4$) | Greenhouse warming for atmospheric thickening; cycler fuel for inner-system transport | **Phase 1** → **Phase 2** (atmospheric pressure boost) |
| Water ($\text{H}_2\text{O}$) | Direct use in Bio-Nursery Domes; meets Phase 3/4 liquid water trigger | **Phase 3** → **Phase 4 gating** |

**Strategic Impact**: Local Sabatier processing gives Mars **dual chemistry options** depending on operational priority:

| Chemistry Path | Inputs | Output | Use Case |
|---------------|--------|--------|----------|
| **Sabatier** ($\text{H}_2 + \text{CO}_2$) | Saturnian $\text{H}_2$ + native Martian $\text{CO}_2$ | $\text{CH}_4$ + $\text{H}_2\text{O}$ | Fuel production, greenhouse warming, water generation |
| **Combustion** ($\text{H}_2 + \text{O}_2$) | Saturnian $\text{H}_2$ + imported Venusian $\text{O}_2$ | $\text{H}_2\text{O}$ + energy | High-capacity surface power, direct hydration |

This dual-path architecture means Mars can dynamically choose between **fuel/water production** (Sabatier) and **power generation** (combustion) based on which need is most critical at any given phase of terraforming.

### Mars Power & Hydration Engine

Mars combines imported Saturnian $\text{H}_2$ with imported Venusian $\text{O}_2$ for two critical outputs:

$$2\text{H}_2 + \text{O}_2 \rightarrow 2\text{H}_2\text{O} + \text{energy}$$

| Output | Use | Terraforming Phase Link |
|--------|-----|------------------------|
| Liquid water ($\text{H}_2\text{O}$) | Meets Phase 3/4 liquid water trigger; hydrates regolith for Bio-Nursery Domes | **Phase 3** → **Phase 4 gating** |
| High-capacity surface power | Powers lava tube bases, Worldhouse construction, Bio-Nursery Dome life support | All phases |

**Market Demand**: This engine creates continuous high-value contracts for:
- Saturn $\text{H}_2$ skimming operations (fuel + raw material)
- Venus $\text{O}_2$ electrolysis and export (industrial oxidizer)
- Mars delivery logistics (heavy cargo through cycler network)

### Volatile Loop Summary

```
[Saturn Harvester] ──(H₂)──► [Venus Sabatier Plant] ──(CH₄, O₂)──► [Mars Power & Hydration Engine]
       │                           │                                      │
       │                           ▼                                      ▼
       │                  Local fuel + water export              Liquid water trigger + surface power
       │
       └──────────────────────(H₂)─────────────────────────────► [Martian Sabatier Processing]
                                                                   │
                                                                   ▼
                                                            CH₄ (greenhouse/fuel) + H₂O (bio-nursery)
```

This loop is the **primary industrial driver** of the pre-wormhole economy — every phase of Mars terraforming depends on its continuous operation. When players enter the game, this loop will already be active and generating ongoing market orders for all three nodes.

---

## System Archetypes at Player Entry

When players enter Galaxy Game, systems exist at different stages of the AI Managers' pipeline:

| System Status | AI Manager Focus | Primary Player Opportunities |
|--------------|-----------------|------------------------------|
| **Core (Mature)** | High-density trade, stabilized biomes | High-volume trading, manufactured goods transport |
| **Development** | Active Phase 4 Worldhouse framing | Bulk hauling of I-beams, panels, gas shipments |
| **Frontier** | Phase 1 & 3: L1 shields, Bio-Nursery Domes | High-risk scouting, seed payload transport |

---

## Historical Context: Sol → Eden → Expansion

### The Three Core Systems

| System | Role | History |
|--------|------|---------|
| **Sol** | Anchor & Cradle | Primary industrial engine; SOP perfected here; home to massive Sol Anchor Node powered by Jupiter counterbalance |
| **Eden** | Reclaimed Crown Jewel | Discovered as superior terraforming target; partially built before Snap Event; now resuming 5-phase SOP with player support |
| **System B** | Frontier Proving Ground | Unplanned discovery during the Snap Event; experimental testbed for first Artificial Wormhole Station pair |

### Timeline

```
[Pre-Snap Era] → Sol perfects SOP + Eden rush begins
       │
       ▼
[The Snap Event] → Eden severed mid-construction; System B exposed via wild rupture
       │
       ▼
[Recovery Era] → Sol invents AWS pairs; tests on System B; reconnects to Eden
       │
       ▼
[Expansion Era / Player Entry] → Sol Anchor fires controlled Snaps through natural wormholes;
                                  AI Managers deploy NPC Corps across new systems;
                                  players enter active, re-connected galaxy
```

---

## Integration with Existing Systems

### Habitability Calculation

The `calculate_habitability` method in the Biosphere model should use a **world-agnostic, stage-gate evaluation matrix** rather than hardcoded Mars-specific thresholds. Factors:

1. **Oxygen factor** — weighted 30%
2. **Temperature factor** — weighted 30%
3. **Liquid water factor** — derived from hydrosphere `state_distribution['liquid']`, weighted 25%
4. **Pressure factor** — weighted 15%
5. **Life presence bonus** — bootstrapping effect when life already exists (up to 10%)

All thresholds should be relative to the target celestial body's ambient conditions, not absolute values. The habitability score feeds into:
- Phase 3 → Phase 4 gating (liquid water trigger)
- Bio-Nursery Dome adaptation progress calculations
- Terraforming Seed deployment eligibility

### Worldhouse Integration

Worldhouses are **structures over terrain**, not terraforming themselves. They create contained, breathable environments within pre-existing geological formations. The broader SOP context defines *when* and *why* Worldhouses are deployed (Phase 4), but the structural design, segment workflow, and biome engineering remain in `docs/architecture/structures/worldhouse_design.md`.

---

## Document History

| Date | Author | Change |
|------|--------|--------|
| 2026-08-04 | Planning Agent | Initial creation from Gemini chat log synthesis |
| 2026-08-04 | Planning Agent | Added Sol Tri-System Volatile Loop (Saturn → Venus Sabatier → Mars Power & Hydration) |
