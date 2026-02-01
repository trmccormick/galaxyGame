# Planetary Map UI Implementation

## Overview

Galaxy Game implements a SimEarth-inspired user interface for planetary terraforming and management. The UI combines FreeCiv-style tile rendering with real-time simulation controls, providing an intuitive yet scientifically accurate terraforming experience.

## Core UI Architecture

### MVC Pattern Implementation
**Model**: Terrain data and simulation state
**View**: Canvas-based tile rendering with layered overlays
**Controller**: User interaction handling and state management

```ruby
# Controller structure
class CelestialBodiesController < ApplicationController
  def monitor
    @planet = Geosphere.find(params[:id])
    @terrain_data = @planet.terrain_map
    @simulation_state = @planet.terraforming_state
  end

  def update_terrain
    # Handle terraforming actions
    @planet = Geosphere.find(params[:id])
    TerraformingService.new(@planet).apply_changes(params[:changes])
    redirect_to monitor_celestial_body_path(@planet)
  end
end
```

## Canvas-Based Rendering

### Tile Rendering System
**Canvas Setup**:
```html
<!-- app/views/admin/celestial_bodies/monitor.html.erb -->
<canvas id="planet-canvas" width="800" height="600"></canvas>
<script src="/assets/tileset_loader.js"></script>
<script src="/assets/planet_renderer.js"></script>
```

**JavaScript Renderer**:
```javascript
class PlanetRenderer {
  constructor(canvas, tilesetLoader) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.tilesetLoader = tilesetLoader;
    this.layers = {
      terrain: true,
      hydrosphere: true,
      biosphere: true,
      infrastructure: true,
      elevation: false
    };
  }

  render(terrainGrid) {
    this.clearCanvas();

    // Render layers in order
    if (this.layers.terrain) this.renderTerrainLayer(terrainGrid);
    if (this.layers.hydrosphere) this.renderHydrosphereLayer(terrainGrid);
    if (this.layers.biosphere) this.renderBiosphereLayer(terrainGrid);
    if (this.layers.infrastructure) this.renderInfrastructureLayer(terrainGrid);
    if (this.layers.elevation) this.renderElevationOverlay(terrainGrid);
  }

  renderTerrainLayer(terrainGrid) {
    terrainGrid.forEach((row, y) => {
      row.forEach((cell, x) => {
        const tile = this.tilesetLoader.getTerrainTile(cell.type);
        this.ctx.drawImage(tile, x * TILE_SIZE, y * TILE_SIZE);
      });
    });
  }
}
```

### Layer Toggle Controls
**UI Panel Structure**:
```html
<div class="layer-controls">
  <h3>Display Layers</h3>
  <label><input type="checkbox" id="terrain-toggle" checked> Terrain</label>
  <label><input type="checkbox" id="hydrosphere-toggle" checked> Hydrosphere</label>
  <label><input type="checkbox" id="biosphere-toggle" checked> Biosphere</label>
  <label><input type="checkbox" id="infrastructure-toggle" checked> Infrastructure</label>
  <label><input type="checkbox" id="elevation-toggle"> Elevation</label>
</div>
```

**Event Handling**:
```javascript
document.getElementById('terrain-toggle').addEventListener('change', (e) => {
  renderer.layers.terrain = e.target.checked;
  renderer.render(terrainGrid);
});
```

## Terraforming Tools

### Tool Selection Interface
**Tool Palette**:
```html
<div class="terraforming-tools">
  <button id="select-tool" class="tool-button active">
    <i class="icon-select"></i> Select
  </button>
  <button id="terraform-tool" class="tool-button">
    <i class="icon-plant"></i> Plant Biosphere
  </button>
  <button id="station-tool" class="tool-button">
    <i class="icon-station"></i> Place Station
  </button>
  <button id="analyze-tool" class="tool-button">
    <i class="icon-analyze"></i> Analyze
  </button>
</div>
```

### Tool Implementation
```javascript
class TerraformingTools {
  constructor(renderer, planetId) {
    this.renderer = renderer;
    this.planetId = planetId;
    this.activeTool = 'select';
    this.brushSize = 1;
  }

  setActiveTool(toolName) {
    this.activeTool = toolName;
    this.updateToolCursor();
  }

  onCanvasClick(x, y) {
    const gridX = Math.floor(x / TILE_SIZE);
    const gridY = Math.floor(y / TILE_SIZE);

    switch (this.activeTool) {
      case 'terraform':
        this.applyTerraforming(gridX, gridY);
        break;
      case 'station':
        this.placeStation(gridX, gridY);
        break;
      case 'analyze':
        this.showAnalysis(gridX, gridY);
        break;
    }
  }

  applyTerraforming(x, y) {
    // Send terraforming request to server
    fetch(`/admin/celestial_bodies/${this.planetId}/terraform`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'plant_biosphere',
        location: { x, y },
        radius: this.brushSize
      })
    }).then(response => response.json())
      .then(data => this.renderer.render(data.updatedTerrain));
  }
}
```

## Simulation Dashboard

### Real-Time Monitoring
**Status Display**:
```html
<div class="simulation-dashboard">
  <div class="metric">
    <label>Atmospheric Pressure:</label>
    <span id="atm-pressure">0.45 atm</span>
  </div>
  <div class="metric">
    <label>Surface Temperature:</label>
    <span id="surface-temp">285 K (12°C)</span>
  </div>
  <div class="metric">
    <label>Biosphere Coverage:</label>
    <span id="bio-coverage">25%</span>
  </div>
  <div class="metric">
    <label>Hydrosphere Status:</label>
    <span id="hydro-status">Temperate</span>
  </div>
</div>
```

### Progress Visualization
**Charts and Graphs**:
```javascript
function updateSimulationCharts(state) {
  // Update atmospheric composition pie chart
  updateAtmosphereChart(state.atmosphere.composition);

  // Update temperature trend line
  updateTemperatureChart(state.temperature.history);

  // Update biosphere growth curve
  updateBiosphereChart(state.biosphere.history);
}
```

## Interactive Features

### Zoom and Pan Controls
**Viewport Management**:
```javascript
class ViewportController {
  constructor(canvas) {
    this.canvas = canvas;
    this.scale = 1.0;
    this.offsetX = 0;
    this.offsetY = 0;
    this.setupEventListeners();
  }

  zoom(factor, centerX, centerY) {
    const newScale = this.scale * factor;
    if (newScale >= 0.5 && newScale <= 4.0) {
      this.scale = newScale;
      this.updateTransform();
    }
  }

  pan(deltaX, deltaY) {
    this.offsetX += deltaX;
    this.offsetY += deltaY;
    this.updateTransform();
  }

  updateTransform() {
    this.ctx.setTransform(this.scale, 0, 0, this.scale, this.offsetX, this.offsetY);
  }
}
```

### Selection and Highlighting
**Tile Selection**:
```javascript
function highlightTile(x, y) {
  // Draw selection rectangle
  ctx.strokeStyle = '#ffff00';
  ctx.lineWidth = 2;
  ctx.strokeRect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);

  // Show tooltip with tile information
  showTileTooltip(x, y, terrainGrid[y][x]);
}

function showTileTooltip(x, y, tileData) {
  const tooltip = document.getElementById('tile-tooltip');
  tooltip.innerHTML = `
    <strong>Terrain:</strong> ${tileData.type}<br>
    <strong>Elevation:</strong> ${tileData.elevation}m<br>
    <strong>Bio Density:</strong> ${(tileData.bio_density * 100).toFixed(1)}%<br>
    <strong>Temperature:</strong> ${calculateLocalTemp(x, y)}K
  `;
  tooltip.style.left = `${x * TILE_SIZE + 10}px`;
  tooltip.style.top = `${y * TILE_SIZE + 10}px`;
  tooltip.style.display = 'block';
}
```

## Time Controls

### Simulation Speed Control
**Time Acceleration**:
```html
<div class="time-controls">
  <button id="pause-btn">⏸️ Pause</button>
  <button id="play-btn">▶️ Play</button>
  <button id="fast-btn">⏩ Fast</button>
  <select id="speed-select">
    <option value="1">1x Speed</option>
    <option value="10">10x Speed</option>
    <option value="100">100x Speed</option>
    <option value="1000">1000x Speed</option>
  </select>
</div>
```

**Speed Implementation**:
```javascript
class SimulationController {
  constructor() {
    this.speed = 1; // 1x real time
    this.isRunning = false;
    this.lastUpdate = Date.now();
  }

  setSpeed(multiplier) {
    this.speed = multiplier;
  }

  start() {
    this.isRunning = true;
    this.simulationLoop();
  }

  simulationLoop() {
    if (!this.isRunning) return;

    const now = Date.now();
    const deltaTime = (now - this.lastUpdate) * this.speed;
    this.lastUpdate = now;

    // Advance simulation by deltaTime
    this.advanceSimulation(deltaTime);

    // Schedule next frame
    requestAnimationFrame(() => this.simulationLoop());
  }

  advanceSimulation(deltaTime) {
    // Update terraforming progress
    // Refresh UI displays
    // Trigger events based on time passage
  }
}
```

## Data Management Interface

### Import/Export Controls
**File Operations**:
```html
<div class="data-controls">
  <form action="/admin/celestial_bodies/<%= @planet.id %>/import_terrain" method="post" enctype="multipart/form-data">
    <input type="file" name="terrain_file" accept=".sav,.json">
    <button type="submit">Import Terrain</button>
  </form>

  <button id="export-btn">Export Terrain Data</button>
</div>
```

### Backup and Restore
**State Management**:
```javascript
function exportTerrainData() {
  const data = {
    terrainGrid: terrainGrid,
    simulationState: simulationState,
    timestamp: new Date().toISOString()
  };

  const blob = new Blob([JSON.stringify(data, null, 2)], {type: 'application/json'});
  const url = URL.createObjectURL(blob);

  const a = document.createElement('a');
  a.href = url;
  a.download = `planet_${planetId}_terrain_${Date.now()}.json`;
  a.click();
}
```

## Responsive Design

### Mobile Adaptation
**Touch Controls**:
```javascript
class TouchController {
  constructor(canvas) {
    this.canvas = canvas;
    this.touchStartX = 0;
    this.touchStartY = 0;
    this.setupTouchListeners();
  }

  setupTouchListeners() {
    this.canvas.addEventListener('touchstart', (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      this.touchStartX = touch.clientX;
      this.touchStartY = touch.clientY;
    });

    this.canvas.addEventListener('touchmove', (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      const deltaX = touch.clientX - this.touchStartX;
      const deltaY = touch.clientY - this.touchStartY;

      viewport.pan(deltaX, deltaY);

      this.touchStartX = touch.clientX;
      this.touchStartY = touch.clientY;
    });

    this.canvas.addEventListener('touchend', (e) => {
      // Handle tap vs swipe
      if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10) {
        // This was a tap
        this.handleTap(touch.clientX, touch.clientY);
      }
    });
  }
}
```

### Adaptive Layout
**CSS Media Queries**:
```css
@media (max-width: 768px) {
  .layer-controls {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(0,0,0,0.8);
    padding: 10px;
  }

  .terraforming-tools {
    flex-direction: row;
    overflow-x: auto;
  }

  #planet-canvas {
    width: 100vw;
    height: 60vh;
  }
}
```

## Accessibility Features

### Keyboard Navigation
**Key Bindings**:
```javascript
document.addEventListener('keydown', (e) => {
  switch (e.key) {
    case 't':
      toggleLayer('terrain');
      break;
    case 'h':
      toggleLayer('hydrosphere');
      break;
    case 'b':
      toggleLayer('biosphere');
      break;
    case 'i':
      toggleLayer('infrastructure');
      break;
    case 'e':
      toggleLayer('elevation');
      break;
    case ' ':
      simulationController.togglePause();
      break;
  }
});
```

### Screen Reader Support
**ARIA Labels**:
```html
<canvas id="planet-canvas"
        role="img"
        aria-label="Interactive planetary terrain map"
        aria-describedby="canvas-instructions">
</canvas>

<div id="canvas-instructions" class="sr-only">
  Use mouse to select tiles and apply terraforming.
  Press T to toggle terrain layer, H for hydrosphere, B for biosphere, I for infrastructure.
  Spacebar to pause/resume simulation.
</div>
```

## Performance Optimization

### Rendering Optimization
**Frame Rate Management**:
```javascript
class RenderOptimizer {
  constructor(renderer) {
    this.renderer = renderer;
    this.lastRender = 0;
    this.targetFPS = 30;
    this.frameInterval = 1000 / this.targetFPS;
  }

  requestRender() {
    const now = performance.now();
    if (now - this.lastRender >= this.frameInterval) {
      this.renderer.render();
      this.lastRender = now;
    } else {
      // Skip frame to maintain target FPS
    }
  }
}
```

### Memory Management
**Resource Cleanup**:
```javascript
function cleanupResources() {
  // Clear canvas
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Release image references
  tilesetLoader.clearCache();

  // Cancel pending animations
  cancelAnimationFrame(animationFrameId);
}
```

## Testing Framework

### UI Tests
- [ ] Canvas rendering displays correctly
- [ ] Layer toggles update display
- [ ] Tool selection changes cursor
- [ ] Zoom and pan work smoothly
- [ ] Touch controls on mobile

### Integration Tests
- [ ] Terraforming actions update server state
- [ ] Real-time updates reflect simulation changes
- [ ] Import/export preserves data integrity
- [ ] Responsive design adapts to screen sizes

### Performance Tests
- [ ] Rendering maintains 30fps
- [ ] Memory usage stays under 100MB
- [ ] Load times under 2 seconds
- [ ] Touch responsiveness under 100ms

## Future Enhancements

### Advanced Features
- **3D Rendering**: WebGL-based terrain visualization
- **Multi-Touch Gestures**: Pinch-to-zoom, rotate
- **Voice Commands**: Speech-to-text terraforming
- **VR Support**: WebXR planetary exploration

### Multiplayer UI
- **Collaborative Tools**: Shared terraforming cursors
- **Chat Integration**: Real-time communication
- **Progress Sharing**: Public terraforming achievements

## Documentation Requirements

**All UI changes must be documented:**

1. **New Controls**: Document tool functions and key bindings
2. **Layout Changes**: Update responsive design specifications
3. **Performance**: Record FPS targets and memory limits
4. **Accessibility**: Document ARIA labels and keyboard navigation

## Critical Constraints

- **Cross-Browser Compatibility**: Support Chrome, Firefox, Safari, Edge
- **Mobile Responsiveness**: Full functionality on tablets and phones
- **Performance Standards**: Maintain 30fps rendering with large maps
- **Accessibility Compliance**: WCAG 2.1 AA standards
- **Progressive Enhancement**: Core functionality works without JavaScript</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/UI_IMPLEMENTATION.md