/**
 * SimpleTilesetLoader - JSON-based tileset loader for Galaxy Game
 * Replaces complex FreeCiv .tilespec parser with simple JSON config
 */

class SimpleTilesetLoader {
  constructor(tilesetName) {
    this.tilesetName = tilesetName;
    this.tilesetPath = `/tilesets/galaxy_game/`;
    this.config = null;
    this.tileImages = new Map();
    this.loaded = false;
  }

  async loadTileset() {
    if (this.loaded) return true;

    try {
      console.log(`🧩 Loading tileset: ${this.tilesetName}`);
      
      // Load JSON config
      const configPath = `${this.tilesetPath}${this.tilesetName}.json`;
      const response = await fetch(configPath);
      
      if (!response.ok) {
        throw new Error(`Failed to load config: ${response.status}`);
      }
      
      this.config = await response.json();
      console.log(`✅ Config loaded:`, this.config);
      
      // Load all sprite sheets
      for (const [sheetName, sheet] of Object.entries(this.config.sheets)) {
        await this.loadSheet(sheetName, sheet);
      }
      
      this.loaded = true;
      console.log(`✅ Tileset loaded: ${this.tileImages.size} tiles`);
      return true;
      
    } catch (error) {
      console.error(`❌ Failed to load tileset:`, error);
      return false;
    }
  }

  async loadSheet(sheetName, sheet) {
    console.log(`📄 Loading sheet: ${sheetName} (${sheet.file})`);
    
    // Load sprite sheet image
    const img = await this.loadImage(`${this.tilesetPath}${sheet.file}`);
    
    console.log(`✅ Sheet loaded: ${sheet.file} (${img.width}×${img.height})`);
    
    // Extract individual tiles
    const tileSize = this.config.tile_size;
    let tilesExtracted = 0;
    
    for (const [tileName, coords] of Object.entries(sheet.tiles)) {
      const canvas = document.createElement('canvas');
      canvas.width = tileSize;
      canvas.height = tileSize;
      const ctx = canvas.getContext('2d');
      
      // Extract tile from sprite sheet
      ctx.drawImage(
        img,
        coords.x, coords.y,     // Source position
        tileSize, tileSize,      // Source size
        0, 0,                    // Dest position
        tileSize, tileSize       // Dest size
      );
      
      // Store in map
      this.tileImages.set(tileName, canvas);
      tilesExtracted++;
    }
    
    console.log(`✅ Extracted ${tilesExtracted} tiles from ${sheetName}`);
  }

  loadImage(src) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error(`Failed to load image: ${src}`));
      img.src = src;
    });
  }

  getTile(tileName) {
    return this.tileImages.get(tileName);
  }

  hasTile(tileName) {
    return this.tileImages.has(tileName);
  }

  isLoaded() {
    return this.loaded;
  }

  getTileSize() {
    return this.config?.tile_size || 32;
  }

  getAllTileNames() {
    return Array.from(this.tileImages.keys());
  }

  getTilesByPrefix(prefix) {
    return Array.from(this.tileImages.keys())
      .filter(name => name.startsWith(prefix));
  }
}

// Make available globally
window.SimpleTilesetLoader = SimpleTilesetLoader;
console.log('✅ SimpleTilesetLoader defined');
