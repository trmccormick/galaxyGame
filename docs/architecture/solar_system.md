# Solar System Model

## Overview
The SolarSystem model represents a complete star system containing stars, planets, moons, and other celestial bodies. It manages the relationships between all components of a star system and provides methods for loading and managing celestial objects.

## Key Associations
- **Stars**: Multiple stars (supports binary/trinary systems)
- **Terrestrial Planets**: Rocky planets like Earth, Mars
- **Gas Giants**: Large gaseous planets like Jupiter
- **Ice Giants**: Smaller gaseous planets like Neptune
- **Dwarf Planets**: Pluto-like bodies
- **Moons**: Satellites orbiting planets
- **Celestial Bodies**: General collection of all bodies

## Core Methods

### Star Management
- `load_star(params)`: Creates or updates a star in the system
- `primary_star`: Returns the most massive star
- `binary_system?`: Checks if system has multiple stars
- `binary_companion`: Returns companion star in binary systems

### Planet Loading
- `load_terrestrial_planet(params)`: Adds rocky planets
- `load_moon(params)`: Creates moons with automatic parent assignment
- `total_mass`: Calculates combined mass of all planets and dwarf planets

### Validation
- Requires unique identifier
- Ensures proper associations and data integrity

## Factory Configuration
The test factory creates solar systems with:
- Unique names and identifiers
- Optional star and planet traits
- Validation skipping for test environments

## Recent Fixes
**Issue**: Multiple validation and association failures in tests
**Root Cause**: Factory classes didn't match model associations, missing identifiers and traits, incomplete star relationship methods
**Solution**: 
- Updated factory classes to match association class_names
- Added identifier sequences to all celestial body factories
- Added :earth trait to terrestrial_planet factory
- Implemented binary_system? and binary_companion methods on Star model
- Corrected load_moon test expectations