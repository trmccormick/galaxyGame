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
            // Load tilespec
            const tilespecResponse = await fetch(`${this.tilesetPath}${this.tilesetName}.tilespec`);
            if (!tilespecResponse.ok) {
                throw new Error(`Failed to load tilespec: ${tilespecResponse.status}`);
            }

            const tilespecText = await tilespecResponse.text();
            this.tilespecData = this.parseTilespec(tilespecText);

            // Load tile images
            await this.loadTileImages();

            this.loaded = true;
            return true;
        } catch (error) {
            console.error('Failed to load tileset:', error);
            return false;
        }
    }

    // Parse FreeCiv tilespec format
    parseTilespec(content) {
        const data = {};
        let currentSection = null;
        let currentTile = null;

        const lines = content.split('\n');

        for (const line of lines) {
            const trimmed = line.trim();

            // Skip comments and empty lines
            if (trimmed.startsWith('#') || trimmed === '') continue;

            // Section headers
            const sectionMatch = trimmed.match(/^\[([^\]]+)\]$/);
            if (sectionMatch) {
                currentSection = sectionMatch[1];
                if (currentSection === 'files') {
                    data[currentSection] = [];
                } else {
                    data[currentSection] = {};
                }
                currentTile = null;
                continue;
            }

            // Tile definitions (name =)
            if (currentSection === 'tiles' && trimmed.match(/^[a-zA-Z_]+ =$/)) {
                currentTile = trimmed.replace(' =', '').trim();
                data[currentSection][currentTile] = {};
                continue;
            }

            // Key-value pairs (either tile properties or section properties)
            if (currentSection && trimmed.includes('=')) {
                const [key, ...valueParts] = trimmed.split('=');
                const value = valueParts.join('=').trim();
                const parsedValue = this.parseValue(value);

                if (currentTile && currentSection === 'tiles') {
                    // This is a property of the current tile
                    data[currentSection][currentTile][key.trim()] = parsedValue;
                } else if (currentSection === 'files') {
                    // Files section: collect file info
                    if (key.trim() === 'file') {
                        data[currentSection].push({file: parsedValue});
                    } else if (data[currentSection].length > 0) {
                        // Add properties to the last file
                        const lastFile = data[currentSection][data[currentSection].length - 1];
                        lastFile[key.trim()] = parsedValue;
                    }
                } else {
                    // This is a section property
                    data[currentSection][key.trim()] = parsedValue;
                }
            }
        }

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
        if (!this.tilespecData?.files) return;

        const loadPromises = this.tilespecData.files.map(async (fileInfo) => {
            if (!fileInfo.file) return;

            try {
                const image = new Image();
                const imagePath = `${this.tilesetPath}${fileInfo.file}`;

                await new Promise((resolve, reject) => {
                    image.onload = () => resolve();
                    image.onerror = () => {
                        // Create fallback colored tile if image fails to load
                        console.warn(`Failed to load ${fileInfo.file}, creating fallback tile`);
                        const fallbackCanvas = document.createElement('canvas');
                        fallbackCanvas.width = fileInfo.width || 64;
                        fallbackCanvas.height = fileInfo.height || 64;
                        const ctx = fallbackCanvas.getContext('2d');
                        
                        // Generate a simple colored pattern based on filename
                        const hash = fileInfo.file.split('').reduce((a, b) => {
                            a = ((a << 5) - a) + b.charCodeAt(0);
                            return a & a;
                        }, 0);
                        const hue = Math.abs(hash) % 360;
                        ctx.fillStyle = `hsl(${hue}, 50%, 50%)`;
                        ctx.fillRect(0, 0, fallbackCanvas.width, fallbackCanvas.height);
                        
                        // Convert canvas to image
                        const fallbackImage = new Image();
                        fallbackImage.src = fallbackCanvas.toDataURL();
                        resolve();
                        return;
                    };
                    image.src = imagePath;
                });

                this.tileImages.set(fileInfo.file, {
                    image: image,
                    width: fileInfo.width || this.tilespecData.tile_width || 64,
                    height: fileInfo.height || this.tilespecData.tile_height || 64
                });

            } catch (error) {
                console.warn(`Failed to load tile image ${fileInfo.file}:`, error);
                // Create a basic fallback tile
                this.createFallbackTile(fileInfo.file, fileInfo.width || 64, fileInfo.height || 64);
            }
        });

        await Promise.all(loadPromises);
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

        // Map Galaxy Game terrain to FreeCiv terrain
        const freecivTerrain = this.mapGalaxyToFreecivTerrain(terrainType);
        if (!freecivTerrain) return null;

        // Get tile definition
        const tilesSection = this.tilespecData?.tiles;
        if (!tilesSection) return null;

        const tileDef = tilesSection[freecivTerrain];
        if (!tileDef) return null;

        // Get image
        const imageData = this.tileImages.get(tileDef.file);
        if (!imageData) return null;

        return {
            image: imageData.image,
            x: tileDef.x || 0,
            y: tileDef.y || 0,
            width: imageData.width,
            height: imageData.height,
            terrainType: terrainType
        };
    }

    // Map Galaxy Game terrain types to FreeCiv terrain names
    mapGalaxyToFreecivTerrain(galaxyTerrain) {
        const mapping = {
            'arctic': 'arctic',
            'deep_sea': 'deep_ocean',
            'desert': 'desert',
            'forest': 'forest',
            'plains': 'plains',
            'grasslands': 'grassland',
            'boreal': 'tundra',  // boreal forest -> tundra
            'jungle': 'jungle',
            'ocean': 'ocean',
            'swamp': 'swamp',
            'tundra': 'tundra',
            'rock': 'mountains'  // rock -> mountains
        };

        return mapping[galaxyTerrain.toLowerCase()] || 'grassland';
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
            'deep_sea': 'ocean',
            'desert': 'desert',
            'forest': 'forest',
            'plains': 'plains',
            'grasslands': 'grassland',
            'boreal': 'tundra',
            'jungle': 'jungle',
            'ocean': 'ocean',
            'swamp': 'swamp',
            'tundra': 'tundra',
            'rock': 'mountains',
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