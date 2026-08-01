/**
 * TerrainTileRenderer — ES6 class
 *
 * Loads 45 terrain family PNG sprites from /api/assets/terrain/:terrain_type/variant_XX.png
 * and provides deterministic variant selection for surface view rendering.
 *
 * Tile inventory:
 *   - 5 terrain families: dust, frozen, regolith, temperate, volcanic
 *   - 9 variants per family: variant_01.png through variant_09.png
 *   - Tile dimensions: 150×150px (confirmed via macOS sips)
 *
 * Designed for integration with surface_view.js canvas rendering.
 * Tiles are pre-loaded and cached; draw() uses canvas drawImage with crisp pixel rendering.
 *
 * Usage:
 *   const renderer = new TerrainTileRenderer();
 *   await renderer.init();
 *   renderer.draw(ctx, 'dust', 10, 20, seed);
 *
 * Guard: safe to load multiple times (Turbo navigation / duplicate script tags).
 */

if (typeof window === 'undefined' || !window.TerrainTileRenderer) {

'use strict';

class TerrainTileRenderer {
  /* ─── Constants ──────────────────────────────────────────────── */

  static TILE_SIZE    = 150;
  static TERRAINS     = ['dust', 'frozen', 'regolith', 'temperate', 'volcanic'];
  static VARIANT_COUNT = 9;
  static BASE_PATH     = '/api/assets/terrain/';

  /** Canonical ordered list — must match directory names under data/images/terrain/ */
  static TERRAIN_NAMES = TerrainTileRenderer.TERRAINS;

  /* ─── Constructor ─────────────────────────────────────────────── */

  constructor() {
    /**
     * Keyed by terrain name → Map of variant index → pre-loaded Image.
     * @type {Map<string, Map<number, HTMLImageElement>>}
     */
    this.tiles = new Map();

    /** @type {boolean} True once init() has finished (even on partial failures) */
    this.ready = false;

    /** @type {number|null} Seeded value for deterministic variant selection */
    this._seed = null;
  }

  /* ─── Public API ──────────────────────────────────────────────── */

  /**
   * Load all terrain tiles in parallel.
   * Safe to await; always resolves — tile failures degrade gracefully (null entries).
   *
   * @returns {Promise<TerrainTileRenderer>} this (chainable)
   */
  async init() {
    try {
      /* Load all terrains × variants concurrently */
      const loadPromises = TerrainTileRenderer.TERRAIN_NAMES.flatMap(terrain =>
        Array.from({ length: TerrainTileRenderer.VARIANT_COUNT }, (_, i) => {
          const variantIndex = i + 1;
          const variantName  = `variant_${String(variantIndex).padStart(2, '0')}`;
          const url          = `${TerrainTileRenderer.BASE_PATH}${terrain}/${variantName}.png`;
          return this._loadImage(terrain, variantIndex, url);
        })
      );

      await Promise.all(loadPromises);

      const totalLoaded = Array.from(this.tiles.values())
        .reduce((sum, variants) => sum + Array.from(variants.values()).filter(Boolean).length, 0);

      console.log(
        `✅ TerrainTileRenderer: ${totalLoaded}/${TerrainTileRenderer.TERRAIN_NAMES.length * TerrainTileRenderer.VARIANT_COUNT} tiles ready ` +
        `(${TerrainTileRenderer.TILE_SIZE}px)`
      );
    } catch (err) {
      console.error('❌ TerrainTileRenderer.init() failed:', err);
      /* Non-fatal — draw() will fall back to solid colours */
    }

    this.ready = true;
    return this;
  }

  /**
   * Set the seed for deterministic variant selection.
   * Same seed + same terrain → same variant every time.
   *
   * @param {number} seed — Integer seed value
   */
  setSeed(seed) {
    this._seed = Math.floor(seed);
  }

  /**
   * Get the variant index for a given terrain and seed (1-based).
   * Uses simple hash of seed + terrain name for deterministic selection.
   *
   * @param {string} terrain — Terrain family name
   * @param {number} [seed] — Optional seed (falls back to this._seed)
   * @returns {number} Variant index (1–9)
   */
  getVariantIndex(terrain, seed = this._seed) {
    if (!seed && seed !== 0) return 1; // Default to first variant

    // Simple hash: combine seed with terrain name for uniqueness
    let hash = 0;
    const str = `${seed}-${terrain}`;
    for (let i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.charCodeAt(i);
      hash |= 0; // Convert to 32-bit integer
    }

    // Map to 1–9 range
    return (Math.abs(hash) % TerrainTileRenderer.VARIANT_COUNT) + 1;
  }

  /**
   * Draw a terrain tile on `ctx`.
   *
   * @param {CanvasRenderingContext2D} ctx        Target context
   * @param {string}                  terrain    e.g. 'dust', 'volcanic'
   * @param {number}                  x           Top-left pixel X
   * @param {number}                  y           Top-left pixel Y
   * @param {number}                  [seed]      Seed for variant selection
   * @param {number}                  [rotation=0] Rotation in radians
   */
  draw(ctx, terrain, x, y, seed, rotation = 0) {
    const key     = (terrain || '').toLowerCase().trim();
    const size    = TerrainTileRenderer.TILE_SIZE;
    const cx      = x + size * 0.5;
    const cy      = y + size * 0.5;
    const variant = this.getVariantIndex(terrain, seed);

    ctx.save();

    /* Apply rotation around the tile centre */
    if (rotation !== 0) {
      ctx.translate(cx, cy);
      ctx.rotate(rotation);
      ctx.translate(-cx, -cy);
    }

    const variants = this.tiles.get(key);
    const image    = variants?.get(variant);

    if (image && image.complete && image.naturalWidth > 0) {
      /* Crisp pixel rendering — no blurring at any scale */
      ctx.imageSmoothingEnabled = false;
      ctx.drawImage(image, x, y, size, size);
    } else {
      /* Solid-colour fallback when tile is missing or not yet loaded */
      const fallbackColors = {
        'dust': '#c4a35a',
        'frozen': '#b8d4e3',
        'regolith': '#8a8a8a',
        'temperate': '#6b8e4e',
        'volcanic': '#8b4513'
      };
      ctx.fillStyle = fallbackColors[key] || '#1a1a2e';
      ctx.fillRect(x, y, size, size);

      console.warn(`⚠️ TerrainTileRenderer: tile missing for ${key}/variant_${String(variant).padStart(2, '0')}`);
    }

    ctx.restore();
  }

  /**
   * Get the list of available terrain families.
   * @returns {string[]}
   */
  getTerrains() {
    return [...TerrainTileRenderer.TERRAIN_NAMES];
  }

  /**
   * Check if a specific tile exists in the cache.
   *
   * @param {string} terrain
   * @param {number} variantIndex (1-based)
   * @returns {boolean}
   */
  hasTile(terrain, variantIndex) {
    const key = (terrain || '').toLowerCase().trim();
    const variants = this.tiles.get(key);
    if (!variants) return false;
    const img = variants.get(variantIndex);
    return !!(img && img.complete && img.naturalWidth > 0);
  }

  /* ─── Private ────────────────────────────────────────────────── */

  /**
   * Load a single image and store it in the tiles cache.
   *
   * @param {string} terrain
   * @param {number} variantIndex (1-based)
   * @param {string} url
   * @returns {Promise<void>}
   */
  _loadImage(terrain, variantIndex, url) {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => resolve(null); // Graceful degradation
      img.src = url;

      if (!this.tiles.has(terrain)) {
        this.tiles.set(terrain, new Map());
      }
      this.tiles.get(terrain).set(variantIndex, img);
    });
  }
}

/* Only define once — prevent redeclaration on Turbo navigation */
if (typeof window.TerrainTileRenderer === 'undefined') {
  window.TerrainTileRenderer = TerrainTileRenderer;
}

} // end of if (typeof window === 'undefined' || !window.TerrainTileRenderer)
