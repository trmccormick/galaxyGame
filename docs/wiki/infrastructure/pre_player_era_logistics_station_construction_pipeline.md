---
title: Pre-Player Era Logistics & Station Construction Pipeline
category: Infrastructure & Engineering
status: Approved Ground Truth
last_updated: 2026-10-27
related_docs:
  - docs/architecture/stations
  - docs/architecture/asteroid_conversion_logic.md
  - docs/architecture/systems/asteroid_conversion_physics.md
  - docs/architecture/patterns/settlement_patterns.md
---

# Pre-Player Era Logistics & Station Construction Pipeline
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* Design intent specification. Code implementation pending or unverified as of audit baseline.

This article documents the physical construction dependencies for pre-player space infrastructure. The Sol bootstrap has an owner-confirmed depot/station order; beyond that foundation, the AI Manager evaluates local construction options rather than following one universal deterministic tree.

In this era, humanity lacks pre-existing deep-space cyclers or heavy tugs. Station construction is treated as a **distinct physical engineering process** that precedes operational use—it is never an instant "spawn" or simple upgrade toggle. All orbital structures must be physically assembled from available materials, equipment, and logistics support. The Sol bootstrap order is specified below; later systems adapt to their local conditions.

---

## 1. Core Engineering & Chemical Constraints

### The Earth Launch Bottleneck
Ships departing Earth's gravity well face extreme mass penalties. The owner-confirmed Sol order establishes the L1 Depot first, then a second depot near LEO, before main station / shipyard infrastructure. This reduces the need for outbound craft to carry all Earth-ascent fuel overhead.

### The Venus-Luna Chemical Feedback Loop
* **Luna Capabilities & Deficits:** Provides structural silicates, metals, and water ice ($\text{H}_2\text{O}$) in its Permanently Shadowed Regions (PSRs), but completely lacks carbon and nitrogen.
* **Venusian Skimming:** Early Heavy Lift Transport (HLT) variants skim the upper Venusian atmosphere to harvest Carbon Dioxide ($\text{CO}_2$) and Nitrogen ($\text{N}_2$).
* **The Sabatier Reaction:** Lunar refineries combine imported Venusian $\text{CO}_2$ with Hydrogen ($\text{H}_2$) from PSR water ice via the Sabatier process:
  $$\text{CO}_2 + 4\text{H}_2 \longrightarrow \text{CH}_4 + 2\text{H}_2\text{O}$$
* **Outputs:** 
  1. **Methalox Propellant ($\text{CH}_4 / \text{LOX}$):** Fuels the early HLT fleet and fills the LEO/L1 depot network.
  2. **Life Support Volatiles:** Supplies Nitrogen/Oxygen breathing mixes and bio-buffers for early Lunar and L1 habitats.

---

## 2. Four-Phase Industrial Expansion Tree

```
[Luna Foothold] ───> [L1 Depot] ───> [Near-LEO Depot] ───> [Main Station / Shipyard] ───> [Heavy Tugs / Cyclers] ───> [Mars / Belt Options]
```

### Phase 1: Sol Core & Luna Industrial Bootstrapping
* **Heavy Lift Transports (HLTs):** Early starship-type craft carry out initial lifts from Earth to LEO/L1.
* **Luna Surface Extraction:** Mining of structural metals and PSR ice processing.
* **Venus Skimming Operations:** Specialized HLTs scoop atmospheric $\text{CO}_2$ and $\text{N}_2$.
* **Depot sequence (owner-confirmed 2026-11-21):** Establish the L1 Depot first using Luna-sourced bulk output and Earth-sourced specialized/high-tech imports as needed; then establish the second depot near LEO for Earth-side launch, refueling, and staging.

### Phase 2: Main Station / Shipyard Infrastructure & Fleet Scaling
* **Main Station / Shipyard:** Main orbital industrial infrastructure is constructed after the L1 and near-LEO depots are established, using Luna-sourced bulk materials and Earth-sourced specialized/high-tech imports as needed.
* **Capital Craft Fabrication:** L1 shipyards manufacture the first generation of **Heavy Tugs** (such as the Asteroid Relocation Tug variants) and deep-space **Cyclers**.

### Phase 3: Mars System Access & Industrial Options

Station construction at Mars is option-driven. See **[Station Construction Options](../engineering/station_construction_options.md)** for the full option set including L1 infrastructure sub-options (compact magnetic shield station early, modular CNT panel array later). Preferred early path does not require tugs or moon relocation; other paths remain valid when technology and survey support them.

* **Preferred early path:** Cycler + HLT from L1 → lean mining outpost on one moon (in place, Mk-I compatible, hollowing not required) → separate Mars orbital depot (seed fuel for cycler refueling) → station as capacity allows. Surface later.
* **Heavier in-place moon work:** Hollow/fit a moon as station or depot in natural orbit without relocating it.
* **Tug deployment & slag economy (when tug class exists):** Heavy tugs built at L1 can deploy to the Martian system. A later heavy tug class may capture, hollow, and optionally reposition bodies. Hollowing can convert on the order of ~30% of a body to structure and ~70% to waste slag processed to `slag_fuel_id` for tug propulsion — a self-sustaining loop for that craft class, not a requirement for the preferred early path. (Mk-I supports in-place conversion only, not repositioning.)
* **Import / pure orbital:** L1-built modules or complete stations assembled in Martian orbit remain valid bootstrap or parallel options.

Technology available at the time (cycler-only vs tug class, fusion, etc.) changes which path scores best. Do not treat tug + dual-moon hollow + slag as the only Phase 3 outcome.

### Phase 4: Belt Expansion & Asteroid Repositioning
* **Belt Operations:** Heavy tugs move into the Asteroid Belt to capture raw asteroids.
* **No-Moon Anchoring:** Asteroids are repositioned into orbit around moonless bodies (such as Venus, Eden, or System B) to act as physical structural anchors for AWS/WS stations, preventing structural instability and avoiding catastrophes like the Eden Snap Event.
* **System-Wide Cyclers:** Regular cycler routes lock into place, finalizing the pre-player baseline infrastructure before Act 2 begins.

---

## 3. Station Construction vs. Operational Use

* **Physical Assembly:** Station construction is a distinct physical engineering phase requiring localized or imported mass, heavy equipment, and dedicated staging schedules. Stations can never be "spawned" or instantly toggled into existence.
* **Basic vs. Anchored Classification:**
  * **Pure Orbital Builds (e.g., LEO/L1 Depots):** Assembled directly in vacuum from Luna-sourced components and fuel networks without planetary body alteration.
  * **Planetary/Asteroid-Anchored Conversions:** Require heavy tug capture, laser hollowing, and slag reinforcement to establish permanent structural foundations.