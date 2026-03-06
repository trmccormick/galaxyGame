# TASK: fix_surface_view_viewport.md
## Assign: GPT-4.1 | Priority: HIGH | Time: 60 min
## File: app/assets/javascripts/surface_view.js

IMPORTANT: All 6 fixes are interconnected. Assign to ONE agent only.
Do not split. Pan clamp is called from zoom. Wrap logic is shared between
viewport calculation and render loop.

Context: Surface view is the Civ4/FreeCiv strategic planetary map.
It is a viewport window - player pans and zooms to navigate.
Planet is a cylinder: horizontal scrolling wraps, vertical clamps at poles.
This is NOT the whole-planet monitor view.

FIX 1 - Turbo not firing on first page visit
Symptom: Requires manual reload before anything renders.
Cause: DOMContentLoaded does not fire on Turbo navigation.

Find where SurfaceView.init() is called at the bottom of the file.
Replace with:
  function initSurfaceView() {
    if (document.getElementById('surfaceCanvas')) SurfaceView.init();
  }
  document.addEventListener('DOMContentLoaded', initSurfaceView);
  document.addEventListener('turbo:load', initSurfaceView);
  document.addEventListener('turbo:render', initSurfaceView);

FIX 2 - Blurry tiles (canvas pixel size mismatch)
Symptom: All tiles blurry/pixelated at any zoom.
Cause: CSS sizes canvas with width/height 100% but canvas.width and
canvas.height pixel dimensions never set to match. CSS stretches = blur.

In init(), immediately after `this.canvas = canvas`, add:
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

FIX 3 - Auto-fit zoom on first load
Symptom: Map opens too zoomed in (blurry grey squares).
Scale 2.5 x 32px = 80px tiles, far too large.
Player should see full map on load for orientation then zoom in.
This is the Civ4/FreeCiv first-load experience.

Find the viewportInitialized block in renderGrid(). Replace with:
  if (!this.viewportInitialized) {
    const { width, height } = this.layers.elevation;
    const fitScaleX = (this.canvas.width  * 0.95) / (width  * this.TILE_SIZE);
    const fitScaleY = (this.canvas.height * 0.95) / (height * this.TILE_SIZE);
    this.scale = Math.min(fitScaleX, fitScaleY);
    const slider = document.getElementById('zoom');
    if (slider) slider.value = this.scale;
    const label  = document.getElementById('zoomValue');
    if (label)  label.textContent = this.scale.toFixed(2) + 'x';
    const worldW = width  * this.TILE_SIZE * this.scale;
    const worldH = height * this.TILE_SIZE * this.scale;
    this.offsetX = (this.canvas.width  - worldW) / 2;
    this.offsetY = (this.canvas.height - worldH) / 2;
    this.viewportInitialized = true;
  }

FIX 4 - Pan clamping and horizontal cylindrical wrap
Symptom: Panning goes off into black in all directions.
Cause: No boundaries. Planet is a cylinder - no east/west edge.

Replace setupPan() entirely:
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
  },

Also call this._clampOffset() at end of setupZoom() so zoom respects bounds too.

FIX 5 - Horizontal tile wrapping in render loop
Symptom: Scrolling east hits black instead of wrapping to west.
Cause: _getVisibleTileRange clamps endCol to gridWidth-1.

In _getVisibleTileRange change endCol:
  FROM: endCol: Math.min(gridWidth-1, Math.ceil((left + this.canvas.width) / tileSize) + buffer)
  TO:   endCol: Math.ceil((left + this.canvas.width) / tileSize) + buffer

In renderGrid inner column loop, add as FIRST line inside loop:
  const wrappedCol = ((col % width) + width) % width;

Change all data lookups to use wrappedCol:
  eRow[col] -> eRow[wrappedCol]
  bRow[col] -> bRow[wrappedCol]
  lRow[col] -> lRow[wrappedCol]
  rRow[col] -> rRow[wrappedCol]

Screen x position stays unwrapped (continuous scroll):
  const x = col * tileSize + this.offsetX;
Only DATA lookups wrap. Screen position does not.

FIX 6 - Tile click for AI planning panel
Purpose: Surface view is an AI planning tool. Click tile = show full detail.
Passability derived from adjacent tile slope - no new data source needed.

Add click handler in init() after setupPan() call:
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

Add _showTileDetail method to SurfaceView object:
  _showTileDetail: function(col, row) {
    const { width, height } = this.layers.elevation;
    const elev  = this.layers.elevation.grid[row]?.[col];
    const biome = this.layers.biomes?.grid[row]?.[col]    || '-';
    const res   = this.layers.resources?.grid[row]?.[col] || '-';
    const lat   = (90  - (row  / height) * 180).toFixed(1);
    const lon   = (-180 + (col / width)  * 360).toFixed(1);

    let passability = 'Unknown';
    if (elev != null) {
      const neighbours = [
        this.layers.elevation.grid[row]?.[col - 1],
        this.layers.elevation.grid[row]?.[col + 1],
        this.layers.elevation.grid[row - 1]?.[col],
        this.layers.elevation.grid[row + 1]?.[col],
      ].filter(v => v != null);
      if (neighbours.length > 0) {
        const maxSlope = Math.max(...neighbours.map(n => Math.abs(n - elev)));
        passability = maxSlope < 200  ? 'Easy'
                    : maxSlope < 600  ? 'Moderate'
                    : maxSlope < 1500 ? 'Difficult'
                    : 'Impassable';
      }
    }

    const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
    set('cursor-tile',        col + ', ' + row);
    set('cursor-pos',         lat + ' deg, ' + lon + ' deg');
    set('cursor-biome',       biome);
    set('cursor-elevation',   elev != null ? Math.round(elev) + 'm' : '-');
    set('cursor-passability', passability);
    set('cursor-resource',    res && res !== 'none' ? res : '-');
  },

Verification after all 6 fixes:
  [ ] Surface loads on first navigation - no reload needed
  [ ] Tiles sharp at all zoom levels
  [ ] Map auto-fits canvas on first load, slider matches zoom
  [ ] Panning east wraps to west seamlessly
  [ ] Panning north/south stops at poles, no black
  [ ] No black in any pan direction
  [ ] Clicking tile updates all 6 right panel fields