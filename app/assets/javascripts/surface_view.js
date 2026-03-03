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
    const resizeCanvas = () => {
      const rect = this.canvas.parentElement.getBoundingClientRect();
      const w = Math.floor(rect.width)  || 1200;
      const h = Math.floor(rect.height) || 700;
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
    if (window.SimpleTilesetLoader) {
      this.tilesetLoader = new window.SimpleTilesetLoader('galaxy_game_base_terrain');
      const nameEl = document.getElementById('tileset-name');
      const statusEl = document.getElementById('tileset-status');
      if (nameEl) nameEl.textContent = 'galaxy_game_base_terrain';
      if (statusEl) statusEl.textContent = 'Loading...';
      const success = await this.tilesetLoader.loadTileset();
      if (success) {
        this.tilesetLoaded = true;
        console.log(`✅ Tileset loaded: ${this.tilesetLoader.tileImages.size} tiles`);
        // ...existing code...
      } else {
        console.error('❌ Failed to load tileset');
        // ...existing code...
      }
    } else {
      console.warn('⚠️ SimpleTilesetLoader not available - using color fallback');
    }
    this.renderGrid();
    this.setupZoom();
    this.setupPan();
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
    
    // Only render visible tiles
    for (let row = viewport.startRow; row <= viewport.endRow; row++) {
      const eRow = terrain.elevation[row];
      if (!eRow) continue;
      const bRow = hasBiosphere && this.layers.biomes.grid[row]
                   ? this.layers.biomes.grid[row]
                   : null;
      const lRow = liquidGrid  ? liquidGrid[row]   : null;
      const rRow = resourceGrid ? resourceGrid[row] : null;

      for (let col = viewport.startCol; col <= viewport.endCol; col++) {
        // FIX 5: wrap horizontal col
        const wrappedCol = ((col % terrain.width) + terrain.width) % terrain.width;
        // Change all data lookups to use wrappedCol
        const rawElev = eRow[wrappedCol];
        if (rawElev == null) continue;
        const normElev = (rawElev - minElev) / elevRange;
        const x = col * TILE_SIZE * scale + this.offsetX;
        const y = row * TILE_SIZE * scale + this.offsetY;
        const tileScreenSize = TILE_SIZE * scale;
        
        // Get tile name
        const tileName = this.getTerrainTileName(elev, biome);
        
        // Try to draw tileset sprite
        if (this.tilesetLoaded && this.tilesetLoader.hasTile(tileName)) {/* Lines 113-116 omitted */} else {/* Lines 117-122 omitted */}
        
        // Optional: grid lines at high zoom
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
