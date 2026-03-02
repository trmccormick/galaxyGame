/**
 * BiomeRenderer — ES6 class
 *
 * Loads 10 individual biome PNGs from the asset pipeline and pre-scales each
 * to exactly 142×142 pixels (crisp nearest-neighbour, no smoothing).
 *
 * Designed for 20fps integration with surface_view.js.
 *
 * Usage:
 *   const renderer = new BiomeRenderer();
 *   await renderer.init();
 *   renderer.draw(ctx, 'desert', x, y, rotation);
 */
'use strict';

class BiomeRenderer {
  /* ─── Constants ──────────────────────────────────────────────── */

  static TILE_SIZE    = 142;
  static CONFIG_PATH  = '/tilesets/galaxy_game/biomes.json';

  /** Canonical ordered list — must match biomes.json keys exactly */
  static BIOME_NAMES = [
    'desert',
    'forest',
    'grasslands',
    'jungle',
    'mountains',
    'mountains_snow_covered',
    'ocean',
    'plains',
    'swamp',
    'tundra'
  ];

  /* ─── Constructor ─────────────────────────────────────────────── */

  constructor() {
    /**
     * Keyed by biome name → pre-scaled 142×142 OffscreenCanvas (or <canvas>).
     * @type {Map<string, HTMLCanvasElement>}
     */
    this.tiles     = new Map();

    /**
     * Fallback solid hex colour per biome name (populated from biomes.json).
     * @type {Map<string, string>}
     */
    this.fallbacks = new Map();

    /** @type {object|null} Parsed biomes.json */
    this.config    = null;

    /** @type {boolean} True once init() has finished (even on partial failures) */
    this.ready     = false;
  }

  /* ─── Public API ──────────────────────────────────────────────── */

  /**
   * Load biomes.json then fetch and scale all 10 PNGs in parallel.
   * Safe to await; always resolves — PNG failures degrade to colour fallbacks.
   *
   * @returns {Promise<BiomeRenderer>} this (chainable)
   */
  async init() {
    try {
      /* 1 ── fetch config */
      const resp = await fetch(BiomeRenderer.CONFIG_PATH);
      if (!resp.ok) throw new Error(`biomes.json fetch failed: ${resp.status}`);
      this.config = await resp.json();

      const assetPath    = this.config.asset_path || '/assets/biomes/';
      const biomeEntries = Object.entries(this.config.biomes);

      /* 2 ── seed fallback colours */
      biomeEntries.forEach(([name, meta]) => {
        this.fallbacks.set(name, meta.color_fallback || '#1a1a2e');
      });

      /* 3 ── load + scale all PNGs concurrently */
      await Promise.all(
        biomeEntries.map(([name, meta]) =>
          this._loadAndScale(name, `${assetPath}${meta.file}`)
        )
      );

      console.log(
        `✅ BiomeRenderer: ${this.tiles.size}/${biomeEntries.length} biome tiles ready ` +
        `(${BiomeRenderer.TILE_SIZE}px)`
      );
    } catch (err) {
      console.error('❌ BiomeRenderer.init() failed:', err);
      /* Non-fatal — draw() will fall back to solid colours */
    }

    this.ready = true;
    return this;
  }

  /**
   * Draw a single biome tile on `ctx`.
   *
   * @param {CanvasRenderingContext2D} ctx        Target context
   * @param {string}                  biomeName   e.g. 'ocean', 'mountains_snow_covered'
   * @param {number}                  x           Top-left pixel X
   * @param {number}                  y           Top-left pixel Y
   * @param {number}                  [rotation=0] Rotation in radians (planetary spin)
   */
  draw(ctx, biomeName, x, y, rotation = 0) {
    const key  = (biomeName || '').toLowerCase().trim();
    const size = BiomeRenderer.TILE_SIZE;
    const cx   = x + size * 0.5;
    const cy   = y + size * 0.5;

    ctx.save();

    /* Apply rotation around the tile centre */
    if (rotation !== 0) {
      ctx.translate(cx, cy);
      ctx.rotate(rotation);
      ctx.translate(-cx, -cy);
    }

    if (this.tiles.has(key)) {
      /* Crisp pixel rendering — no blurring at any scale */
      ctx.imageSmoothingEnabled = false;
      ctx.drawImage(this.tiles.get(key), x, y, size, size);
    } else {
      /* Solid-colour fallback when PNG is missing */
      ctx.fillStyle = this.fallbacks.get(key) || '#1a1a2e';
      ctx.fillRect(x, y, size, size);
    }

    ctx.restore();
  }

  /**
   * Convenience: draw a tile addressed by grid column/row — compatible with
   * surface_view.js's pan/zoom state.
   *
   * @param {CanvasRenderingContext2D} ctx
   * @param {string}  biomeName
   * @param {number}  col
   * @param {number}  row
   * @param {number}  [scale=1]     Zoom level from surface_view.js
   * @param {number}  [offsetX=0]   Pan offset X from surface_view.js
   * @param {number}  [offsetY=0]   Pan offset Y from surface_view.js
   * @param {number}  [rotation=0]  Planetary rotation radians
   */
  drawAt(ctx, biomeName, col, row, scale = 1, offsetX = 0, offsetY = 0, rotation = 0) {
    const tileSize = BiomeRenderer.TILE_SIZE * scale;
    const px = col * tileSize + offsetX;
    const py = row * tileSize + offsetY;
    this.draw(ctx, biomeName, px, py, rotation);
  }

  /**
   * Returns all successfully loaded biome names — useful for 20fps diagnostics.
   * @returns {string[]}
   */
  loadedBiomes() {
    return Array.from(this.tiles.keys());
  }

  /**
   * Biome names that have no PNG (they will render as solid colour).
   * @returns {string[]}
   */
  missingBiomes() {
    return BiomeRenderer.BIOME_NAMES.filter(name => !this.tiles.has(name));
  }

  /** True once init() has settled (even if some PNGs failed). */
  get isReady() {
    return this.ready;
  }

  /* ─── Private helpers ─────────────────────────────────────────── */

  /**
   * Fetch one PNG, blit it into a crisp 142×142 off-screen canvas, and store
   * it in `this.tiles`.  Always resolves, never rejects.
   *
   * @private
   * @param {string} name  Biome key
   * @param {string} url   Asset URL
   * @returns {Promise<boolean>} true on success
   */
  _loadAndScale(name, url) {
    return new Promise((resolve) => {
      const img = new Image();

      img.onload = () => {
        const offscreen        = document.createElement('canvas');
        offscreen.width        = BiomeRenderer.TILE_SIZE;
        offscreen.height       = BiomeRenderer.TILE_SIZE;
        const ctx              = offscreen.getContext('2d');
        ctx.imageSmoothingEnabled = false;
        ctx.drawImage(img, 0, 0, BiomeRenderer.TILE_SIZE, BiomeRenderer.TILE_SIZE);
        this.tiles.set(name, offscreen);
        resolve(true);
      };

      img.onerror = () => {
        console.warn(`⚠️  BiomeRenderer: PNG not found → ${url} (colour fallback active)`);
        resolve(false);
      };

      img.src = url;
    });
  }
}

/* ─── Export ──────────────────────────────────────────────────── */
// Compatible with Rails Sprockets (no bundler) and Node/Jest environments.
if (typeof module !== 'undefined' && module.exports) {
  module.exports = BiomeRenderer;
} else {
  window.BiomeRenderer = BiomeRenderer;
}
