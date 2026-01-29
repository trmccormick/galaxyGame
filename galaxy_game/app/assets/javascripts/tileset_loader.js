// app/assets/javascripts/tileset_loader.js
if (typeof TilesetLoader !== 'undefined') {
    console.log('TilesetLoader already loaded, skipping...');
} else {

// app/assets/javascripts/tileset_loader.js
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

        const lines = content.split('\n');

        for (const line of lines) {
            const trimmed = line.trim();

            // Skip comments and empty lines
            if (trimmed.startsWith('#') || trimmed === '') continue;

            // Section headers
            const sectionMatch = trimmed.match(/^\[([^\]]+)\]$/);
            if (sectionMatch) {
                currentSection = sectionMatch[1];
                data[currentSection] = {};
                continue;
            }

            // Key-value pairs
            if (currentSection && trimmed.includes('=')) {
                const [key, ...valueParts] = trimmed.split('=');
                const value = valueParts.join('=').trim();
                data[currentSection][key.trim()] = this.parseValue(value);
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

} // End of TilesetLoader guard