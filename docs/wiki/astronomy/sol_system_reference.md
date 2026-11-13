# Sol System Reference

> **Wiki section:** Astronomy · **Status:** DIRECTION  
> *Last Updated:* 2026-11-11  
> *Related:* [Celestial Systems Template](celestial_systems.md), [Natural Wormholes & EM](../technical/natural_wormholes_and_em.md), [Artificial Magnetosphere](../infrastructure/artificial_magnetosphere.md), [Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md)

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-11  
> *Audit Summary:* Corrected Venus methane production claim (Venus provides CO₂ feedstock; CH₄ synthesized on Luna via Sabatier). Corrected Mk1 tug Phobos/Deimos repositioning claim: Mk1 can convert in place using the Mk1 slag-engine approach with station-keeping only; cannot physically reposition either moon. Fixed three broken wiki links to resolve to docs/ paths. Preserved all other content as consistent with established design intent.

This page is a concrete reference for the **Sol system** as it exists in Galaxy Game — bodies, roles, infrastructure milestones, and wormhole context. It is **not** the procedural template (that lives on [Celestial Systems Template](celestial_systems.md)); use that page to create per-system docs for procedurally generated systems.

All content is **DIRECTION** or **OPEN** unless marked otherwise. No quantitative orbital elements, masses, resource quantities, or station counts are invented here.

## System Identity

| Field | Value |
|---|---|
| **System Name** | Sol |
| **Generation Path** | Predefined (harvested from `sol-complete.json` / `sol.json`) |
| **Naming Status** | `settlement_named` (originally `scientific_catalog`; renamed via `NameGeneratorService#generate_star_proper_name`) |
| **Galaxy** | Milky Way / MILKY-WAY |

---

## Star

| Field | Value |
|---|---|
| **Identifier** | STAR-SOL-01 |
| **Spectral Type** | G2V |
| **Life Stage** | main_sequence |
| **Habitable Zone (r_ecosphere)** | OPEN — not stated in harvested sources |

The Sol star is the host for all playable bodies. Its G2V classification and ~4.6 Gyr age are consistent with standard stellar astrophysics references used by terrain generation (see `AUTOMATIC_TERRAIN_GENERATOR.md` for Sol-world data sourcing).

---

## Major Bodies and Their Roles

### Earth

| Attribute | Value |
|---|---|
| **Type** | Terrestrial planet |
| **Role in logistics loop** | R&D nucleus, precision hardware manufacturing, early orbital assembly; high-value exports only (avionics, quantum microelectronics, reactor control units); source settlement is Cape Canaveral Spaceport (owned by AstroLift) |
| **Constraints** | Deep-well launch penalties phase out heavy raw material exports during Phase 1; Earth trade uses USD; shipping cost is real |
| **Key infrastructure** | LEO depot, Earth L1 fuel depots, Earth L1 shipyard (planned, not implemented as of last audit) |

Earth's gravity well creates the primary launch bottleneck. Early outbound craft cannot carry Earth-ascent fuel overhead efficiently, so orbital fuel depots at LEO and L1 are prioritized before any deep-space expansion.

### Luna (Moon)

| Attribute | Value |
|---|---|
| **Type** | Natural satellite of Earth |
| **Role in logistics loop** | Primary ISRU hub: structural silicates, metals, PSR water ice; early manufacturing and refining; Venus-Luna chemical feedback loop partner |
| **Key assets** | Permanently Shadowed Regions (PSRs) with water ice; regolith oxygen production; lava tube habitat sites |
| **Deficits** | Lacks carbon and nitrogen — requires Venusian skimming to close the Sabatier fuel loop |

Luna is the first foothold location. The Venus-Luna chemical feedback loop is foundational: Luna provides structural silicates, metals, and H₂O from PSRs; Venusian atmospheric skimming provides CO₂ and N₂; the Sabatier reaction (CO₂ + 4H₂ → CH₄ + 2H₂O) synthesizes Methalox propellant for the HLT fleet.

### Venus

| Attribute | Value |
|---|---|
| **Type** | Terrestrial planet |
| **Role in logistics loop** | Volatile and energy powerhouse: atmospheric volatile harvester, carbon-structure factory; primary source of O₂, N₂, CNTs, and CO₂ feedstock for Luna-based Sabatier methane synthesis |
| **Key infrastructure** | High-altitude aerostat skimming stations; thermal/chemical cracking arrays; CNT shell manufacturing; orbital mass driver arrays |
| **Terraforming options** | Option A (Terraforming Reserve): managed N₂ exports against 1-bar buffer; Option B (Pure Industrial Powerhouse): uncapped N₂ and CO₂ skimming |

Venus is the system's industrial powerhouse. Its atmosphere (~96% CO₂, ~3.5% N₂) is harvested at scale through high-altitude aerostat stations. The Venus-Luna chemical feedback loop closes early-game fuel production. Later, the Venus→Mars brute-force terraforming pipeline delivers engineered gas-pods via mass drivers across the ballistic corridor.

### Mars

| Attribute | Value |
|---|---|
| **Type** | Terrestrial planet |
| **Role in logistics loop** | Central gateway and outer-system staging hub; intercepts incoming raw ore from Ceres/Psyche; processes and holds volatile imports from Saturn; schedules inward distribution to Venus, Luna, and LEO |
| **Key infrastructure** | Mars-orbit transfer hub; Phobos/Deimos station conversions; artificial magnetosphere (L1 superconducting dipole) |
| **Surface operations** | Begin only after core cycler loop is online; surface markets mature as trade volume increases |

Mars becomes solvent through hub economics: branch and core volume pass through Mars, generating revenue that funds solvent demand so Venus and other suppliers keep exporting. Without hub economics, Mars cannot pay, Venus throttles export, and resource flow stalls.

### Main Belt (Ceres / Asteroid Belt)

| Attribute | Value |
|---|---|
| **Type** | Asteroid belt between Mars and Jupiter |
| **Role in logistics loop** | Raw material extraction: Ceres for water-ice and hydration-salts; 16 Psyche for nickel-iron ore; broader belt for structural materials |
| **Key infrastructure** | Belt capture barges; heavy tug operations (Phase 4); asteroid relocation tugs |

The Main Belt is the system's raw material source. Heavy tugs manufactured at L1 deploy to the belt in Phase 3, capturing and routing raw asteroids. Phobos/Deimos can be converted in place using the Mk1 slag-engine approach, with the drives providing station-keeping capability only. The Mk1 cannot physically reposition either moon; larger-body relocation requires a later tug class or an alternative capture-to-anchor approach.

### Jupiter

| Attribute | Value |
|---|---|
| **Type** | Gas giant |
| **Role in system stability** | Natural counterbalance for Sol-side wormhole mouth stability; Jupiter-class mass on a natural wormhole mouth dampens volatility and reduces uncontrolled EM ejection |
| **Role in logistics** | Outer-system transit destination (via Mars cycler hub); not a direct inner-system stop |

Jupiter's massive gravity well provides a critical stabilizing function for the Sol system's natural wormhole infrastructure. Without a Jupiter-class counterbalance, wormhole mouths would be inherently more unstable — analogous to the Eden-side volatility observed before the Snap.

---

## Natural Wormhole Mouth in Sol

**ESTABLISHED SCENARIO INTENT — 2026-11-13**

Sol has a natural wormhole mouth associated with the historical Eden connection. Jupiter's placement opposite the Sol-side mouth provides a substantial counterbalance, making the Sol mouth comparatively more stable than the historical Eden-side mouth. This is relative stability, not permanent or absolute stability: natural EM ejection and mass-throughput behavior still apply.

The Eden-side mouth was less stable and snapped before EM stabilization technology was developed. The later capture-and-return stabilization technology grew from the lessons of that event.

For the current human-expansion gameplay scenario, Sol's natural wormhole remains present and does not shift or snap. The narrative is also currently planned around its continued existence. This is a current scenario treatment, not a hard-coded permanent rule for all future scenarios.

Sol's natural wormhole produces some excess EM in local space even while comparatively more stable. Greater mass pushed through a natural wormhole contributes to greater EM ejection. Mature EM stabilization captures ejected EM and directs it back toward the wormhole to restore mass-limit capacity and improve relative stability.

> **Cross-link:** For natural wormhole behavior, relative stability, mass limits, EM harvesting/stabilization, shifting/snapping, and Hammer Protocol, see [Natural Wormholes & EM](../technical/natural_wormholes_and_em.md).
> **Cross-link:** For AWS network topology and artificial pairing, see [Portals & AWS](../technical/portals_and_aws.md).

## Sol AWS placement study

**DIRECTION / OPEN — 2026-11-13**

Jupiter is already associated with the natural Sol wormhole and is not counted as an available AWS placement candidate in the current planning discussion. Saturn, Uranus, and Neptune are the three major outer-planet candidates currently under consideration. The planned Sol–Eden AWS connection is most likely associated with a location opposite Saturn, but this is not a finalized placement.

Other possible configurations include an outer-system AWS pair whose members balance one another. Do not assume one AWS per giant planet or lock a placement before evaluating the system.

Placement must consider several competing constraints:
- gravitational influence and counterbalance geometry;
- wormhole/EM stabilization requirements;
- orbital motion and whether a configuration remains useful over time;
- ship travel time, transfer opportunities, fuel, construction and maintenance logistics;
- the desire to keep AWS infrastructure outside the inner system/habitable zone rather than placing it among inner terrestrial planets.

Farther-out placement can increase ship travel and resupply times; actual travel depends on orbital positions, trajectories, propulsion, and launch windows, not distance alone. The mass of the AWS stations themselves should not be assumed to provide planetary-scale gravitational counterbalance; any such effect must be supported by the game's established fictional wormhole/EM mechanics.

Planet Nine is hypothetical and is not part of the current Sol placement baseline. Other moons or small bodies may be evaluated later, but no additional anchor is established here.

No exact orbital position, AWS count, pairing, gravity calculation, or final Sol network topology is approved. StarSim and AI Manager should eventually be able to evaluate candidate configurations rather than rely on a hard-coded one-station-per-planet rule.

---

## Key Early / Pre-Player Infrastructure Assets

### Artificial Magnetosphere (Mars L1)

The artificial magnetosphere is the primary long-term solution for retaining a rebuilt Martian atmosphere against solar-wind stripping. Without it, continuous bulk injection of volatiles remains a permanent utility cost ("leaky bucket").

- **Position:** Mars–Sun L1 (approximately 1 million miles ahead of Mars)
- **Core hardware:** Superconducting magnet coils, nuclear/fusion power cores, heavy structural alloys
- **Material sourcing:** Superconducting material mined from Ceres/Belt, delivered to Mars L1 depot for assembly
- **Tier evolution:** Tier 1 (fusion-powered, 60–80% retention) → Tier 2 (Electromagnetic-core (EM-core) retrofit, 95%+) → Tier 3 (wormhole-stabilized, ~100%)
- **Prerequisite relationship:** High-throughput atmospheric injection requires the magnetosphere to be active before gas injection begins

> **Cross-link:** For full magnetosphere architecture, power tiers, and alternative designs, see **[Artificial Magnetosphere](../infrastructure/artificial_magnetosphere.md)**.

### Venus–Mars Ballistic Corridor (Brute-Force Loop)

The brute-force terraforming loop delivers engineered gas-pods from Venusian processing infrastructure into the Martian atmosphere:

1. Venusian CO₂ cracking at high-altitude aerostat stations
2. CNT shell manufacturing from processed carbon
3. Mass driver launch of frozen O₂/N₂ pods on alignment windows
4. Engineered Martian reentry dispersion (CNT shells ablate at target altitude)

The corridor is gated behind cycler operations: real terraforming programs do not begin until sustained logistics (Mars–Saturn/Titan cycler) are established.

> **Cross-link:** For full ballistic corridor mechanics including pod specifications, launch architecture, and reentry dispersion, see **[Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md)**.

### Pre-Player Era Logistics Pipeline

The deterministic expansion sequence that bootstraps all Sol infrastructure:

1. **Phase 1:** Sol Core & Luna Industrial Bootstrapping (HLTs, Luna surface extraction, Venus skimming, LEO/L1 depots)
2. **Phase 2:** Earth L1 Shipyards & Fleet Scaling (L1 industrial hubs, capital craft fabrication)
3. **Phase 3:** Mars Moon Conversion & Slag Economy (tug deployment, Phobos/Deimos hollowing, slag propulsion)
4. **Phase 4:** Belt Expansion & Asteroid Repositioning (belt operations, no-moon anchoring, cycler network lock)

> **Cross-link:** For the full pipeline specification including autonomous trade corridors, bootstrapping mechanics, and transit decay models, see **[Pre-Player Era Logistics Pipeline](../infrastructure/pre_player_era_logistics_pipeline.md)** and **[Station Construction Pipeline](../infrastructure/pre_player_era_logistics_station_construction_pipeline.md)**.

---

## Corporate / Institutional Actors in Sol

| Entity | Role |
|---|---|
| **Lunar Development Corporation (LDC)** | Manages initial lunar settlements; construction partner in Wormhole Transit Consortium |
| **AstroLift** | Primary early logistics corporation; operates orbital logistics including LEO depots, cyclers, and tugs; combines with LDC to form the Wormhole Transit Consortium |
| **Venus Development Corporation (VDC)** | Cloud cities, Venus atmospheric harvesting operations |
| **Wormhole Transit Consortium** | Emerges from crisis; regulates core arterial natural mouths and primary AWS lanes |
| **Saturn/Titan Administration (SDC/TDC)** | Saturn system administration, Titan mining colony operations |

---

## Player Entry Window (Working Intent)

Players enter after Sol core buildout and the reconnection effort toward Eden is underway (AWS path). The universe already has markets, routes, and a frontier.

- **Spawn:** At a player-chosen open Development Corporation foothold base
- **First loop:** Tutorial mode teaches basics at that location
- **Available systems:** Markets, cycler routes, Eden frontier for survey/salvage/logistics/claims

The exact timing is not locked — it is a working intent, not a fixed campaign script.

---

## Open Questions

- Exact orbital elements (semi-major axes, eccentricities, inclinations) for all bodies
- Star mass, radius, luminosity, temperature values
- Habitable zone boundaries in AU
- Natural wormhole mouth location within Sol system
- Precise post-reconnection state of Eden (Ghost / Remnant / Expanding bands are possible outcomes)
- Exact EM yield curve and units
- Stabilization-satellite and feed-back rates
- Whether brinkmanship farming (pushing a mouth toward instability to farm ejection spikes) is encouraged, neutral, or discouraged by institutional policy
- Ownership and licensing of EM taps on regulated mouths
- How much residual pre-Snap EM remains harvestable in Eden after reconnection
- Exact trigger mass for controlled Snap and relation to mass threshold
- Buffer size (Saturation Limit) per station and satellite

---

## Relationship to Other Pages

| Page | Relationship |
|---|---|
| [Celestial Systems Template](celestial_systems.md) | Per-system documentation template; use this page as a concrete Sol example, not the procedural generator |
| [System Blueprints & Procedural Generation](system_blueprints.md) | StarSim procedural generation spec; Sol is predefined, not procedurally generated |
| [Scenario: Super Mars](scenario_super_mars.md) | Test-bench scenario using moonless planetary colonization patterns derived from Sol logistics |
| [Natural Wormholes & EM](../technical/natural_wormholes_and_em.md) | Full natural wormhole physics; Sol's mouth and the Snap event |
| [Artificial Magnetosphere](../infrastructure/artificial_magnetosphere.md) | Mars L1 shield architecture |
| [Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md) | Brute-force terraforming loop mechanics |
| [Portals & AWS](../technical/portals_and_aws.md) | Artificial wormhole stations and intra-system portal networks |
| [Pre-Player Era Logistics Pipeline](../infrastructure/pre_player_era_logistics_pipeline.md) | Deterministic expansion sequence |
| [Station Construction Pipeline](../infrastructure/pre_player_era_logistics_station_construction_pipeline.md) | Station construction vs. operational use |
| [Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md) | Venusian skimming and atmospheric engineering |
| [Terraforming Options](../infrastructure/terraforming_options.md) | Planetary-scale atmosphere modification options |
| [Luna Settlement Lifecycle](../../../docs/design/LUNA_SETTLEMENT_LIFECYCLE.md) | Three-phase industrial lifecycle of lunar settlement |
| [Sol Core Buildup](../../../docs/gameplay/sol_core_buildup.md) | Preferred early Sol dependency chain and player-entry window |
| [Lore Canon](../../../docs/storyline/11_lore_canon.md) | Canonical lore for Sol-era narrative elements |

---

*This page is a living reference. Mark anything not clearly stated as OPEN. Do not invent orbital elements, masses, resource quantities, or station counts.*
