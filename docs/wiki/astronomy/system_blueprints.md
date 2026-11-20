> **Wiki section:** Development · **Status:** needs review against current game — documents StarSim (system generation and JSON system loading), not manufacturing unit blueprints

# System Blueprints & Procedural Generation Spec
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-01  
> *Audit Summary:* Design intent specification. Code implementation pending or unverified as of audit baseline.

> **Scope:** Master design-by-contract specification for Galaxy Game's procedural star system generation engine. Grounded in `star_sim/system_generator_service.rb` and `star_sim/procedural_generator.rb` as reviewed during Phase 3. All field names, structures, and constants reflect actual source code — no invented fields.

---

> **Boundary:** This page documents **StarSim** system and celestial-body generation (seeds, JSON systems, procedural and predefined paths). It does **not** document **Map Studio** body-terrain or geographic map generation. For Admin terrain preparation and external map examples as learning references, see [Admin Dashboard and AI Manager](../ui/03_admin_and_ai_manager.md) and [Admin Celestial Body View](../ui/05_admin_celestial_body_view.md).

## 1. Component Map

| Role | Class / Path |
|---|---|
| Entry point | `StarSim::SystemGeneratorService` |
| Procedural seed generation | `StarSim::ProceduralGenerator` |
| Predefined system construction | `StarSim::SystemBuilderService` |
| Accretion-based generation (optional) | `StarSim::AccretionSimulationService` |
| System lookup / existence check | `Lookup::StarSystemLookupService` |
| Generated file output path | `GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH` |
| Predefined system JSON path | `Lookup::StarSystemLookupService::SYSTEMS_PATH` |
| Planet template files | `GalaxyGame::Paths::TEMPLATE_PATH` |

---

## 2. Generation Paths

`SystemGeneratorService#generate!` branches on whether the solar system's identifier exists in `Lookup::StarSystemLookupService`:

### Path A — Predefined System

If `StarSystemLookupService#system_exists?` returns `true`, the service delegates to `StarSim::SystemBuilderService.new(name: @solar_system.identifier).build!`. The builder reads the corresponding JSON file from `SYSTEMS_PATH` and constructs ActiveRecord objects directly.

**Special case — Alpha Centauri (`AC-01`):** Uses `ProceduralGenerator#generate_hybrid_system_from_seed` to load the ground-truth seed from `alpha_centauri.json`, lock in Proxima Centauri b with a fixed atmosphere (`90% N2, 10% CO2`), and procedurally fill the remaining orbits around Alpha Centauri A (1.23 AU) and B (0.71 AU). The hybrid result is written to `alpha_centauri_hybrid.json` before being passed to `SystemBuilderService`.

A generic version of hybrid seeding is also available via `ProceduralGenerator#generate_hybrid_system_from_seed_generic`, which preserves all bodies from a seed file and fills per-star orbital gaps without name-based logic.

### Path B — Random Procedural System

If the system identifier is not found in the lookup service, `generate_random_system` runs:

1. `StarSim::ProceduralGenerator#generate_system_seed` produces the full seed hash.
2. Outside test environment, the seed is written to `GENERATED_STAR_SYSTEMS_PATH` as `generated_{identifier}_{timestamp}.json`.
3. The solar system's `name` and `identifier` are updated from the seed and saved (bypassing validations).
4. `fallback_build` consumes the seed hash and creates ActiveRecord objects directly.

### Path C — Prize Target System

`ProceduralGenerator#generate_system_seed_with_prize_targets` wraps the standard seed generation and ensures the first 3 wormhole shift events produce a system containing at least one of the prize template planets (`TPL-A01` or `TPL-A05`) from `alien_world_templates_v1.1.json`.

### Path D — Accretion Mode

When `ProceduralGenerator` is initialized with `use_accretion: true`, `generate_celestial_bodies_via_accretion` replaces the standard body generation. It runs `AccretionSimulationService` per star using a dust disk model (inner limit 0.1 AU, outer limit 40 AU, band width 0.5 AU). Asteroids are not produced by accretion mode.

---

## System starting information, StarSim completion, and ongoing discovery

**OWNER-CONFIRMED DESIGN INTENT — evolving project understanding (2026-11-20).** GalaxyGame is unfinished and its system-generation design is still being explored and adjusted. This page records the current understanding reached while investigating JSON fixture defects; it is not a declaration that the overall StarSim architecture or data-directory layout is final.

### Active-system lifecycle, archival, and reactivation

**OWNER-CONFIRMED DESIGN INTENT — 2026-10-31; clarified 2026-11-20.** System existence in the game's retained data is distinct from being loaded into the active database and continuously processed by the simulation.

- A system is kept active while it has an active player presence or an active connection through the artificial wormhole network or a live natural wormhole. Stabilization satellites can keep a natural wormhole live, so a system being harvested through that route remains accessible and active.
- Once a system has no active player presence and no active wormhole-network connection—such as an explored, unsettled system whose natural wormhole has been shifted away—it can be exported to JSON and unloaded from the active database/simulation.
- The export preserves the system's current state and relevant information to the practical extent possible. The purpose is to stop processing an inaccessible system while retaining enough state to restore it later.
- If the system is reconnected or selected for settlement, its archived JSON can be loaded back into the database and active simulation can resume. Reloading the system record and establishing a current wormhole route are separate operations; an archived JSON export does not itself make the system reachable.

This lifecycle is an intended performance/persistence behavior, not a claim that automatic unload/reload is fully implemented. The exact export schema, completeness guarantees, trigger evaluation, background-job behavior, and restoration/consistency checks remain to be verified and designed against the evolving code.

### On-demand frontier generation and a bounded active universe

**OWNER-CONFIRMED DESIGN DIRECTION — 2026-11-20; implementation details OPEN.** GalaxyGame may create new star systems as exploration needs fresh destinations. Natural-wormhole discoveries can provide access to a genuinely unknown system, at which point StarSim can generate its starting system data and establish a new survey, exploration, and harvesting opportunity. This is distinct from reconnecting to a previously known system, which should restore its archived state rather than generate a replacement.

This supports a persistent but dynamically expanding universe without requiring every possible system to be generated, loaded, or simulated at once:

- Keep systems with active players, active network connections, or ongoing operational value in the active simulation.
- Archive systems that no longer need continuous processing, preserving their state so they can be restored if a future natural-wormhole connection or other gameplay event makes them relevant again.
- Generate new systems when a genuinely new frontier is revealed and gameplay calls for a destination, rather than pre-generating a vast inventory simply to reach a target count.
- Treat the active system population and the universe's retained/possible system population as different quantities. New discoveries can refresh exploration and harvesting opportunities while archival limits unnecessary active-world bloat.

This is a design opportunity, not a commitment to infinite generation, a fixed active-system cap, or automatic generation at every wormhole. The rules governing when a new system is generated, how novelty and quality are maintained, how system identity and history are preserved, and how generation is balanced against performance and gameplay remain OPEN. A natural wormhole may just as validly reconnect to a known or archived system.
 
### Starting information is not a complete system

A JSON file in the system-data tree is not, by itself, a complete or exhaustive playable system.

- **Sol is the only fixed, manually authored system baseline.** Its data has special preservation importance, but it is still an incomplete representation of the real Sol system. Not every real object or property is known or modeled. StarSim may generate or add further objects/details in Sol too.
- **Every other system begins as incomplete starting information.** This includes real astronomical systems with substantial known data, real systems with only a small amount of known data, and systems whose starting conditions are generated. The available information varies in quantity and confidence; none of these inputs should be treated as a finished playable inventory.
- Real-system source data records what is currently known or supplied. It does not imply that all planets, moons, minor bodies, orbital details, or physical properties are known.

### StarSim completion and population

StarSim uses the available starting information to establish a playable system. It must retain and use known information appropriately while completing or generating additional system content. Initial completion does not make the resulting inventory exhaustive or permanently closed.

This applies to Sol as well as every other system. A generated output is a snapshot/result of a generation or completion process, not a claim that every object in the real or simulated environment has been represented.

### Survey missions, discovery, and additional detail

Survey missions are part of how systems gain additional detail over time. Survey activity can help bring newly discovered objects and information into the represented/available system, including supporting the spawning or addition of further objects/details as exploration proceeds. The exact division between an object already existing in the simulation, its generation/spawning, its discovery, and when it becomes visible or known must be checked against the evolving mission and StarSim implementation; do not collapse those concepts into one assumed mechanic.

Keep distinct:
- **Simulated world state:** the objects and conditions currently represented in the simulation.
- **Available starting information:** the known or supplied data used to initialize or complete a system.
- **Discovered/recorded knowledge:** information obtained through surveys and made available to the relevant game actors.

These categories may overlap, but they are not automatically identical. Surveying is not simply a UI operation that reveals a guaranteed complete pre-authored catalog.

### Current data organization — observed, not finalized

The current main-app data tree includes `data/json-data/star_systems/` and `data/json-data/generated_star_systems/`.

- `star_systems/` currently contains Sol data and real-system source records of varying completeness. It is not a directory containing only complete playable systems. For non-Sol systems, these files are incomplete starting information for StarSim.
- `generated_star_systems/` contains generated system outputs/fixtures, including hybrid completions and fully generated examples. These outputs are also not exhaustive inventories and may be replaced or regenerated.
- Alpha Centauri illustrates a known-real-system input being completed by StarSim: `star_systems/alpha_centauri.json` is the known-data input; a generated hybrid output is a separate artifact.
- Eden is a role/selection requirement, not a permanent assignment to one generated file. Its essential requirement is that the selected system provide better terraforming targets than Sol. The current `AOL-732356` instance has been a working candidate, but the generated instance may be replaced.
- Other generated prototype examples, including FR-488530 and DJEW-716790, are replaceable test data, not permanent game-system identities.

The current directory arrangement may not be the best long-term organization. Separating real astronomical reference data, incomplete seeds, authored baselines, and generated/completed outputs may eventually be useful, but **no directory migration or taxonomy is decided here**. First understand the generator, lookup/loading paths, provenance needs, and UI discovery behavior. Document the current arrangement accurately; do not treat it as a finalized architecture.



### Galaxy-wide playable scale and system count

**OPEN GAMEPLAY / WORLD-SCALE QUESTION — OWNER-RAISED 2026-11-20**

The total number of star systems needed to create a satisfying GalaxyGame experience has not been decided. GalaxyGame should not assume that it needs thousands of systems simply because EVE Online uses a very large star-system universe or because some of its map and navigation concepts are useful references.

The relevant design question is what scale supports the intended gameplay: meaningful exploration and discovery, strategically distinct destinations, resource and settlement opportunities, useful natural-wormhole network topology, and enough room for network expansion without creating large amounts of low-value or operationally inaccessible content. The quality, diversity, relationships, and accessibility of systems may matter more than raw count.

No target, minimum, maximum, density, or required number of systems is established. Do not select an EVE-like count, generate systems merely to reach a large number, or treat the current set of generated examples as a target universe size. The appropriate scale should be evaluated against actual gameplay needs and the costs of generating, surveying, retaining, loading, and simulating systems. This is a design question, not a decision to constrain the universe to a small fixed count.

---

## 3. Seed Hash Structure

`ProceduralGenerator#generate_system_seed` returns a Ruby hash with the following top-level keys. This is the intermediate format consumed by `fallback_build` and written to JSON — it is **not** the same as the persisted ActiveRecord model structure.

```
{
  "galaxy"          => { ... },
  "solar_system"    => { ... },
  "metadata"        => { ... },
  "stars"           => [ ... ],
  "celestial_bodies" => {
    "terrestrial_planets" => [ ... ],
    "gas_giants"          => [ ... ],
    "ice_giants"          => [ ... ],
    "dwarf_planets"       => [ ... ],
    "asteroids"           => [ ... ]
  }
}
```

The hybrid generic path also includes `"moons"` as a key inside `"celestial_bodies"`.

**Wormholes are not part of the seed hash.** They are a separate system and are never generated or stored as part of system seed files.

### Dynamic wormhole network — owner-confirmed design intent

The wormhole network is not fixed by design and is separate from system seed data:

- **Natural wormholes** can shift through their lifecycle, potentially in response to reaching a mass limit; the Hammer Protocol can also deliberately force a natural exit to shift. A shift changes the current exit/connection and is distinct from an uncontrolled snap. The precise relationship between mass-limit exhaustion, shifting, and snapping remains to be reconciled in the natural-wormhole physics design.
- A natural shift can create a new survey opportunity. The AI Manager announces survey missions, players explore the newly accessible system, and survey findings establish whether it is a valuable prize with strong resource and terraforming targets.
- Discovery does not require immediate AWS construction or a forced shift. If a system is not selected for permanent reconnection or settlement, the AI Manager may deploy stabilization satellites and keep its natural wormhole open for as long as continued player harvesting is worthwhile and supportable.
- The AI Manager can later choose to use the Hammer Protocol to force the natural exit to shift, or remove the stabilization satellites and allow the wormhole to degrade naturally. These are distinct operational choices; neither is an automatic consequence of completing a survey.
- For a selected frontier, the AI Manager determines suitable AWS placement (potentially one or two stations in the new system) and coordinates construction while natural access remains open.
- Once the frontier AWS endpoint is ready, an active Sol-side AWS route serving another system can be disconnected and reassigned to connect Sol to the new station. The displaced route can be retargeted elsewhere, reorganizing rather than simply accumulating fixed links.
- After the artificial route provides durable access to Sol's industrial network, operators can use the Hammer Protocol to shift the natural exit to a new location and begin another survey cycle. If the system is not permanently integrated, the natural route can instead remain stabilized by satellites for ongoing harvesting; the AI Manager can eventually hammer it or remove the satellites and let it degrade naturally.
- **Artificial wormholes** can therefore be shut down and retargeted as part of deliberate network reconfiguration. System records and wormhole connection state remain distinct: a system may continue to exist in simulation/data while its former route is no longer active or accessible.
- Any UI, route planner, or network overview must use current connection state when determining available routes. Historical/configured connections are not proof of current traversability.

This is the owner's likely strategic expansion pattern, not yet a locked rule or an automatic result of every natural shift or survey. The AI Manager evaluates survey evidence, resource/terraforming value, infrastructure and logistics costs, and network priorities. Exact persistence, timing, event handling, AWS placement/pairing, route-reassignment mechanics, and runtime implementation must still be checked in code as the wormhole systems evolve.

### `galaxy` block

| Field | Type | Notes |
|---|---|---|
| `"name"` | String | Galaxy name; defaults to `"Milky Way"` |
| `"identifier"` | String | Galaxy identifier; defaults to `"MILKY-WAY"` |

### `solar_system` block

| Field | Type | Notes |
|---|---|---|
| `"name"` | String | Generated by `NameGeneratorService#generate_system_name` |
| `"identifier"` | String | Derived: `system_name.upcase.gsub(/\s+/, '-')` |

### `metadata` block

| Field | Type | Notes |
|---|---|---|
| `"naming_status"` | String | Always `"scientific_catalog"` at generation time |
| `"original_scientific_id"` | String | Set only after `rename_system_for_settlement` runs |
| `"vetted_for_system_a"` | Boolean | Set only on vetted system loads |

**Naming lifecycle:** Systems are generated with scientific catalog identifiers. When a player or AI initiates settlement, `rename_system_for_settlement` replaces the identifier with a proper settlement name via `NameGeneratorService#generate_star_proper_name` and updates `naming_status` to `"settlement_named"`.

### Story-system naming exception: `AOL-732356`

**OWNER-CONFIRMED CURRENT WORKING LABEL:** The generated system with identifier `AOL-732356` has been used with the working display name **Eden**. Eden is not a locked or final star-system name or permanent assignment to this particular generated system. `AOL-732356` remains the stable identifier of that specific system if it is retained; changing its display name must not change that identifier or break references. However, the game may select a different generated system for the Eden role if it provides better terraforming targets than Sol.

The working name is under review because the procedural generator also uses **Eden** as a planet name, creating possible system/body-name ambiguity, and **New Eden** is strongly associated with EVE Online. A replacement system name has not been selected. **Gaia** and **Aki Gaia** have been mentioned during discussion, but neither is confirmed as the final star-system name. Do not infer that either is the system name, and do not rename the JSON yet.

This is a specific owner-confirmed naming constraint for `AOL-732356`; it does not by itself establish a general change to the generator's naming lifecycle above.

### General naming intent: stable identity, flexible names, and aliases

**OWNER-CONFIRMED DESIGN INTENT — use this as the guide when reviewing or tuning name generation.** A celestial body's identity must be independent of the names used for it. Its stable identifier establishes which world it is; names describe how that world is referred to. Changing, adding, translating, or selecting a different name must not create a new body or change its identifier.

A single celestial body may have multiple valid names or aliases at the same time. These may come from different languages, cultures, naming traditions, scientific or astronomical conventions, historical periods, local usage, or informal nicknames. Names that look like different naming systems or styles are not necessarily names for different worlds. For example, **Earth**, **Sol III**, **Sol Prime**, and **Topaz** could be alternative names or designations for the same world in a particular setting; they are illustrative possibilities, not a fixed mapping.

Name generation should remain flexible and may select names from different traditions or patterns. **Prime**, Roman-numeral designations, and distinctive thematic names are naming possibilities, not universal rules that determine a body's physical role, orbital order, or uniqueness. A generated name such as Sol Prime does not imply that the world must be the primary habitable planet, and Sol III does not necessarily identify a different world. The same world may be known by different names in different languages or contexts.

When the naming model is tuned, preserve enough context to distinguish a body's names and their usage where useful (for example, language, culture or naming tradition, designation type, and historical or local context). Do not assume one universally preferred name, a one-name-per-body relationship, or a one-to-one relationship between a naming pattern and a distinct celestial body. Alias/name resolution must resolve all recognized names to the same stable body identity.

This section records intended behavior; it does **not** claim that the current generator, JSON format, or persisted model fully supports multilingual names and contextual aliases today. Verify the implementation and data model before treating those capabilities as complete.

#### Current persisted model — verified 2026-11-19

The current Rails implementation already separates a celestial body's stable identity from its names, but supports only a simple alias list:

- `celestial_bodies.identifier` is a required, unique string column and is the stable internal identity used to refer to the body.
- `celestial_bodies.name` is a separate string column for the body's primary stored name. The `CelestialBody#name` method falls back to `identifier` when the name column is blank.
- `celestial_bodies.properties` is a non-null JSONB column. `CelestialBody` exposes `aliases` through `store_accessor :properties`; aliases are currently stored as an array of plain strings.
- The shared `CelestialBody` model provides `all_names`, `has_alias?`, `add_alias`, `remove_alias`, and `find_by_name_or_alias`. Planet subclasses inherit this behavior; it is not planet-only.
- `all_names` combines the primary name and aliases. Name/alias lookup also checks the stable identifier.

**Current limitation:** Alias entries have no structured attributes. The implementation does not currently record a name's designation type, language, cultural or naming tradition, source/authority, historical period, or validity. The existing alias array therefore cannot fully represent the richer naming intent above. The current model also does not establish a separate canonical/preferred-name policy beyond the `name` column.

**Design direction, not implemented:** Keep the stable identifier and existing primary-name field. Evolve the names/aliases stored in the celestial body's `properties` metadata into structured name records when this capability is implemented. Each record should retain the name and relevant context (such as name type, language, cultural tradition, source, and historical/validity information). Do not imply that this richer structure or its resolution rules already exist in the Rails model or current JSON import path.

The code review confirmed the shared implementation in `app/models/celestial_bodies/celestial_body.rb`, the inherited planet model in `app/models/celestial_bodies/planets/planet.rb`, and the `celestial_bodies` table migration. The current database stores `identifier` and `name` as separate columns and `properties` as JSONB.


**Scientific grounding:** Prefer naming practices recognizable from real astronomy over arbitrary fictional rules. In particular, keep scientific designations distinct from proper/common names. A designation may be catalog- or survey-based and may combine letters and numbers; exoplanet designations commonly build on the host star's designation with a lowercase letter. That letter convention is generally tied to discovery order, not necessarily orbital order. A proper name can coexist with the scientific designation; it does not have to replace it. Real astronomy does not have one universal exoplanet naming convention, so GalaxyGame should not impose one rigid pattern on every generated system.

For multilingual naming, retain names in their language of origin where appropriate and support transliteration or language-specific forms. Do not assume every language form is a literal translation: names may be inherited, culturally distinct, historical, or locally used. Keep the stable body identity and the relationship among its designations, proper names, and aliases explicit. Use the scientific designation as a reliable disambiguating reference, while allowing context-appropriate names to be displayed.

This is a science-inspired design direction, not a claim that GalaxyGame must reproduce every IAU rule or approval process. The goal is credible, recognizable astronomical conventions with room for fictional systems, cultures, and naming histories.
---

### `stars` array

Each entry is produced by `ProceduralGenerator#generate_stars`. Spectral type is selected by weighted probability (M: 76%, K: 12%, G: 7.6%, F: 3%, A: 0.6%, B: 0.1%, O: 0.01%).

| Field | Type | Notes |
|---|---|---|
| `"name"` | String | From `NameGeneratorService#generate_star_name` |
| `"identifier"` | String | `star_name.upcase.gsub(/\s+/, '-')` |
| `"type"` | String | Spectral class e.g. `"G2V"`, `"M5V"` |
| `"mass"` | Float | Solar masses |
| `"radius"` | Float | Meters |
| `"luminosity"` | Float | Solar luminosity units |
| `"temperature"` | Float | Kelvin |

When stars are created as AR objects (in `fallback_build`), additional fields are set: `type_of_star`, `life` (`"main_sequence"`), `age`, `r_ecosphere`, and a `properties` hash containing `"spectral_class"` and `"stellar_class"`.

---

## 4. Celestial Body Seed Fields

### Terrestrial Planets

Produced by `generate_terrestrial_planets` (procedural path) or `generate_from_template` (template path, ~40% of planets via `TERRAFORMABLE_CHANCE = 0.4`).

**String-keyed fields (present in all terrestrial planet seeds):**

| Field | Type | Notes |
|---|---|---|
| `"name"` | String | Scientific catalog identifier initially; e.g. `"TEST-SYSTEM-P1"` |
| `"identifier"` | String | Same as name at generation; sanitized by `sanitize_identifiers!` |
| `"type"` | String | Always `"terrestrial"` |
| `"mass"` | Float | kg |
| `"radius"` | Float | meters |
| `"density"` | Float | Derived: `mass / volume` |
| `"gravity"` | Float | m/s², derived |
| `"albedo"` | Float | 0.1–0.6 procedural; clamped 0.05–0.9 from template |
| `"surface_temperature"` | Float | Kelvin; recalculated from orbit after placement |
| `"size"` | Float | Earth radii: `radius / 6.371e6` |
| `"known_pressure"` | Float | atm |
| `"geological_activity"` | Integer | 10–90 |
| `"geosphere_attributes"` | Hash | See below |
| `"from_template"` | Boolean | `true` if derived from alien_world_templates |
| `"orbits"` | Array | Single-entry array; see orbit structure below |

**Optional string-keyed fields:**

| Field | Type | When present |
|---|---|---|
| `"moons"` | Array | 60% of terrestrial planets; produced by `generate_moons_for_planet` |
| `"market_status"` | String | `"unclaimed_procedural"` on procedural and hybrid systems |
| `"from_seed"` | Boolean | `true` when body is preserved from a seed file in hybrid mode |

**Symbol-keyed fields (added after generation, not serialized to JSON by default):**

| Field | Notes |
|---|---|
| `:atmosphere` | Hash from `AtmosphereGeneratorService#generate_composition_for_body` |
| `:hydrosphere` | Hash from `HydrosphereGeneratorService#generate` |
| `:biosphere` | Hash from `ProceduralGenerator#generate_biosphere_data` |

When `generate_planet_at_orbit` is used (hybrid seeding), these are instead stored as string-keyed `"atmosphere_attributes"`, `"hydrosphere_attributes"`, and `"biosphere_attributes"` so they serialize to JSON correctly.

**`"geosphere_attributes"` hash:**

| Field | Type | Notes |
|---|---|---|
| `"geological_activity"` | Integer | 10–90 |
| `"tectonic_activity"` | Boolean | ~40% chance |
| `"total_crust_mass"` | Float | kg; 1–5% of body mass |
| `"total_mantle_mass"` | Float | kg; 60–70% of body mass |
| `"total_core_mass"` | Float | kg; 25–35% of body mass |

**`"orbits"` array entry:**

| Field | Type | Notes |
|---|---|---|
| `"around"` | String | Star name or `"Primary Star"` |
| `"semi_major_axis_au"` | Float | AU |
| `"eccentricity"` | Float | 0.0–0.3 |
| `"inclination_deg"` | Float | degrees |
| `"orbital_period_days"` | Float | Kepler's Third Law: `sqrt(a³) * 365.25` |
| `"distance"` | Float | Same value as `semi_major_axis_au` |

### Gas Giants

Produced by `generate_gas_giants`. Placed further out (orbit index offset +3).

| Field | Type | Notes |
|---|---|---|
| `"name"` | String | `"Gas Giant {n}"` |
| `"identifier"` | String | `"GAS_GIANT-{n}"` |
| `"type"` | String | `"gas_giant"` |
| `"mass"` | Float | 10–1000 Earth masses |
| `"radius"` | Float | 4–20 Earth radii |
| `"density"` | Float | Derived |
| `"gravity"` | Float | Derived |
| `"albedo"` | Float | 0.4–0.9 |
| `"surface_temperature"` | Float | Kelvin |
| `"orbits"` | Array | Same structure as terrestrial |
| `:atmosphere` | Hash | Symbol key; from `AtmosphereGeneratorService` |
| `:hydrosphere` | Hash | Symbol key; from `HydrosphereGeneratorService` |

### Ice Giants

Produced by `generate_ice_giants`. Placed further out (orbit index offset +5). Same field structure as gas giants with:
- `"type"` = `"ice_giant"`
- Mass range: 10–50 Earth masses
- Radius range: 3–5 Earth radii
- Albedo: 0.5–0.8

### Dwarf Planets

Produced by `generate_dwarf_planets`. Placed furthest out (orbit index offset +7).
- `"type"` = `"dwarf_planet"`
- Mass range: 0.01–0.1 Earth masses
- Radius range: 0.1–0.5 Earth radii
- Same core fields as gas giants; no `"geosphere_attributes"`

### Asteroids

Produced by `generate_asteroids` (5–15 per system).

| Field | Type | Notes |
|---|---|---|
| `"name"` | String | Sanitized to `"{SYSTEM}-AST-{n}"` by `sanitize_identifiers!` |
| `"identifier"` | String | Same format |
| `"type"` | String | `"asteroid"` |
| `"mass"` | Float | kg |
| `"radius"` | Float | meters |
| `"diameter_km"` | Float | `(radius * 2) / 1000` |
| `"density"` | Float | Derived |
| `"gravity"` | Float | Derived |
| `"albedo"` | Float | 0.05–0.3 |
| `"surface_temperature"` | Float | Kelvin |
| `"orbits"` | Array | Belt zone: 2.0–4.0 AU |

---

## 5. ActiveRecord Model Hierarchy

`fallback_build` maps seed data to the following AR model classes. The full planet subclass taxonomy is larger than what `fallback_build` currently samples — additional subclasses exist in the codebase and will require generator updates.

**Currently sampled by `fallback_build`:**

| Seed Type | AR Class |
|---|---|
| Terrestrial (procedural/template) | `CelestialBodies::Planets::Rocky::TerrestrialPlanet` |
| Super-Earth | `CelestialBodies::Planets::Rocky::SuperEarth` |
| Gas Giant | `CelestialBodies::Planets::Gaseous::GasGiant` |
| Ice Giant | `CelestialBodies::Planets::Gaseous::IceGiant` |
| Ocean Planet | `CelestialBodies::Planets::Ocean::OceanPlanet` |
| Small Moon | `CelestialBodies::Satellites::SmallMoon` |
| Large Moon | `CelestialBodies::Satellites::LargeMoon` |

**Known additional subclasses not yet mapped by the generator `[PENDING generator update]`:**

| AR Class | Namespace |
|---|---|
| `CelestialBodies::Planets::Rocky::LavaWorld` | Rocky |
| `CelestialBodies::Planets::Rocky::CarbonPlanet` | Rocky |
| `CelestialBodies::Planets::Ocean::HyceanPlanet` | Ocean |
| `CelestialBodies::Planets::Ocean::WaterWorld` | Ocean |

> **Phase 3 task:** The generator's `planet_types` array in `fallback_build` must be expanded to include all confirmed subclasses. Each addition requires corresponding `minimum_mass_for_type`, `minimum_radius_for_type`, `minimum_gravity_for_type`, `random_mass_for_type`, `random_radius_for_type`, `random_density_for_type`, and `random_gravity_for_type` case branches.

**All celestial body AR models share these base fields** (from `CelestialBody` factory):

`name`, `identifier`, `size`, `gravity`, `density`, `mass`, `radius`, `status`, `orbital_period`, `albedo`, `insolation`, `surface_temperature`, `known_pressure`, `properties` (JSONB)

**All bodies auto-create these AR associations after save:**

`Atmosphere`, `Hydrosphere`, `Geosphere`, `Biosphere`, `SpatialLocation` (x/y/z coordinates), `StarDistance`

---

## 6. The Validation Gap — Architectural Directive

> **CRITICAL PHASE 3 DEBT ITEM**

`SystemGeneratorService#fallback_build` and `ProceduralGenerator`'s generation methods do not validate generated orbital distances against `GameConstants::SAFE_DISTANCE_FROM_STAR` or `GameConstants::MAX_DISTANCE_FROM_STAR`. A planet or asteroid can be placed at an orbital distance that violates the macro spatial envelope and will be persisted silently.

Additionally, `fallback_build` uses `planet_class = planet_types.sample` with no weighting — body type distribution is currently uniform random across the 5 sampled types, which does not reflect realistic stellar system composition.

### Mandated Validation

The following exception and guard must be implemented in `UniverseRegistrationJob` (for JSON-path systems) and in `fallback_build` (for procedural AR-path systems) before Phase 4:

```ruby
class InvalidSystemBoundariesError < StandardError; end

def validate_orbital_distance!(body_name, semi_major_axis_au)
  distance_m = semi_major_axis_au * 1.496e11 # AU to meters

  if distance_m < GameConstants::SAFE_DISTANCE_FROM_STAR
    raise InvalidSystemBoundariesError,
      "'#{body_name}' at #{semi_major_axis_au} AU is inside the inner safety boundary (1 AU / #{GameConstants::SAFE_DISTANCE_FROM_STAR} m)"
  end

  if distance_m > GameConstants::MAX_DISTANCE_FROM_STAR
    raise InvalidSystemBoundariesError,
      "'#{body_name}' at #{semi_major_axis_au} AU exceeds the outer macro boundary (100 AU / #{GameConstants::MAX_DISTANCE_FROM_STAR} m)"
  end
end
```

Note: orbital distances in the seed are stored as AU (`semi_major_axis_au`). The macro constants are in meters. Conversion: `au * 1.496e11 = meters`. This conversion must be explicit in any validation — do not compare AU values directly against the meter constants.

### Coordinate Space Isolation Reminder

The macro spatial constants (`SAFE_DISTANCE_FROM_STAR`, `MAX_DISTANCE_FROM_STAR`) are in **meters** and apply to system-level orbital placement. The wormhole stabilizer constants (`STABILIZER_EFFECTIVE_RANGE = 100.0`) are in **local spatial grid units** and are entirely separate. These two systems must never be compared against each other. The commented-out `# MAX_DISTANCE_FROM_STAR = 1000.0` in `game_constants.rb` is a legacy artifact in local grid units and is not active.

---

## 7. Template System

`ProceduralGenerator` loads terraformable planet templates at initialization:

- Primary: `GalaxyGame::Paths::TEMPLATE_PATH/alien_world_templates_v1.1.json`
- Fallback: `GalaxyGame::Paths::TEMPLATE_PATH/alien_world_templates_v1.json`

Templates are filtered to `type == "terrestrial"` only. Required template fields (enforced by spec): `type`, `mass`, `radius`, `density`, `gravity`, `albedo`, `known_pressure`, `surface_temperature`, `geological_activity`, `geosphere_attributes`.

Template-derived planets are marked `"from_template": true`. Mass and radius receive ±5% variation via `generate_from_template`; density, gravity, and size are recalculated from the varied values. Albedo is also varied ±5% and clamped to `[0.05, 0.9]`.

Terraformable planets receive preferential orbital placement via `generate_optimized_orbital_parameters`, biasing toward the star's habitable zone. Procedural planets use `generate_orbital_parameters` which spaces planets by exponential distance from the star.

---

## 8. Gap Tracking & Known Issues

- [ ] **`fallback_build` — no orbital boundary validation:** Planets and moons are created without checking `SAFE_DISTANCE_FROM_STAR` or `MAX_DISTANCE_FROM_STAR`. Implement `validate_orbital_distance!` before Phase 4.
- [ ] **`fallback_build` — incomplete planet type coverage:** `LavaWorld`, `CarbonPlanet`, `HyceanPlanet`, `WaterWorld` are not yet in the `planet_types` sample array. Requires helper method branches for each new type.
- [ ] **`fallback_build` — uniform type sampling:** All 5 current types are sampled with equal probability. Should use weighted distribution reflecting realistic system composition (more terrestrial/rocky, fewer giants).
- [ ] **`generate_stars` stub vs full implementation:** `ProceduralGenerator#generate_stars` (the simple version, lines 36–45) produces only `name`, `identifier`, `mass`, and `galaxy` — it is a stub compared to the full `generate_stars` private method (lines 440–485) which includes full spectral class generation. The public stub must be removed or consolidated.
- [ ] **Symbol vs string key inconsistency in seed:** Sphere data (`:atmosphere`, `:hydrosphere`, `:biosphere`) is stored as symbol keys in the terrestrial planet seed but as string keys (`"atmosphere_attributes"`) in `generate_planet_at_orbit`. This inconsistency must be resolved before the seed format is treated as a stable contract.
- [x] **`known_pressure` field:** Set as `rand(0.1..2.0)` in procedural generation. **Unit confirmed: atm** — verified via sol-complete.json values (Venus=92, Earth=1.0, Mars=0.006) and consistent with `EARTH_ATMOSPHERE`/`HUMAN_LIFE_SUPPORT` constants.

---

*Last verified against: `star_sim/system_generator_service.rb`, `star_sim/procedural_generator.rb`, `spec/factories/celestial_bodies.rb` — Phase 3 (Integration & Restoration)*
