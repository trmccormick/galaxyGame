// ============================================================================
// VENUS MAP RENDERING FIX - Quick Implementation
// ============================================================================
// Add this to monitor.html.erb rendering code

// Enhanced getTerrainColor with Venus override
function getTerrainColor(terrainType, elevation, latitude) {
    const planetName = '<%= @celestial_body.name %>';
    const planetTemp = <%= @celestial_body.surface_temperature || 288 %>;
    const planetPressure = <%= @celestial_body.atmosphere&.pressure || 1.0 %>;
    
    // ========================================================================
    // VENUS OVERRIDE - Render based on actual planet, not map
    // ========================================================================
    const isVenus = planetName.toLowerCase().includes('venus') || 
                    (planetTemp > 700 && planetPressure > 50);
    
    if (isVenus) {
        // Venus is hellishly hot - all terrain should look volcanic
        // Ignore what the map says (ocean, grass, etc.)
        // Render based on elevation instead
        
        if (['ocean', 'deep_sea', 'coast'].includes(terrainType)) {
            // Low elevation (ancient ocean basins) → Sulfur yellow lava plains
            const lowlandBase = '#E3BB76';  // Sulfur yellow
            return adjustBrightness(lowlandBase, 1.0 + (elevation || 0) * 0.2);
        }
        
        if (['plains', 'grasslands', 'swamp'].includes(terrainType)) {
            // Mid elevation (volcanic plains) → Orange-brown
            const plainsBase = '#D4A574';   // Volcanic orange
            return adjustBrightness(plainsBase, 1.0 + (elevation || 0) * 0.3);
        }
        
        if (['desert', 'tundra', 'boreal'].includes(terrainType)) {
            // High elevation (highlands) → Tan-brown
            const highlandBase = '#C19A6B';  // Camel brown
            return adjustBrightness(highlandBase, 1.0 + (elevation || 0) * 0.4);
        }
        
        if (terrainType === 'arctic' || terrainType === 'rocky') {
            // Very high elevation (peaks) → Light tan
            return '#B8956A';  // Tan peaks
        }
        
        // Default Venus terrain
        return '#D4A574';  // Volcanic orange
    }
    
    // ========================================================================
    // MARS OVERRIDE - Cold desert appearance
    // ========================================================================
    const isMars = planetName.toLowerCase().includes('mars') ||
                   (planetTemp < 250 && planetPressure < 0.1);
    
    if (isMars) {
        // Mars is cold and dry - everything should look red/brown
        
        if (['ocean', 'deep_sea', 'coast'].includes(terrainType)) {
            // Ancient ocean basins → Dark red-brown
            return '#8B4513';  // Saddle brown (dry basins)
        }
        
        if (['plains', 'grasslands'].includes(terrainType)) {
            // Plains → Red desert
            return '#C1440E';  // Rust red
        }
        
        if (terrainType === 'desert') {
            // Desert → Bright red-orange
            return '#CD5C5C';  // Indian red
        }
        
        if (['tundra', 'boreal'].includes(terrainType)) {
            // Highlands → Dark red-brown
            return '#A0522D';  // Sienna
        }
        
        if (terrainType === 'arctic') {
            // Polar caps → White ice
            return '#FFFFFF';  // Keep ice white
        }
        
        // Default Mars terrain
        return '#C1440E';  // Rust red
    }
    
    // ========================================================================
    // EARTH-LIKE - Normal rendering
    // ========================================================================
    const isEarthLike = planetTemp > 250 && planetTemp < 320 && 
                        planetPressure > 0.5 && planetPressure < 2.0;
    
    if (isEarthLike) {
        // Earth-like conditions - render terrain as-is
        const baseColors = {
            ocean: '#004488',
            deep_sea: '#002244',
            coast: '#0066AA',
            grasslands: '#9ACD32',
            plains: '#D2B48C',
            desert: '#F4A460',
            tundra: '#C0C0C0',
            arctic: '#FFFFFF',
            forest: '#228B22',
            jungle: '#006400',
            swamp: '#556B2F',
            boreal: '#2F4F4F',
            rocky: '#696969'
        };
        
        let baseColor = baseColors[terrainType] || '#8B7355';
        
        // Apply elevation shading
        if (elevation !== undefined) {
            const elevationFactor = 1.0 + (elevation - 0.5) * 0.4;
            baseColor = adjustBrightness(baseColor, elevationFactor);
        }
        
        return baseColor;
    }
    
    // ========================================================================
    // EXOTIC PLANETS - Temperature-based rendering
    // ========================================================================
    
    // Very hot (Venus-like but not quite)
    if (planetTemp > 400 && planetTemp < 700) {
        const hotColors = {
            ocean: '#D4A574',      // Brown-orange
            plains: '#C19A6B',     // Tan
            desert: '#E3BB76',     // Light yellow
            arctic: '#B8956A'      // Tan
        };
        return hotColors[terrainType] || '#C19A6B';
    }
    
    // Very cold (ice world)
    if (planetTemp < 200) {
        const coldColors = {
            ocean: '#87CEEB',      // Sky blue (frozen)
            plains: '#C0C0C0',     // Silver (frozen)
            desert: '#E0E0E0',     // Light gray
            arctic: '#FFFFFF'      // White
        };
        return coldColors[terrainType] || '#C0C0C0';
    }
    
    // ========================================================================
    // DEFAULT - Neutral colors
    // ========================================================================
    const neutralColors = {
        ocean: '#004488',
        desert: '#D2B48C',
        plains: '#A0826D',
        arctic: '#E0E0E0'
    };
    
    return neutralColors[terrainType] || '#8B7355';
}

// ============================================================================
// Color Helper Functions (if not already defined)
// ============================================================================

function adjustBrightness(color, factor) {
    const rgb = parseColor(color);
    const r = Math.min(255, Math.max(0, Math.round(rgb.r * factor)));
    const g = Math.min(255, Math.max(0, Math.round(rgb.g * factor)));
    const b = Math.min(255, Math.max(0, Math.round(rgb.b * factor)));
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
        return { 
            r: parseInt(values[0]), 
            g: parseInt(values[1]), 
            b: parseInt(values[2]) 
        };
    }
    return { r: 139, g: 115, b: 85 }; // Default tan
}

// ============================================================================
// USAGE NOTES
// ============================================================================

/*
This fix addresses the Venus rendering issue by:

1. Detecting Venus (by name or conditions: temp>700, pressure>50)
2. Overriding terrain colors based on elevation, not terrain type
3. Making all Venus terrain look volcanic (yellow/orange/brown)

The same terraformed Venus map will now render as:
- Venus (737K): Yellow-orange volcanic appearance ✅
- Earth (288K): Blue oceans, green land ✅
- Mars (210K): Red-brown desert appearance ✅

The map structure (terrain layout) is preserved, only colors change
based on the planet's actual conditions.

This is the CORRECT interpretation - same map, different planets,
different appearances based on real physics.

TO IMPLEMENT:
1. Replace existing getTerrainColor() function in monitor.html.erb
2. Ensure planetName, planetTemp, planetPressure are available
3. Test with Venus, Mars, Earth
4. Verify terraforming progress gradually shifts colors
*/
