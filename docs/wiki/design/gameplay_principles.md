# Gameplay Principles

> **Wiki section:** Design & Architecture · **Status:** DIRECTION — harvested from legacy design reference and reconciled with current owner direction  
> **Last Updated:** 2026-11-21

This page records high-level design principles that help keep GalaxyGame coherent as its gameplay, simulation, AI Manager, and player interfaces continue to develop. It is not a complete game design specification, a fixed campaign plan, or a list of fully implemented mechanics.

## GalaxyGame has its own identity

**ESTABLISHED INTENT — owner clarification, 2026-11-21**

GalaxyGame is its own game, with its own goals, mechanics, simulation model, and player experience. It may draw inspiration from many games, simulations, and applications, but it is not an attempt to recreate or combine EVE Online, SimEarth, Civilization, SimCity, or any other existing product.

References are useful for particular ideas—such as a visualization, map interaction, planning workflow, or information layout. They do not define GalaxyGame's gameplay rules, terminology, progression, data model, or architecture. Adapt a useful idea to GalaxyGame rather than importing the reference product's assumptions.

## Science-grounded, but designed for play

**DIRECTION — retained from legacy design reference**

Use real-world scientific data and established physical principles where they are available and relevant. Procedural content should follow meaningful planetary, astronomical, geological, and environmental constraints rather than arbitrary randomness.

Scientific accuracy is a guide, not a requirement to simulate every phenomenon at maximum detail. Simplifications and time/scale compression are acceptable when they improve playability, provided the result remains internally consistent and believable. The game should make complex systems understandable, not bury players in detail for its own sake.

Related: [StarSim and Protection Classes](starsim_and_protection_classes.md), [TerraSim](../technical/terrasim.md), and [Celestial-Body Sphere Models & Environmental Interactions](../technical/sphere_models_and_interactions.md).

## Meaningful resource and operational trade-offs

**DIRECTION — retained from legacy design reference**

Resource acquisition and use should create meaningful choices. Resource availability is geographically and operationally constrained; extraction and processing require suitable equipment, energy, time, infrastructure, and transport. Location, resource quality, production capacity, and logistics affect which option makes sense.

Do not assume unlimited deposits, free extraction, instant transport, or costless production. Specific quantities, depletion models, extraction rates, and economic rules belong in their relevant system specifications and must not be invented from this principle alone.

Related: [Resource and Market Logistics](../logistics/resource_and_market_logistics.md), [Logistics and Hauling](../logistics/logistics_and_hauling.md), and [Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md).

## Exploration and discovery should matter

**DIRECTION — retained from legacy design reference and current StarSim intent**

Celestial bodies and systems should have meaningful differences. Surveying and exploration help players and the AI Manager understand conditions, resources, hazards, and opportunities. Initial system data may be incomplete; discovery and later refinement are part of the intended experience rather than proof that every starting catalog must be exhaustive.

Procedural generation should create variety within plausible constraints. Do not treat a game-balanced map, an external game map, or a designer's hypothetical world as verified planetary data.

Related: [System Blueprints and Procedural Generation](../astronomy/system_blueprints.md), [First Hour and Entry State](../player/first_hour_and_entry_state.md), and [Precursor Discoveries and Research Opportunities](../technical/precursor_discoveries_and_research_opportunities.md).

## Time, dependencies, and long-term planning matter

**DIRECTION — retained from legacy design reference and current simulation intent**

Settlements, infrastructure, manufacturing capabilities, and inter-system expansion take time and depend on available resources, equipment, technology, logistics, and prior infrastructure. Actions should have consequences that unfold through the simulation; systems should not bypass meaningful dependencies with arbitrary instant completion.

Pre-player test controls may accelerate or pause observation of the simulation, but elapsed game time must still process the intervening simulation. Player pacing is governed by the shared universe clock, not by individual player speed controls.

Related: [Game Time and Simulation Loop](../engineering/game_time_and_simulation_loop.md), [Settlement Progression and Footholds](../player/settlement_progression_and_footholds.md), and [Space and Surface Operations](../player/space_and_surface_operations.md).

## Automation supports agency; it does not erase it

**DIRECTION — retained from legacy design reference and current AI Manager / player intent**

Automation should reduce repetitive micromanagement and allow operations to continue without requiring the player to watch every step. The AI Manager operates NPC infrastructure and makes strategic decisions for its assigned objectives. Players can participate directly, establish their own operations, assign work, and manage assets within the game's location, authority, and communications constraints.

This is not a blanket rule that the AI always acts for the player or that the player can instantly control every remote asset. Existing authorizations, craft autonomy, communication availability, and delayed information matter. See [AI Manager](../services/ai_manager.md), [Interstellar Communications](../engineering/interstellar_communications.md), and [Space and Surface Operations](../player/space_and_surface_operations.md).

## Complexity should build on working foundations

**DIRECTION — retained from legacy design reference**

Core gameplay should be understandable and useful before every advanced system is available. Advanced technologies, networks, world-scale simulation, and long-horizon projects should add depth to working foundations rather than be prerequisites for understanding every basic activity.

This does not prescribe a universal phase sequence or fixed campaign progression. The AI Manager should adapt development to local conditions and mission objectives; the relevant system pages define actual prerequisites and open choices.

## Status and limits

The principles above are high-level direction. They do not independently establish:

- Exact resource depletion or regeneration equations.
- Specific survey, discovery, or procedural-generation algorithms.
- A fixed technology tree, victory condition, difficulty setting, multiplayer mode, or campaign sequence.
- Exact player contract windows, rewards, reputation gates, or market behavior.
- Universal automation authority or instantaneous remote control.
- The detailed simulation fidelity required for every planetary or astronomical process.

Those details remain governed by the current topic pages, owner-confirmed decisions, and code review. Older documents may contain proposals or assumptions that are not adopted; consult the [Migration Log](../migration-log.md) for source-by-source disposition.
