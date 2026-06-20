# TerrainForge Layer - Civilization Layer Interaction Mode

## Overview
TerrainForge IS the Civilization Layer (Layer 4) on the Surface View — not a separate view. It provides two interaction modes within the existing Surface View: Admin mode and Player Corporation mode.

## Key Architecture Correction
- **Surface View** = Single unified view with multiple interaction modes
- **TerrainForge** = Civilization Layer interaction mode within Surface View (NOT a separate view)
- **Two Modes**: Admin (DC base direction, AI Manager training, full visibility) and Player Corporation (base placement, unit deployment, road building, resource claiming)

## Interaction Modes

### Admin Mode
Primary user: System administrators and AI developers
- DC base direction and oversight
- AI Manager training and priority adjustment
- Full visibility across all settlements and corporations
- Megaproject monitoring (Worldhouse, terraforming) — DC/AI Manager only

### Player Corporation Mode
Secondary user: Player corporations (requires corporation membership)
- Base placement and colony development
- Unit deployment and road building
- Resource claiming and infrastructure construction
- Restricted to own corporation assets and territories
- DC bases provide player home base before corporation level

## Access Requirements
- Players must be part of a player corporation to access TerrainForge mode
- DC bases serve as temporary home bases for individual players before corporation formation
- Corporation membership unlocks full TerrainForge capabilities

## Scope Boundaries

### Current Scope: Surface Operations Only
- Planetary surface construction and development
- Colony establishment and expansion
- Resource extraction and processing
- Local infrastructure (roads, landing pads, habitats)
- Corporation-level strategic planning

### Future Scope: Orbital Civilization Layer (Not in Current Scope)
- Orbital infrastructure (AWS, depots, cycler routes)
- Interplanetary logistics networks
- Space station construction
- Fleet operations and tug networks
- Cislunar economic systems

## Technical Specifications
### ConstructionEvent Schema
```json
{
  "event": "ConstructionEvent",
  "type": "building|mining|infrastructure",
  "location": {"x": 45, "y": 22, "celestial_body_id": 123},
  "ai_manager_decision": true,
  "priority": "high|medium|low",
  "estimated_completion": "2026-03-15T10:00:00Z",
  "resources_required": {"steel": 100, "concrete": 50},
  "timestamp": "2026-03-02T12:00:00Z"
}
```
