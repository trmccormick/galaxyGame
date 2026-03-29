# Location System Architecture

## Overview

The Galaxy Game uses a polymorphic location system to track the position of entities in 3D space. The system supports different location types (spatial coordinates, orbital positions, surface coordinates) and polymorphic associations for flexibility.

---

## Core Components

### Location::SpatialLocation

**Purpose:** Track 3D Cartesian coordinates (x, y, z) for objects in space

**Database Table:** `spatial_locations`

**Associations:**
- `spatial_context` (polymorphic) - The container/reference frame (e.g., SolarSystem, Planet)
- `locationable` (polymorphic) - The entity being located (e.g., Craft, Station, Asteroid)

**Key Attributes:**
```ruby
t.string :name              # Human-readable location identifier
t.float :x_coordinate       # X position in 3D space
t.float :y_coordinate       # Y position in 3D space
t.float :z_coordinate       # Z position in 3D space
t.references :spatial_context, polymorphic: true
t.references :locationable, polymorphic: true
```

---

## Coordinate System

### 3D Cartesian Coordinates

The spatial location system uses standard 3D Cartesian coordinates:

- **X-axis**: East-West (positive = East)
- **Y-axis**: North-South (positive = North)
- **Z-axis**: Vertical (positive = Up/Away from reference plane)

### Units

- Coordinates are stored as floating-point numbers
- Unit interpretation depends on spatial_context:
  - **Solar System context**: Astronomical Units (AU)
  - **Planetary orbit context**: Kilometers (km)
  - **Surface context**: Meters (m)

### Validation

**Position Uniqueness:**
- Each 3D position (x, y, z) must be unique within a spatial_context
- Validated via `unique_3d_position_within_context` custom validator
- Scoped uniqueness: `[:y_coordinate, :z_coordinate, :spatial_context_type, :spatial_context_id]`

**Coordinate Ranges:**
- All coordinates accept values from `-Float::INFINITY` to `Float::INFINITY`
- Presence validation ensures all three coordinates exist

---

## Public API

### Instance Methods

#### `#distance_to(other_location)`

Calculates Euclidean distance between two spatial locations.

```ruby
location1 = SpatialLocation.find(1)
location2 = SpatialLocation.find(2)
distance = location1.distance_to(location2)  # Returns Float (distance in context units)
```

**Formula:**
```
distance = √[(x₂-x₁)² + (y₂-y₁)² + (z₂-z₁)²]
```

#### `#update_location(coordinates)`

Updates spatial coordinates atomically with validation.

```ruby
new_coords = {
  x_coordinate: 100.0,
  y_coordinate: 200.0,
  z_coordinate: 300.0
}

spatial_location.update_location(new_coords)
# Returns true if update succeeds, false if validation fails
```

**Behavior:**
- Validates uniqueness within spatial_context before updating
- Atomic update via Rails `update` method
- Triggers ActiveRecord callbacks (validations, before_save, etc.)
- Returns boolean success/failure

**Use Cases:**
- Moving craft to new coordinates
- Updating orbital station positions
- Asteroid trajectory updates
- Procedural generation coordinate assignment

---

## Spatial Contexts

### Polymorphic Container Pattern

Spatial locations exist within a `spatial_context`, which defines their reference frame:

**Solar System Context:**
```ruby
SpatialLocation.create!(
  name: 'Asteroid Belt Position',
  x_coordinate: 2.7,      # 2.7 AU from origin
  y_coordinate: 0.0,
  z_coordinate: 0.1,
  spatial_context: solar_system
)
```

**Planetary Orbit Context:**
```ruby
SpatialLocation.create!(
  name: 'Lunar Orbit Station',
  x_coordinate: 384400.0,  # km from planet center
  y_coordinate: 0.0,
  z_coordinate: 0.0,
  spatial_context: planet
)
```

---

## Locationable Entities

Entities that can have spatial locations (via polymorphic `locationable` association):

- **Craft::BaseCraft** - Spacecraft, shuttles, freighters
- **Stations** - Orbital stations, space platforms
- **Asteroids** - Procedurally generated asteroid fields
- **Wormholes** - Spatial anomaly entrance/exit points
- **Fleets** - Groups of craft moving together

---

## Related Documentation

- [Craft System](./craft_system.md) - Spacecraft and orbital mechanics
- [Procedural Generation](../developer/procedural_generation.md) - Asteroid field generation
- [Database Schema](./database_schema.md) - Full schema reference

---

## Implementation Examples

### Creating a Spatial Location

```ruby
# For a craft in solar system
craft_location = Location::SpatialLocation.create!(
  name: 'Freighter Position',
  x_coordinate: 1.0,
  y_coordinate: 0.0,
  z_coordinate: 0.0,
  spatial_context: solar_system,
  locationable: craft
)
```

### Moving an Object

```ruby
# Update craft position
new_position = { x_coordinate: 1.5, y_coordinate: 0.2, z_coordinate: 0.0 }
craft_location.update_location(new_position)

# Or use standard Rails update
craft_location.update!(x_coordinate: 1.5, y_coordinate: 0.2, z_coordinate: 0.0)
```

### Distance Calculations

```ruby
# Calculate distance between two craft
craft1_location = craft1.spatial_location
craft2_location = craft2.spatial_location

distance_km = craft1_location.distance_to(craft2_location)
# => 450000.0 (km)

# Check if within range
in_docking_range = distance_km < 10.0  # 10km docking radius
```

### Position Validation

```ruby
# Attempt to create duplicate position
duplicate_location = Location::SpatialLocation.new(
  name: 'Duplicate',
  x_coordinate: 1.0,
  y_coordinate: 0.0,
  z_coordinate: 0.0,
  spatial_context: solar_system  # Same context as craft_location above
)

duplicate_location.valid?
# => false

duplicate_location.errors.full_messages
# => ["This 3D position is already taken within this context"]
```

---

## Future Enhancements

- **Velocity tracking**: Add dx/dt, dy/dt, dz/dt for orbital mechanics
- **Rotation**: Quaternion-based orientation tracking
- **Trajectory prediction**: Calculate future positions based on velocity
- **Spatial indexing**: PostGIS integration for efficient proximity queries
- **Coordinate transformations**: Convert between reference frames
