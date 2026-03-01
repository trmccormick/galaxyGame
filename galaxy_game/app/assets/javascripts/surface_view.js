window.SurfaceView = {
  TILE_SIZE: 32,
  scale: 1.0,
  offsetX: 0,
  offsetY: 0,
  isDragging: false,
  dragStartX: 0,
  dragStartY: 0,
  dragStartOffsetX: 0,
  dragStartOffsetY: 0,
  tileImages: new Map(),
  tilesetLoaded: false,
  
  init: async function() {
    console.log("🧩 SURFACE VIEW - GEMINI GALAXY TILESET");
    const dataEl = document.getElementById('surface-data');
    const canvas = document.getElementById('surfaceCanvas');
    
    if (!dataEl || !canvas) {
      console.error('❌ Missing surface-data or canvas');
      return;
    }
    
    this.data = JSON.parse(dataEl.textContent);
    this.terrain = this.data.terrain_data;
    this.ctx = canvas.getContext('2d');
    this.canvas = canvas;
    
    console.log(`📊 Terrain: ${this.terrain?.width}×${this.terrain?.height}`);
    console.log(`🌍 Planet: ${this.data?.planet_name}`);
    
    // Update UI
    const nameEl = document.getElementById('tileset-name');
    const statusEl = document.getElementById('tileset-status');
    if (nameEl) nameEl.textContent = 'Gemini Galaxy Base';
    if (statusEl) statusEl.textContent = 'Loading...';
    
    // Load tileset
    await this.loadTileset();
    
    // Setup UI
    this.setupZoom();
    this.setupPan();
    
    // Initial render
    this.renderGrid();
  },
  
  loadTileset: async function() {
    return new Promise(resolve => {
      const img = new Image();
      img.onload = () => {
        console.log('Tileset PNG loaded:', img.width, 'x', img.height);
        ['ocean','plains','desert','forest','mountains','tundra','grasslands','swamp','jungle']
          .forEach((name, i) => {
            const canvas = document.createElement('canvas');
            canvas.width = canvas.height = 32;
            const ctx = canvas.getContext('2d');
            ctx.imageSmoothingEnabled = false;
            ctx.fillStyle = '#1a1a1a'; ctx.fillRect(0,0,32,32);
            ctx.drawImage(img, i*32, 0, 32, 32, 0, 0, 32, 32);
            this.tileImages.set(name, canvas);
          });
        this.tilesetLoaded = true;
        console.log('9 tiles loaded from PNG');
        this.renderGrid();
        resolve(true);
      };
      img.onerror = () => { console.error('PNG load failed'); resolve(false); };
      img.src = 'http://localhost:3000/tilesets/galaxy_game/base_terrain.png';
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
    
    // Clear to black
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Get visible range
    const viewport = this.getVisibleTileRange();
    
    let tilesRendered = 0;
    let tilesFallback = 0;
    
    // Render visible tiles
    for (let row = viewport.startRow; row <= viewport.endRow; row++) {
      for (let col = viewport.startCol; col <= viewport.endCol; col++) {
        if (row < 0 || row >= terrain.height || col < 0 || col >= terrain.width) {
          continue;
        }
        
        const elev = terrain.elevation[row][col];
        const biome = terrain.biomes?.[row]?.[col];
        
        const x = col * TILE_SIZE * scale + this.offsetX;
        const y = row * TILE_SIZE * scale + this.offsetY;
        const tileSize = TILE_SIZE * scale;
        
        // Get tile name
        const tileName = this.getTileName(elev, biome);
        
        // Try to draw tile
        if (this.tilesetLoaded && this.tileImages.has(tileName)) {
          const tileCanvas = this.tileImages.get(tileName);
          ctx.drawImage(tileCanvas, x, y, tileSize, tileSize);
          tilesRendered++;
        } else {
          // Fallback color
          const color = this.getFallbackColor(elev, biome);
          ctx.fillStyle = color;
          ctx.fillRect(x, y, tileSize, tileSize);
          tilesFallback++;
        }
      }
    }
    
    console.log(`✅ Rendered: ${tilesRendered} tiles, ${tilesFallback} fallback`);
  },
  
  getTileName: function(elev, biome) {
    const b = (biome || '').toLowerCase();
    if (b.includes('ice') || b.includes('tundra')) return 'tundra';
    if (b.includes('desert')) return 'desert';
    if (b.includes('forest') || b.includes('rain')) return 'forest';
    if (b.includes('jungle')) return 'jungle';
    if (b.includes('wetland') || b.includes('swamp')) return 'swamp';
    if (elev > 2000) return 'mountains';
    if (elev < 0) return 'ocean';
    return 'plains';  // Default
  },
  
  getFallbackColor: function(elev, biome) {
    let normElev = elev;
    if (elev > 10) {
      normElev = Math.max(0, Math.min(1, (elev + 8000) / 16000));
    }
    
    if (elev < 0 || normElev < 0.4) return '#1e3a8a';
    
    if (biome) {
      const b = biome.toLowerCase();
      if (b.includes('jungle')) return '#065F46';
      if (b.includes('forest')) return '#10B981';
      if (b.includes('grass')) return '#84CC16';
      if (b.includes('desert')) return '#F59E0B';
      if (b.includes('tundra')) return '#9CA3AF';
      if (b.includes('ice')) return '#E0F2FE';
    }
    
    if (normElev > 0.8) return '#78716C';
    if (normElev > 0.6) return '#A8A29E';
    return '#D6D3D1';
  },
  
  getVisibleTileRange: function() {
    const TILE_SIZE = this.TILE_SIZE;
    const scale = this.scale;
    
    const viewportLeft = -this.offsetX;
    const viewportTop = -this.offsetY;
    const viewportRight = viewportLeft + this.canvas.width;
    const viewportBottom = viewportTop + this.canvas.height;
    
    const startCol = Math.floor(viewportLeft / (TILE_SIZE * scale));
    const startRow = Math.floor(viewportTop / (TILE_SIZE * scale));
    const endCol = Math.ceil(viewportRight / (TILE_SIZE * scale));
    const endRow = Math.ceil(viewportBottom / (TILE_SIZE * scale));
    
    const buffer = 1;
    
    return {
      startRow: Math.max(0, startRow - buffer),
      startCol: Math.max(0, startCol - buffer),
      endRow: Math.min(this.terrain.height - 1, endRow + buffer),
      endCol: Math.min(this.terrain.width - 1, endCol + buffer)
    };
  },
  
  showNoTerrain: function() {
    const ctx = this.ctx;
    const canvas = this.canvas;
    
    ctx.fillStyle = '#0a1628';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    ctx.fillStyle = '#ffffff';
    ctx.font = '16px monospace';
    ctx.textAlign = 'center';
    ctx.fillText('NO TERRAIN DATA', canvas.width / 2, canvas.height / 2 - 20);
    ctx.fillText('Generate terrain first', canvas.width / 2, canvas.height / 2 + 10);
  },
  
  setupZoom: function() {
    const canvas = this.canvas;
    let zoomEl = document.getElementById('zoom');
    
    if (zoomEl) {
      zoomEl.value = this.scale;
      zoomEl.addEventListener('input', (e) => {
        this.scale = parseFloat(e.target.value);
        const valEl = document.getElementById('zoomValue');
        if (valEl) valEl.textContent = this.scale.toFixed(1) + 'x';
        this.renderGrid();
      });
    }
    
    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      this.scale *= e.deltaY > 0 ? 0.9 : 1.1;
      this.scale = Math.max(0.5, Math.min(4, this.scale));
      
      zoomEl = document.getElementById('zoom');
      if (zoomEl) zoomEl.value = this.scale;
      const valEl = document.getElementById('zoomValue');
      if (valEl) valEl.textContent = this.scale.toFixed(1) + 'x';
      this.renderGrid();
    }, { passive: false });
    
    const resetBtn = document.getElementById('resetViewBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        this.scale = 1.0;
        this.offsetX = 0;
        this.offsetY = 0;
        zoomEl = document.getElementById('zoom');
        if (zoomEl) zoomEl.value = 1.0;
        const valEl = document.getElementById('zoomValue');
        if (valEl) valEl.textContent = '1.0x';
        this.renderGrid();
      });
    }
  },

  setupPan: function() {
    const canvas = this.canvas;
    if (!canvas) return;
    
    canvas.style.cursor = 'grab';
    
    let renderThrottle = null;
    
    canvas.addEventListener('mousedown', (e) => {
      this.isDragging = true;
      this.dragStartX = e.clientX;
      this.dragStartY = e.clientY;
      this.dragStartOffsetX = this.offsetX;
      this.dragStartOffsetY = this.offsetY;
      canvas.style.cursor = 'grabbing';
    });
    
    canvas.addEventListener('mousemove', (e) => {
      if (!this.isDragging) return;
      
      const dx = e.clientX - this.dragStartX;
      const dy = e.clientY - this.dragStartY;
      
      this.offsetX = this.dragStartOffsetX + dx;
      this.offsetY = this.dragStartOffsetY + dy;
      
      if (renderThrottle) return;
      
      renderThrottle = setTimeout(() => {
        this.renderGrid();
        renderThrottle = null;
      }, 33);
    });
    
    canvas.addEventListener('mouseup', () => {
      this.isDragging = false;
      canvas.style.cursor = 'grab';
    });
    
    canvas.addEventListener('mouseleave', () => {
      this.isDragging = false;
      canvas.style.cursor = 'grab';
    });
  }
};

// Auto-init
document.addEventListener('DOMContentLoaded', () => {
  window.SurfaceView.init();
});

if (typeof Turbo !== 'undefined') {
  document.addEventListener('turbo:load', () => {
    window.SurfaceView.init();
  });
}