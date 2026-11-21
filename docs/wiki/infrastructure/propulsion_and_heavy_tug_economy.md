# Propulsion Classes & Heavy-Tug Economy

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-12  
> *Audit Summary:* Propulsion class tiers and heavy-tug economy consolidated from live wiki sources. Mk-I in-place conversion vs. later tug class relocation capability clarified: Mk-I supports in-place conversion and station-keeping only; a later heavy tug class enables capture and repositioning. Code implementation pending or unverified as of audit baseline.

This page consolidates all still-valid material about propulsion classes (HLT tiers, tug technology progression) and the heavy-tug economy that operates across the pre-player pipeline, station construction pipeline, Sol system reference, and related pages. It covers what is stated in live wiki sources; gaps are marked **OPEN**.

## Current Ship-Class Set (DIRECTION)

The current early-game design is intentionally limited to **three ship classes**:

| Ship class | Primary role in the current setup | Initial construction approach |
|---|---|---|
| **HLT (Heavy Lift Transport)** | Flexible transport ships that can be fitted/configured for assigned operations, including cargo transport and the early Venus atmospheric-harvesting role. | Early HLT Mk1 ships are produced on Earth. Later marks may use more capable construction facilities as the industrial base develops. |
| **Cycler** | Long-range/interplanetary transport infrastructure operating on established routes; may carry or rendezvous with HLT support craft. | First cyclers are constructed in orbit at the Earth–Moon L1 shipyard. |
| **Tug** | Heavy-duty orbital construction, body capture, station-keeping, and (with appropriate later capability) asteroid/moon relocation. | First tugs are constructed in orbit at the Earth–Moon L1 shipyard. |

These are the three ship classes in the current design baseline, not an exhaustive limit on every possible future vehicle concept. HLT is a ship class; Mk1, Mk2, Mk3, and later marks are successive versions within that class. Roles such as atmospheric harvester describe how an HLT is fitted and assigned, not an additional ship class. The initial Venus example is an Earth-produced HLT Mk1 fitted for harvesting. The same HLT class also supports cargo transport between Earth, Luna, and L1; later HLT marks may be used for that work without being required to share the Mk1 Venus-harvesting fit.

The initial Cycler and Tug construction location is a deliberate infrastructure dependency: both are built in orbit at L1, rather than being early Earth-built ships. This assumes the L1 shipyard and its supporting industrial/logistics capacity have first been established. Exact production rates, fleet counts, and detailed build recipes remain OPEN.

---

## 1. Propulsion Classes

### 1.1 Heavy Lift Transport (HLT) Tiers

The **HLT Mk1 is the only HLT design established for the initial fleet**. Mk2 and Mk3 have been discussed as possible future marks, including in connection with the Titan mission concept below, but their designs and specifications are not yet established.

| Initial design | Primary Build Site | Established Role / Capability | Thermal & Cryogenic Boundary |
|-----------------|-------------------|-------------------------------|------------------------------|
| **HLT Mk1** | Earth-produced | Flexible early transport craft; individual ships are fitted/configured for their assigned role, including the initial Venus atmospheric-harvesting mission and local inner-system logistics. | Passive thermal protection; its cryogenic storage/boiloff performance is inadequate for the multi-year Titan harvesting mission. |

> **Cross-link:** For the pre-player pipeline that gates HLT production behind the Venus-Luna Sabatier loop and L1 shipyard construction, see **[Pre-Player Era Logistics Pipeline](./pre_player_era_logistics_pipeline.md)**.  
> **Cross-link:** For cycler network integration (Tier 3 transport), see **[Import Order & Cycler Models](../logistics/import_order_and_cycler_models.md)**.


### Titan Atmospheric Harvesting: Original Early Objective, Deferred by Mk1 Limitation (DIRECTION)

Titan atmospheric harvesting was originally intended as an **early part of the industrial plan**, not merely a distant expansion objective. The initial concept was to use an HLT for Titan harvesting and bring useful atmospheric products back into the inner Solar System. The plan encountered a concrete craft limitation: **HLT Mk1 could not retain cryogenic cargo economically across the long outbound transit, extraction stay, and return journey**. The problem was cumulative boiloff, not a lack of interest in Titan's resources.

The early fleet therefore pivoted its immediate Luna resource strategy rather than making the initial settlement dependent on an unsuitable Mk1 long-haul mission. The Luna buildout was redirected to establish **permanently shadowed region (PSR) water-ice mining as the local source for its H₂ needs**. This is the near-term Luna supply path; it does not cancel the Titan harvesting objective. Titan remains an intended HLT-class mission once a suitable higher-capability craft and cryogenic cargo system can be developed.

The HLT's methane requirement was part of the mission design, but **Titan was intended to provide methane/ethane through a simple onboard gas separator**. The corresponding oxidizer would not be recovered by that separator, so the HLT would carry additional O₂ for the return burn. Separately, the Luna buildout establishes a local propellant-production path: combine PSR-derived hydrogen with Luna's CO₂ feedstock to produce methane and oxygen for the local HLT fuel loop. The early simulation must test and tune the lunar chain's throughput, process configuration, storage, transfer, losses, and ability to sustain operations; do not treat successful closed-loop operation or sufficient production capacity as already validated.

Titan harvesting is an established future mission concept for the HLT class, not a current Mk1 capability and not a separate ship class. The Titan and Venus harvesting fits share the HLT harvesting platform: the key processing-equipment substitution is the Titan gas separator in place of the Venus CO₂-processing unit. The Titan mission still needs the long-duration cryogenic retention, storage, and fuel/oxidizer handling capability described below; these mission requirements do not imply a different ship class. The limiting problem identified in the earlier design work is **cryogenic boiloff over the long outbound, extraction, and return mission**. A Titan mission cannot be treated as an ordinary Mk1 Venus-style harvesting run with a longer route: volatile cargo and return propellant must remain usable across a multi-year transit.

The discussed design direction is to develop a more capable HLT mark/configuration—previously discussed as a possible **Mk2 or Mk3 HLT**, with the cryogenic cargo system reaching **Mk3/Mk4 capability or better**—that can support Titan harvesting and delivery back into the inner-system logistics network. The exact HLT mark and equipment allocation are not yet a finalized craft specification.

The September 2026 atmospheric-harvesting mission proposal records this Titan option as follows:

- **Mission:** travel to Titan, collect its atmospheric mixture, recover methane for the return fuel requirement, and return the remaining mixed atmospheric cargo to a receiving facility.
- **Transit constraint:** the proposal estimates approximately **1,388 days** for the Earth–Titan leg. Boiloff must be tracked during outbound transit, the extraction stay, and return transit; it is the cumulative loss over the complete mission that makes the Mk1/early cryogenic arrangement unsuitable.
- **On-site work:** the proposal estimates **20–30 days** for extraction. The actual duration should emerge from atmospheric conditions, collection/processing throughput, and tank capacity rather than being treated as a guaranteed fixed duration.
- **Return propellant concept:** the proposal specifies an **8,000 kg methane return-fuel tank** and an additional contingency reserve, with the amount and loading strategy dependent on departure location and the final mission design.
- **Cryogenic cargo concept:** the proposal specifies **three Mk3-or-better cryogenic cargo tanks**, primarily for nitrogen-rich mixed atmospheric cargo. The cargo tanks' boiloff performance must be sufficient for the full return leg.
- **Processing concept:** the Titan harvesting fit uses a simple onboard gas separator to recover methane/ethane from the atmospheric intake. This separator is the Titan-fit counterpart to the CO₂-processing unit used in the Venus harvesting fit; the harvesting configuration change is the processing unit, not a different HLT class or a wholly different harvesting platform. The recovered hydrocarbons support return propulsion, while the HLT carries additional O₂ because the separator does not provide the oxidizer. Exact separator performance, recovered methane/ethane usability as engine fuel, and oxygen reserve sizing remain OPEN.

This is a future HLT capability direction, not a claim that the initial Earth-produced HLT Mk1 already has these systems. It also does not establish that every later HLT mark carries Titan equipment. The ship class remains HLT; mark, mission role, and installed equipment determine the actual capability.

**Design boundary:** the Titan concept addresses boiloff by improving cryogenic storage/thermal management and mission configuration. It must not be simplified to “more fuel” alone. The mission needs a viable volatile-storage solution across the complete mission duration, alongside adequate return propellant and contingency reserves.

**Additional design direction — modular upgrades and tank-capacity reuse:** Titan capability need not require an entirely new HLT class or a single fixed Mk3 design. A later HLT mark (such as a possible Mk2 or Mk3), improved technology, upgraded modules, or mission-specific fittings could provide the required separator, cryogenic retention, handling, and transfer capabilities. The mission concept also allows surplus recovered methane and/or LOX to be held temporarily in suitable tanks otherwise assigned to raw-gas or mixed-volatiles storage, then transferred into the primary propellant tanks before the propellant is needed. This can make better use of installed tank volume and provide operational flexibility; it is not yet established that every raw-gas tank is compatible with methane or LOX.

**OPEN / validation required:** tank-by-tank fluid compatibility and pressure/temperature ratings; whether methane and LOX can use the same nominal raw-gas tank type or require distinct qualified tanks; transfer pumps/lines/valves and cryogenic conditioning; boiloff during temporary storage and transfer; separation of oxidizer and fuel; usable reserve volumes; and timing/sequence for transferring material into primary tanks. Model fuel and oxidizer inventories separately and do not assume nominal tank volume equals usable propellant capacity.

**OPEN / validation required:** exact HLT mark (Mk2 vs. Mk3); whether Mk3 or Mk4 cryogenic tanks are required for the full mission; actual boiloff rates and thermal-system performance; propulsion and transit-time assumptions; Titan atmospheric collection and methane-recovery throughput; return destination/routing; tank capacities beyond the proposal values; contingency-fuel amount and loading strategy; and whether the earlier proposal's numerical values remain suitable after the current mission model is reconciled. The proposal's figures are retained as design-study inputs, not validated game constants.

### 1.2 Tug Propulsion Technology Progression

Asteroid relocation tugs and heavy tugs share a three-stage propulsion evolution:

| Stage | Propulsion Type | Capabilities | Transit Impact | Cost Impact |
|-------|----------------|--------------|---------------|-------------|
| **Phase 1** | Nuclear Thermal | Reliable for inner solar system operations; xenon fuel canisters, nuclear fuel rods | Base transit times (30–180 days departure, 50–500 days towing) | Base cost |
| **Phase 2** | Fusion Drive | 2× faster transit, better fuel efficiency; helium-3 fuel | −50% transit time; +100% fuel efficiency | −30% mission cost |
| **Phase 3** | Continuous Fusion | Constant thrust, 4× faster transit, extended range to Oort cloud / interstellar precursor | −80% transit time; +300% fuel efficiency | −60% mission cost |

> **OPEN:** Exact technology unlock conditions (which pre-player phase gates each propulsion tier).  
> **OPEN:** Specific thrust figures, Isp values, and dry/wet mass ratios for each tug class.

---

## 2. Heavy-Tug Role & Operations

### 2.1 Core Missions

Heavy tugs (specifically the **Asteroid Relocation Tug** class) are manufactured at L1 shipyards in Phase 2 and deploy to the Martian system in Phase 3. Their roles span:

| Mission | Description | Phase |
|---------|-------------|-------|
| **Phobos/Deimos Relocation** | Capture and reposition Mars' moons (requires a later heavy tug class); Mk-I tugs support only in-place conversion for depot/station construction without relocation | Phase 3 |
| **Belt Capture** | Move into the Asteroid Belt to capture raw asteroids (Ceres, 16 Psyche-class bodies) | Phase 4 |
| **No-Moon Anchoring** | Reposition asteroids into orbit around moonless bodies (Venus, Eden, System B) as physical structural anchors for AWS/WS stations | Phase 4 |
| **Post-Snap Recovery** | Transit through stabilized portals to Eden's legacy anchor site; haul EM-loaded legacy WS to exit coordinates | Post-Snap |

### 2.2 Slag Propulsion Economy

A defining feature of the heavy-tug economy:

- When a celestial body is converted via Rule B hollowing, **30%** becomes structural hull/decks/framing and **70%** becomes inert slag.
- The waste slag is processed into reaction mass propellant (`slag_fuel_id`) via onboard slag engines.
- This enables **self-sustaining long-haul transit** without requiring Earth/Luna fuel imports.
- Slag serves as reaction mass for tug station-keeping and orbit positioning.

> **Cross-link:** For the full Rule B hollowing mechanics (mass ratios, structural disqualifiers), see **[Pre-Player Era Logistics Station Construction Pipeline](./pre_player_era_logistics_station_construction_pipeline.md)**.

### 2.3 Tug Operational States

| State | Power Draw | Fuel Consumption | Speed / Range |
|-------|-----------|-----------------|---------------|
| Docked | 150 kW idle; 2 h daily maintenance | — | — |
| Cruise | 1,000 kW | 50 kg/hour | Max 15 km/s |
| Capture Approach | 3,000 kW | 150 kg/hour | 0.5 km/s approach |
| Capture Active | 5,000 kW | 5,000 kg for 24 h | — |
| Towing | 2,500 kW | 100 kg/hour | 50 km/day tow speed |
| Release Positioning | 3,500 kW | 180 kg/hour | 48-hour duration |

> **OPEN:** Whether these operational states apply to all tug classes or only the Asteroid Relocation Tug specifically.  
> **OPEN:** Surface propulsion mode details (installs `asteroid_propulsion_module` units on surface for targets > 10¹⁰ kg) — needs integration into this page.

### 2.4 Dual-Operation Modes

The Asteroid Relocation Tug supports two distinct operational modes:

| Mode | Target Mass | Method |
|------|------------|--------|
| **Traditional Towing** | < 10¹⁰ kg | Direct physical attachment to asteroid hull; thrust via towing cables |
| **Surface Propulsion Installation** | > 10¹⁰ kg | No physical attachment; installs `asteroid_propulsion_module` units on surface |

---

## 3. Where Tugs Are Built / Staged

### 3.1 Build Location

- **L1 Earth-Moon Lagrange Shipyard** is the primary deep-space vessel construction nexus and the sole build site for Heavy Tugs and Mk2/Mk3 HLTs.
- L1 shipyards are constructed using Luna-sourced bulk raw materials (structural silicates, refined metals) and specialized/high-tech imports from Earth as needed, with the L1 and near-LEO depots supporting the logistics chain.

### 3.2 Staging & Deployment

| Step | Location | Action |
|------|----------|--------|
| **Build** | Earth L1 Shipyard | Capital craft fabrication (Heavy Tugs + Cyclers) |
| **Propellant fill** | L1 Fuel Depot | Methalox loading from Venus-Luna Sabatier loop |
| **Deploy to Mars** | Mars system | Phase 3: tug operations begin; Phobos/Deimos capture |
| **Deploy to Belt** | Main Belt | Phase 4: belt capture and no-moon anchoring |

> **Cross-link:** For L1 depot as the Venus-Titan-Luna logistics triangle hub, see **[Import Order & Cycler Models](../logistics/import_order_and_cycler_models.md)**.

---

## 4. Relationship to Cyclers, Mass Drivers & Pre-Player Phases

### 4.1 Tug ↔ Cycler Relationship

| Aspect | Heavy Tugs | Cyclers |
|--------|-----------|---------|
| **Role** | Build infrastructure, capture/relocate bodies, shuttle cargo | Permanent interplanetary transit backbone |
| **Timeline** | Phase 2 (build) → Phase 3 (deploy) → Phase 4 (belt ops) | Phase 3+ (regular routes operational) |
| **Ownership** | AstroLift (NPC fleet); eventually player-owned | AstroLift (owned and operated all cyclers) |
| **Interaction** | Skimmer craft match vectors with cyclers for orbital insertion/extraction at terminal hubs | Tugs act as shuttle craft to cycler meetup points |

> **Cross-link:** For the three-tier transport model (local craft → cycler rendezvous → interplanetary cycler network), see **[Import Order & Cycler Models](../logistics/import_order_and_cycler_models.md)**.

### 4.2 Tug ↔ Mass Driver Relationship

- The Venus→Mars ballistic corridor uses mass drivers to launch frozen O₂/N₂ pods from Venusian processing infrastructure into the Martian atmosphere.
- Heavy tugs deliver the structural materials and propellant needed to build these mass drivers.
- Slag propellant economy enables tug operations without importing reaction mass, keeping the loop self-sustaining.

> **Cross-link:** For the full ballistic corridor mechanics (pod specs, launch architecture, reentry dispersion), see **[Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md)**.

### 4.3 Pre-Player Phase Gating

```
Sol bootstrap sequence (owner-confirmed 2026-11-21)
  └─ Luna foothold and industrial output
  └─ L1 Depot (Luna bulk materials + Earth specialized imports)
  └─ Second depot near LEO
  └─ Main station / shipyard infrastructure

Fleet scaling follows the required depot and shipyard dependencies.
  └─ Heavy Tugs manufactured ← propulsion economy begins here
  └─ Deep-space Cyclers manufactured

Phase 3: Mars Moon Conversion
  └─ Heavy tugs deploy to Mars system
  └─ Phobos/Deimos hollowing + slag propulsion economy active
  └─ HLT-Mk-II fleet (L1 built) operational

Phase 4: Belt Expansion & Asteroid Repositioning
  └─ Heavy tugs move to Main Belt
  └─ No-moon anchoring begins
  └─ Cycler network locks into place
```

---

## 5. OPEN Items — Missing Numbers & Undecided Design

| # | Item | Source Notes |
|---|------|-------------|
| **OPEN-1** | Exact Mk1/Mk2/Mk3 mass thresholds for tug classes | Mk1 constraint mentioned: Phobos/Deimos can be converted in place under Mk1; larger bodies require later tug class or capture-to-anchor. No numeric thresholds stated. |
| **OPEN-2** | Thrust figures, Isp, delta-v budgets per tug class | Delta-v formula present in pre-player pipeline but all values are **[PROPOSED / PLACEHOLDER]** and not game-validated. |
| **OPEN-3** | Fleet counts (how many HLTs, how many heavy tugs) | No fleet count numbers stated anywhere in wiki sources. |
| **OPEN-4** | Cost per tug class (GCC) | Mission cost tables exist in frozen docs but are not yet wiki-validated. |
| **OPEN-5** | Propulsion technology unlock conditions | Phase 1→2→3 progression described qualitatively; no explicit pre-player phase gates for propulsion tiers. |
| **OPEN-6** | Heavy Tug radiation exposure model values | Starsim page has **[PROPOSED / PLACEHOLDER]** survival probabilities (~10% unshielded, ~35% Al hull) for 100–500 day transit — not game-validated. |
| **OPEN-7** | Surface propulsion mode integration | `asteroid_propulsion_module` units for > 10¹⁰ kg targets described in tug guide but not yet integrated into wiki narrative. |
| **OPEN-8** | Cycler repeat periods and corridor parameters | Pre-player pipeline has a corridor table with **[PROPOSED / PLACEHOLDER]** repeat periods (73 h, 584 h, 26 mo, etc.) — not game-validated. |

### Resolved: Epstein Drive Purge

> **Status:** RESOLVED — purged for IP compliance.
>
> The term "Epstein drive" has been removed from all active documentation to prevent IP/copyright friction. Canonical project term is **Fusion Torch Drive** (`fusion_torch_engine`), per:
> - [`unit_and_manufacturing_blueprints.md`](../engineering/unit_and_manufacturing_blueprints.md) (line 196): *"Fusion Torch Drive (`fusion_torch_engine`) is the canonical reference for fusion-class propulsion."*
> - [`starsim_and_protection_classes.md`](../design/starsim_and_protection_classes.md) (line 229): *"The term 'Epstein Drive' has been removed from all active documentation to prevent IP/copyright friction."*
>
> The frozen doc `docs/architecture/stations/asteroid_relocation_tug.md` (line 38) still references "Epstein drives" in a tech-scaling table; this is legacy ore with no operational authority.

---

## 6. Harvested Sources

| Source | Content Used |
|--------|-------------|
| [`pre_player_era_logistics_pipeline.md`](./pre_player_era_logistics_pipeline.md) | HLT Mk tiers (Section 2.1), corridor tug classes, delta-v framework, slag propulsion economy concept |
| [`pre_player_era_logistics_station_construction_pipeline.md`](./pre_player_era_logistics_station_construction_pipeline.md) | L1 shipyard → Heavy Tug build pipeline, Rule B hollowing (30/70 split), Phase gating narrative |
| [`pre_player_era_logistics_architecture.md`](./pre_player_era_logistics_architecture.md) | HLT Mk tier table (build site, range, thermal/cryo capabilities), outer system transit trap, cycler solution |
| [`sol_system_reference.md`](../astronomy/sol_system_reference.md) | Main Belt heavy tug operations (Phase 4), asteroid relocation tugs role |
| [`starsim_and_protection_classes.md`](../astronomy/starsim_and_protection_classes.md) | Heavy Tug radiation exposure model (proposed values, marked OPEN) |
| `docs/architecture/stations/asteroid_relocation_tug.md` (frozen) | Propulsion technology progression (nuclear → fusion → continuous fusion), tug operational states, dual-operation modes, economic ROI framework |
| [`import_order_and_cycler_models.md`](../logistics/import_order_and_cycler_models.md) | Three-tier transport model, cycler/tug interaction, L1 depot hub role |

---

*Created 2026-11-11 as a dedicated home for propulsion classes and heavy-tug economy. Harvested from live wiki pages and one frozen architecture doc. No numbers invented — all gaps marked OPEN.*
