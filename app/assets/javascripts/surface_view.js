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
    
    // Enable canvas smoothing for better quality
    this.ctx.imageSmoothingEnabled = true;
    this.ctx.imageSmoothingQuality = 'high';
    
    console.log(`🧩 Terrain grid: ${this.terrain.width}×${this.terrain.height}`);
    
    // Initialize tileset loader
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
        
        if (nameEl) /* Line 52 omitted */
        if (statusEl) /* Line 53 omitted */
        
        const loadedEl = document.getElementById('tiles-loaded');
        if (loadedEl) /* Line 56 omitted */
      } else {
        console.error('❌ Failed to load tileset');
        if (statusEl) /* Line 59 omitted */
      }
    } else {
      console.warn('⚠️ SimpleTilesetLoader not available - using color fallback');
    }
    
    this.renderGrid();
    this.setupZoom();
    this.setupPan();
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
      for (let col = viewport.startCol; col <= viewport.endCol; col++) {
        // Bounds check
        if (row < 0 || row >= terrain.height || col < 0 || col >= terrain.width) {/* Lines 97-98 omitted */}
        
        const elev = terrain.elevation[row][col];
        const biome = terrain.biomes?.[row]?.[col];
        
        // Calculate screen position
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
  
  getVisibleTileRange: function() {
    const canvas = this.canvas;
    const TILE_SIZE = this.TILE_SIZE;
    const scale = this.scale;
    
    // World coordinates of viewport corners
    const viewportLeft = -this.offsetX;
    const viewportTop = -this.offsetY;
    const viewportRight = viewportLeft + canvas.width;
    const viewportBottom = viewportTop + canvas.height;
    
    // Convert to tile coordinates
    const startCol = Math.floor(viewportLeft / (TILE_SIZE * scale));
    const startRow = Math.floor(viewportTop / (TILE_SIZE * scale));
    const endCol = Math.ceil(viewportRight / (TILE_SIZE * scale));
    const endRow = Math.ceil(viewportBottom / (TILE_SIZE * scale));
    
    // Add 1-tile buffer for smooth panning
    const buffer = 1;
    
    return {
      startRow: Math.max(0, startRow - buffer),
      startCol: Math.max(0, startCol - buffer),
      endRow: Math.min(this.terrain.height - 1, endRow + buffer),
      endCol: Math.min(this.terrain.width - 1, endCol + buffer)
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
    // ...existing code from surface_view_optimized.js attachment...
  },

  setupPan: function() {
    // ...existing code from surface_view_optimized.js attachment...
  }
};

// AUTO INIT
document.addEventListener('DOMContentLoaded', () => {
  window.SurfaceView.init();
});

if (typeof Turbo !== 'undefined') {
  document.addEventListener('turbo:load', () => {
    window.SurfaceView.init();
  });
}
