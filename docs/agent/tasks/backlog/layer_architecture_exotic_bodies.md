# Backlog Task: Layer Architecture for Exotic Celestial Bodies

## Problem
Current layer implementation uses a hardcoded enum with only 4 values:
crust, mantle, core, unknown. This is insufficient for simulating
exotic celestial bodies with complex internal structures.

## Core Issue
Layer structure is driven by temperature and pressure, not by
hardcoded categories. Different body types have fundamentally
different layer configurations:

**Terrestrial (Earth, Mars)**
- crust
- upper_mantle
- lower_mantle
- outer_core
- inner_core

**Titan-like (thick atmosphere, subsurface ocean)**
- atmosphere
- hydrosphere (liquid methane/ethane surface)
- cryosphere (water ice shell)
- sub_hydrosphere (possible liquid water slush)
- silicate_mantle
- core

**Europa-like (ice shell, subsurface ocean)**
- ice_shell
- subsurface_ocean
- silicate_mantle
- core

**Gas Giant (Jupiter, Saturn)**
- upper_atmosphere
- lower_atmosphere
- metallic_hydrogen
- rocky_core

**Small Bodies (asteroids, comets)**
- surface
- regolith
- interior

## Current Implementation Problems
- t.string "layer" with null: false, default: 'crust' on materials table
- Model defines layer as integer enum — WRONG, column is string
- Enum values too limited for exotic bodies
- No connection between layer definition and body type
- No temperature/pressure context per layer

## Proposed Solution

### 1. Remove layer enum from Material model
Replace integer enum with plain string:
```ruby