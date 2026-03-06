/**
 * SurfaceView — Civ4/FreeCiv-style planetary surface viewer
 *
 * Rendering pipeline ported from AdminMonitor:
 *   Layer 0: elevation (always shown, grayscale or colour-mapped)
 *   Layer 1: liquid    (hydrosphere bathtub, same as monitor)
 *   Layer 2: biomes    (full biome colour map, Earth-class worlds only)
 *   Layer 3: resources (optional overlay)
 *
 * BiomeRenderer PNG sprites are used on top of the colour pass when available.
 *
 * Key differences from monitor:
 *   - Fixed 32px tile size (Civ4 feel); player zooms in/out rather than
 *     the map auto-scaling to fit the canvas.
 *   - Viewport culling — only visible tiles are drawn each frame.
 *   - RAF dirty-flag loop instead of direct re-render calls.
 */

'use strict';

window.SurfaceView = {

  /* ── Constants ─────────────────────────────────────────────────── */
  TILE_SIZE: 32,

  /* ── Viewport state ────────────────────────────────────────────── */
  scale:              1.0,
  offsetX:            0,
  offsetY:            0,
  isDragging:         false,
  dragStartX:         0,
  dragStartY:         0,
  dragStartOffsetX:   0,
  dragStartOffsetY:   0,
  viewportInitialized: false,

  /* ── RAF / dirty flag ──────────────────────────────────────────── */
  rafId:   null,
  dirty:   true,
  _lastLogTime: 0,

  /* ── Planet & terrain state ────────────────────────────────────── */
  data:        null,
  terrain:     null,
  planetData:  null,
  planetName:  '',
  planetType:  '',

  /* ── Layers (same structure as monitor) ────────────────────────── */
  layers: {
    elevation: null,
    liquid:    null,
    biomes:    null,
    resources: null
  },

  /* ── BiomeRenderer (PNG sprites) ──────────────────────────────── */
  renderer:    null,
  showSprites: true,   // toggle between PNG sprites and colour fallback

  /* ── Visible overlay layers ────────────────────────────────────── */
  visibleLayers: new Set(['terrain', 'liquid', 'biomes']),

  /* ═══════════════════════════════════════════════════════════════
     INIT
  ═══════════════════════════════════════════════════════════════ */

  init: async function() {
    const dataEl = document.getElementById('surface-data');
    const canvas = document.getElementById('surfaceCanvas');
    if (!dataEl || !canvas) return;

    // Cancel any previous RAF loop
    if (this.rafId) { cancelAnimationFrame(this.rafId); this.rafId = null; }

    // Parse injected JSON
    this.data       = JSON.parse(dataEl.textContent);
    this.terrain    = this.data.terrain_data;
    this.planetData = this.data.planet_data || {};
    this.ctx        = canvas.getContext('2d');
    this.canvas     = canvas;

    // Planet identity — prefer window globals (set unescaped in ERB footer)
    this.planetType = window.PLANET_TYPE || this.data.planet_type || '';
    this.planetName = window.PLANET_NAME || this.data.planet_name || '';
    console.log(`🌍 SurfaceView: "${this.planetName}" type:"${this.planetType}"`);

    // Build layers exactly like monitor does
    this._buildLayers();

    // Decide whether this world can show biomes
    const hasBiomes = this.layers.biomes !== null;
    console.log(`🗺️  Layers: elevation=${!!this.layers.elevation} biomes=${hasBiomes} liquid=${!!this.layers.liquid}`);

    // Status panel
    const nameEl   = document.getElementById('tileset-name');
    const statusEl = document.getElementById('tileset-status');
    const loadedEl = document.getElementById('tiles-loaded');

    if (hasBiomes && window.BiomeRenderer) {
      // Load PNG sprites for biome worlds
      if (nameEl)   nameEl.textContent   = 'Gemini Galaxy Biomes';
      if (statusEl) statusEl.textContent = 'Loading sprites…';
      this.renderer = new window.BiomeRenderer();
      await this.renderer.init();
      const loaded  = this.renderer.tiles.size;
      const missing = this.renderer.missingBiomes();
      if (missing.length) console.warn('⚠️  Missing PNGs (colour fallback):', missing);
      if (loadedEl) loadedEl.textContent = `${loaded}/10`;
      if (statusEl) statusEl.textContent = loaded === 10 ? '✅ All 10 loaded' : `⚠️ ${loaded}/10`;
    } else {
      if (nameEl)   nameEl.textContent   = hasBiomes ? 'Biome Colours' : 'Elevation Grayscale';
      if (statusEl) statusEl.textContent = '✅ Ready';
      if (loadedEl) loadedEl.textContent = 'N/A';
      this.renderer = null;
    }

    // Toggle button (biome worlds only)
    const toggleBtn = document.getElementById('toggleTerrainBtn');
    if (toggleBtn) {
      toggleBtn.style.display = hasBiomes ? '' : 'none';
      toggleBtn.textContent   = 'Show Elevation';
      toggleBtn.onclick = () => {
        this.showSprites = !this.showSprites;
        // Also toggle the biomes layer visibility
        if (this.showSprites) {
          this.visibleLayers.add('biomes');
          this.visibleLayers.add('liquid');
          toggleBtn.textContent = 'Show Elevation';
        } else {
          this.visibleLayers.delete('biomes');
          this.visibleLayers.delete('liquid');
          toggleBtn.textContent = 'Show Biomes';
        }
        this.dirty = true;
      };
    }

    // Layer toggle buttons (terrain/grid/features etc.)
    this._setupLayerToggles();

    this.setupZoom();
    this.setupPan();

    // Centre viewport on first load
    this.viewportInitialized = false;

    this.dirty = true;
    this._startRenderLoop();
  },

  /* ═══════════════════════════════════════════════════════════════
     LAYER BUILDING  (mirrors monitor.js renderTerrainMap setup)
  ═══════════════════════════════════════════════════════════════ */

  _buildLayers: function() {
    this.layers = { elevation: null, liquid: null, biomes: null, resources: null };
    const td = this.terrain;
    if (!td) return;

    // ── Elevation ──────────────────────────────────────────────────
    if (td.elevation && Array.isArray(td.elevation) && td.elevation.length > 0) {
      this.layers.elevation = {
        grid:   td.elevation,
        width:  td.elevation[0]?.length || 0,
        height: td.elevation.length
      };
    }

    if (!this.layers.elevation) {
      console.warn('⚠️  No elevation grid found in terrain_data');
      return;
    }

    const { width, height } = this.layers.elevation;

    // ── Biomes — detect and load if present ───────────────────────
    console.log(`🔍 Biome check: td.biomes exists=${!!td.biomes}, type=${typeof td.biomes}`);
    if (td.biomes && Array.isArray(td.biomes) && td.biomes.length > 0) {
      const biomeHeight = td.biomes.length;
      const biomeWidth  = Array.isArray(td.biomes[0]) ? td.biomes[0].length : 0;
      console.log(`🔍 Biome grid dims: ${biomeWidth}x${biomeHeight} vs elevation ${width}x${height}`);

      // Find first non-null/non-empty cell to determine data type
      let sample = null;
      outer: for (let sy = 0; sy < Math.min(biomeHeight, 10); sy++) {
        for (let sx = 0; sx < Math.min(biomeWidth, 10); sx++) {
          const v = td.biomes[sy]?.[sx];
          if (v !== null && v !== undefined && v !== '') { sample = v; break outer; }
        }
      }
      console.log(`🔍 Biome sample value: "${sample}" (type: ${typeof sample})`);

      if (typeof sample === 'string' && sample.length > 0) {
        // Valid biome strings — use whatever dimensions the biomes grid has
        this.layers.biomes = {
          grid:   td.biomes,
          width:  biomeWidth,
          height: biomeHeight
        };
        const unique = new Set();
        for (let y = 0; y < Math.min(biomeHeight, 100); y++)
          for (let x = 0; x < Math.min(biomeWidth, 100); x++)
            if (td.biomes[y]?.[x]) unique.add(td.biomes[y][x]);
        console.log('✅ Biome layer loaded. Unique biomes found:', Array.from(unique));
      } else if (typeof sample === 'number') {
        console.log('ℹ️  biomes grid contains numbers — same as elevation, elevation-only world (Luna etc.)');
      } else {
        console.log('ℹ️  biomes grid empty or unrecognised — elevation-only rendering');
      }
    } else {
      console.log('ℹ️  No biomes array in terrain_data — elevation-only rendering');
    }

    // ── Liquid (same bathtub algorithm as monitor) ─────────────────
    if (this.planetData) {
      this.layers.liquid = this._calculateWaterLayer(this.layers.elevation);
      if (this.layers.liquid)
        console.log(`💧 Liquid layer: sea level=${this.layers.liquid.sea_level}m coverage=${(this.layers.liquid.water_coverage*100).toFixed(1)}%`);
    }

    // Cache elevation range — used every render frame
    let minElev = Infinity, maxElev = -Infinity;
    for (let y = 0; y < this.layers.elevation.height; y++)
      for (let x = 0; x < this.layers.elevation.width; x++) {
        const e = this.layers.elevation.grid[y][x];
        if (e != null) { if (e < minElev) minElev = e; if (e > maxElev) maxElev = e; }
      }
    this.layers.elevation.minElev = isFinite(minElev) ? minElev : 0;
    this.layers.elevation.maxElev = isFinite(maxElev) ? maxElev : 1000;
    console.log(`📊 Elevation range: ${this.layers.elevation.minElev}m → ${this.layers.elevation.maxElev}m`);

    // ── Resources ─────────────────────────────────────────────────
    if (td.resource_grid &&
        Array.isArray(td.resource_grid) &&
        td.resource_grid.length > 0) {
      this.layers.resources = {
        grid:   td.resource_grid,
        width:  td.resource_grid[0]?.length || 0,
        height: td.resource_grid.length
      };
    }
  },

  /* Bathtub algorithm — identical to monitor.js */
  _calculateWaterLayer: function(elevLayer) {
    if (!elevLayer || !elevLayer.grid) return null;

    const pd = this.planetData;
    let coverage = 0;
    if (pd.water_coverage != null)       coverage = pd.water_coverage;
    else if (pd.hydrosphere?.water_coverage != null) coverage = pd.hydrosphere.water_coverage;

    if (coverage > 1) coverage /= 100.0;
    coverage = Math.max(0, Math.min(1, coverage));
    if (coverage <= 0) return null;

    const { grid, width, height } = elevLayer;
    const allElevations = [];
    let hasNegative = false;

    for (let y = 0; y < height; y++)
      for (let x = 0; x < width; x++) {
        const e = grid[y][x];
        if (e != null) { allElevations.push(e); if (e < 0) hasNegative = true; }
      }

    if (!allElevations.length) return null;

    let seaLevel = 0;
    if (!hasNegative) {
      allElevations.sort((a, b) => a - b);
      const idx = Math.floor(allElevations.length * coverage);
      seaLevel = allElevations[Math.min(idx, allElevations.length - 1)];
    }

    const waterGrid = [];
    for (let y = 0; y < height; y++) {
      waterGrid[y] = [];
      for (let x = 0; x < width; x++) {
        const e = grid[y][x];
        waterGrid[y][x] = (e != null && e < seaLevel) ? seaLevel - e : 0;
      }
    }
    return { grid: waterGrid, width, height, sea_level: seaLevel, water_coverage: coverage };
  },

  /* ═══════════════════════════════════════════════════════════════
     RENDER LOOP
  ═══════════════════════════════════════════════════════════════ */

  _startRenderLoop: function() {
    const loop = () => {
      if (this.dirty) {
        this.renderGrid();
        this.dirty = false;
      }
      this.rafId = requestAnimationFrame(loop);
    };
    this.rafId = requestAnimationFrame(loop);
  },

  /* ═══════════════════════════════════════════════════════════════
     MAIN RENDER  (viewport-culled, layered)
  ═══════════════════════════════════════════════════════════════ */

  renderGrid: function() {
    if (!this.layers.elevation) {
      this._showNoTerrain();
      return;
    }

    const ctx      = this.ctx;
    const canvas   = this.canvas;
    const tileSize = this.TILE_SIZE * this.scale;

    const { grid: elevGrid, width, height, minElev, maxElev } = this.layers.elevation;
    const elevRange = (maxElev - minElev) || 1;
    const liquidGrid   = this.layers.liquid?.grid   || null;
    const resourceGrid = this.layers.resources?.grid || null;

    // Centre once on first render
    if (!this.viewportInitialized) {
      const worldW = width  * tileSize;
      const worldH = height * tileSize;
      this.offsetX = (canvas.width  - worldW) / 2;
      this.offsetY = (canvas.height - worldH) / 2;
      this.viewportInitialized = true;
    }

    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.imageSmoothingEnabled = false;

    // Viewport culling
    const vp      = this._getVisibleTileRange(width, height, tileSize);
    // hasBiosphere: true only if we actually have a string biome grid
    // Never rely on planetData.has_biosphere — it may be missing or wrong for this view
    const hasBiosphere = this.layers.biomes !== null;

    for (let row = vp.startRow; row <= vp.endRow; row++) {
      const eRow = elevGrid[row];
      if (!eRow) continue;
      const bRow = hasBiosphere && this.layers.biomes.grid[row]
                   ? this.layers.biomes.grid[row]
                   : null;
      const lRow = liquidGrid  ? liquidGrid[row]   : null;
      const rRow = resourceGrid ? resourceGrid[row] : null;

      for (let col = vp.startCol; col <= vp.endCol; col++) {
        const rawElev = eRow[col];
        if (rawElev == null) continue;

        const normElev = (rawElev - minElev) / elevRange;
        const x = col * tileSize + this.offsetX;
        const y = row * tileSize + this.offsetY;

        // ── Layer 0: base elevation colour ──────────────────────────
        let color = this._getElevationColor(normElev);

        // ── Layer 1: liquid ─────────────────────────────────────────
        const waterDepth = lRow ? (lRow[col] || 0) : 0;
        const isWet = waterDepth > 0;
        if (this.visibleLayers.has('liquid') && isWet) {
          color = this._getWaterColor(waterDepth);
        }

        // ── Layer 2: biomes ─────────────────────────────────────────
        if (this.visibleLayers.has('biomes') && hasBiosphere && bRow && !isWet) {
          const biome = bRow[col];
          if (biome && biome !== 'ocean' && biome !== 'none') {
            const biomeColor = this._getBiomeColor(biome);
            if (biomeColor) color = biomeColor;
            // null return = geological feature — keep elevation base colour
          }
        }

        // ── Layer 3: resources (yellow tint) ────────────────────────
        if (this.visibleLayers.has('resources') && rRow && rRow[col] && rRow[col] !== 'none') {
          color = this._blendColors(color, '#FFFF00', 0.35);
        }

        // ── PNG sprite overlay (biome worlds, when loaded) ───────────
        const biome = bRow ? bRow[col] : null;
        if (this.showSprites && this.renderer && !isWet && biome) {
          const tileName = this._biomeTileKey(rawElev, biome);
          if (tileName) {
            const tileCvs = this.renderer.tiles.get(tileName);
            if (tileCvs) {
              ctx.drawImage(tileCvs, x, y, tileSize, tileSize);
              continue; // sprite drawn — skip fillRect below
            }
          }
        }

        ctx.fillStyle = color;
        ctx.fillRect(x, y, tileSize, tileSize);
      }
    }

    const now = Date.now();
    if (now - this._lastLogTime > 5000) {
      console.log(`🗺️  SurfaceView rendered ${width}x${height} [scale=${this.scale.toFixed(1)}]`);
      this._lastLogTime = now;
    }
  },

  /* ═══════════════════════════════════════════════════════════════
     COLOUR FUNCTIONS  (ported from monitor.js)
  ═══════════════════════════════════════════════════════════════ */

  _getElevationColor: function(t) {
    // Grayscale for no-biome worlds; subtle earth-tone for biome worlds
    if (!this.layers.biomes) {
      const v = Math.round(30 + t * 200);
      return `rgb(${v},${v},${v})`;
    }
    // Earth-tone gradient: deep brown → tan (same as monitor default scheme)
    const low  = { r: 45,  g: 24,  b: 16  }; // #2d1810
    const high = { r: 210, g: 180, b: 140 }; // #d2b48c
    const r = Math.round(low.r + (high.r - low.r) * t);
    const g = Math.round(low.g + (high.g - low.g) * t);
    const b = Math.round(low.b + (high.b - low.b) * t);
    return `rgb(${r},${g},${b})`;
  },

  /* Planet-aware liquid colour — identical to monitor.getHydrosphereColor()
     Reads liquid composition and surface temperature from planetData so
     Titan gets orange methane, frozen worlds get blue-white ice, etc.     */
  _getWaterColor: function(depth) {
    const pd     = this.planetData || {};
    const liquid = (pd.liquid_name || 'H2O').toUpperCase();
    const temp   = pd.surface_temperature || pd.temperature || 288;

    const shallow = 200, deep = 4000;

    // ── Frozen / ice surface ──────────────────────────────────────
    if (liquid === 'ICE' || liquid.includes('FROZEN') ||
        (liquid === 'H2O' && temp < 273)) {
      if (depth < shallow) {
        const t = depth / shallow;
        const v = Math.round(240 - t * 20);
        return `rgba(${v},${v},255,0.8)`;
      } else if (depth < deep) {
        const t = (depth - shallow) / (deep - shallow);
        const v = Math.round(220 - t * 40);
        return `rgba(${v},${v},255,0.85)`;
      }
      const t = Math.min(1, (depth - deep) / 4000);
      const v = Math.round(180 - t * 40);
      return `rgba(${v},${v},255,0.9)`;
    }

    // ── Methane / ethane (Titan) ──────────────────────────────────
    if (liquid === 'CH4' || liquid === 'C2H6' ||
        liquid.includes('METHANE') || liquid.includes('ETHANE')) {
      if (depth < shallow) {
        const t = depth / shallow;
        return `rgba(${Math.round(255-t*30)},${Math.round(180-t*40)},${Math.round(50-t*20)},0.8)`;
      } else if (depth < deep) {
        const t = (depth - shallow) / (deep - shallow);
        return `rgba(${Math.round(225-t*75)},${Math.round(140-t*60)},${Math.round(30-t*30)},0.85)`;
      }
      const t = Math.min(1, (depth - deep) / 4000);
      return `rgba(${Math.round(150-t*50)},${Math.round(80-t*40)},0,0.9)`;
    }

    // ── Nitrogen (Triton-like) ────────────────────────────────────
    if (liquid === 'N2' || liquid.includes('NITROGEN')) {
      if (depth < shallow) {
        const t = depth / shallow;
        return `rgba(${Math.round(240-t*10)},${Math.round(240-t*20)},${Math.round(250-t*20)},0.7)`;
      } else if (depth < deep) {
        const t = (depth - shallow) / (deep - shallow);
        return `rgba(${Math.round(230-t*30)},${Math.round(220-t*40)},${Math.round(230-t*50)},0.75)`;
      }
      const t = Math.min(1, (depth - deep) / 4000);
      return `rgba(${Math.round(200-t*30)},${Math.round(180-t*40)},${Math.round(180-t*40)},0.8)`;
    }

    // ── Ammonia ───────────────────────────────────────────────────
    if (liquid === 'NH3' || liquid.includes('AMMONIA')) {
      if (depth < shallow) {
        const t = depth / shallow;
        return `rgba(${Math.round(200-t*30)},${Math.round(150-t*50)},${Math.round(255-t*30)},0.75)`;
      } else if (depth < deep) {
        const t = (depth - shallow) / (deep - shallow);
        return `rgba(${Math.round(170-t*50)},${Math.round(100-t*50)},${Math.round(225-t*75)},0.8)`;
      }
      const t = Math.min(1, (depth - deep) / 4000);
      return `rgba(${Math.round(120-t*30)},${Math.round(50-t*20)},${Math.round(150-t*50)},0.85)`;
    }

    // ── Default: H2O ──────────────────────────────────────────────
    if (depth < shallow) {
      const t = depth / shallow;
      return `rgba(${Math.round(100-t*50)},${Math.round(200-t*50)},${Math.round(255-t*35)},0.85)`;
    } else if (depth < deep) {
      const t = (depth - shallow) / (deep - shallow);
      return `rgba(${Math.round(50-t*50)},${Math.round(150-t*100)},${Math.round(220-t*70)},0.9)`;
    }
    const t = Math.min(1, (depth - deep) / 4000);
    return `rgba(0,${Math.round(20-t*10)},${Math.round(100-t*20)},0.95)`;
  },

  /* True biome colours only — geological features (mountains, craters,
     volcanic, maria, regolith) are NOT biomes and are intentionally
     absent here. They fall through to the elevation base colour which
     is appropriate for those terrain types.
     Ocean/coast are handled by the liquid layer, not here.            */
  _getBiomeColor: function(biome) {
    const map = {
      // ── 15 Canonical Biomes ──────────────────────────────────────
      arctic:                   '#E8E8E8',
      tundra:                   '#B8C4C8',
      ice:                      '#E0FFFF',
      boreal_forest:            '#2E8B57',
      temperate_forest:         '#228B22',
      tropical_rainforest:      '#004000',
      tropical_seasonal_forest: '#006400',
      desert:                   '#DAA520',
      grassland:                '#7CCD7C',
      plains:                   '#C4B454',
      savanna:                  '#9ACD32',
      jungle:                   '#004400',
      wetlands:                 '#698B69',
      swamp:                    '#556B2F',
      savannah:                 '#9ACD32', // variant of savanna

      // ── Additional Variants & Defaults ──────────────────────────
      grasslands:               '#7CCD7C',
      temperate_grassland:      '#90EE90',
      tropical_grassland:       '#98FB98',
      steppe:                   '#BDB76B',
      lowlands:                 '#8FBC8F',
      forest:                   '#228B22',
      tropical_forest:          '#004400',
      boreal:                   '#2E8B57',
      taiga:                    '#2E8B57',
      temperate_rainforest:     '#006633',
      rainforest:               '#004000',
      hot_desert:               '#F4A460',
      polar_desert:             '#E8DCC8',
      cold_desert:              '#C2B280',
      polar_ice:                '#F0FFFF',
      snow:                     '#FFFAFA',
      marsh:                    '#6B8E23',
      wetland:                  '#698B69',
      bog:                      '#556B2F',
      highlands:                '#BC8F8F',
      montane:                  '#A0907A',
      alpine:                   '#C8BEB0',
    };

    const b = (biome || '').toLowerCase().trim();
    if (map[b]) return map[b];

    // Substring fallbacks removed in favor of exact mapping.
    // Variant resolution should happen in _biomeTileKey or generator.

    // Unknown biome — return null so caller can fall back to elevation colour
    console.warn(`⚠️  Unknown biome type: "${biome}" — using elevation fallback`);
    return null;
  },

  /* Map biome string → BiomeRenderer PNG key (one of the 10 loaded PNGs).
     Returns null for geological terms (crater, regolith, volcanic, maria,
     lava) so the render loop skips the sprite and uses the elevation colour. */
  _biomeTileKey: function(elev, biome) {
    const b = (biome || '').toLowerCase().trim();

    // Single-character grid codes from automatic_terrain_generator.rb
    const charMap = {
      ' ': 'ocean', ':': 'ocean', '.': 'ocean',
      'a': 'tundra', 't': 'tundra',
      'f': 'forest', 'g': 'grasslands', 'p': 'plains',
      'd': 'desert', 'j': 'jungle',     's': 'swamp',
      'h': 'mountains', 'm': 'mountains'
    };
    if (b.length === 1) return charMap[b] || null;

    // Geological features — no sprite, use elevation colour
    if (b.includes('crater'))  return null;
    if (b.includes('regolith')) return null;
    if (b === 'maria' || b === 'mare') return null;
    if (b === 'volcanic' || b === 'lava') return null;
    if (b === 'ocean' || b === 'deep_sea' || b.includes('coast')) return null; // handled by liquid layer

    // Explicit Mapping for PNG sprites (BiomeRenderer.BIOME_NAMES)
    const exactMap = {
      // ── Canonical mappings ──
      arctic:                   'tundra',
      tundra:                   'tundra',
      ice:                      'tundra',
      polar_ice:                'tundra',
      snow:                     'tundra',

      boreal_forest:            'forest',
      temperate_forest:         'forest',
      forest:                   'forest',
      boreal:                   'forest',
      taiga:                    'forest',

      tropical_rainforest:      'jungle',
      tropical_seasonal_forest: 'jungle',
      tropical_forest:          'jungle',
      rainforest:               'jungle',
      jungle:                   'jungle',

      desert:                   'desert',
      hot_desert:               'desert',
      polar_desert:             'desert',
      cold_desert:              'desert',

      grassland:                'grasslands',
      grasslands:               'grasslands',
      savanna:                  'grasslands',
      savannah:                 'grasslands',
      temperate_grassland:      'grasslands',
      tropical_grassland:       'grasslands',

      plains:                   'plains',
      steppe:                   'plains',
      lowlands:                 'plains',

      swamp:                    'swamp',
      marsh:                    'swamp',
      wetlands:                 'swamp',
      wetland:                  'swamp',
      bog:                      'swamp',

      highlands:                'mountains',
      montane:                  'mountains',
      alpine:                   'mountains',
      mountain:                 'mountains',
      mountains:                'mountains',
      hill:                     'mountains'
    };

    if (exactMap[b]) {
      const key = exactMap[b];
      if (key === 'mountains' && elev > 3500) return 'mountains_snow_covered';
      return key;
    }

    // Elevation hints for unlabelled tiles
    if (elev !== undefined) {
      if (elev < 0)    return null;   // below sea level — liquid layer handles it
      if (elev > 3500) return 'mountains_snow_covered';
      if (elev > 2000) return 'mountains';
    }
    return 'plains'; // final fallback for unrecognised biome strings
  },

  _blendColors: function(base, overlay, alpha) {
    const h2r = h => {
      const r = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(h);
      return r ? { r: parseInt(r[1],16), g: parseInt(r[2],16), b: parseInt(r[3],16) } : null;
    };
    const b = h2r(base), o = h2r(overlay);
    if (!b || !o) return base;
    const r = Math.round(b.r*(1-alpha) + o.r*alpha);
    const g = Math.round(b.g*(1-alpha) + o.g*alpha);
    const bv= Math.round(b.b*(1-alpha) + o.b*alpha);
    return '#' + [r,g,bv].map(v=>v.toString(16).padStart(2,'0')).join('');
  },

  /* ═══════════════════════════════════════════════════════════════
     VIEWPORT HELPERS
  ═══════════════════════════════════════════════════════════════ */

  _getVisibleTileRange: function(gridWidth, gridHeight, tileSize) {
    const buffer = 2;
    const left   = -this.offsetX;
    const top    = -this.offsetY;
    return {
      startRow: Math.max(0,           Math.floor(top  / tileSize) - buffer),
      endRow:   Math.min(gridHeight-1, Math.ceil((top  + this.canvas.height) / tileSize) + buffer),
      startCol: Math.max(0,           Math.floor(left / tileSize) - buffer),
      endCol:   Math.min(gridWidth-1,  Math.ceil((left + this.canvas.width)  / tileSize) + buffer)
    };
  },

  /* ═══════════════════════════════════════════════════════════════
     LAYER TOGGLES
  ═══════════════════════════════════════════════════════════════ */

  _setupLayerToggles: function() {
    document.querySelectorAll('.layer-btn').forEach(btn => {
      const layer = btn.dataset.layer;
      if (!layer) return;
      btn.addEventListener('click', () => {
        if (this.visibleLayers.has(layer)) {
          this.visibleLayers.delete(layer);
          btn.classList.remove('active');
        } else {
          this.visibleLayers.add(layer);
          btn.classList.add('active');
        }
        this.dirty = true;
      });
    });
  },

  /* ═══════════════════════════════════════════════════════════════
     ZOOM
  ═══════════════════════════════════════════════════════════════ */

  setupZoom: function() {
    const canvas = this.canvas;
    let zoomEl   = document.getElementById('zoom');

    const applyScale = (newScale) => {
      this.scale = Math.max(0.5, Math.min(6, newScale));
      zoomEl = document.getElementById('zoom');
      if (zoomEl) zoomEl.value = this.scale;
      const valEl = document.getElementById('zoomValue');
      if (valEl) valEl.textContent = this.scale.toFixed(1) + 'x';
      this.dirty = true;
    };

    if (zoomEl) {
      zoomEl.value = this.scale;
      zoomEl.addEventListener('input', (e) => applyScale(parseFloat(e.target.value)));
    }

    // Zoom toward cursor (same as monitor)
    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      const rect   = canvas.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;
      const wBefore = (mouseX - this.offsetX) / this.scale;
      const hBefore = (mouseY - this.offsetY) / this.scale;
      applyScale(this.scale * (e.deltaY > 0 ? 0.9 : 1.1));
      this.offsetX = mouseX - wBefore * this.scale;
      this.offsetY = mouseY - hBefore * this.scale;
    }, { passive: false });

    const resetBtn = document.getElementById('resetViewBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        this.viewportInitialized = false; // will re-centre on next render
        applyScale(1.0);
      });
    }
  },

  /* ═══════════════════════════════════════════════════════════════
     PAN
  ═══════════════════════════════════════════════════════════════ */

  setupPan: function() {
    const canvas = this.canvas;
    if (!canvas) return;
    canvas.style.cursor = 'grab';

    canvas.addEventListener('mousedown', (e) => {
      this.isDragging       = true;
      this.dragStartX       = e.clientX;
      this.dragStartY       = e.clientY;
      this.dragStartOffsetX = this.offsetX;
      this.dragStartOffsetY = this.offsetY;
      canvas.style.cursor   = 'grabbing';
    });

    canvas.addEventListener('mousemove', (e) => {
      if (this.isDragging) {
        this.offsetX = this.dragStartOffsetX + (e.clientX - this.dragStartX);
        this.offsetY = this.dragStartOffsetY + (e.clientY - this.dragStartY);
        this.dirty   = true;
      }
      this._updateCursorReadout(e);
    });

    canvas.addEventListener('mouseup',    () => { this.isDragging = false; canvas.style.cursor = 'grab'; });
    canvas.addEventListener('mouseleave', () => { this.isDragging = false; canvas.style.cursor = 'grab'; });
  },

  /* ═══════════════════════════════════════════════════════════════
     CURSOR READOUT
  ═══════════════════════════════════════════════════════════════ */

  _updateCursorReadout: function(e) {
    if (!this.layers.elevation) return;
    const rect     = this.canvas.getBoundingClientRect();
    const tileSize = this.TILE_SIZE * this.scale;
    const col      = Math.floor((e.clientX - rect.left  - this.offsetX) / tileSize);
    const row      = Math.floor((e.clientY - rect.top   - this.offsetY) / tileSize);

    const { grid, width, height } = this.layers.elevation;
    const posEl   = document.getElementById('cursor-pos');
    const tileEl  = document.getElementById('cursor-tile');
    const biomeEl = document.getElementById('cursor-biome');
    const elevEl  = document.getElementById('cursor-elevation');

    if (col < 0 || col >= width || row < 0 || row >= height || !grid[row]) {
      if (posEl)   posEl.textContent   = `${col}, ${row} (out of bounds)`;
      if (tileEl)  tileEl.textContent  = '-';
      if (biomeEl) biomeEl.textContent = '-';
      if (elevEl)  elevEl.textContent  = '-';
      return;
    }

    const elev  = grid[row][col];
    const biome = this.layers.biomes?.grid[row]?.[col] || null;

    if (posEl)   posEl.textContent   = `col ${col}, row ${row}`;
    if (elevEl)  elevEl.textContent  = `${Math.round(elev)} m`;
    if (biomeEl) biomeEl.textContent = biome || '-';
    if (tileEl)  tileEl.textContent  = biome ? this._biomeTileKey(elev, biome) : 'elevation';
  },

  /* ═══════════════════════════════════════════════════════════════
     MISC
  ═══════════════════════════════════════════════════════════════ */

  _showNoTerrain: function() {
    const ctx    = this.ctx;
    const canvas = this.canvas;
    ctx.fillStyle = '#0a1628';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = '#ffffff';
    ctx.font = '16px monospace';
    ctx.textAlign = 'center';
    ctx.fillText('NO TERRAIN DATA', canvas.width / 2, canvas.height / 2 - 20);
    ctx.fillText('Generate terrain first', canvas.width / 2, canvas.height / 2 + 10);
  }

};

/* ── Auto-init ────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
  window.PLANET_TYPE = window.PLANET_TYPE ||
    document.getElementById('surface-data')?.dataset?.planetType || '';
  window.SurfaceView.init();
});

if (typeof Turbo !== 'undefined') {
  document.addEventListener('turbo:load', () => {
    window.SurfaceView.init();
  });
}
