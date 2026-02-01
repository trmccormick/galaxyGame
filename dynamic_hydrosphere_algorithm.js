// Dynamic Hydrosphere Rendering Algorithm
// Calculates sea level from water volume and elevation map
// Enables realistic Mars terraforming with rising water levels

function renderDynamicHydrosphere(terrainMap) {
    const elevations = terrainMap.elevation;
    const waterVolume = terrainMap.water_volume;
    const seaLevel = calculateSeaLevel(elevations, waterVolume);

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const elevation = elevations[y][x];
            const isUnderwater = elevation < seaLevel;

            if (isUnderwater) {
                // Water tile - depth based on elevation difference
                const depth = seaLevel - elevation;
                renderWaterTile(x, y, depth);
            } else {
                // Land tile - render terrain
                renderTerrainTile(x, y, elevation);

                // Add biosphere if land is well above water
                if (terrainMap.biosphere && elevation > seaLevel + 0.05) {
                    renderBiosphereTile(x, y, terrainMap.biosphere);
                }
            }
        }
    }
}

function calculateSeaLevel(elevations, waterVolume) {
    const sortedElevations = elevations.flat().sort((a,b) => a-b);
    const totalTiles = sortedElevations.length;
    const waterTiles = Math.round(waterVolume * totalTiles);
    return sortedElevations[Math.max(0, waterTiles - 1)] || 0;
}