# TerraSim — Environmental Simulation, Calibration & Evolution

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-26
> *Audit Summary:* Foundational direction for evaluation and tuning confirmed by owner.

> **Status:** DESIGN INTENT — foundational direction for future evaluation and tuning
> **Last Updated:** 2026-11-14

## Purpose

TerraSim is Galaxy Game's general-purpose environmental simulation engine. It models the physical and environmental systems of an existing celestial body, how those systems interact, and how the world evolves over time.

TerraSim is **not defined solely by terraforming**. It must be able to simulate a world in its existing natural configuration and project reasonable future behavior without requiring intentional environmental changes. Terraforming is one application of this broader simulation capability.

This page records design intent for future development and tuning. It does not assert that existing TerraSim functionality is missing or needs to be rebuilt. Existing models and services must be inspected and evaluated before proposing replacement or expansion.

**Gameplay-oriented scope:** TerraSim is a simplified planetary environmental model informed by real-world science. Its required fidelity is the level needed to support meaningful terraforming and planetary management in GalaxyGame. It is not a complete planetary simulation, a high-fidelity scientific modeling platform, or a recreation of SimEarth. The model should represent important processes, matter and energy transfers, feedbacks, and response times well enough that interventions have plausible and understandable consequences. Scientific mechanisms inform the model; gameplay and operational relevance determine the necessary level of detail.

**Legacy terminology clarification:** Some older architecture notes describe TerraSim primarily as a regression/weathering filter that starts from a StarSim-generated lush or terraformed heightmap and moves the world toward a barren baseline. That description is not the current canonical definition of TerraSim. Weathering and regression-related processes may be part of environmental evolution, but TerraSim's purpose is broader: simulate a world's natural state and evolution, model events and historical scenarios, and calculate the consequences of intentional interventions. Do not treat a proposed full regression filter as an existing capability or an immediate requirement.

## 1. Three distinct simulation uses

TerraSim should support three related but distinct kinds of work:

### Natural-state simulation and projection

Given a world's current or specified initial configuration, TerraSim should calculate its environmental state and project its evolution without requiring terraforming interventions.

For known worlds such as Earth, Mars, and Venus, the engine should be able to use their modeled physical characteristics and environmental state as inputs and produce reasonable projections. This baseline capability is also necessary for evaluating and tuning TerraSim itself.

### Historical reconstruction and environmental events

TerraSim should support simulations that begin from an earlier world state and evolve under specified historical conditions, as well as hypothetical natural events and disturbances.

Examples include:
- Earth's geological, atmospheric, hydrological, and climatic history;
- Mars's transition from ancient warmer and wetter conditions toward its present state;
- competing plausible histories for Venus, including hypotheses involving early surface water and different paths to its present extreme environment;
- asteroid impacts, major volcanic events, changes in solar input, atmospheric loss, and other environmental disturbances.

Historical and planetary-science evidence is incomplete. Where multiple explanations remain plausible, TerraSim should support alternative scenarios rather than encode one disputed history as established fact.

### Intentional environmental modification

Terraforming and other deliberate interventions are intentional changes to a world. TerraSim calculates their physical and environmental consequences; it does not decide which objectives to pursue or autonomously operate terraforming programs. Those responsibilities belong to the appropriate planning/operations systems, including AI Manager.

Interventions must be represented distinctly from natural evolution and external events so that simulations can identify what changed the world and why.

## 2. Reference-world calibration and validation

Earth, Mars, and Venus are important reference environments for evaluating and tuning TerraSim's underlying models and interactions.

| Reference world | Calibration and validation value |
|---|---|
| **Earth** | Extensive present-day observations and historical records across atmosphere, hydrosphere, geosphere, climate, and biosphere. Use known history to test reconstruction and forward projection. |
| **Mars** | Geological and mineralogical evidence of ancient water and a warmer/wetter past, followed by evolution toward today's cold, dry conditions. Tests long-term environmental change and coupled processes. |
| **Venus** | Present-day extreme atmospheric and surface conditions, combined with competing hypotheses about its early environment and possible water history. Tests divergent planetary evolution and scenario comparison. |

The objective is not to hardcode three planetary outcomes. Reference worlds should help calibrate and validate the general physical models, processes, and interactions that explain their behavior.

### Historical calibration discipline

A historical reconstruction should distinguish:
- **Initial conditions:** the modeled state at the start of the reconstruction;
- **Historical forcing:** known or hypothesized external influences and events over the modeled interval;
- **Model parameters:** physical relationships and process parameters being evaluated or calibrated;
- **Interventions:** deliberate changes introduced into a scenario;
- **Validation observations:** geological, atmospheric, climatic, and other evidence used to compare simulation results.

Do not tune a model by silently hardcoding the historical answer into its inputs. Calibration should improve the underlying relationships and expose where model results diverge from observations.

Historical evidence, inferred conditions, and competing hypotheses must retain their uncertainty and provenance. TerraSim should not present uncertain reconstructions as settled facts or imply greater precision than the evidence supports.

## 3. Generalization to procedural and poorly characterized worlds

The purpose of reference-world calibration is to develop models that generalize beyond those examples.

For a StarSim-generated world or a world with limited observational information, TerraSim should use the available physical characteristics, initial conditions, and relevant environmental data to estimate its behavior and evolution using the same underlying physical models.

Results should distinguish:
- values calculated from sufficiently known inputs;
- estimates based on incomplete information or model assumptions;
- unknowns and areas of substantial uncertainty.

As surveys and observations add information, the modeled initial conditions and projections can be refined. Missing observations must not be silently treated as zero, absence, or certainty.

StarSim generates or supplies the celestial body and its initial world data. TerraSim evaluates and evolves the environmental state; it does not generate the star system.

## 4. Sphere models and interactions

Sphere models organize the detailed physical and environmental systems associated with a celestial body. The central CelestialBody record provides the common body identity and core properties; the sphere models hold their respective detailed data.

TerraSim models processes and exchanges across those systems. A sphere's stored state and the rules governing its interaction with other spheres are related but distinct concerns. Spheres are not independent simulation silos: processes can transfer matter and energy between them, and those transfers can produce consequential changes in multiple sphere states. TerraSim should represent the important exchanges and feedbacks rather than merely update each sphere independently and combine the results afterward.

The level of detail is selective. Model the real-world mechanisms and relationships that materially affect planetary conditions, habitability, resource availability, and management decisions; use explicit approximations for less consequential or poorly characterized processes. This is a game-oriented model, not an attempt to reproduce every process in a real planetary system.

Examples of coupled processes include:
- atmosphere–hydrosphere exchanges, including evaporation, condensation, precipitation, and greenhouse effects;
- geosphere–atmosphere exchanges, including volcanism, weathering, and gas release;
- geosphere–hydrosphere exchanges, including erosion, dissolution, heat transfer, and water-rock interaction;
- biosphere interactions with atmospheric, hydrological, and geological conditions;
- energy balance and external forcing that affect multiple spheres.

The relevant processes and interactions depend on the body's physical nature and modeled configuration. Do not assume every celestial body has identical Earth-like conditions or that every sphere participates in every process.

The sphere architecture is intended to accommodate different kinds of celestial bodies. Broader body types may require additional or adjusted physical processes and different interactions among spheres. For example, ice moons may involve strong coupling among an ice shell, subsurface liquid water, and a rocky interior, including tidal heating and cryovolcanic exchange. This is a future modeling consideration, not a requirement to expand the initial terraforming-focused work or to create a separate simulation engine.

When a new body type or environmental use case is addressed, evaluate the relevant sphere data and TerraSim interaction rules together. Do not assume that a sphere data-model change alone implements the required physical behavior.

## 5. Scope and responsibilities

- **CelestialBody and sphere models:** represent the body and store detailed physical/environmental state.
- **StarSim:** generates stars, systems, and celestial bodies and supplies their initial generation data.
- **Map Studio:** prepares or generates **initial** terrain/geographic data for a body. That initial state can feed later environmental simulation; Map Studio is not TerraSim and does not perform ongoing environmental evolution.
- **TerraSim:** calculates environmental states, coupled processes, natural evolution, projections, and consequences of modeled events or interventions.
- **AI Manager:** selects and executes approved operational and terraforming strategies using available world state and projections.
- **Digital Twin:** creates an isolated duplicate of an existing celestial body's world state for accelerated what-if experiments, then uses TerraSim to calculate projected environmental outcomes. It provides the scenario inputs, comparison, and results workspace; it is not a separate simulation engine. Its intended Admin/AI Manager use also includes cost and execution-time projections assembled from the relevant economic, manufacturing, construction, and logistics systems. Detailed workflows and UI controls remain OPEN.

TerraSim calculates environmental states, evolution, and consequences from the world state it is given; it does not autonomously choose terraforming objectives or perform operational actions.

## 6. Future evaluation and tuning direction

When TerraSim is next evaluated for tuning, begin by auditing existing implementation and tests. Determine what is already modeled, what is calibrated, which sphere interactions are represented, and what evidence supports their behavior.

Use the following questions to guide that evaluation:
1. Can the existing engine simulate Earth, Mars, and Venus from specified natural initial conditions without requiring terraforming interventions?
2. Can it reconstruct selected historical intervals when supplied with appropriate historical forcing and compare results with observations?
3. Can it represent alternative scenarios where planetary history is uncertain?
4. Can it model a natural disturbance, such as an asteroid impact on Earth, and project coupled environmental consequences?
5. Can the same underlying models produce reasonable estimates for procedurally generated worlds with limited data, while exposing uncertainty?
6. Are sphere interactions physically coherent for the body type and scenario being modeled?
7. Which gaps are missing processes, which are parameter/calibration issues, and which are data-quality or uncertainty issues?

Existing capabilities may already satisfy some or much of this direction. This is a framework for future evaluation and tuning, not an instruction to rebuild working systems or expand every model immediately.

## 7. Gameplay priorities and timescales

TerraSim's simulation effort should reflect the conditions most relevant to terraforming and planetary management. Atmospheric and surface conditions have the highest practical priority because they directly affect habitability, protection, settlement suitability, and the results of interventions. Hydrological and biological processes should be represented where they materially influence those conditions and management outcomes.

The Geosphere remains important primarily through its effects on the surface environment, other spheres, and resource availability. Relevant examples include volcanic/outgassing contributions to atmospheric composition; weathering, erosion, dissolution, and water-rock interactions affecting surface materials and hydrology; and soil/regolith composition affecting biosphere suitability and resource use. Detailed geological evolution for its own sake is a lower priority. Geosphere processes need enough fidelity to produce meaningful downstream effects, not comprehensive internal geological simulation.

TerraSim must also respect the different timescales of processes. The time required to carry out an intervention is distinct from the onset and development of its environmental response, and both are distinct from the interval over which a simulation is advanced. Some operational, atmospheric, and surface effects may be relatively quick; mixing, water movement, ecological responses, and longer-term environmental trends may take longer. These are relative process behaviors, not fixed universal time bands or prescribed durations.

Long simulation advances and projections should preserve meaningful rates, delays, dependencies, and accumulated effects. Avoid treating every process as instantaneous on each update, but also avoid unnecessary detail that prevents useful gameplay projections. Use plausible approximations and avoid false precision where the model or evidence does not justify it.

## 8. Sphere-model reference

The established sphere record structure, JSON initialization, and material inventories are documented in [Celestial Body & Sphere Data Model](celestial_body_and_sphere_data_model.md). The relationship between sphere state and TerraSim's cross-sphere processes is documented in [Celestial-Body Sphere Models & Environmental Interactions](sphere_models_and_interactions.md). That page also records a focused implementation snapshot and identifies where current service behavior is simplified or incomplete.

## 9. Scope boundary

The initial implementation and gameplay emphasis has been planetary terraforming, especially worlds such as Mars and Venus. That priority does not narrow TerraSim's underlying purpose to intentional world modification. Natural-state simulation, historical calibration, and event modeling are foundational capabilities and validation goals for the engine.

Comprehensive modeling of every natural process on every type of celestial body is not required immediately. In particular, broader ice-moon and other non-terraforming-world process models can be developed when the relevant simulation or gameplay use case is prioritized. Preserve the extensible sphere architecture and record future requirements without prematurely building systems that are not yet needed.
