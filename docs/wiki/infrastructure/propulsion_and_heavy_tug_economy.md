# Propulsion Classes & Heavy-Tug Economy

> **Status:** `DIRECTION`  
> *Created:* 2026-11-11  
> *Last Audited:* —  

This page consolidates all still-valid material about propulsion classes (HLT tiers, tug technology progression) and the heavy-tug economy that operates across the pre-player pipeline, station construction pipeline, Sol system reference, and related pages. It covers what is stated in live wiki sources; gaps are marked **OPEN**.

---

## 1. Propulsion Classes

### 1.1 Heavy Lift Transport (HLT) Tiers

The HLT fleet is the primary interplanetary transport until an L1 shipyard exists. Three Mk tiers are defined, each with increasing range, thermal/cryogenic capability, and build site.

| Tier | Primary Build Site | Operational Range | Thermal & Cryo Capabilities | Max Transit Time |
|------|-------------------|-------------------|----------------------------|-----------------|
| **Mk1 HLT** | Earth / Luna Surface | Earth ↔ Luna, Luna ↔ Venus | Passive thermal shielding only. Unmitigated cryogenic boil-off over extended durations. | < 180 days |
| **Mk2 HLT** | L1 Shipyard | Inner System ↔ Mars / Main Belt | Active reliquefaction loops, multi-layer insulation (MLI), dynamic solar-shade orientation. | 1.5 years |
| **Mk3 HLT** | L1 Shipyard / Mars Orbit | Mars ↔ Outer System (Saturn/Titan) | Heavy magnetic shielding, full closed-loop reliquefaction, micro-meteoroid armor, extended life support. | 3.5+ years |

> **Cross-link:** For the pre-player pipeline that gates HLT production behind the Venus-Luna Sabatier loop and L1 shipyard construction, see **[Pre-Player Era Logistics Pipeline](./pre_player_era_logistics_pipeline.md)**.  
> **Cross-link:** For cycler network integration (Tier 3 transport), see **[Import Order & Cycler Models](../logistics/import_order_and_cycler_models.md)**.

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
| **Phobos/Deimos Conversion** | Capture, reposition, and progressively hollow out Mars' moons for depot/station conversion | Phase 3 |
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
- L1 shipyards are constructed using Luna-sourced raw materials (structural silicates, refined metals) and fueled by L1 fuel depots.

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
Phase 1: Sol Core & Luna Bootstrapping
  └─ HLT-Mk-I fleet (Earth/Luna built)
  └─ Venus skimmers harvest CO₂/N₂
  └─ LEO/L1 fuel depots established

Phase 2: L1 Shipyards & Fleet Scaling
  └─ L1 shipyard construction (Luna-sourced materials)
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
