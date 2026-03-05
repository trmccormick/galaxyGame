# Implement TerrainForge Layer - Civilization Layer Interaction Mode

## Overview
TerrainForge IS the Civilization Layer (Layer 4) on the Surface View — not a separate view. It provides two interaction modes within the existing Surface View: Admin mode and Player Corporation mode.

## Corrected Architecture
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

## Implementation Roadmap
- Phase 1: Foundation (TerrainForge mode integration into Surface View)
- Phase 2: Admin Mode (DC base direction, AI Manager training, full visibility)
- Phase 3: Player Corporation Mode (base placement, unit deployment, road building, resource claiming)
- Phase 4: Corporation Access Control (membership requirements, asset restrictions)

## Dependencies
- Surface View completion
- AI Manager service integration
- Corporation membership system
- Player authentication and authorization

## Success Criteria
- TerrainForge accessible as mode toggle in Surface View
- Admin mode provides full system visibility and control
- Player Corporation mode restricts to corporation assets
- Corporation membership required for TerrainForge access
- DC bases available as temporary player home bases
- Megaprojects restricted to DC/AI Manager only
- Orbital infrastructure clearly marked as future scope