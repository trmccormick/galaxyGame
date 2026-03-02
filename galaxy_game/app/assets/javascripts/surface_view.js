
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
  renderer: null,
  rafId: null,
  dirty: true,
  _lastLogTime: 0,
  showBiomes: true,
  planetType: "Earth",

  init: async function() {
    const dataEl = document.getElementById('surface-data');
    const canvas = document.getElementById('surfaceCanvas');
    if (!dataEl || !canvas) return;
    if (this.rafId) { cancelAnimationFrame(this.rafId); this.rafId = null; }

    this.data    = JSON.parse(dataEl.textContent);
    this.terrain = this.data.terrain_data;
    this.ctx     = canvas.getContext('2d');
    this.canvas  = canvas;

    // ── Planet identity ──────────────────────────────────────────────────
    const rawType = window.PLANET_TYPE || this.data.planet_type || '';
    const rawName = window.PLANET_NAME || this.data.planet_name || '';
    this.planetType = rawType || rawName || 'Unknown';
    this.planetName = rawName;
    console.log(`🌍 Planet: "${rawName}" type: "${rawType}"`);

    // ── Terrain mode detection (data-format, not name heuristic) ─────────
    // BIOME mode : terrain.biomes[row][col] is a non-empty string
    // ELEVATION  : terrain.biomes is absent / null — numbers only
    if (this.terrain && this.terrain.elevation) {
      const firstBiome = this.terrain.biomes &&
                         this.terrain.biomes[0] &&
                         this.terrain.biomes[0][0];
      this.terrainMode = (typeof firstBiome === 'string' && firstBiome.length > 0)
        ? 'biome'
        : 'elevation';
    } else {
      this.terrainMode = 'elevation';
    }
    console.log(`🗺️  Terrain mode: ${this.terrainMode} (biomes present: ${!!(this.terrain && this.terrain.biomes)})`);

    const nameEl   = document.getElementById('tileset-name');
    const statusEl = document.getElementById('tileset-status');

    if (this.terrainMode === 'biome') {
      // ── BIOME mode: load BiomeRenderer PNGs ─────────────────────────
      if (nameEl)   nameEl.textContent   = 'Gemini Galaxy Biomes';
      if (statusEl) statusEl.textContent = 'Loading BiomeRenderer…';
      if (!window.BiomeRenderer) {
        if (statusEl) statusEl.textContent = '❌ BiomeRenderer missing';
        return;
      }
      this.renderer = new window.BiomeRenderer();
      await this.renderer.init();
      const loaded = this.renderer.tiles.size;
      const missing = this.renderer.missingBiomes();
      if (missing.length > 0) console.warn('⚠️ Missing PNGs (colour fallback):', missing);
      const tilesLoadedEl = document.getElementById('tiles-loaded');
      if (tilesLoadedEl) tilesLoadedEl.textContent = `${loaded}/10`;
      if (statusEl) statusEl.textContent = loaded === 10 ? '✅ All 10 loaded' : `⚠️ ${loaded}/10`;
    } else {
      // ── ELEVATION mode: grayscale — no sprites needed ────────────────
      if (nameEl)   nameEl.textContent   = 'Elevation Colormap';
      if (statusEl) statusEl.textContent = '✅ Grayscale elevation';
      const tilesLoadedEl = document.getElementById('tiles-loaded');
      if (tilesLoadedEl) tilesLoadedEl.textContent = 'N/A';
      this.renderer = null; // explicitly not used
    }

    const toggleBtn = document.getElementById('toggleTerrainBtn');
    if (toggleBtn) {
      toggleBtn.style.display = this.terrainMode === 'biome' ? '' : 'none';
      toggleBtn.onclick = () => {
        this.showBiomes = !this.showBiomes;
        toggleBtn.textContent = this.showBiomes ? 'Show Elevation' : 'Show Biomes';
        this.dirty = true;
      };
    }

    this.setupZoom();
    this.setupPan();
    this.setupCursorInfo();
    this.dirty = true;
    this.startRenderLoop();
  },

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

  renderGrid: function() {
    if (!this.terrain || !this.terrain.elevation) {
      this.showNoTerrain();
      return;
    }
    const ctx      = this.ctx;
    const canvas   = this.canvas;
    const terrain  = this.terrain;
    const tileSize = this.TILE_SIZE * this.scale;

    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.imageSmoothingEnabled = false;

    const viewport = this.getVisibleTileRange();
    let tilesRendered = 0, tilesFallback = 0;

    for (let row = viewport.startRow; row <= viewport.endRow; row++) {
      const elevRow  = terrain.elevation[row];
      if (!elevRow) continue;
      const biomeRow = terrain.biomes ? terrain.biomes[row] : null;

      for (let col = viewport.startCol; col <= viewport.endCol; col++) {
        const elev = elevRow[col];
        if (elev === undefined || elev === null) continue;

        const x = col * tileSize + this.offsetX;
        const y = row * tileSize + this.offsetY;

        if (this.terrainMode === 'elevation') {
          // ── ELEVATION mode: pure grayscale colormap, no sprites ───────
          ctx.fillStyle = this.getElevationColor(elev);
          ctx.fillRect(x, y, tileSize, tileSize);
          tilesFallback++;
        } else {
          // ── BIOME mode: BiomeRenderer PNGs with colour fallback ───────
          const biome    = biomeRow ? biomeRow[col] : null;
          const tileName = this.getTileName(elev, biome);
          const tileCvs  = this.renderer ? this.renderer.tiles.get(tileName) : null;

          if (this.showBiomes && tileCvs) {
            ctx.drawImage(tileCvs, x, y, tileSize, tileSize);
            tilesRendered++;
          } else {
            ctx.fillStyle = this.getFallbackColor(elev, biome);
            ctx.fillRect(x, y, tileSize, tileSize);
            tilesFallback++;
          }
        }
      }
    }

    const now = Date.now();
    if (now - this._lastLogTime > 5000) {
      console.log(`✅ [${this.terrainMode}] Rendered: ${tilesRendered} tiles, ${tilesFallback} fills`);
      this._lastLogTime = now;
    }
  },

  getTileName: function(elev, biome) {
    const b = (biome || '').toLowerCase().trim();
    if (this.planetType === "Luna") {
      if (b === "crater" || b.includes("crater")) return "crater";
      if (b === "low"    || b.includes("regolith")) return "regolith";
      if (b === "med"    || b.includes("maria")) return "maria";
      if (b === "high"   || b.includes("highlands")) return "highlands";
      if (elev < 0) return "regolith";
      if (elev > 3000) return "highlands";
      return "maria";
    } else {
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
      if (elev < 0)    return 'ocean';
      if (elev > 3000) return 'mountains';
      return 'plains';
    }
  },

  // ── Grayscale colormap for elevation-only worlds (Luna, rocky bodies) ─
  // Normalises to the typical planetary terrain range: -10 000 m … +10 000 m
  // Result: near-black maria → mid-grey plains → bright highland peaks
  getElevationColor: function(elev) {
    const t = Math.max(0, Math.min(1, (elev + 10000) / 20000));
    const v = Math.round(30 + t * 200); // 30 (deep basins) … 230 (peaks)
    return `rgb(${v},${v},${v})`;
  },

  getFallbackColor: function(elev, biome) {
    const normElev = Math.max(0, Math.min(1, (elev + 8000) / 16000));
    if (elev < 0 || normElev < 0.4) return '#1e3a8a';
    if (biome) {
      const b = biome.toLowerCase();
      if (b.includes('jungle'))        return '#065F46';
      if (b.includes('forest'))        return '#10B981';
      if (b.includes('grass'))         return '#84CC16';
      if (b.includes('desert'))        return '#F59E0B';
      if (b.includes('tundra'))        return '#9CA3AF';
      if (b.includes('ice'))           return '#E0F2FE';
    }
    if (normElev > 0.8) return '#78716C';
    if (normElev > 0.6) return '#A8A29E';
    return '#D6D3D1';
  },

  getVisibleTileRange: function() {
    const tileSize     = this.TILE_SIZE * this.scale;
    const viewportLeft   = -this.offsetX;
    const viewportTop    = -this.offsetY;
    const viewportRight  = viewportLeft  + this.canvas.width;
    const viewportBottom = viewportTop   + this.canvas.height;
    const buffer   = 2;
    const maxRows  = (this.terrain ? this.terrain.elevation.length : 0) - 1;
    const maxCols  = (this.terrain && this.terrain.elevation[0] ? this.terrain.elevation[0].length : 0) - 1;
    const startRow = Math.max(0,       Math.floor(viewportTop    / tileSize) - buffer);
    const startCol = Math.max(0,       Math.floor(viewportLeft   / tileSize) - buffer);
    const endRow   = Math.min(maxRows, Math.ceil( viewportBottom / tileSize) + buffer);
    const endCol   = Math.min(maxCols, Math.ceil( viewportRight  / tileSize) + buffer);
    return { startRow, endRow, startCol, endCol };
  },

  showNoTerrain: function() {
    // ...existing code...
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
    // ...existing code...
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
    // ...existing code...
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

  setupCursorInfo: function() {
    this.canvas.addEventListener('mousemove', (e) => this.updateCursorReadout(e));
  },

  updateCursorReadout: function(e) {
    if (!this.terrain || !this.terrain.elevation) return;
    const rect     = this.canvas.getBoundingClientRect();
    const tileSize = this.TILE_SIZE * this.scale;
    const col      = Math.floor((e.clientX - rect.left  - this.offsetX) / tileSize);
    const row      = Math.floor((e.clientY - rect.top   - this.offsetY) / tileSize);
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

    if (posEl) posEl.textContent = `col ${col}, row ${row}`;

    if (this.terrainMode === 'elevation') {
      // Elevation-only world (Luna etc.) — no biome field exists
      if (tileEl)  tileEl.textContent  = 'elevation';
      if (biomeEl) biomeEl.textContent = '-';
      if (elevEl)  elevEl.textContent  = `${Math.round(elev)} m`;
      // Override the static label to "Terrain:" if the DOM element exists
      const biomeLabel = biomeEl ? biomeEl.closest('.data-row')?.querySelector('.data-label') : null;
      if (biomeLabel) biomeLabel.textContent = 'Terrain:';
      const tileLabel  = tileEl  ? tileEl.closest('.data-row')?.querySelector('.data-label')  : null;
      if (tileLabel)  tileLabel.textContent  = 'Mode:';
    } else {
      // Biome world (Earth etc.)
      const tile = this.getTileName(elev, biome);
      if (tileEl)  tileEl.textContent  = tile;
      if (biomeEl) biomeEl.textContent = biome || '(elevation only)';
      if (elevEl)  elevEl.textContent  = `${Math.round(elev)} m`;
    }
  }
};

document.addEventListener('DOMContentLoaded', () => {
  window.PLANET_TYPE = window.PLANET_TYPE || document.getElementById('surface-data')?.dataset?.planetType || "Earth";
  window.SurfaceView.init();
});
if (typeof Turbo !== 'undefined') {
  document.addEventListener('turbo:load', () => {
    window.SurfaceView.init();
  });
}