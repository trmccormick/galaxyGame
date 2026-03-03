/* ...existing code from surface_view_optimized.js attachment... */
window.SurfaceView = {
  TILE_SIZE: 32,
  scale: 1.0,
  // --- Pan state ---
  offsetX: 0,
  offsetY: 0,
  isDragging: false,
  dragStartX: 0,
  dragStartY: 0,
  dragStartOffsetX: 0,
  dragStartOffsetY: 0,
  // --- Tileset loader ---
  tilesetLoader: null,
  tilesetLoaded: false,

  init: async function() {
    console.log("🧩 SURFACE VIEW - OPTIMIZED VERSION");
    const dataEl = document.getElementById('surface-data');
    const canvas = document.getElementById('surfaceCanvas');
    if (!dataEl || !canvas) {
      console.error('Missing surface-data or canvas');
      return;
    }
    this.data = JSON.parse(dataEl.textContent);
    this.terrain = this.data.terrain_data;
    this.ctx = canvas.getContext('2d');
    this.canvas = canvas;
    // FIX 2: Ensure canvas pixel size matches CSS size for sharp tiles
    // PHASE 1: Regional view 16K scaling
    const MAX_CANVAS_WIDTH  = 16384;
    const MAX_CANVAS_HEIGHT = 8192;
    const resizeCanvas = () => {
      const rect = this.canvas.parentElement.getBoundingClientRect();
      let w = Math.floor(rect.width)  || 1200;
      let h = Math.floor(rect.height) || 700;
      // Clamp to max regional view size
      w = Math.min(w, MAX_CANVAS_WIDTH);
      h = Math.min(h, MAX_CANVAS_HEIGHT);
      if (this.canvas.width !== w || this.canvas.height !== h) {
        this.canvas.width  = w;
        this.canvas.height = h;
        this.viewportInitialized = false;
        this.dirty = true;
      }
    };
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    this.ctx.imageSmoothingEnabled = true;
    this.ctx.imageSmoothingQuality = 'high';
    console.log(`🧩 Terrain grid: ${this.terrain.width}×${this.terrain.height}`);
    // PHASE 2: Sprite atlas integration
    if (window.SimpleTilesetLoader) {
      // Use external atlas and config for regional view
      this.tilesetLoader = new window.SimpleTilesetLoader('galaxy_surface', '/assets/galaxy_surface.png', '/assets/galaxy_surface_tileset.json');
      const nameEl = document.getElementById('tileset-name');
      const statusEl = document.getElementById('tileset-status');
      if (nameEl) nameEl.textContent = 'galaxy_surface';
      if (statusEl) statusEl.textContent = 'Loading...';
      const success = await this.tilesetLoader.loadTileset();
      if (success) {
        this.tilesetLoaded = true;
        console.log(`✅ Sprite atlas loaded: ${this.tilesetLoader.tileImages.size} tiles`);
      } else {
        console.error('❌ Failed to load sprite atlas');
      }
    } else {
      console.warn('⚠️ SimpleTilesetLoader not available - using color fallback');
    }
    this.renderGrid();
    this.setupZoom();
    this.setupPan();
    // PHASE 2: Add layer toggles for units/cities
    this.visibleLayers = new Set(['terrain', 'liquid', 'biomes', 'units', 'cities']);
    const unitToggle = document.getElementById('toggleUnitsBtn');
    if (unitToggle) {
      unitToggle.addEventListener('click', () => {
        if (this.visibleLayers.has('units')) this.visibleLayers.delete('units');
        else this.visibleLayers.add('units');
        this.dirty = true;
      });
    }
    const cityToggle = document.getElementById('toggleCitiesBtn');
    if (cityToggle) {
      cityToggle.addEventListener('click', () => {
        if (this.visibleLayers.has('cities')) this.visibleLayers.delete('cities');
        else this.visibleLayers.add('cities');
        this.dirty = true;
      });
    }
    // FIX 6: Add click handler for AI planning panel
    canvas.addEventListener('click', e => {
      if (!this.layers.elevation) return;
      const rect     = canvas.getBoundingClientRect();
      const mouseX   = e.clientX - rect.left;
      const mouseY   = e.clientY - rect.top;
      const tileSize = this.TILE_SIZE * this.scale;
      const { width, height } = this.layers.elevation;
      const col        = Math.floor((mouseX - this.offsetX) / tileSize);
      const row        = Math.floor((mouseY - this.offsetY) / tileSize);
      const wrappedCol = ((col % width) + width) % width;
      if (row < 0 || row >= height) return;
      this._showTileDetail(wrappedCol, row);
    });
  },

  renderGrid: function() {
    if (!this.terrain) {
      this.showNoTerrain();
      return;
    }
    
    const ctx = this.ctx;
    const canvas = this.canvas;
    const terrain = this.terrain;
    const TILE_SIZE = this.TILE_SIZE;
    const scale = this.scale;
    
    // Clear canvas
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Calculate visible tile range (OPTIMIZATION!)
    const viewport = this.getVisibleTileRange();
    
    let tilesRendered = 0;
    let tilesFallback = 0;
    
      // PHASE 3: Optimized render loop for 16K regional view
      // Only render visible tiles (viewport culling)
      for (let row = viewport.startRow; row <= viewport.endRow; row++) {
        const eRow = terrain.elevation[row];
        if (!eRow) continue;
        const bRow = hasBiosphere && this.layers.biomes.grid[row]
                     ? this.layers.biomes.grid[row]
                     : null;
        const lRow = liquidGrid  ? liquidGrid[row]   : null;
        const rRow = resourceGrid ? resourceGrid[row] : null;

        for (let col = viewport.startCol; col <= viewport.endCol; col++) {
          const wrappedCol = ((col % terrain.width) + terrain.width) % terrain.width;
          const rawElev = eRow[wrappedCol];
          if (rawElev == null) continue;
          const normElev = (rawElev - minElev) / elevRange;
          const x = col * TILE_SIZE * scale + this.offsetX;
          const y = row * TILE_SIZE * scale + this.offsetY;
          const tileScreenSize = TILE_SIZE * scale;

          // Level-of-detail: batch draw distant tiles as single color blocks
          if (scale < 0.7) {
            // Low zoom: batch by 4x4 tiles for speed
            if (col % 4 === 0 && row % 4 === 0) {
              ctx.fillStyle = this.getTerrainColor(rawElev, bRow ? bRow[wrappedCol] : null);
              ctx.fillRect(x, y, tileScreenSize * 4, tileScreenSize * 4);
              tilesFallback++;
            }
            continue;
          }

          // Get tile name for sprite rendering
          const tileName = this.getTerrainTileName(rawElev, bRow ? bRow[wrappedCol] : null);
          if (this.tilesetLoaded && this.tilesetLoader.hasTile(tileName)) {
            const sprite = this.tilesetLoader.getTile(tileName);
            if (sprite) {
              ctx.drawImage(sprite, x, y, tileScreenSize, tileScreenSize);
              tilesRendered++;
              continue;
            }
          }
          // Fallback: draw color
          ctx.fillStyle = this.getTerrainColor(rawElev, bRow ? bRow[wrappedCol] : null);
          ctx.fillRect(x, y, tileScreenSize, tileScreenSize);
          tilesFallback++;
          // Optional: grid lines at high zoom
          if (scale >= 2.0) {/* Lines 126-129 omitted */}
        }
      }
        if (scale >= 2.0) {/* Lines 126-129 omitted */}
      }
    }
    
    // Log performance stats
    console.log(`✅ Rendered ${tilesRendered + tilesFallback} tiles (${tilesRendered} sprites, ${tilesFallback} colors) ` +
                `viewport: [${viewport.startRow}-${viewport.endRow}, ${viewport.startCol}-${viewport.endCol}]`);
  },
  
  getVisibleTileRange: function(gridWidth, gridHeight, tileSize) {
    const buffer = 2;
    const left   = -this.offsetX;
    const top    = -this.offsetY;
    return {
      startRow: Math.max(0,           Math.floor(top  / tileSize) - buffer),
      endRow:   Math.min(gridHeight-1, Math.ceil((top  + this.canvas.height) / tileSize) + buffer),
      startCol: Math.max(0,           Math.floor(left / tileSize) - buffer),
      endCol:   Math.ceil((left + this.canvas.width)  / tileSize) + buffer // FIX 5: remove clamp
    };
  },
  
  getTerrainTileName: function(elev, biome) {
    // ...existing code from surface_view_optimized.js attachment...
    // ...see attachment for full logic...
  },
  
  getTerrainColor: function(elev, biome) {
    // ...existing code from surface_view_optimized.js attachment...
    // ...see attachment for full logic...
  },
  
  showNoTerrain: function() {
    // ...existing code from surface_view_optimized.js attachment...
  },
  
  setupZoom: function() {
    // ...existing code...
    // Call clampOffset at end
    if (typeof this._clampOffset === 'function') this._clampOffset();
  },

  setupPan: function() {
    const canvas = this.canvas;

    this._clampOffset = () => {
      if (!this.layers.elevation) return;
      const { width, height } = this.layers.elevation;
      const worldW = width  * this.TILE_SIZE * this.scale;
      const worldH = height * this.TILE_SIZE * this.scale;

      // Vertical: hard clamp - poles are top and bottom edges, no black
      const minY = Math.max(0, this.canvas.height - worldH);
      this.offsetY = Math.max(minY, Math.min(0, this.offsetY));

      // Horizontal: cylindrical wrap - no east/west edge on a planet
      if (worldW > this.canvas.width) {
        this.offsetX = ((this.offsetX % worldW) + worldW) % worldW;
      } else {
        // Entire map fits on screen - centre it
        this.offsetX = (this.canvas.width - worldW) / 2;
      }
    };

    canvas.addEventListener('mousedown', e => {
      this.isDragging       = true;
      this.dragStartX       = e.clientX;
      this.dragStartY       = e.clientY;
      this.dragStartOffsetX = this.offsetX;
      this.dragStartOffsetY = this.offsetY;
      canvas.style.cursor   = 'grabbing';
    });

    window.addEventListener('mousemove', e => {
      if (!this.isDragging) return;
      this.offsetX = this.dragStartOffsetX + (e.clientX - this.dragStartX);
      this.offsetY = this.dragStartOffsetY + (e.clientY - this.dragStartY);
      this._clampOffset();
      this.dirty = true;
    });

    window.addEventListener('mouseup', () => {
      this.isDragging     = false;
      canvas.style.cursor = 'grab';
    });

    canvas.style.cursor = 'grab';
  }
};

function initSurfaceView() {
  if (document.getElementById('surfaceCanvas')) SurfaceView.init();
}
document.addEventListener('DOMContentLoaded', initSurfaceView);
document.addEventListener('turbo:load', initSurfaceView);
document.addEventListener('turbo:render', initSurfaceView);
