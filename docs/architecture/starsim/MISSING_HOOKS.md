# StarSim — MISSING_HOOKS.md

This document lists all architectural intents from OVERVIEW.md that currently lack corresponding code hooks or models in the Rails app.

## Missing Structural Hooks

### 1. Weathering Engine / Erosion State
- No persistent attribute for 'Erosion State' on CelestialBody or Geosphere models. Only a method for updating erosion rate in geosphere.rb, not a full state or history.

### 2. Radiolytic Decay
- No attribute or logic for 'Radiolytic Decay' or radiolytic resource loss on any celestial body or resource model.

### 3. Velocity Vectors for Interstellar Visitors
- No model or attribute for storing or updating velocity vectors for transient/interstellar objects (e.g., KBOs, comets, visitors).

### 4. KBO-to-Mars Logic
- No hook or placeholder in system_builder_service.rb for Kuiper Belt Object (KBO) transfer or impact logic.

### 5. Terraforming Impact on Terrain
- No direct service or model hook for applying terraforming effects to terrain or planetary surface models.

### 6. Dynamic Population
- No dynamic spawning or lifespan logic for transient objects in the main Rails models (handled only in procedural generation, not persisted).

---

## Top 3 Biggest Gaps

1. **No persistent 'Erosion State' or 'Radiolytic Decay' attributes** on celestial bodies or resources — critical for weathering and planetary evolution.
2. **No velocity vector or dynamic population model** for interstellar/transient objects — needed for Oort/visitor simulation.
3. **No KBO-to-Mars or terraforming impact hooks** in system builder or terrain models — blocks simulation of major system events and surface changes.
