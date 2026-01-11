# Sol System Celestial Body Data

This directory contains structured data about celestial bodies in the Sol system, including their features.

## Data Organization

- `/sol/celestial_bodies/` - Contains data for all bodies in the Sol system
  - `/earth/moon/features/` - Contains lunar features like craters and lava tubes
  - `/mars/features/` - Contains martian features like craters

## Data Sources

The feature data (craters, lava tubes, etc.) was collected using Wikipedia scraping scripts located in the `galaxy_game/import` directory.

## Feature Data Usage

These datasets can be used to:
1. Populate the game world with realistic celestial body features
2. Create missions and exploration objectives at specific locations
3. Define resource distribution across celestial bodies