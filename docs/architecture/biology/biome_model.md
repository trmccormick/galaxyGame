# Biome Model Intent

The `Biome` model represents a distinct ecological region on a planet, defined by its temperature and humidity ranges. It is used for both static terrain display and, in the future, dynamic simulation of planetary biospheres.

## Key Features
- **Attributes:**
  - `name`: Unique name for the biome (e.g., "desert", "tundra").
  - `temperature_range`: Range (in Kelvin) where the biome is viable.
  - `humidity_range`: Range (percentage or value) for biome viability.
- **Associations:**
  - `has_many :planet_biomes` (links to specific planetary locations)
  - `has_many :celestial_bodies, through: :planet_biomes`
- **Methods:**
  - `climate_type`: Classifies the biome as tropical, temperate, polar, arid, etc., based on temperature and humidity.
  - Custom range parsing for temperature/humidity.

## Intent
- **Static Display:**
  - Used by terrain generation and surface view to display biome grids on planets.
- **Dynamic Simulation (Future):**
  - Will be integrated with biosphere and TerraSim for dynamic evolution and simulation of biomes based on planetary conditions.
- **Design Principle:**
  - Decoupled from direct planetary attributes; instead, biomes are assigned to locations via `planet_biomes`.

## Guidance for Development
- Do not couple Biome directly to CelestialBody; always use the join model.
- Future simulation logic should update `planet_biomes` based on environmental changes, not the Biome model itself.
- Biome definitions should remain stable and canonical for all planets.

---

See also: [Biology Models Overview](./biology_models.md) and [TerraSim Service Intent](./terrasim_service.md).