# TerraSim Service Intent

The TerraSim service is the core planetary simulation engine responsible for updating and evolving planetary spheres (atmosphere, hydrosphere, geosphere, biosphere) over time. It integrates with biomes and biospheres to simulate climate, habitability, and ecological change.

## Key Components
- **Simulator:**
  - Updates fundamental planetary properties (temperature, gravity).
  - Steps through each sphere in dependency order.
- **BiosphereSimulationService:**
  - Simulates biosphere conditions, ecosystem interactions, food webs, and atmospheric influence from life forms.
- **BiomeValidator:**
  - Validates biome placement against environmental constraints (elevation, temperature, rainfall, latitude).
- **Other Services:**
  - Atmosphere, hydrosphere, geosphere simulation and interface services.

## Intent
- **Dynamic Simulation:**
  - Evolve planetary conditions and biomes over time based on physical and biological processes.
- **Integration:**
  - Biomes are validated and updated based on environmental state.
  - Biosphere and life forms influence atmospheric and ecological outcomes.
- **Extensibility:**
  - Designed for future expansion (e.g., exotic worlds, advanced terraforming, digital twin scenarios).

## Guidance for Development
- Keep simulation logic modular and sphere-specific.
- Use validators to ensure biomes are placed realistically.
- Biosphere and life form effects should be calculated and applied each simulation step.
- Avoid hard-coding planetary or biome logic; use configuration and canonical definitions.

---

See also: [Biology Models Overview](./biology_models.md) and [Biome Model Intent](./biome_model.md).