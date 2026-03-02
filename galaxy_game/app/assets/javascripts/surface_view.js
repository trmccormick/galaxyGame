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
  renderer: null,       // BiomeRenderer instance (individual PNGs, no spritesheet)
  rafId: null,          // requestAnimationFrame handle
  dirty: true,          // marks canvas as needing redraw
  _lastLogTime: 0,
  
  init: async function() {
    console.log("🧩 SURFACE VIEW - GEMINI GALAXY TILESET");
    const dataEl = document.getElementById('surface-data');
    const canvas = document.getElementById('surfaceCanvas');
    
    if (!dataEl || !canvas) {
      console.error('❌ Missing surface-data or canvas');
      return;
    }
    
    // Cancel any previous rAF loop from a Turbo navigation
    if (this.rafId) { cancelAnimationFrame(this.rafId); this.rafId = null; }
    
    this.data    = JSON.parse(dataEl.textContent);
    this.terrain = this.data.terrain_data;
    this.ctx     = canvas.getContext('2d');
    this.canvas  = canvas;
    
    if (!this.terrain || !this.terrain.elevation) {
      console.warn('⚠️ No terrain data — generate terrain first');
    } else {
      const elevData = this.terrain.elevation;
      const actualRows = elevData.length;
      const actualCols = elevData[0] ? elevData[0].length : 0;
      console.log(`📊 Terrain: ${this.terrain.width}×${this.terrain.height} (elevation[${actualRows}][${actualCols}] row-major)`);
      
      // Log a sample raw biome name to confirm format
      const biomeData = this.terrain.biomes;
      if (biomeData) {
        let sample = null;
        outer: for (let row = 0; row < biomeData.length; row++) {
          for (let col = 0; col < (biomeData[row] ? biomeData[row].length : 0); col++) {
            if (biomeData[row][col]) { sample = biomeData[row][col]; break outer; }
          }
        }
        console.log(`🌿 biomes[0][0] sample: "${sample}" (raw terrain name from generator)`);
      } else {
        console.warn('⚠️ terrain.biomes is null — elevation-only fallback active');
      }
    }
    console.log(`🌍 Planet: ${this.data.planet_name}`);
    
    // Update UI
    const nameEl   = document.getElementById('tileset-name');
    const statusEl = document.getElementById('tileset-status');
    if (nameEl)   nameEl.textContent   = 'Gemini Galaxy Biomes';
    if (statusEl) statusEl.textContent = 'Loading BiomeRenderer…';
    
    // ── Init BiomeRenderer (10 individual PNGs — no spritesheet required) ──
    if (!window.BiomeRenderer) {
      console.error('❌ BiomeRenderer not loaded — include biome_renderer.js before surface_view.js');
      if (statusEl) statusEl.textContent = '❌ BiomeRenderer missing';
      return;
    }
    this.renderer = new window.BiomeRenderer();
    await this.renderer.init();
    
    const loaded  = this.renderer.tiles.size;
    const missing = this.renderer.missingBiomes();
    console.log(`🗺️ BiomeRenderer: ${loaded}/10 PNGs ready`);
    if (missing.length > 0) console.warn('⚠️ Missing biome PNGs (colour fallback):', missing);
    
    const tilesLoadedEl = document.getElementById('tiles-loaded');
    if (tilesLoadedEl) tilesLoadedEl.textContent = `${loaded}/10`;
    if (statusEl) statusEl.textContent = loaded === 10 ? '✅ All 10 loaded' : `⚠️ ${loaded}/10 loaded`;
    
    // Setup interactivity
    this.setupZoom();
    this.setupPan();
    this.setupCursorInfo();
    
    // Start rAF render loop (dirty flag prevents unnecessary redraws)
    this.dirty = true;
    this.startRenderLoop();
  },
  
  // ── rAF render loop ──────────────────────────────────────────────────────
  startRenderLoop: function() {
    const loop = () => {
      if (this.dirty) {
        this.renderGrid();
        this.dirty = false;
      }
      this.rafId = requestAnimationFrame(loop);
    };
    this.rafId = requestAnimationFrame(loop);
  },
  
  // ── Main render ────────────────────────────────────────────────────────
  renderGrid: function() {
    if (!this.terrain || !this.terrain.elevation) {
      this.showNoTerrain();
      return;
    }
    
    const ctx      = this.ctx;
    const canvas   = this.canvas;
    const terrain  = this.terrain;
    const scale    = this.scale;
    const tileSize = this.TILE_SIZE * scale;
    
    // Clear
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    const viewport = this.getVisibleTileRange();
    
    let tilesRendered = 0;
    let tilesFallback = 0;
    
    for (let row = viewport.startRow; row <= viewport.endRow; row++) {
      const elevRow  = terrain.elevation[row];
      const biomeRow = terrain.biomes ? terrain.biomes[row] : null;
      if (!elevRow) continue;
      
      for (let col = viewport.startCol; col <= viewport.endCol; col++) {
        const elev  = elevRow[col];
        if (elev === undefined || elev === null) continue;
        
        const biome = biomeRow ? biomeRow[col] : null;
        const x     = col * tileSize + this.offsetX;
        const y     = row * tileSize + this.offsetY;
        
        const tileName   = this.getTileName(elev, biome);
        const tileCanvas = this.renderer ? this.renderer.tiles.get(tileName) : null;
        
        if (tileCanvas) {
          ctx.imageSmoothingEnabled = false;
          ctx.drawImage(tileCanvas, x, y, tileSize, tileSize);
          tilesRendered++;
        } else {
          ctx.fillStyle = this.getFallbackColor(elev, biome);
          ctx.fillRect(x, y, tileSize, tileSize);
          tilesFallback++;
        }
      }
    }
    
    // Throttle console to once per 5 s (rAF fires every frame)
    const now = Date.now();
    if (now - this._lastLogTime > 5000) {
      console.log(`✅ Rendered: ${tilesRendered} tiles, ${tilesFallback} fallback`);
      this._lastLogTime = now;
    }
  },
  
  // ── Biome name normalisation ─────────────────────────────────────────
  // Maps automatic_terrain_generator.rb raw names → BiomeRenderer PNG keys:
  //   ocean / coast → 'ocean'     arctic / ice → 'tundra'
  //   tropical_rainforest / jungle → 'jungle'
  //   temperate_forest / forest → 'forest'
  //   grassland / savanna / grass → 'grasslands'
  //   hills → 'mountains'
  getTileName: function(elev, biome) {
    const b = (biome || '').toLowerCase().trim();
    
    if (b === 'ocean'   || b.includes('ocean') || b === 'coast' || b.includes('coast')) return 'ocean';
    if (b === 'arctic'  || b.includes('arctic') || b.includes('ice'))    return 'tundra';
    if (b === 'tundra'  || b.includes('tundra'))                          return 'tundra';
    if (b === 'desert'  || b.includes('desert'))                          return 'desert';
    if (b.includes('tropical') || b.includes('rainforest') || b === 'jungle') return 'jungle';
    if (b.includes('swamp')    || b.includes('wetland') || b.includes('marsh')) return 'swamp';
    if (b.includes('forest'))                                              return 'forest';
    if (b === 'grassland' || b.includes('grass') || b.includes('savanna')) return 'grasslands';
    if (b === 'hills'     || b.includes('hill'))                           return 'mountains';
    if (b.includes('mountain') || b.includes('alpine'))                    return 'mountains';
    
    // Elevation-only fallback (no biome field in terrain data)
    if (elev < 0)    return 'ocean';
    if (elev > 3000) return 'mountains';
    return 'plains';
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
    const tileSize = this.TILE_SIZE * this.scale;
    
    const viewportLeft   = -this.offsetX;
    const viewportTop    = -this.offsetY;
    const viewportRight  = viewportLeft  + this.canvas.width;
    const viewportBottom = viewportTop   + this.canvas.height;
    
    const buffer   = 2;
    const maxRows  = (this.terrain ? this.terrain.elevation.length      : 0) - 1;
    const maxCols  = (this.terrain && this.terrain.elevation[0] ? this.terrain.elevation[0].length : 0) - 1;
    
    return {
      startRow: Math.max(0,       Math.floor(viewportTop    / tileSize) - buffer),
      startCol: Math.max(0,       Math.floor(viewportLeft   / tileSize) - buffer),
      endRow:   Math.min(maxRows, Math.ceil( viewportBottom / tileSize) + buffer),
      endCol:   Math.min(maxCols, Math.ceil( viewportRight  / tileSize) + buffer)
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
        this.dirty = true;
      });
    }
    
    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      this.scale *= e.deltaY > 0 ? 0.9 : 1.1;
      this.scale = Math.max(0.5, Math.min(6, this.scale));
      
      zoomEl = document.getElementById('zoom');
      if (zoomEl) zoomEl.value = this.scale;
      const valEl = document.getElementById('zoomValue');
      if (valEl) valEl.textContent = this.scale.toFixed(1) + 'x';
      this.dirty = true;
    }, { passive: false });
    
    const resetBtn = document.getElementById('resetViewBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        this.scale   = 1.0;
        this.offsetX = 0;
        this.offsetY = 0;
        zoomEl = document.getElementById('zoom');
        if (zoomEl) zoomEl.value = 1.0;
        const valEl = document.getElementById('zoomValue');
        if (valEl) valEl.textContent = '1.0x';
        this.dirty = true;
      });
    }
  },

  setupPan: function() {
    const canvas = this.canvas;
    if (!canvas) return;
    
    canvas.style.cursor = 'grab';
    
    canvas.addEventListener('mousedown', (e) => {
      this.isDragging      = true;
      this.dragStartX      = e.clientX;
      this.dragStartY      = e.clientY;
      this.dragStartOffsetX = this.offsetX;
      this.dragStartOffsetY = this.offsetY;
      canvas.style.cursor  = 'grabbing';
    });
    
    canvas.addEventListener('mousemove', (e) => {
      if (this.isDragging) {
        this.offsetX = this.dragStartOffsetX + (e.clientX - this.dragStartX);
        this.offsetY = this.dragStartOffsetY + (e.clientY - this.dragStartY);
        this.dirty   = true;
      }
      // Update cursor readout regardless of drag state
      this.updateCursorReadout(e);
    });
    
    canvas.addEventListener('mouseup', () => {
      this.isDragging     = false;
      canvas.style.cursor = 'grab';
    });
    
    canvas.addEventListener('mouseleave', () => {
      this.isDragging     = false;
      canvas.style.cursor = 'grab';
    });
  },

  // ── Cursor tile readout ──────────────────────────────────────────────
  setupCursorInfo: function() {
    // Thin wrapper — actual work in updateCursorReadout (called from mousemove)
    this.canvas.addEventListener('mousemove', (e) => this.updateCursorReadout(e));
  },

  updateCursorReadout: function(e) {
    if (!this.terrain || !this.terrain.elevation) return;
    
    const rect     = this.canvas.getBoundingClientRect();
    const px       = e.clientX - rect.left;
    const py       = e.clientY - rect.top;
    const tileSize = this.TILE_SIZE * this.scale;
    const col      = Math.floor((px - this.offsetX) / tileSize);
    const row      = Math.floor((py - this.offsetY) / tileSize);
    
    const elevRow  = this.terrain.elevation[row];
    const biomeRow = this.terrain.biomes ? this.terrain.biomes[row] : null;
    
    const posEl   = document.getElementById('cursor-pos');
    const tileEl  = document.getElementById('cursor-tile');
    const biomeEl = document.getElementById('cursor-biome');
    const elevEl  = document.getElementById('cursor-elevation');
    
    if (!elevRow || elevRow[col] === undefined) {
      if (posEl)   posEl.textContent   = `${col}, ${row} (out of bounds)`;
      if (tileEl)  tileEl.textContent  = '-';
      if (biomeEl) biomeEl.textContent = '-';
      if (elevEl)  elevEl.textContent  = '-';
      return;
    }
    
    const elev  = elevRow[col];
    const biome = biomeRow ? biomeRow[col] : null;
    const tile  = this.getTileName(elev, biome);
    
    if (posEl)   posEl.textContent   = `col ${col}, row ${row}`;
    if (tileEl)  tileEl.textContent  = tile;
    if (biomeEl) biomeEl.textContent = biome || '(elevation only)';
    if (elevEl)  elevEl.textContent  = `${Math.round(elev)} m`;
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