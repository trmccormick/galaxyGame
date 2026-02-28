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
    console.log("🧩 SURFACE VIEW - TILESET VERSION");
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
    
      // Get tileset name and variant (default to RoundSquare for Earth, Alio for others)
    const tilesetName = this.getPlanetTilesetName(this.data.planet_name);
      // Example: select variant based on world or user setting
      // You can set this dynamically, e.g., from user input or world properties
      const tilesetVariant = this.data.tileset_variant || 'base';
    console.log(`🧩 Loading tileset: ${tilesetName} for ${this.data.planet_name}`);
      console.log(`🧩 Loading tileset: ${tilesetName} [variant: ${tilesetVariant}] for ${this.data.planet_name}`);
    
    // Initialize tileset loader
      if (window.SimpleTilesetLoader) {
        this.tilesetLoader = new window.SimpleTilesetLoader(tilesetName);
          this.tilesetVariant = tilesetVariant; // Store variant for rendering
      
      // Update UI
      const nameEl = document.getElementById('tileset-name');
      const statusEl = document.getElementById('tileset-status');
      
      if (nameEl) nameEl.textContent = tilesetName;
      if (statusEl) statusEl.textContent = 'Loading...';
      
      // Load tileset
      const success = await this.tilesetLoader.loadTileset();
      // Wait for all tile images to be fully loaded
      await this.waitForTileImagesLoaded();

      // Check for missing sprite sheet
      if (this.tilesetLoader.config && this.tilesetLoader.config.sheets) {
        Object.values(this.tilesetLoader.config.sheets).forEach(sheet => {
          if (!sheet.file || sheet.file.includes('TODO')) {
            console.warn('⚠️ Sprite sheet image missing for tileset:', tilesetName, sheet.file);
          }
        });
      }

      if (success) {
        this.tilesetLoaded = true;
        console.log(`✅ Tileset loaded: ${this.tilesetLoader.tileImages.size} tiles`);
        
        const nameEl = document.getElementById('tileset-name');
        const statusEl = document.getElementById('tileset-status');
        const loadedEl = document.getElementById('tiles-loaded');
        
        if (nameEl) nameEl.textContent = tilesetName;
        if (statusEl) statusEl.textContent = 'Loaded';
        if (loadedEl) loadedEl.textContent = this.tilesetLoader.tileImages.size;
      } else {
        console.error('❌ Failed to load tileset');
        const statusEl = document.getElementById('tileset-status');
        if (statusEl) statusEl.textContent = 'Failed';
      }
    } else {
      console.error('❌ TilesetLoader not available');
      const statusEl = document.getElementById('tileset-status');
      if (statusEl) statusEl.textContent = 'TilesetLoader Missing';
    }
    
    // UI STATUS
    if (this.terrain) {
      const sizeEl = document.getElementById('terrain-size');
      const sourceEl = document.getElementById('terrain-source');
      
      if (sizeEl) sizeEl.textContent = `${this.terrain.width}×${this.terrain.height}`;
      if (sourceEl) sourceEl.textContent = this.terrain.generation_method || 'Unknown';
      
      console.log(`🧩 Terrain grid: ${this.terrain.width}x${this.terrain.height}`);
    }
    
    this.renderGrid();
    this.setupZoom();
    this.setupPan();
    this.setupTilesetSelector();
  },
  
  getPlanetTilesetName: function(planetName) {
    // Map planets to appropriate tilesets
    const tilesetMap = {
      'Earth': 'galaxy_game_base_terrain',   // Use new JSON tileset for Earth
      'Mars': 'alio',
      'Luna': 'alio',
      'Titan': 'alio',
      'Europa': 'alio',
      'Venus': 'alio'
    };
    return tilesetMap[planetName] || 'galaxy_game_base_terrain'; // Default to new JSON tileset
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

    // BLACK BACKGROUND
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // RENDER TILES
    for (let row = 0; row < terrain.height; row++) {
      for (let col = 0; col < terrain.width; col++) {
        const elev = terrain.elevation[row][col];
        const biome = terrain.biomes?.[row]?.[col];
        // Get tile name for this terrain
        const tileName = this.getTerrainTileName(elev, biome);
        // Calculate screen position with viewport
        const x = col * TILE_SIZE * scale + this.offsetX;
        const y = row * TILE_SIZE * scale + this.offsetY;
        // Skip if off-screen
        if (x + TILE_SIZE * scale < 0 || x > canvas.width ||
            y + TILE_SIZE * scale < 0 || y > canvas.height) {
          continue;
        }
        // Try to draw tileset sprite with safety check
        if (this.tilesetLoaded && this.tilesetLoader.tileImages.has(tileName)) {
          const tileImg = this.tilesetLoader.tileImages.get(tileName);
          if (tileImg?.image && tileImg.image.complete && tileImg.image.naturalWidth > 0) {
            ctx.imageSmoothingEnabled = false;
            ctx.drawImage(tileImg.image, x, y, TILE_SIZE * scale, TILE_SIZE * scale);
          } else {
            // Fallback: color-coded
            const color = this.getTerrainColor(elev, biome);
            ctx.fillStyle = color;
            ctx.fillRect(x, y, TILE_SIZE * scale, TILE_SIZE * scale);
          }
        } else {
          // Fallback: color-coded
          const color = this.getTerrainColor(elev, biome);
          ctx.fillStyle = color;
          ctx.fillRect(x, y, TILE_SIZE * scale, TILE_SIZE * scale);
        }
        // Optional: grid lines
        if (scale >= 1.5) {
          ctx.strokeStyle = 'rgba(64,64,64,0.3)';
          ctx.lineWidth = 1;
          ctx.strokeRect(x, y, TILE_SIZE * scale, TILE_SIZE * scale);
        }
      }
    }
    console.log(`✅ Grid rendered: ${terrain.width}x${terrain.height}`);
  },
  
  getTerrainTileName: function(elev, biome) {
    // Map elevation and biome to FreeCiv tile tags from tiles.spec (RoundSquare)
    if (elev == null) return 't.l0.coast_cell_u000'; // Default fallback

    // Water tiles (use actual tags from tiles.spec)
    if (elev < 0) {
      if (elev < -100) return 't.l1.floor_n1e1s1w1'; // Deep ocean (floor)
      return 't.l1.coast_n1e1s1w1'; // Shallow ocean/coast
    }

      if (biome) {
        const biomeLower = biome.toLowerCase();
        // Arctic/Ice
        if (biomeLower.includes('arctic') || biomeLower.includes('ice')) {
          return 't.l0.arctic1';
        }
        // Tundra
        if (biomeLower.includes('tundra')) {
          return 't.l0.tundra1';
        }
        // Desert
        if (biomeLower.includes('desert')) {
          return 't.l0.desert1';
        }
        // Jungle
        if (biomeLower.includes('jungle') || biomeLower.includes('rain')) {
          return 't.l0.jungle1';
        }
        // Forest
        if (biomeLower.includes('forest')) {
          // Boreal/northern forests might be on tundra
          if (biomeLower.includes('boreal')) {
            return 't.l0.tundra1';
          }
          return 't.l0.forest1';
        }
        // Swamp
        if (biomeLower.includes('swamp') || biomeLower.includes('marsh')) {
          return 't.l0.swamp1';
        }
        // Grassland
        if (biomeLower.includes('grass') || biomeLower.includes('temperate')) {
          return 't.l0.grassland1';
        }
        // Plains
        if (biomeLower.includes('plain')) {
          return 't.l0.plains1';
        }
      }

      // ELEVATION-BASED FALLBACK (if no biome or biome not recognized)
      if (elev > 2000 || elev > 0.85) {
        return 't.l0.mountains1'; // High mountains
      }
      if (elev > 1000 || elev > 0.7) {
        return 't.l0.hills1'; // Hills
      }
      if (elev > 500 || elev > 0.6) {
        return 't.l0.grassland1'; // Grassland
      }
      if (elev > 200 || elev > 0.5) {
        return 't.l0.plains1'; // Plains
      }

      // Low coastal areas
      return 't.l0.coast1';
  },
  
  getTerrainColor: function(elev, biome) {
    // Fallback colors when tileset isn't loaded
    if (elev == null) return '#666';
    
    if (elev < -100) return '#000080'; // Deep ocean
    if (elev < 0) return '#1e3a8a';    // Shallow ocean
    if (elev < 100) return '#4682b4';  // Coast
    
    if (biome) {
      const biomeLower = biome.toLowerCase();
      if (biomeLower.includes('forest')) return '#228b22';
      if (biomeLower.includes('jungle')) return '#006400';
      if (biomeLower.includes('desert')) return '#daa520';
      if (biomeLower.includes('tundra')) return '#b0c4de';
      if (biomeLower.includes('arctic')) return '#ffffff';
      if (biomeLower.includes('grass')) return '#adff2f';
    }
    
    if (elev > 1000) return '#8b4513'; // Hills
    if (elev > 500) return '#90ee90';  // Grassland
    return '#adff2f';                   // Plains
      // More distinct fallback colors when tileset isn't loaded
      if (elev == null) return '#808080'; // Gray

      // Water - Blues
      if (elev < -100 || elev < 0.2) return '#000080'; // Navy - Deep ocean
      if (elev < 0 || elev < 0.3) return '#4169E1';    // Royal blue - Shallow ocean
      if (elev < 100 || elev < 0.4) return '#87CEEB';  // Sky blue - Coast

      if (biome) {
        const biomeLower = biome.toLowerCase();

        // Cold
        if (biomeLower.includes('arctic') || biomeLower.includes('ice')) {
          return '#FFFFFF'; // White
        }
        if (biomeLower.includes('tundra')) {
          return '#B0E0E6'; // Powder blue
        }

        // Vegetation
        if (biomeLower.includes('jungle') || biomeLower.includes('rain')) {
          return '#006400'; // Dark green
        }
        if (biomeLower.includes('forest')) {
          if (biomeLower.includes('boreal')) {
            return '#228B22'; // Forest green
          }
          return '#32CD32'; // Lime green
        }
        if (biomeLower.includes('grass')) {
          return '#7CFC00'; // Lawn green
        }

        // Dry
        if (biomeLower.includes('desert')) {
          return '#F4A460'; // Sandy brown
        }
        if (biomeLower.includes('plain')) {
          return '#DAA520'; // Goldenrod
        }

        // Wet
        if (biomeLower.includes('swamp') || biomeLower.includes('marsh')) {
          return '#556B2F'; // Dark olive green
        }
      }

      // Elevation-based for unknown biomes
      if (elev > 2000 || elev > 0.85) return '#696969'; // Dim gray - Mountains
      if (elev > 1000 || elev > 0.7) return '#8B4513';  // Saddle brown - Hills
      if (elev > 500 || elev > 0.6) return '#90EE90';   // Light green - Grassland
      if (elev > 200 || elev > 0.5) return '#F0E68C';   // Khaki - Plains

      return '#D2B48C'; // Tan - Low areas
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
    ctx.fillText('AVAILABLE', canvas.width / 2, canvas.height / 2 + 10);
    ctx.fillText('Generate terrain to view surface', canvas.width / 2, canvas.height / 2 + 40);
  },
  
  setupZoom: function() {
    const canvas = this.canvas;
    let zoomEl = document.getElementById('zoom');
    
    // ZOOM SLIDER
    if (zoomEl) {
      zoomEl.value = this.scale;
      zoomEl.addEventListener('input', (e) => {
        this.scale = parseFloat(e.target.value);
        document.getElementById('zoomValue').textContent = this.scale.toFixed(1) + 'x';
        this.renderGrid();
      });
    }
    
    // MOUSE WHEEL ZOOM
    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      this.scale *= e.deltaY > 0 ? 0.9 : 1.1;
      this.scale = Math.max(0.5, Math.min(4, this.scale));
      
      zoomEl = document.getElementById('zoom');
      if (zoomEl) zoomEl.value = this.scale;
      document.getElementById('zoomValue').textContent = this.scale.toFixed(1) + 'x';
      this.renderGrid();
    }, { passive: false });
    
    // RESET BUTTON
    const resetBtn = document.getElementById('resetViewBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        this.scale = 1.0;
        this.offsetX = 0;
        this.offsetY = 0;
        zoomEl = document.getElementById('zoom');
        if (zoomEl) zoomEl.value = 1.0;
        document.getElementById('zoomValue').textContent = '1.0x';
        this.renderGrid();
      });
    }
  },

  setupPan: function() {
    const canvas = this.canvas;
    if (!canvas) return;
    
    canvas.style.cursor = 'grab';
    
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
      
      let newOffsetX = this.dragStartOffsetX + dx;
      let newOffsetY = this.dragStartOffsetY + dy;
      
      // Clamp pan bounds
      if (this.terrain) {
        const mapWidth = this.terrain.width * this.TILE_SIZE * this.scale;
        const mapHeight = this.terrain.height * this.TILE_SIZE * this.scale;
        const canvasWidth = this.canvas.width;
        const canvasHeight = this.canvas.height;
        
        if (mapWidth > canvasWidth) {
          const minX = canvasWidth - mapWidth;
          newOffsetX = Math.max(minX, Math.min(0, newOffsetX));
        } else {
          newOffsetX = (canvasWidth - mapWidth) / 2;
        }
        
        if (mapHeight > canvasHeight) {
          const minY = canvasHeight - mapHeight;
          newOffsetY = Math.max(minY, Math.min(0, newOffsetY));
        } else {
          newOffsetY = (canvasHeight - mapHeight) / 2;
        }
      }
      
      this.offsetX = newOffsetX;
      this.offsetY = newOffsetY;
      this.renderGrid();
      
      // Update cursor info
      this.updateCursorInfo(e);
    });
    
    canvas.addEventListener('mouseup', () => {
      this.isDragging = false;
      canvas.style.cursor = 'grab';
    });
    
    canvas.addEventListener('mouseleave', () => {
      this.isDragging = false;
      canvas.style.cursor = 'grab';
    });
  },
  
  setupTilesetSelector: function() {
    const selector = document.getElementById('tilesetSelect');
    const reloadBtn = document.getElementById('reloadTilesetBtn');
    
    if (selector) {
      selector.addEventListener('change', async () => {
        const newTileset = selector.value;
        console.log(`🧩 Switching to tileset: ${newTileset}`);
        
        document.getElementById('tileset-status').textContent = 'Loading...';
        
        this.tilesetLoader = new window.TilesetLoader(newTileset);
        const success = await this.tilesetLoader.loadTileset();
        
        if (success) {
          this.tilesetLoaded = true;
          document.getElementById('tileset-name').textContent = newTileset;
          document.getElementById('tileset-status').textContent = 'Loaded';
          document.getElementById('tiles-loaded').textContent = this.tilesetLoader.tileImages.size;
          this.renderGrid();
        } else {
          document.getElementById('tileset-status').textContent = 'Failed';
        }
      });
    }
    
    if (reloadBtn) {
      reloadBtn.addEventListener('click', async () => {
        if (this.tilesetLoader) {
          console.log(`🔄 Reloading tileset: ${this.tilesetLoader.tilesetName}`);
          this.tilesetLoader.loaded = false;
          this.tilesetLoader.tileImages.clear();
          
          const success = await this.tilesetLoader.loadTileset();
          if (success) {
            this.renderGrid();
          }
        }
      });
    }
  },
  
  updateCursorInfo: function(e) {
    if (!this.terrain) return;
    
    const rect = this.canvas.getBoundingClientRect();
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;
    
    const worldX = (mouseX - this.offsetX) / this.scale;
    const worldY = (mouseY - this.offsetY) / this.scale;
    
    const tileX = Math.floor(worldX / this.TILE_SIZE);
    const tileY = Math.floor(worldY / this.TILE_SIZE);
    
    const posEl = document.getElementById('cursor-pos');
    if (posEl) posEl.textContent = `${tileX}, ${tileY}`;
    
    if (tileX >= 0 && tileX < this.terrain.width && 
        tileY >= 0 && tileY < this.terrain.height) {
      const elev = this.terrain.elevation?.[tileY]?.[tileX];
      const biome = this.terrain.biomes?.[tileY]?.[tileX];
      const tileName = this.getTerrainTileName(elev, biome);
      
      const tileEl = document.getElementById('cursor-tile');
      const biomeEl = document.getElementById('cursor-biome');
      
      if (tileEl) tileEl.textContent = tileName || '-';
      if (biomeEl) biomeEl.textContent = biome || '-';
    } else {
      const tileEl = document.getElementById('cursor-tile');
      const biomeEl = document.getElementById('cursor-biome');
      
      if (tileEl) tileEl.textContent = '-';
      if (biomeEl) biomeEl.textContent = '-';
    }
  },
  
  waitForTileImagesLoaded: async function() {
    if (!this.tilesetLoader || !this.tilesetLoader.tileImages) return;
    const images = Array.from(this.tilesetLoader.tileImages.values())
      .map(tile => tile.image)
      .filter(img => img instanceof Image);
    await Promise.all(images.map(img => {
      return new Promise(resolve => {
        if (img.complete && img.naturalWidth > 0) {
          resolve();
        } else {
          img.onload = () => resolve();
          img.onerror = () => resolve();
        }
      });
    }));
    console.log('✅ All tile images loaded');
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
