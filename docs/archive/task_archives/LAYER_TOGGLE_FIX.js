// ============================================================================
// CORRECTED LAYER SYSTEM - SimEarth Style Additive Overlays
// ============================================================================

// Layer visibility state - terrain ALWAYS visible as geological base
let visibleLayers = new Set(['terrain']); // Terrain is permanent lithosphere base

/**
 * Toggle layer visibility (ADDITIVE overlays, not exclusive modes)
 * SimEarth Behavior: Multiple layers can be active simultaneously
 */
function toggleLayer(layerName) {
    if (layerName === 'terrain') {
        // Terrain is the geological base (lithosphere) - cannot be turned off
        // Clicking it resets view to bare planet (removes all overlays)
        visibleLayers.clear();
        visibleLayers.add('terrain');
        logConsole('Reset to base terrain (bare planet lithosphere)', 'info');
    } else {
        // All other layers are ADDITIVE overlays on the base terrain
        if (visibleLayers.has(layerName)) {
            // Remove this overlay
            visibleLayers.delete(layerName);
            logConsole(`${layerName} overlay hidden`, 'info');
        } else {
            // Add this overlay (terrain stays visible underneath)
            visibleLayers.add(layerName);
            logConsole(`${layerName} overlay shown`, 'info');
        }
    }
    
    renderTerrainMap(); // Re-render with new layer configuration
    updateLayerButtons();
}

/**
 * Update button active states
 * Buttons show active when their layer is visible
 */
function updateLayerButtons() {
    document.querySelectorAll('.layer-btn').forEach(btn => {
        const layer = btn.dataset.layer;
        if (visibleLayers.has(layer)) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });
}

/**
 * Get base terrain color (bare planet lithosphere)
 * This is always rendered first, then overlays are applied
 */
function getTerrainColor(terrainType, elevation, latitude) {
    const isMars = planetName.toLowerCase().includes('mars');
    const isVenus = planetName.toLowerCase().includes('venus');
    const isLuna = planetName.toLowerCase().includes('luna') || planetName.toLowerCase().includes('moon');
    
    // Base terrain colors (bare planet - geological foundation)
    const baseColors = {
        desert: isMars ? '#C1440E' : '#F4A460',      // Mars: red-orange, Earth: sandy
        rocky: isMars ? '#8B4513' : '#696969',       // Mars: dark red-brown, Earth: gray
        arctic: '#FFFFFF',                            // Ice/snow caps
        ocean: '#004488',                             // Deep blue water
        deep_sea: '#002244',                          // Very deep blue
        plains: isMars ? '#B85C3E' : '#D2B48C',      // Mars: red-tan, Earth: tan
        tundra: '#C0C0C0',                            // Gray-white frozen ground
        grasslands: isMars ? '#A0522D' : '#9ACD32',  // Mars: sienna (bare), Earth: yellow-green
        forest: '#556B2F',                            // Dark olive (minimal on bare planet)
        jungle: '#3B5323',                            // Very dark green (minimal on bare planet)
        swamp: '#708090',                             // Slate gray wetlands
        boreal: '#696969'                             // Gray forested hills
    };
    
    let baseColor = baseColors[terrainType] || '#4A3C28'; // Default dark brown
    
    // Apply elevation-based shading (SimEarth style)
    // Lower elevation = darker, higher elevation = lighter
    if (elevation !== undefined) {
        const elevationFactor = 1.0 + (elevation - 0.5) * 0.4; // ±20% brightness
        baseColor = adjustBrightness(baseColor, elevationFactor);
    }
    
    // Apply planetary color filters
    if (isMars) {
        baseColor = applyRedTint(baseColor, 0.3);
    } else if (isVenus) {
        baseColor = applyYellowTint(baseColor, 0.2);
    } else if (isLuna) {
        baseColor = desaturate(baseColor, 0.8);
    }
    
    return baseColor;
}

/**
 * Main rendering function with proper layer compositing
 */
function renderTerrainMap() {
    const canvas = document.getElementById('planetCanvas');
    if (!canvas) {
        console.error('Canvas not found');
        return;
    }

    const ctx = canvas.getContext('2d');

    // Load terrain data (supports both old and new schema)
    const currentState = terrainData.current_state || terrainData; // Bare planet
    const bioDensity = terrainData.biosphere?.bio_density || null; // Vegetation overlay
    const grid = currentState.grid;
    const width = currentState.width || grid[0]?.length || 0;
    const height = currentState.height || grid.length;

    if (width === 0 || height === 0) {
        console.error('Invalid terrain dimensions');
        return;
    }

    // Set canvas size
    const tileSize = 8;
    canvas.width = width * tileSize;
    canvas.height = height * tileSize;

    // Render each tile with layer compositing
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const terrainType = grid[y][x];
            const latitude = (y / height - 0.5) * 180; // -90 to +90
            const elevation = calculateElevation(terrainType, latitude, planetTemp, planetPressure);
            
            // ========================================================================
            // STEP 1: Render base terrain (lithosphere - ALWAYS visible)
            // ========================================================================
            let finalColor = getTerrainColor(terrainType, elevation, latitude);
            
            // ========================================================================
            // STEP 2: Apply layer overlays (additive, in order)
            // ========================================================================
            
            // Water layer overlay (blue highlights on water/ice)
            if (visibleLayers.has('water')) {
                if (['ocean', 'deep_sea'].includes(terrainType)) {
                    const waterColor = layerOverlays.water.terrainColors[terrainType];
                    finalColor = blendColors(finalColor, waterColor, 0.7);
                } else if (terrainType === 'arctic') {
                    finalColor = blendColors(finalColor, '#00FFFF', 0.4); // Cyan ice highlight
                }
            }
            
            // Biomes layer overlay (green vegetation gradient based on bio_density)
            if (visibleLayers.has('biomes')) {
                if (bioDensity && bioDensity[y] && bioDensity[y][x] !== undefined) {
                    const density = bioDensity[y][x];
                    if (density > 0) {
                        // Vegetation color based on density
                        const greenValue = Math.floor(255 * Math.min(density, 1.0));
                        const vegColor = `rgb(0, ${greenValue}, 0)`;
                        finalColor = blendColors(finalColor, vegColor, density * 0.6);
                    }
                } else if (['forest', 'jungle', 'grasslands', 'plains', 'swamp', 'boreal'].includes(terrainType)) {
                    // Fallback: use terrain-specific biome colors if no bio_density data
                    const biomeColor = layerOverlays.biomes.terrainColors[terrainType];
                    if (biomeColor) {
                        const color = typeof biomeColor === 'function' ? biomeColor(latitude) : biomeColor;
                        finalColor = blendColors(finalColor, color, 0.5);
                    }
                }
            }
            
            // Features layer overlay (geological highlights)
            if (visibleLayers.has('features')) {
                if (['rocky', 'boreal'].includes(terrainType)) {
                    const featureColor = layerOverlays.features.terrainColors[terrainType] || '#696969';
                    finalColor = blendColors(finalColor, featureColor, 0.5);
                }
            }
            
            // Temperature layer overlay (SimEarth red/blue thermal)
            if (visibleLayers.has('temperature')) {
                const tempColor = layerOverlays.temperature.getOverlayColor(
                    latitude, elevation, planetTemp, planetPressure
                );
                finalColor = blendColors(finalColor, tempColor, 0.35);
            }
            
            // Rainfall layer overlay (blue wetness gradient)
            if (visibleLayers.has('rainfall')) {
                const rainfallColors = layerOverlays.rainfall.terrainColors;
                if (rainfallColors[terrainType]) {
                    finalColor = blendColors(finalColor, rainfallColors[terrainType], 0.4);
                }
            }
            
            // Resources layer overlay (gold mineral highlights)
            if (visibleLayers.has('resources')) {
                if (['rocky', 'arctic', 'desert'].includes(terrainType)) {
                    const resourceColor = '#FFD700'; // Gold
                    finalColor = blendColors(finalColor, resourceColor, 0.3);
                }
            }
            
            // ========================================================================
            // STEP 3: Render composited tile
            // ========================================================================
            ctx.fillStyle = finalColor;
            ctx.fillRect(x * tileSize, y * tileSize, tileSize, tileSize);

            // Optional: subtle grid lines
            ctx.strokeStyle = 'rgba(0, 0, 0, 0.1)';
            ctx.lineWidth = 0.5;
            ctx.strokeRect(x * tileSize, y * tileSize, tileSize, tileSize);
        }
    }

    const uniqueTerrains = grid.flat().filter((v, i, a) => a.indexOf(v) === i);
    console.log(`Rendered ${width}x${height} terrain map`);
    console.log('Active layers:', Array.from(visibleLayers).join(', '));
    console.log('Terrain types:', uniqueTerrains.join(', '));
    logConsole(`Map rendered: ${width}x${height}, Layers: ${Array.from(visibleLayers).join(', ')}`, 'success');
}

// ============================================================================
// Helper Functions
// ============================================================================

function blendColors(color1, color2, alpha) {
    // Parse RGB values
    const rgb1 = parseColor(color1);
    const rgb2 = parseColor(color2);
    
    // Blend with alpha
    const r = Math.round(rgb1.r * (1 - alpha) + rgb2.r * alpha);
    const g = Math.round(rgb1.g * (1 - alpha) + rgb2.g * alpha);
    const b = Math.round(rgb1.b * (1 - alpha) + rgb2.b * alpha);
    
    return `rgb(${r}, ${g}, ${b})`;
}

function parseColor(color) {
    if (color.startsWith('#')) {
        const hex = color.slice(1);
        return {
            r: parseInt(hex.slice(0, 2), 16),
            g: parseInt(hex.slice(2, 4), 16),
            b: parseInt(hex.slice(4, 6), 16)
        };
    } else if (color.startsWith('rgb')) {
        const values = color.match(/\d+/g);
        return { r: parseInt(values[0]), g: parseInt(values[1]), b: parseInt(values[2]) };
    }
    return { r: 0, g: 0, b: 0 };
}

function adjustBrightness(color, factor) {
    const rgb = parseColor(color);
    const r = Math.min(255, Math.max(0, Math.round(rgb.r * factor)));
    const g = Math.min(255, Math.max(0, Math.round(rgb.g * factor)));
    const b = Math.min(255, Math.max(0, Math.round(rgb.b * factor)));
    return `rgb(${r}, ${g}, ${b})`;
}

function applyRedTint(color, amount) {
    const rgb = parseColor(color);
    const r = Math.min(255, Math.round(rgb.r + (255 - rgb.r) * amount));
    const g = Math.max(0, Math.round(rgb.g * (1 - amount * 0.3)));
    const b = Math.max(0, Math.round(rgb.b * (1 - amount * 0.5)));
    return `rgb(${r}, ${g}, ${b})`;
}

function applyYellowTint(color, amount) {
    const rgb = parseColor(color);
    const r = Math.min(255, Math.round(rgb.r + (255 - rgb.r) * amount));
    const g = Math.min(255, Math.round(rgb.g + (255 - rgb.g) * amount * 0.8));
    const b = Math.max(0, Math.round(rgb.b * (1 - amount * 0.4)));
    return `rgb(${r}, ${g}, ${b})`;
}

function desaturate(color, amount) {
    const rgb = parseColor(color);
    const gray = Math.round(rgb.r * 0.299 + rgb.g * 0.587 + rgb.b * 0.114);
    const r = Math.round(rgb.r + (gray - rgb.r) * amount);
    const g = Math.round(rgb.g + (gray - rgb.g) * amount);
    const b = Math.round(rgb.b + (gray - rgb.b) * amount);
    return `rgb(${r}, ${g}, ${b})`;
}
