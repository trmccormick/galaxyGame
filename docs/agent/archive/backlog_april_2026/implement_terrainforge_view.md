# Implement TerrainForge View Interface

**ARCHITECTURAL CORRECTION**: TerrainForge is NOT a separate view. It is the Civilization Layer interaction mode within the existing Surface View. This task has been updated to reflect the correct architecture where TerrainForge provides two interaction modes (Admin and Player Corporation) within the unified Surface View interface.

## Overview
This task implements the TerrainForge interaction mode within the Surface View, providing users with civilization layer construction monitoring and control capabilities. The mode integrates seamlessly with existing Surface View infrastructure while adding specialized construction oversight and player corporation management features.

## Dependencies
- Surface View infrastructure with mode switching capability
- TerrainForge data models (DCSettlement, ConstructionProject) with corporation support
- Corporation membership and access control system
- Admin/Player mode authentication and authorization
- WebSocket/EventBus for real-time updates within Surface View context

## Phase 1: Mode Integration into Surface View (1 week)
### Tasks
- Add TerrainForge mode toggle to Surface View interface
- Implement mode switching between Admin and Player Corporation modes
- Create corporation membership validation for TerrainForge access
- Add civilization layer overlay controls to Surface View
- Set up mode-specific UI elements and state management

### Success Criteria
- TerrainForge mode accessible via toggle in Surface View
- Mode switching works between Admin and Player Corporation
- Corporation membership required for Player mode access
- Civilization layer elements integrate with Surface View
- Mode state persists correctly across interactions

## Phase 2: Admin Mode Interface (1 week)
### Tasks
- Build DC base and settlement monitoring panel for Admin mode
- Implement AI Manager training and priority controls
- Add full visibility construction queue display
- Create megaproject monitoring (Worldhouse, terraforming)
- Add corporation oversight capabilities

### Success Criteria
- Admin mode provides complete system visibility
- AI Manager controls functional and effective
- Construction monitoring comprehensive
- Megaproject oversight available
- Corporation management tools integrated

## Phase 3: Player Corporation Mode Interface (2 weeks)
### Tasks
- Implement base placement and colony development tools
- Add unit deployment and road building capabilities
- Create resource claiming and infrastructure construction interface
- Build corporation asset restriction system
- Add corporation-specific construction queue management

### Success Criteria
- Base placement works within corporation territories
- Unit deployment and road building functional
- Resource claiming restricted to corporation assets
- Infrastructure construction available
- Corporation boundaries enforced

## Phase 4: Civilization Layer Visualization (2 weeks)
### Tasks
- Add civilization layer overlays to Surface View terrain
- Implement construction progress visualization
- Create settlement pattern displays
- Build resource and infrastructure visualization
- Add corporation territory visualization

### Success Criteria
- Civilization elements overlay Surface View terrain
- Construction progress clearly visible
- Settlement patterns displayed appropriately
- Resources and infrastructure shown
- Corporation territories demarcated

## Phase 5: Access Control and Permissions (1 week)
### Tasks
- Implement corporation membership validation
- Add DC base access for non-corporation players
- Create mode-specific permission checks
- Build access restriction enforcement
- Add membership requirement messaging

### Success Criteria
- Corporation membership enforced for TerrainForge access
- DC bases available as temporary access points
- Permissions correctly restrict functionality
- Access controls prevent unauthorized actions
- Clear messaging for membership requirements

## Phase 6: Integration and Polish (1 week)
### Tasks
- Integrate all mode features with Surface View
- Add smooth transitions between modes
- Implement comprehensive testing
- Create user documentation
- Performance optimization

### Success Criteria
- All features integrated seamlessly
- Mode switching smooth and intuitive
- Comprehensive testing passed
- Documentation complete
- Performance acceptable

## Technical Specifications

### Surface View Mode Integration
```erb
<!-- app/views/admin/celestial_bodies/surface.html.erb -->
<div class="surface-view-container" data-mode="<%= @current_mode %>">
  <!-- Existing Surface View content -->
  
  <!-- TerrainForge Mode Toggle -->
  <div class="mode-switcher">
    <button class="mode-btn" data-mode="exploration">Exploration</button>
    <button class="mode-btn" data-mode="terrainforge">TerrainForge</button>
  </div>
  
  <!-- TerrainForge Mode UI (conditionally rendered) -->
  <% if @current_mode == 'terrainforge' %>
    <div class="terrainforge-overlay">
      <!-- Civilization layer controls and overlays -->
    </div>
  <% end %>
</div>
```

### Mode-Aware JavaScript Architecture
```javascript
// app/assets/javascripts/surface_view.js (extended)
class SurfaceViewController {
  constructor() {
    this.currentMode = 'exploration'; // 'exploration' | 'terrainforge'
    this.terrainforgeController = null;
    this.eventBus = new EventBus();
  }
  
  switchMode(mode) {
    this.currentMode = mode;
    if (mode === 'terrainforge') {
      this.enableTerrainForgeMode();
    } else {
      this.disableTerrainForgeMode();
    }
    this.updateUI();
  }
  
  enableTerrainForgeMode() {
    // Initialize TerrainForge overlay and controls
    this.terrainforgeController = new TerrainForgeModeController(this);
    this.terrainforgeController.init();
  }
}
```
    this.loadLocationTerrain();
    this.loadColonyData();
    this.switchWebSocketChannel();
    this.renderView();
  }
  
  switchView(mode) {
    this.viewMode = mode;
    this.renderCanvas();
  }
  
  selectColony(colonyId) {
    this.selectedColony = colonyId;
    this.loadColonyDetails();
    this.renderSidebar();
    this.renderCanvas();
  }
  
  // Location-specific rendering methods
  renderLocationSpecificCanvas() {
    const locationConfig = this.getLocationVisualizationConfig();
    // Render with location-appropriate colors, symbols, and layouts
  }
  
  getLocationVisualizationConfig() {
    return LOCATION_CONFIGS[this.currentCelestialBody] || LOCATION_CONFIGS.default;
  }
}
```

### Location-Specific Visual Rendering Options
```javascript
const LOCATION_CONFIGS = {
  luna: {
    terrainLayer: true,
    overlayZones: { color: '#4A90E2', opacity: 0.7 },
    animations: { pulse: 'subtle', dust: false },
    icons: { style: 'subsurface', radiation: true },
    schematic: { layout: 'lavatube_focused', colors: { precursor: '#87CEEB', industrial: '#FFA500', orbital: '#9370DB' } }
  },
  mars: {
    terrainLayer: true,
    overlayZones: { color: '#CD853F', opacity: 0.6 },
    animations: { pulse: 'moderate', dust: true },
    icons: { style: 'surface_orbital', radiation: true },
    schematic: { layout: 'orbital_first', colors: { orbital: '#FF6347', surface: '#32CD32', resource: '#FFD700', mining: '#8B4513' } }
  },
  venus: {
    terrainLayer: false, // No surface terrain
    overlayZones: { color: '#FF69B4', opacity: 0.8 },
    animations: { pulse: 'intense', corrosion: true },
    icons: { style: 'atmospheric', altitude: true },
    schematic: { layout: 'cloud_focused', colors: { orbital: '#DA70D6', harvesting: '#00CED1', cloud: '#FF1493', foundry: '#B22222', industrial: '#DC143C' } }
  },
  default: {
    // Generic configuration
  }
};
```

### Location-Aware Interaction Handlers
```javascript
// Click handlers with location context
onColonyClick: (colonyId) => {
  this.selectColony(colonyId);
  this.trackLocationInteraction('colony_selected');
},

onStructureClick: (structureId) => {
  this.selectProject(structureId);
  this.showProjectDetails();
  this.validateLocationOverride(structureId);
},

onLocationSwitch: (celestialBodyId) => {
  this.switchLocation(celestialBodyId);
  this.trackLocationSwitch(celestialBodyId);
},

onPriorityAdjust: (scope = 'global') => {
  if (scope === 'location') {
    this.showLocationPriorityControls(this.currentCelestialBody);
  } else {
    this.showGlobalPriorityControls();
  }
},

onOverrideClick: (projectId) => {
  const project = this.getProject(projectId);
  const locationConstraints = this.getLocationConstraints(project.celestialBody);
  this.showOverrideDialog(projectId, locationConstraints);
}
```

## Location-Specific Features
- **Luna View**: Lavatube-focused schematic, radiation overlays, subsurface construction highlighting
- **Mars View**: Orbital dependency visualization, dust storm effect simulation, resource extraction tracking
- **Venus View**: Altitude-based rendering, atmospheric corrosion indicators, cloud city construction focus
- **Multi-Location**: Interplanetary supply route visualization, cross-location colony comparisons

## Testing Requirements
- View loading and navigation with location switching
- Colony selection and filtering across celestial bodies
- Structure interaction and details with location context
- View mode switching maintaining location state
- Real-time data updates across location-specific channels
- Performance with large datasets distributed across multiple locations

## Risk Mitigation
- Start with schematic view, add grid overlay later with location testing
- Implement progressive loading for colony data with location prioritization
- Add error boundaries for failed data loads with location-specific fallbacks
- Create fallback views for missing terrain data or unsupported celestial bodies

## Success Metrics
- Admin can monitor all active construction projects across celestial bodies
- Location switching works without data loss or state confusion
- Real-time updates maintain <1 second latency across location channels
- Interface handles 1000+ simultaneous projects distributed across locations
- Override functionality reduces inappropriate AI decisions by 80% with location awareness