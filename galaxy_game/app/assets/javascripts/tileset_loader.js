// app/assets/javascripts/tileset_loader.js
console.log('Loading tileset_loader.js...');

// Always define TilesetLoader - check if already defined to handle Turbo reloads
if (typeof window.TilesetLoader === 'undefined') {
    console.log('Defining TilesetLoader...');
    class TilesetLoader {
    constructor(tilesetName = 'trident') {
        this.tilesetName = tilesetName;
        this.tilesetPath = `/tilesets/${tilesetName}/`;
        this.tilespecData = null;
        this.tileImages = new Map();
        this.loaded = false;
    }

    // Load tileset specification and images
    async loadTileset() {
        if (this.loaded) return true;

        try {
            // Try multiple tilespec locations (FreeCiv standard)
            const possibleTilespecs = [
                `${this.tilesetPath}${this.tilesetName}.tilespec`,
                `/tilesets/${this.tilesetName}.tilespec`,     // Parent folder (YOUR CASE)
                `${this.tilesetPath}${this.tilesetName.charAt(0).toUpperCase() + this.tilesetName.slice(1)}.tilespec`
            ];

            let tilespecLoaded = false;
            for (let tilespecPath of possibleTilespecs) {
                try {
                    const tilespecResponse = await fetch(tilespecPath);
                    if (tilespecResponse.ok) {
                        const tilespecText = await tilespecResponse.text();
                        this.tilespecData = this.parseTilespec(tilespecText);
                        tilespecLoaded = true;
                        console.log(`✅ Tilespec loaded from: ${tilespecPath}`);
                        break;
                    }
                } catch(e) {
                    continue;
                }
            }

            if (!tilespecLoaded) {
                throw new Error('No tilespec found in any location');
            }

            // Load tile images
            await this.loadTileImages();

            this.loaded = true;
            return true;
        } catch (error) {
            console.error('Failed to load tileset:', error);
            return false;
        }
    }

    // Parse FreeCiv tilespec format (handles multi-line files = section)
    parseTilespec(content) {
        const data = {};
        let currentSection = null;
        let currentTile = null;
        data.files = [];

        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
            let trimmed = lines[i].trim();
            // Skip comments and empty lines
            if (trimmed.startsWith('#') || trimmed === '') continue;

            // Section headers
            const sectionMatch = trimmed.match(/^\[([^\]]+)\]$/);
            if (sectionMatch) {
                currentSection = sectionMatch[1];
                if (currentSection !== 'files') {
                    data[currentSection] = {};
                }
                currentTile = null;
                continue;
            }

            // FREE CIV FILES= - Handle multi-line + indentation
            if (trimmed.match(/files\s*=\s*/i) || (currentSection === 'files')) {
                // Extract .spec files from ANY line in files section
                const fileMatches = trimmed.match(/"([^\"]*\.spec[^\"]*)"|\b([a-zA-Z0-9_/.-]+\.spec)/gi);
                if (fileMatches) {
                    fileMatches.forEach(match => {
                        let filename = (match.match(/"([^\"]+)"/)?.[1] || match).replace(/"/g, '');
                        filename = filename.split('/').pop(); // Strip path
                        if (filename.endsWith('.spec')) {
                            data.files.push({file: filename});
                        }
                    });
                }
                currentSection = 'files'; // Stay in files section
                continue;
            }

            // Key-value pairs (your existing logic)
            if (currentSection && trimmed.includes('=')) {
                const [key, ...valueParts] = trimmed.split('=');
                const value = valueParts.join('=').trim();
                const parsedValue = this.parseValue(value);

                if (currentTile && currentSection === 'tiles') {
                    data[currentSection][currentTile][key.trim()] = parsedValue;
                } else {
                    data[key.trim()] = parsedValue;
                }
            }
        }

        console.log('🔍 Extracted files:', data.files.slice(0, 5));
        console.log('🔍 Parsed tilespec.files:', data.files.length, data.files);
        return data;
    }

    // Parse tilespec values
    parseValue(value) {
        // Remove quotes
        const unquoted = value.replace(/^["']|["']$/g, '');

        // Numbers
        if (/^\d+$/.test(unquoted)) return parseInt(unquoted);
        if (/^\d+\.\d+$/.test(unquoted)) return parseFloat(unquoted);

        // Booleans
        if (unquoted.toLowerCase() === 'true') return true;
        if (unquoted.toLowerCase() === 'false') return false;

        return unquoted;
    }

    // Load tile images
    async loadTileImages() {
        if (!this.tilespecData?.files) {
            console.warn('tilespecData.files missing or empty');
            return;
        }

        // 1. Load main terrain image
        await this.loadTerrainImage();

        // 2. Parse all .spec files
        await this.parseAllSpecFiles();

        // 3. Extract sprites
        await this.extractSpritesFromSpecFiles();

        console.log(`✅ Extracted ${this.tileImages.size} tiles from .spec files`);
    }

    // NEW: Load terrain sprite sheet
    async loadTerrainImage() {
        const possibleFiles = [
            'tiles.png',           // RoundSquare/Trident standard
            'terrain.png',         // Generic
            `${this.tilesetName}/tiles.png`,  // Subfolder
            'terrain1.png',        // Legacy
            'terrain2.png'
        ];

        for (let filename of possibleFiles) {
            try {
                const img = new Image();
                img.src = `${this.tilesetPath}${filename}`;
                await new Promise((resolve, reject) => {
                    img.onload = () => {
                        this.terrainImage = img;
                        this.tileWidth = this.tilespecData.normal_tile_width || 30;
                        this.tileHeight = this.tilespecData.normal_tile_height || 30;
                        resolve();
                    };
                    img.onerror = reject;
                });
                console.log(`✅ Terrain loaded: ${filename}`);
                return;
            } catch(e) {
                continue;
            }
        }
        throw new Error('No terrain image found');
    }

    // Parse ALL .spec files from tilespec "files" section
    async parseAllSpecFiles() {
        if (!this.tilespecData.files) {
            console.warn('No files section in tilespec');
            return;
        }

        for (const fileInfo of this.tilespecData.files) {
            if (!fileInfo.file || !fileInfo.file.endsWith('.spec')) continue;

            try {
                const url = `${this.tilesetPath}${fileInfo.file}`;
                const specResponse = await fetch(url);
                if (specResponse.ok) {
                    const specText = await specResponse.text();
                    console.log(`📄 Parsing spec: ${url}`);
                    this.parseSpecFile(specText, fileInfo.file);
                } else {
                    console.warn(`Spec ${url} responded ${specResponse.status}`);
                }
            } catch (e) {
                console.warn(`Failed to parse ${fileInfo.file}:`, e);
            }
        }

        console.log('📦 tileImages size after parseAllSpecFiles:', this.tileImages.size);
    }

    // Parse FreeCiv .spec format → sprite coordinates
    parseSpecFile(specText, specFilename) {
        const lines = specText.split('\n');
        let currentGrid = null;

        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed) continue;

            // Grid definition: [grid_tag]
            if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
                currentGrid = trimmed.slice(1, -1);
                continue;
            }

            // Tile position: row,col,"tag"
            const tileMatch = trimmed.match(/^(\d+),\s*(\d+),\s*"(.+)"$/);
            if (tileMatch && currentGrid) {
                const [, row, col, tag] = tileMatch;
                const r = parseInt(row, 10);
                const c = parseInt(col, 10);

                this.tileImages.set(tag, {
                    tag,
                    row: r,
                    col: c,
                    grid: currentGrid,
                    specFile: specFilename
                });
            }
        }
    }

    async extractSpritesFromSpecFiles() {
        if (!this.tileImages || this.tileImages.size === 0) {
            console.warn('No tile definitions to extract sprites for');
            return;
        }

        // collect PNGs
        const spriteSheetFiles = new Set();
        for (const [, tileData] of this.tileImages) {
            if (tileData.specFile) {
                spriteSheetFiles.add(tileData.specFile.replace('.spec', '.png'));
            }
        }

        if (!this.spriteSheets) this.spriteSheets = new Map();

        const loadPromises = Array.from(spriteSheetFiles).map(pngFile => {
            return new Promise(resolve => {
                const img = new Image();
                img.onload = () => {
                    this.spriteSheets.set(pngFile, img);
                    resolve();
                };
                img.onerror = () => {
                    console.warn(`Failed to load sprite sheet ${pngFile}, using terrainImage`);
                    this.spriteSheets.set(pngFile, this.terrainImage);
                    resolve();
                };
                img.src = `${this.tilesetPath}${pngFile}`;
            });
        });

        await Promise.all(loadPromises);

        let extracted = 0;
        for (const [tag, tileData] of this.tileImages) {
            if (tileData.row == null || tileData.col == null) continue;

            const pngFile = tileData.specFile.replace('.spec', '.png');
            const sheet = this.spriteSheets.get(pngFile) || this.terrainImage;
            if (!sheet) continue;

            const sprite = this.extractSpriteFromSheet(sheet, tileData);
            tileData.image = sprite;
            tileData.width = this.tileWidth;
            tileData.height = this.tileHeight;
            extracted++;
        }

        console.log(`✅ extractSpritesFromSpecFiles: extracted ${extracted} sprites`);
    }

    async loadAllSpriteSheets() {
        const spriteSheets = new Map();
        const promises = [];

        // Collect unique PNG files from .spec files
        for (const [, tileData] of this.tileImages) {
            if (tileData.specFile) {
                const pngFile = tileData.specFile.replace('.spec', '.png');
                if (!spriteSheets.has(pngFile)) {
                    promises.push(this.loadSpriteSheet(pngFile, spriteSheets));
                }
            }
        }

        await Promise.all(promises);
        return spriteSheets;
    }

    async loadSpriteSheet(pngFile, spriteSheets) {
        return new Promise((resolve) => {
            const img = new Image();
            img.onload = () => {
                this.spriteSheets.set(pngFile, img);
                spriteSheets.set(pngFile, img);
                resolve(img);
            };
            img.onerror = () => {
                this.spriteSheets.set(pngFile, this.terrainImage);
                spriteSheets.set(pngFile, this.terrainImage);
                resolve(this.terrainImage);
            };
            img.src = `${this.tilesetPath}${pngFile}`;
        });
    }

    getSpriteSheetForSpec(specFile) {
        // Map .spec → PNG filename (tiles.spec → tiles.png)
        const pngFile = specFile.replace('.spec', '.png');
        // CRITICAL: Check if already cached
        if (this.spriteSheets?.has(pngFile)) {
            return this.spriteSheets.get(pngFile);
        }
        // IMMEDIATE FAIL: Return terrainImage if PNG not ready
        return this.terrainImage || null;
    }

    extractSpriteFromSheet(sheet, tileData) {
        const canvas = document.createElement('canvas');
        canvas.width = this.tileWidth;
        canvas.height = this.tileHeight;
        const ctx = canvas.getContext('2d');
        const sx = tileData.col * this.tileWidth;
        const sy = tileData.row * this.tileHeight;
        ctx.drawImage(sheet, sx, sy, this.tileWidth, this.tileHeight, 0, 0, this.tileWidth, this.tileHeight);
        const img = new Image();
        img.src = canvas.toDataURL();
        return img;
    }

    // Create a simple fallback tile when image loading fails
    createFallbackTile(fileName, width, height) {
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        
        // Generate color based on filename
        const hash = fileName.split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0);
        const hue = Math.abs(hash) % 360;
        ctx.fillStyle = `hsl(${hue}, 60%, 45%)`;
        ctx.fillRect(0, 0, width, height);
        
        // Add some texture
        ctx.fillStyle = `hsl(${hue}, 40%, 30%)`;
        for (let i = 0; i < 10; i++) {
            const x = Math.random() * width;
            const y = Math.random() * height;
            const size = Math.random() * 4 + 1;
            ctx.fillRect(x, y, size, size);
        }
        
        const image = new Image();
        image.src = canvas.toDataURL();
        
        this.tileImages.set(fileName, {
            image: image,
            width: width,
            height: height
        });
    }

    // Get tile data for terrain type
    getTerrainTile(terrainType, variation = 0) {
        if (!this.loaded) return null;

        // Map Galaxy Game terrain to FreeCiv terrain tag
        const freecivTerrain = this.mapGalaxyToFreecivTerrain(terrainType);
        if (!freecivTerrain) return null;

        // Directly use the tag for lookup
        const imageData = this.tileImages.get(freecivTerrain);
        if (!imageData) return null;

        return {
            image: imageData.image,
            x: 0,
            y: 0,
            width: imageData.width,
            height: imageData.height,
            terrainType: terrainType
        };
    }

    // Map Galaxy Game terrain types to FreeCiv terrain names
    mapGalaxyToFreecivTerrain(galaxyTerrain) {
        // Map Galaxy Game terrain types to actual FreeCiv tags from tiles.spec
        // Trident tileset terrain tag mapping
        const mapping = {
            'ocean': 'ocean',
            'deep_sea': 'deep_water',
            'desert': 't.l1.desert1',
            'forest': 't.l1.forest1',
            'plains': 't.l1.plains1',
            'grasslands': 't.l0.grassland1',
            'tundra': 't.l1.tundra1',
            'arctic': 't.l1.arctic1',
            'boreal': 't.l1.tundra1',
            'jungle': 't.l1.jungle1',
            'swamp': 't.l1.swamp1',
            'rock': 't.l1.mountains1',
            'mountains': 't.l1.mountains1'
        };
        return mapping[galaxyTerrain.toLowerCase()] || 't.l0.grassland1';
    }

    // Check if tileset is loaded
    isLoaded() {
        return this.loaded;
    }
}

// Assign to window to ensure global availability
window.TilesetLoader = TilesetLoader;
console.log('TilesetLoader assigned to window:', typeof window.TilesetLoader);
} // End TilesetLoader guard clause

// AlioTilesetLoader for sci-fi planetary rendering with burrow tubes
console.log('Defining AlioTilesetLoader...');
if (typeof window.AlioTilesetLoader === 'undefined') {
    console.log('Defining AlioTilesetLoader class...');
    class AlioTilesetLoader {
    constructor(alioTileConfig = null) {
        this.alioTileConfig = alioTileConfig;
        this.tilesetPath = '/tilesets/alio/';
        this.tileImages = new Map();
        this.loaded = false;
        this.tileWidth = 126;
        this.tileHeight = 64;
    }

    // Load Alio tileset
    async loadTileset() {
        if (this.loaded) return true;

        try {
            // Load tile images based on config
            if (this.alioTileConfig) {
                await this.loadTileImagesFromConfig();
            } else {
                // Fallback: load standard Alio tiles
                await this.loadStandardAlioTiles();
            }

            this.loaded = true;
            return true;
        } catch (error) {
            console.error('Failed to load Alio tileset:', error);
            return false;
        }
    }

    // Load tiles from Rails-provided config
    async loadTileImagesFromConfig() {
        const loadPromises = [];

        for (const [tileName, tileData] of Object.entries(this.alioTileConfig)) {
            if (tileData.file) {
                const promise = this.loadTileImage(tileData.file, tileData);
                loadPromises.push(promise);
            }
        }

        await Promise.all(loadPromises);
    }

    // Load standard Alio tiles as fallback
    async loadStandardAlioTiles() {
        // Standard Alio tiles - these would be defined in the tileset
        const standardTiles = [
            'arctic', 'desert', 'forest', 'grassland', 'hills', 'jungle',
            'mountains', 'ocean', 'plains', 'swamp', 'tundra', 'burrow_tube'
        ];

        const loadPromises = standardTiles.map(tileName => {
            return this.loadTileImage(`${tileName}.png`, { name: tileName });
        });

        await Promise.all(loadPromises);
    }

    // Load individual tile image
    async loadTileImage(fileName, tileData) {
        try {
            const image = new Image();
            const imagePath = `${this.tilesetPath}${fileName}`;

            await new Promise((resolve, reject) => {
                image.onload = () => resolve();
                image.onerror = () => {
                    console.warn(`Failed to load Alio tile ${fileName}, creating fallback`);
                    this.createFallbackAlioTile(fileName, tileData);
                    resolve();
                };
                image.src = imagePath;
            });

            this.tileImages.set(tileData.name || fileName.replace('.png', ''), {
                image: image,
                width: this.tileWidth,
                height: this.tileHeight,
                ...tileData
            });

        } catch (error) {
            console.warn(`Failed to load Alio tile ${fileName}:`, error);
            this.createFallbackAlioTile(fileName, tileData);
        }
    }

    // Create fallback tile for Alio tileset
    createFallbackAlioTile(fileName, tileData) {
        const canvas = document.createElement('canvas');
        canvas.width = this.tileWidth;
        canvas.height = this.tileHeight;
        const ctx = canvas.getContext('2d');
        
        // Generate color based on tile name
        const tileName = tileData.name || fileName.replace('.png', '');
        const hash = tileName.split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a & a;
        }, 0);
        const hue = Math.abs(hash) % 360;
        
        // Create a diamond-shaped tile (isometric style)
        ctx.fillStyle = `hsl(${hue}, 60%, 45%)`;
        ctx.beginPath();
        ctx.moveTo(this.tileWidth / 2, 0);
        ctx.lineTo(this.tileWidth, this.tileHeight / 2);
        ctx.lineTo(this.tileWidth / 2, this.tileHeight);
        ctx.lineTo(0, this.tileHeight / 2);
        ctx.closePath();
        ctx.fill();
        
        // Add some texture
        ctx.fillStyle = `hsl(${hue}, 40%, 30%)`;
        for (let i = 0; i < 8; i++) {
            const x = Math.random() * this.tileWidth;
            const y = Math.random() * this.tileHeight;
            const size = Math.random() * 3 + 1;
            ctx.fillRect(x, y, size, size);
        }
        
        const image = new Image();
        image.src = canvas.toDataURL();
        
        this.tileImages.set(tileName, {
            image: image,
            width: this.tileWidth,
            height: this.tileHeight,
            ...tileData
        });
    }

    // Get tile for terrain type with auto-tiling for burrow tubes
    getTerrainTile(terrainType, adjacentTiles = {}) {
        if (!this.loaded) return null;

        const tileName = this.mapTerrainToAlioTile(terrainType);
        let tileData = this.tileImages.get(tileName);
        
        if (!tileData) {
            // Try fallback mapping
            const fallbackTile = this.mapTerrainToAlioTile(terrainType, true);
            tileData = this.tileImages.get(fallbackTile);
        }

        if (!tileData) return null;

        // Handle burrow tube auto-tiling
        if (terrainType === 'burrow_tube' || tileName.includes('burrow')) {
            return this.getBurrowTubeTile(adjacentTiles, tileData);
        }

        return {
            image: tileData.image,
            x: 0,
            y: 0,
            width: tileData.width,
            height: tileData.height,
            terrainType: terrainType
        };
    }

    // Map Galaxy Game terrain to Alio tile names
    mapTerrainToAlioTile(galaxyTerrain, fallback = false) {
        const mapping = {
            'arctic': 'arctic',
            'deep_sea': 't.l1.coast_n1e1s1w1',
            'desert': 't.l0.desert_n1e1s1w1',
            'forest': 't.l0.forest_n0e0s0w0',
            'plains': 't.l0.plains_n1e1s1w1',
            'grasslands': 't.l0.grassland1',
            'boreal': 't.l0.tundra_n1e1s1w1',
            'jungle': 't.l0.jungle_n1e1s1w1',
            'ocean': 't.l1.coast_n1e1s1w1',
            'swamp': 't.l0.swamp_n1e1s1w1',
            'tundra': 't.l0.tundra_n1e1s1w1',
            'rock': 't.l0.mountains_n0e0s0w0',  // rock -> mountains
            'mountains': 'mountains',
            'hills': 'hills',
            'burrow_tube': 'burrow_tube'
        };

        const mapped = mapping[galaxyTerrain.toLowerCase()];
        if (mapped && !fallback) return mapped;
        
        // Fallback mappings
        if (fallback) {
            if (galaxyTerrain.includes('water') || galaxyTerrain.includes('sea')) return 'ocean';
            if (galaxyTerrain.includes('forest') || galaxyTerrain.includes('jungle')) return 'forest';
            if (galaxyTerrain.includes('mountain') || galaxyTerrain.includes('rock')) return 'mountains';
            if (galaxyTerrain.includes('desert') || galaxyTerrain.includes('dry')) return 'desert';
        }

        return mapped || 'grassland';
    }

    // Get burrow tube tile with auto-tiling based on adjacent connections
    getBurrowTubeTile(adjacentTiles, baseTileData) {
        // Calculate bit mask for adjacent burrow tubes
        // Bit positions: 0=NW, 1=NE, 2=E, 3=SE, 4=SW, 5=W
        let bitMask = 0;
        
        if (adjacentTiles.northwest === 'burrow_tube') bitMask |= (1 << 0);
        if (adjacentTiles.northeast === 'burrow_tube') bitMask |= (1 << 1);
        if (adjacentTiles.east === 'burrow_tube') bitMask |= (1 << 2);
        if (adjacentTiles.southeast === 'burrow_tube') bitMask |= (1 << 3);
        if (adjacentTiles.southwest === 'burrow_tube') bitMask |= (1 << 4);
        if (adjacentTiles.west === 'burrow_tube') bitMask |= (1 << 5);

        // Calculate tile position based on bit mask
        const tileIndex = this.calculateTilePosition(bitMask);
        
        return {
            image: baseTileData.image,
            x: tileIndex * this.tileWidth,
            y: 0, // Assuming single row for now
            width: this.tileWidth,
            height: this.tileHeight,
            terrainType: 'burrow_tube',
            bitMask: bitMask
        };
    }

    // Calculate tile position for burrow tube auto-tiling
    // Fixed bit logic for proper connections
    calculateTilePosition(bitMask) {
        // Handle special cases first
        if (bitMask === 0) return 0; // Isolated tube
        
        // Check for straight connections
        if ((bitMask & 0b001001) === 0b001001) return 1; // NW-SE diagonal
        if ((bitMask & 0b000110) === 0b000110) return 2; // NE-SW diagonal
        if ((bitMask & 0b010100) === 0b010100) return 3; // E-W horizontal
        if ((bitMask & 0b100001) === 0b100001) return 4; // N-S vertical
        
        // Check for corner connections
        if ((bitMask & 0b011000) === 0b011000) return 5; // NE-E
        if ((bitMask & 0b110000) === 0b110000) return 6; // E-SE
        if ((bitMask & 0b000011) === 0b000011) return 7; // SW-W
        if ((bitMask & 0b000101) === 0b000101) return 8; // W-NW
        
        // Check for three-way connections
        if ((bitMask & 0b011100) === 0b011100) return 9;  // NE-E-SE
        if ((bitMask & 0b110001) === 0b110001) return 10; // E-SE-SW
        if ((bitMask & 0b100011) === 0b100011) return 11; // SE-SW-W
        if ((bitMask & 0b001101) === 0b001101) return 12; // SW-W-NW
        
        // Check for cross connections
        if ((bitMask & 0b101010) === 0b101010) return 13; // Alternating pattern
        if ((bitMask & 0b010101) === 0b010101) return 14; // Other alternating
        
        // Default to first tile if no pattern matches
        return 0;
    }

    // Check if tileset is loaded
    isLoaded() {
        return this.loaded;
    }
}

// Assign to window to ensure global availability
window.AlioTilesetLoader = AlioTilesetLoader;
console.log('AlioTilesetLoader assigned to window:', typeof window.AlioTilesetLoader);
} // End AlioTilesetLoader guard clause