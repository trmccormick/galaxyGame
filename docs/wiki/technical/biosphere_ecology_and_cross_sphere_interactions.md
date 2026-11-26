# Biosphere Ecology & Cross-Sphere Interactions

> **Code Alignment Status:** `VERIFIED AGAINST CODE`  
> *Last Audited:* 2026-11-26
> *Audit Summary:* Existing biosphere model and biology records confirmed in code; ecosystem coupling paths verified with simplified behavior.

> **Status:** ESTABLISHED BIOSPHERE MODEL AND BIOLOGY RECORDS; ecosystem and environmental coupling paths exist with simplified behavior and overlapping update mechanisms  
> **Last audited:** 2026-11-21  
> **Code inspected:** Biosphere model/concern, Biology life-form models, PlanetBiome, StarSim BiosphereGeneratorService and SystemBuilder, TerraSim BiosphereSimulationService, BiosphereGeosphereInterfaceService, and Simulator

## Purpose and boundaries

The Biosphere is an established CelestialBody sphere. It owns biological/ecological state and relationships; it is not merely a habitability score or a list of biome labels. The existing implementation includes biome associations, life-form records and populations, vegetation/moisture state, biodiversity and habitability measures, atmospheric effects, and a Geosphere soil-health coupling.

This page documents current data ownership and code behavior. It does not propose a new biosphere architecture or imply that every biological process is modeled at scientific fidelity.

See [Celestial Body & Sphere Data Model](celestial_body_and_sphere_data_model.md) and [Celestial-Body Sphere Models & Environmental Interactions](sphere_models_and_interactions.md) for the wider sphere model and TerraSim overview.

## 1. Model ownership and records

### Biosphere

`CelestialBodies::Spheres::Biosphere` belongs to a `CelestialBody` and owns:

- `Biology::LifeForm` records through `life_forms`;
- `CelestialBodies::PlanetBiome` records through `planet_biomes`;
- biome associations through `biomes`;
- polymorphic `CelestialBodies::Material` records through `materials`;
- aggregate attributes including biodiversity, habitability, biome distribution, soil-health and soil-quality fields, and base values.

Biosphere temperature accessors delegate to the body's Atmosphere temperature data. Tropical and polar temperatures are therefore not independent Biosphere-owned temperature inventories.

The model's `biome_distribution` JSON and the relational `planet_biomes` association are separate representations. The JSON stores named distribution values; `PlanetBiome` stores the association and regional properties used by simulation. Do not assume one is automatically a complete projection of the other.

### PlanetBiome

`CelestialBodies::PlanetBiome` joins a Biosphere to a top-level `Biome`. Its JSONB properties expose:

- `area_percentage`;
- `vegetation_cover`;
- `moisture_level`;
- `latitude`;
- `optimal_temperature`;
- `biodiversity`.

Validations constrain area percentage to 0–100, vegetation cover and moisture level to 0–1, and latitude to −90–90. A Biosphere cannot have duplicate association rows for the same biome. Create/destroy callbacks recalculate the Biosphere biodiversity index.

### Life forms

`Biology::LifeForm` inherits from `Biology::BaseLifeForm`, stored in `biology_life_forms`, and belongs to a Biosphere. Life-form records include:

- name, population, complexity, and domain;
- ecological and biological properties in JSONB;
- diet/prey relationships and preferred biome;
- reproduction, mortality, health, size, consumption, and individual-mass parameters;
- optional parent/child lineage relationships;
- per-billion-organism atmospheric and soil-effect rates.

Complexity values are microbial, simple, complex, and intelligent. Domain values are aquatic, terrestrial, aerial, and subterranean. The base model's `total_biomass` derives biomass from population and individual mass; it is not a separate settlement-style stockpile or a new planetary material ledger.

Life forms' atmospheric contribution method scales configured rates by population in billions. The natural `Biology::LifeForm` subclass also provides environment adaptation, food-availability, growth, and interaction helpers. These are distinct model-level methods; their existence does not establish that every helper is called by the main TerraSim service.

## 2. Initial Biosphere generation and persistence

### Procedural generation

`StarSim::BiosphereGeneratorService#generate` selects a complexity level from planetary conditions unless one is supplied. Its automatic detection considers:

- surface temperature;
- atmospheric pressure;
- gravity;
- liquid-water fraction from the Hydrosphere state distribution.

No liquid water yields the `:none` result. Other combinations of temperature, pressure, gravity, and water suitability select primitive, basic, or complex life. The generator then returns aggregate Biosphere attributes, biome-distribution hints, and lists of expected primary producers, consumers, and decomposers, along with an estimated species count. Terraformed seed eras adjust generated values.

These outputs are generation data, not proof that corresponding `LifeForm` or `PlanetBiome` database rows have been created.

### SystemBuilder persistence

`StarSim::SystemBuilderService#create_biosphere` builds and saves the Biosphere from a filtered set of supplied attributes. The inspected whitelist includes fields such as `habitable_ratio`, `biodiversity_index`, `vegetation_cover`, `biome_count`, `biome_distribution`, `soil_health`, `soil_organic_content`, and `soil_microbial_activity`.

The method does not create `LifeForm` records from the generator's primary-producer/consumer/decomposer lists, nor does it turn each generated biome-distribution entry into a `PlanetBiome` association. Those outputs must not be mistaken for persisted species or regional biome records. The automatic terrain path also contains a separate viability-gated default-Biosphere creation route.

The loader's behavior is distinct from later ecological simulation and from explicit life-form introduction/discovery methods.

## 3. Biosphere model behavior

The model provides operations to introduce/remove biome associations, update the JSON biome distribution, calculate biodiversity from the number of associated biomes, calculate habitability, discover microbial life, and calculate aggregate biomass.

The basic `calculate_biodiversity_index` uses biome count divided by a theoretical maximum of ten. The service's `calculate_biodiversity` uses the configured maximum biome count. The model also has an `expanded_biodiversity_index` that adds life-form count and complexity bonuses; these are different calculations and should not be treated as one interchangeable metric.

Habitability is calculated as a weighted score using atmospheric oxygen, temperature suitability, Hydrosphere liquid-state availability, and pressure, with a capped bonus for existing life forms. The implementation uses the body's surface temperature and Atmosphere conditions and reads the Hydrosphere's `state_distribution['liquid']`. This is a world-relative gameplay suitability score, not a direct measure of human life support or a guarantee that a specific organism can survive.

The model's `discover_life` method uses biodiversity as a probability gate and can create an aquatic microbial `Biology::LifeForm` record. This is a separate discovery mechanism from the procedural generator's life-form category lists.

## 4. TerraSim ecosystem simulation

`TerraSim::Simulator#update_spheres` calls `BiosphereSimulationService#simulate` when a body has a Biosphere. The service runs the following sequence:

1. **Biosphere conditions:** calculates a habitability ratio and ice-latitude estimate from tropical and polar temperatures, then updates biodiversity.
2. **Ecosystem interactions:** iterates `PlanetBiome` rows and updates vegetation cover using light availability, biome temperature suitability, moisture, and configured plant-growth factors.
3. **Species populations:** applies configured reproduction and mortality rates to life forms with a preferred biome.
4. **Food web:** updates vegetation for herbivores, removes prey population for carnivores, and adjusts consumer health based on food obtained.
5. **Biome balance:** calculates suitability from temperature and Hydrosphere liquid-water state, adjusts atmospheric tropical/polar temperature data toward weighted biome-optimal temperatures, and adjusts regional moisture levels.
6. **Atmospheric influence:** calculates life-form gas contributions and updates atmospheric gas records.

The service accepts `time_skipped` and uses it in selected population and atmospheric-effect calculations. This does not mean every ecological or climate operation is uniformly scaled by elapsed time.

### Current model simplifications and implementation limits

- Population growth is a compact rate-based calculation, not a full demographic model.
- The population method calculates a `carrying_capacity` local value but the inspected code does not apply it to cap the resulting population.
- Food-web calculations use simplified diet labels, available vegetation/prey estimates, and per-life-form properties.
- Biome suitability and climate balancing use heuristic temperature, humidity, and adjustment formulas.
- The service's biome-balancing method writes tropical/polar values into Atmosphere temperature data; it does not calculate a complete radiative climate response.
- Life-form atmospheric contributions include O2, CO2, CH4, N2-fixation, and soil-improvement values. The inspected atmospheric update consumes O2/CO2/CH4 contributions; N2-fixation and soil-improvement values are collected in the effects hash but are not applied there.
- When no life forms with positive population are present, `influence_atmosphere` applies small hardcoded O2, CO2, and CH4 percentage changes instead of leaving the atmosphere unchanged.
- The atmosphere update reconstructs gas masses from new percentages and the current total atmospheric mass, then applies gas deltas. This is a simplified composition update, not a complete elemental/chemical mass-balance model.

## 5. Biosphere–Atmosphere exchange paths

There is more than one implementation path that can change atmospheric composition.

### BiosphereConcern ecological callback

`BiosphereConcern#ecological_cycle_tick` calls `respond_to_atmospheric_changes`. When biodiversity exceeds 0.1, that method estimates CO2 absorption and O2 production from atmospheric percentages, converts those percentage amounts using total atmospheric mass, then calls Atmosphere `remove_gas('CO2', ...)` and `add_gas('O2', ...)`.

This is a separate simplified carbon-cycle path from `BiosphereSimulationService#influence_atmosphere`.

The model's after_update callback invokes its concern simulation unless simulation_running is set. That means this callback path is separate from the explicit TerraSim service and can affect the same atmospheric gas records when both are triggered in an update workflow. The exact normal-tick overlap remains caller-dependent.

The concern path performs two sequential gas operations using mass values calculated from the same pre-operation total atmospheric mass. The service path derives target masses from a current total, then applies per-gas deltas through methods that recalculate total mass after each operation. Neither path models photosynthetic stoichiometry or a complete elemental budget; they are simplified gas-inventory adjustments. The service's N2-fixation and soil-improvement outputs remain collected but unused by this Atmosphere update.

### TerraSim BiosphereSimulationService

The TerraSim service aggregates each populated life form's `atmospheric_contribution`, scales the O2/CO2/CH4 effects by `time_skipped`, and then updates Atmosphere gas records. It also applies a vegetation factor based on the count of PlanetBiome rows.

These two pathways should not be collapsed into one description. The Biosphere model has an `after_update` callback that invokes `run_simulation` (unless its in-memory `simulation_running` flag is set); that method runs the concern's ecological cycle, biodiversity calculation, and habitability calculation. The TerraSim service separately updates the Biosphere during its own run. This creates a potential for callback-driven ecological/atmospheric updates in addition to the explicit service sequence. The normal call order and intended ownership of these ticks need verification.

Atmosphere–Biosphere gas exchange is internal to the same celestial body. It changes atmospheric composition but should not be interpreted as importing or exporting planetary mass. A biologically mediated chemical conversion should also be distinguished from simple gas removal/addition when validating elemental conservation.

## 6. Biosphere–Geosphere coupling

`TerraSim::BiosphereGeosphereInterfaceService#simulate` is the only dedicated Biosphere–Geosphere interface service found. It requires both sphere objects, then calculates:
- regolith contribution = `geosphere.weathering_rate × 0.5`;
- biological contribution = `biosphere.biodiversity_index × 50`;
- new soil health = `50 + regolith contribution + biological contribution`.

It writes the result through `Biosphere#update_soil_health`. This is a heuristic soil-health score update, not a material exchange. It does not consume Geosphere regolith, move mineral mass, create soil inventory, transfer biomass, or update nutrient stocks. The biological input is the aggregate biodiversity index, not a sum of measured organism biomass or soil contributions.

The service is invoked from two different orchestration paths:
- root `PlanetUpdateService#process_sphere_interfaces`, after all four sphere services in detailed/progressive planet updates;
- `TerraSim::Simulator#update_spheres`, after Atmosphere, Geosphere, Hydrosphere, and Biosphere services.

The CelestialBody before-save callback calls the TerraSim simulator path when simulation-relevant body/sphere changes occur. The root PlanetUpdateService is called by `Game#process_planets` methods, but the active `GameService#advance_by_days` implementation does not call its own `process_planets` method. The repository also defines `Game` in both model and service files, so the job's resolved game-loop implementation needs runtime verification. See the orchestration discussion in [Atmosphere Gas Inventories & Evolution](atmosphere_gas_inventories_and_evolution.md).

The same interface service may therefore be reached through more than one update route, but the code inspection does not establish that both routes execute in every normal tick. Its output is a persisted soil-health attribute, not an independent inventory whose mass should be added to Geosphere or Biosphere totals.

## 7. Material and biomass accounting

- Life-form biomass is derived from population multiplied by individual mass. It is a biological aggregate, not automatically a mass record in the Geosphere or a transferable material stock.
- Biosphere's polymorphic `materials` association is distinct from the LifeForm population/biomass representation.
- Biosphere's specialized `transfer_material` operates on its polymorphic `materials` records and creates/updates a polymorphic material on the target sphere. It does not by itself update LifeForm populations, biomass, vegetation cover, or soil-health fields.
- Atmosphere gas changes are performed through Atmosphere gas methods; they are not a material transfer from a Biosphere inventory record.
- Soil-health updates are scalar quality changes in the Biosphere, not proof that Geosphere mass has moved into a soil material inventory.

No additional Biosphere inventory ledger is implied or required by these existing relationships. Follow the relevant record and transfer path when tracing a concrete material flow.

## 8. Open verification items

1. Establish the intended lifecycle for procedural generator outputs that are not persisted by `create_biosphere`, especially life-form category lists, estimated species counts, and generated biome-distribution data versus relational `PlanetBiome` rows.
2. Trace all paths that create `PlanetBiome` and `Biology::LifeForm` records and determine which are used in normal StarSim creation, discovery, and terraforming workflows.
3. Verify whether Biosphere `after_update` callback simulation is expected to run alongside the explicit TerraSim Biosphere service, and establish the intended tick owner/order.
4. Verify whether the concern carbon-cycle callback and the service's life-form atmospheric effects can both change the Atmosphere during a normal simulation update.
5. Review gas percentage-to-mass conversion and total-atmospheric-mass behavior in the service, including cases where the new gas percentages sum to less than 100%.
6. Trace the unused N2-fixation and soil-improvement outputs and determine whether they are intentionally reserved, handled elsewhere, or currently inert.
7. Confirm whether `carrying_capacity` is intended to constrain population growth; it is calculated but not applied in the inspected method.
8. Trace whether biomass is consumed/converted into any persistent soil or material inventory, or whether current food-web and soil interactions remain ecological state changes only.
9. Verify the intended relationship between Biosphere `biome_distribution` JSON and `PlanetBiome` association rows.

These are focused implementation and call-path checks for the existing Biosphere model. They are not a proposal to create a second biology architecture.

## 9. Primary code inspected

- `galaxy_game/app/models/celestial_bodies/spheres/biosphere.rb`
- `galaxy_game/app/models/concerns/biosphere_concern.rb`
- `galaxy_game/app/models/biology/base_life_form.rb`
- `galaxy_game/app/models/biology/life_form.rb`
- `galaxy_game/app/models/celestial_bodies/planet_biome.rb`
- `galaxy_game/app/services/star_sim/biosphere_generator_service.rb`
- `galaxy_game/app/services/star_sim/system_builder_service.rb`
- `galaxy_game/app/services/terra_sim/biosphere_simulation_service.rb`
- `galaxy_game/app/services/terra_sim/biosphere_geosphere_interface_service.rb`
- `galaxy_game/app/services/terra_sim/simulator.rb`

Historical harvest sources consulted but not modified:

- `docs/architecture/simulation/biosphere_system.md`
- `docs/architecture/biology/terrasim_service.md`
- `docs/architecture/simulation/biology_terraforming_guide.md`
- `docs/developer/pending_changes.md`
