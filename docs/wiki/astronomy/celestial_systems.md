# Celestial Systems — Technical Specification Template

> **Wiki section:** Development · **Status:** needs review against current game (this file is a per-system template)

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* This page remains a design-intent template. Celestial body structures, seed hash keys, and wormhole compliance rules are grounded in `StarSim::ProceduralGenerator`, `StarSim::SystemGeneratorService`, and `Wormhole` model as of Phase 3 (see [system_blueprints.md](./system_blueprints.md) for verified procedural generation data). No Sol-system archetype is populated — use this template to create per-system docs, or refer to the Alpha Centauri hybrid seed at `StarSim::SystemBuilderService` path and the Super-Mars scenario for concrete examples.

> **How to use this template:** Copy this file and rename it to match the system being documented (e.g., `Celestial-Systems-Sol.md`, `Celestial-Systems-Kepler-Reach.md`). Fill in every section. Do not leave template placeholder text in a committed wiki page. Sections that are genuinely not applicable to a system should be marked `N/A — [reason]`, not deleted.

> **Authoritative source:** All physical constants and generation parameters referenced here must match `config/initializers/game_constants.rb`. If a discrepancy is found, the code is authoritative and this wiki page must be corrected.

---

## System Identity

*The galaxy- and solar-system-level identifiers that anchor all celestial bodies in this system.*

| Field | Value |
|---|---|
| **System Name** | [Human-readable name, e.g. "Sol Sector Prime"] |
| **System Identifier** | [Machine identifier, e.g. "SYS-SOL-CORE-01"] |
| **Galaxy** | [Galaxy name and identifier, e.g. "Milky Way / MILKY-WAY"] |
| **Generation Path** | [One of: Predefined / Random Procedural / Hybrid (Alpha Centauri pattern) / Prize Target] |
| **Naming Status** | [One of: `scientific_catalog` / `settlement_named`] |
| **Original Scientific ID** | [If renamed: the original catalog identifier before settlement naming] |
| **Phase Documented** | [Phase number and status at time of documentation] |

> Naming lifecycle: systems are generated with scientific catalog identifiers. When a player or AI initiates settlement, `rename_system_for_settlement` replaces the identifier with a proper settlement name via `NameGeneratorService#generate_star_proper_name` and updates `naming_status` to `"settlement_named"`.

---

## Stellar Profile

*Stars in the system. Most playable systems have one star; binary/multiple-star systems follow the same structure per star.*

### Star 1 — [Star Name]

| Field | Value |
|---|---|
| **Identifier** | [e.g. "STAR-SOL-01"] |
| **Spectral Type** | [e.g. "G2V"] |
| **Stellar Class** | [e.g. "Main Sequence"] |
| **Mass** | [Solar masses, e.g. 1.0 M☉] |
| **Radius** | [Meters, e.g. 6.9634e8 m] |
| **Luminosity** | [Solar luminosity units, e.g. 1.0 L☉] |
| **Temperature** | [Kelvin, e.g. 5778 K] |
| **Life Stage** | [One of: `main_sequence` / `subgiant` / `giant` / `white_dwarf`] |
| **Age** | [Years, e.g. 4.6e9 years] |
| **Habitable Zone (r_ecosphere)** | [AU, e.g. 0.95 – 1.37 AU] |

> Spectral type selection is weighted during procedural generation: M (76%), K (12%), G (7.6%), F (3%), A (0.6%), B (0.1%), O (0.01%). For predefined systems, these values come from JSON seed data.
> Binary/multiple-star systems are handled via the `"stars"` array in the seed hash — see [system_blueprints.md](./system_blueprints.md) for multi-star orbital gap-filling logic.

---

## Wormhole Connectivity

*Wormholes are the only FTL transit mechanism in Galaxy Game. They are **not** part of the celestial body seed hash; they are a separate `Wormhole` model with its own lifecycle.*

> **Guardrail:** Terms "Ring Gate", "jump gate", and "jump point" must not appear in this document. Maximum wormholes per system: `MAX_WORMHOLES_PER_SYSTEM = 3`. All endpoint distances must fall between `SAFE_DISTANCE_FROM_STAR = 1.496e8 m` (1 AU) and `MAX_DISTANCE_FROM_STAR = 1.496e10 m` (100 AU). Endpoint positions within that range are tracked in local spatial grid units by the stabilizer subsystem — these are a separate coordinate space and must not be compared against macro meter values.

### Active Wormholes

*One entry per wormhole. Maximum 3 entries.*

#### Wormhole 1 — [Wormhole ID, e.g. "wh-alpha-vector-01"]

| Field | Value |
|---|---|
| **Wormhole ID** | [e.g. "wh-alpha-vector-01"] |
| **Type** | [Natural / Artificial] |
| **Destination Type** | [One of: `new_system` / `new_galaxy` / `known_system`] |
| **Destination System** | [System name and identifier, or "Unresolved" if `destination_system_id` is null] |
| **Endpoint Distance from Star** | [AU and meters, e.g. "30 AU / 4.488e9 m"] |
| **Stability Status** | [One of: `stable` / `degrading` / `critical` / `collapsed`] |
| **Age** | [Seconds and human-readable, e.g. "345,600 s / ~4 days"] |
| **Max Age** | ["2,592,000 s / 30 days" — derived from `WORMHOLE_MAX_AGE = 30.days`] |
| **Operational Stabilizers** | [Count of stabilizers meeting both: `power_level >= 25` AND `grid_distance_to_singularity <= 100.0` grid units] |

**Stabilizer Detail:**

| Device ID | Power Level | Grid Distance to Singularity | Operational? |
|---|---|---|---|
| [stb-node-alpha] | [e.g. 75] | [e.g. 5.8 grid units] | [Yes / No] |
| [stb-node-beta] | [e.g. 52] | [e.g. 31.4 grid units] | [Yes / No] |

> A `stable` wormhole requires a minimum of `MIN_STABILIZERS_REQUIRED = 2` operational stabilizers. If fewer than 2 are operational, status must be `degrading` or worse. Endpoints shift via `Wormhole#shift_endpoint!` (uses `rand(-MAX_DISTANCE_FROM_STAR..MAX_DISTANCE_FROM_STAR)` for x/y/z coordinates). Stabilizer compliance checks use `GameConstants::STABILIZER_EFFECTIVE_RANGE`.

#### Wormhole 2 — [ID]

*[Repeat entry structure above]*

#### Wormhole 3 — [ID]

*[Repeat entry structure above]*

### Wormhole History

*Log of collapsed or previously active wormholes for this system.*

| Wormhole ID | Type | Destination | Collapse Reason | Collapsed At |
|---|---|---|---|---|
| [ID] | [Natural/Artificial] | [Destination] | [Age expiry / Stabilizer failure / Unknown] | [Timestamp] |

> Wormholes older than `WORMHOLE_MAX_AGE` (30 days) are flagged for collapse before new ones generate. The `WORMHOLE_MAINTENANCE_INTERVAL = 1.hour` stabilizer health check runs independently of generation and does not create new wormholes — it only validates existing stabilizer power and range compliance.

---

## Planetary & Body Profiles

*One section per significant body. Order: planets by orbital distance (inner to outer), then moons, then asteroid depots.*

> **Settlement pattern guardrail:** Each body section must explicitly declare which settlement pattern applies. Do not document a settlement plan that violates the pattern without a formal design exception noted in this file. For settlement patterns themselves, see [settlement_infrastructure.md](../infrastructure/settlement_infrastructure.md).

---

### Body 1 — [Planet Name] ([Type])

**Classification:** [AR model class, e.g. `CelestialBodies::Planets::Rocky::TerrestrialPlanet`]

> Terrestrial planets are produced by `ProceduralGenerator#generate_terrestrial_planets` (procedural path) or `generate_from_template` (~40% chance via `TERRAFORMABLE_CHANCE = 0.4`). See [system_blueprints.md](./system_blueprints.md) for the full seed field reference.

#### Physical Profile

| Field | Value |
|---|---|
| **Identifier** | [e.g. "PLANET-MRZ-02"] |
| **Mass** | [kg, e.g. 6.417e23 kg] |
| **Radius** | [meters, e.g. 3.389e6 m] |
| **Gravity** | [m/s², e.g. 3.72 m/s²] (derived) |
| **Density** | [g/cm³ or derived value] (mass / volume) |
| **Size** | [Earth radii, e.g. 0.53 R⊕] (radius / 6.371e6) |
| **Albedo** | [0.0–1.0, e.g. 0.25] (procedural range: 0.1–0.6; clamped 0.05–0.9 from template) |
| **Orbital Distance** | [AU and meters — must be within `SAFE_DISTANCE_FROM_STAR` to `MAX_DISTANCE_FROM_STAR`] |
| **Orbital Period** | [Earth days] |
| **Surface Temperature** | [Kelvin] (recalculated from orbit after placement) |
| **Surface Pressure** | [Pascals and atm] (`known_pressure` in seed is atm) |
| **Status** | [One of: `active` / `inactive` / `destroyed`] |
| **From Template** | [Yes / No — whether body was derived from `alien_world_templates_v1.1.json`] |

#### Atmosphere

*Produced by `AtmosphereGeneratorService#generate_composition_for_body`. Added as a symbol-keyed field during generation.*

| Gas | Percentage |
|---|---|
| [e.g. CO2] | [e.g. 95.32%] |
| [e.g. N2] | [e.g. 2.60%] |
| [e.g. Ar] | [e.g. 1.90%] |
| [e.g. O2] | [e.g. 0.13%] |
| **Total** | **100.00%** |

**Breathable:** [Yes / No]  
**Terraforming Status:** [Untouched / Active warming phase / Breathable-maintenance phase / Fully terraformed]

> If CO2 exceeds 0.5% and the planet is in breathable-maintenance phase, `AtmosphereProcessor.run_maintenance` will flag this. For atmospheric engineering targets (breathability constraints, EARTH_ATMOSPHERE baselines), see [atmospheric_harvesting.md](../infrastructure/atmospheric_harvesting.md).

#### Hydrosphere

*Produced by `HydrosphereGeneratorService#generate`.*

| Field | Value |
|---|---|
| **Water Coverage** | [%, e.g. 0% / 35% / 71%] |
| **State Distribution** | [e.g. "100% solid ice" / "70% liquid, 30% solid"] |
| **Liquid Type** | [Water / Methane / Other] |
| **Ocean Bodies** | [Description or N/A] |

#### Geosphere

| Field | Value |
|---|---|
| **Geological Activity** | [0–100 scale — procedural range: 10–90] |
| **Tectonic Activity** | [Active / Inactive] |
| **Crust Composition** | [Key minerals and percentages, or "see properties JSONB"] |

#### Biosphere

| Field | Value |
|---|---|
| **Biodiversity Index** | [0.0–1.0] |
| **Habitable Ratio** | [0.0–1.0] |
| **Biomes Present** | [List or N/A] |
| **Life Forms** | [Description or "None detected"] |

#### Human Life Support Assessment

*Evaluated against `GameConstants::HUMAN_LIFE_SUPPORT` parameters.*

| Parameter | Required | Current | Status |
|---|---|---|---|
| O2 partial pressure | ≥ 16.0 kPa | [value] | [Met / Not met] |
| CO2 partial pressure (long-term) | ≤ 1.0 kPa | [value] | [Met / Not met] |
| CO2 partial pressure (emergency) | ≤ 4.0 kPa | [value] | [Met / Not met] |
| Total pressure (unsuited) | ≥ 33.0 kPa | [value] | [Met / Not met] |
| Surface temperature | 283.15–303.15 K | [value] | [Met / Not met] |

**Open-surface operations without pressure suit:** [Safe / Requires suit]

> See [atmospheric_harvesting.md](../infrastructure/atmospheric_harvesting.md) for breathability constraints and market economics of gas import vs. local harvesting.

#### Satellites

*One entry per moon. If no moons, write "None — see Settlement Pattern." Moons are produced by `generate_moons_for_planet` in 60% of terrestrial planets.*

##### Moon [n] — [Moon Name]

**Classification:** [`CelestialBodies::Satellites::LargeMoon` / `CelestialBodies::Satellites::SmallMoon`]

| Field | Value |
|---|---|
| **Identifier** | [e.g. "LUNA-01"] |
| **Mass** | [kg] |
| **Radius** | [meters] |
| **Gravity** | [m/s²] |
| **Orbital Period** | [Earth days] |
| **Surface Temperature** | [Kelvin] |
| **Tidal Locking** | [Yes / No / Partial] |
| **Geological Classification** | [LargeMoon only — e.g. "Silicate / Volcanic"] |

#### Settlement Pattern

> Select one pattern. Delete the other. Do not use both. For detailed settlement infrastructure across tiers, see [settlement_infrastructure.md](../infrastructure/settlement_infrastructure.md).

---

**PATTERN A — LARGE MOON PRESENT (Luna Pattern)**

This body has a qualifying large moon. Settlement follows the Luna Pattern:

1. **Phase 1 — Moon Settlement:** Establish primary colony on [Moon Name]. All initial construction materials sourced locally where possible.
2. **Phase 2 — L1 Depot Construction:** Build L1 orbital depot between [Moon Name] and [Planet Name] surface before any planet approach. Depot must be operational before Phase 3 begins.
3. **Phase 3 — Planet Surface Approach:** Planet-side resource harvesting begins only after L1 depot is confirmed operational. Earth imports are minimised throughout.

**AI Manager Tasks Required:**
- [ ] Moon surface colony establishment
- [ ] Local material sourcing assessment on [Moon Name]
- [ ] L1 depot construction mission
- [ ] L1 depot operational confirmation gate
- [ ] Planet surface resource harvesting mission (blocked until L1 gate passes)

---

**PATTERN B — NO LARGE MOON (Asteroid Depot Pattern)**

This body has no qualifying large moon. Settlement follows the Asteroid Depot Pattern:

**Candidate Asteroids for Depot Conversion:**

| Asteroid | Identifier | Mass | Radius | Orbital Distance | Proposed Role |
|---|---|---|---|---|---|
| [Name] | [ID] | [kg] | [m] | [AU] | [Primary depot / Secondary depot / Mining station] |

1. **Phase 1 — Asteroid Conversion:** Convert primary candidate asteroid into a station/depot. All staging infrastructure is built here.
2. **Phase 2 — Depot Operational Gate:** Depot must be confirmed operational before surface approach begins.
3. **Phase 3 — Planet Surface Approach:** Resource harvesting begins only after asteroid depot is operational.

**AI Manager Tasks Required:**
- [ ] Asteroid candidate survey and selection
- [ ] Asteroid depot conversion mission
- [ ] Depot operational confirmation gate
- [ ] Planet surface resource harvesting mission (blocked until depot gate passes)

---

#### Market Economics Cross-Reference

*Pricing and logistics for this body's resources.* For NPC pricing, EAP ceilings, warehouse caps, and the full order lifecycle, see [resource_and_market_logistics.md](../logistics/resource_and_market_logistics.md). For market bootstrapping and AI-driven price stabilization, see [market_and_ai_bootstrapping.md](../logistics/market_and_ai_bootstrapping.md).

| Parameter | Value |
|---|---|
| **Market Status** | [e.g. "unclaimed_procedural" / "settlement_named"] |
| **EAP Floor (per kg)** | [Calculated: Earth USD reference cost (+ refining) + transport at `INITIAL_TRANSPORTATION_COST_PER_KG`] |
| **Local Production Available** | [Yes / No — if local production exists, it overrides EAP with a locally-derived cost model] |
| **Primary Export Resource** | [e.g. "N2", "CO2", "O2"] |
| **Primary Import Dependency** | [e.g. "Food", "Water", "Electronics"] |

---

### Body 2 — [Name] ([Type])

*[Repeat full body section structure above]*

---

## System-Level Gap Tracking

*Issues that affect the system as a whole rather than a specific body.*

- [ ] [e.g. "Wormhole pre-check against registered graph state not implemented — system could receive a 4th wormhole seed before UniverseRegistrationJob rejects it"]
- [ ] [e.g. "Naming status still `scientific_catalog` — pending player settlement trigger to activate rename flow"]

---

## Generation Paths Reference

*How systems enter the game world. From `StarSim::SystemGeneratorService#generate!`:*

| Path | Trigger | Result |
|------|---------|--------|
| **Predefined** | System ID exists in `StarSystemLookupService` | JSON from `SYSTEMS_PATH` → `SystemBuilderService.build!` |
| **Random Procedural** | System ID not found in lookup | Seed hash from `ProceduralGenerator#generate_system_seed` → written to JSON → `fallback_build` |
| **Hybrid (Alpha Centauri)** | Seed file exists + terrain data | Ground-truth seed preserves all bodies; procedural fills orbital gaps |
| **Prize Target** | Prize target flag set | First 3 wormhole shift events produce a system containing at least one template planet (`TPL-A01` or `TPL-A05`) |
| **Accretion Mode** | `use_accretion: true` in generator init | Dust disk model replaces standard body generation (inner limit 0.1 AU, outer limit 40 AU, band width 0.5 AU) |

---

## Revision History

| Date | Author | Change Summary |
|---|---|---|
| [Date] | [Author] | Initial documentation |
| [Date] | [Author] | [Description of change] |

---

*Template version: Phase 3. Verify all constants against `config/initializers/game_constants.rb` before treating this page as authoritative.*
