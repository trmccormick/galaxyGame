/**
 * Admin Monitor - Planetary Visualization Module
 * 
 * SimEarth-style planetary monitor with layered terrain rendering.
 * Extracted from inline ERB for proper separation of concerns.
 * 
 * Data is injected via #monitor-data JSON element in the view.
 */

// Namespace to avoid global pollution
window.AdminMonitor = (function() {
  'use strict';

  // Module state
  let planetId = null;
  let planetName = '';
  let planetType = '';
  let updateInterval = null;
  let climate = null;
  let planetData = null;
  let terrainData = null;
  let layers = {};
  let visibleLayers = new Set(['terrain']);

  // Layer overlay colors (complete replacement with terrain-specific shades)
  const layerOverlays = {
    water: {
      terrainColors: {
        'coast': '#87CEEB',
        'ocean': '#1e3a8a',
        'deep_sea': '#000080'
      }
    },
    biomes: {
      terrainColors: {
        'forest': '#228B22',
        'jungle': '#006400',
        'grasslands': '#32CD32',
        'plains': '#FFFF00',
        'swamp': '#808000',
        'boreal': '#228B22',
        'arctic': '#ffffff',
        'desert': function(lat, climate) {
          const absLat = Math.abs(lat);
          if (absLat > climate.iceLatitude + 20) {
            return '#ffeedd';
          } else {
            return '#ffdd44';
          }
        }
      }
    },
    features: {
      // Geological features - mountains, hills, volcanic
      terrainColors: {
        'mountains': '#505050',
        'mountain': '#505050',
        'polar_mountains': '#a0a0a0',
        'tropical_mountains': '#606060',
        'hills': '#707050',
        'peaks': '#c0c0c0',
        'rock': '#696969',
        'volcanic': '#8b0000',
        'lava': '#ff4400'
      },
      // Helper function to check if biome is a geological feature
      isFeature: function(biome) {
        if (!biome) return false;
        return biome.includes('mountain') || biome.includes('hill') || 
               biome.includes('peak') || biome.includes('volcanic') ||
               biome === 'rock' || biome === 'lava';
      }
    },
    temperature: {
      getOverlayColor: function(latitude, elevation, globalTemp, pressure) {
        const absLat = Math.abs(latitude);
        let baseTemp;
        // Latitude-based temperature (equator hot, poles cold)
        if (absLat < 30) {
          baseTemp = globalTemp - 273.15 + 20 - (absLat / 30) * 10;
        } else if (absLat < 60) {
          baseTemp = globalTemp - 273.15 - ((absLat - 30) / 30) * 20;
        } else {
          baseTemp = globalTemp - 273.15 - 20 - ((absLat - 60) / 30) * 30;
        }
        // Elevation cooling: ~6.5°C per 1000m (lapse rate)
        // elevation is normalized 0-1, assume max elevation ~8000m
        const elevationMeters = elevation * 8000;
        const elevationCooling = (elevationMeters / 1000) * 6.5;
        const elevationTemp = baseTemp - elevationCooling;
        // Pressure effect (thin atmosphere = cooler)
        const pressureTemp = elevationTemp * (0.5 + Math.min(pressure, 1.0) * 0.5);
        
        // Smoother color gradient
        if (pressureTemp > 35) return '#ff0000';      // Hot red
        else if (pressureTemp > 25) return '#ff4400'; // Warm orange-red
        else if (pressureTemp > 15) return '#ff8800'; // Orange
        else if (pressureTemp > 5) return '#ffcc00';  // Warm yellow
        else if (pressureTemp > -5) return '#88cc44'; // Temperate green
        else if (pressureTemp > -15) return '#44aaff';// Cool blue
        else if (pressureTemp > -30) return '#2288ff';// Cold blue
        else return '#0066cc';                        // Frigid deep blue
      },
      terrainColors: {}
    },
    rainfall: {
      terrainColors: {
        // High rainfall (blues)
        'tropical_rainforest': '#0033ff',
        'jungle': '#0044ff',
        'swamp': '#0055ff',
        'tropical_seasonal_forest': '#0066ff',
        // Medium-high rainfall
        'temperate_forest': '#2288ff',
        'temperate_rainforest': '#1166ff',
        'boreal_forest': '#4499ff',
        'forest': '#3388ff',
        'boreal': '#55aaff',
        // Medium rainfall
        'temperate_grassland': '#66bbff',
        'grassland': '#77ccff',
        'grasslands': '#77ccff',
        'tropical_grassland': '#88ddff',
        'plains': '#99eeff',
        // Low rainfall
        'tundra': '#aaddcc',
        'polar_desert': '#ffee88',
        'desert': '#ffcc00',
        // Ocean (high water but not rainfall)
        'ocean': '#004488',
        'coast': '#006699'
      }
    },
    resources: {
      terrainColors: {
        'rock': '#ffd700',
        'desert': '#daa520'
      }
    }
  };

  // Color map for terrain types
  const colors = {
    ocean: '#0066cc',
    deep_sea: '#003366',
    arctic: '#e8e8e8',
    tundra: '#b8b8b8',
    grasslands: '#90EE90',
    plains: '#F0E68C',
    forest: '#228B22',
    jungle: '#006400',
    desert: '#F4A460',
    mountains: '#696969',
    rock: '#808080',
    rocky: '#808080',
    boreal: '#228B22',
    swamp: '#556B2F'
  };

  // ============================================
  // Utility Functions
  // ============================================

  function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }

  function blendColors(baseColor, overlayColor, alpha) {
    const base = hexToRgb(baseColor);
    const overlay = hexToRgb(overlayColor);
    
    if (!base || !overlay) return baseColor;
    
    const r = Math.round(base.r * (1 - alpha) + overlay.r * alpha);
    const g = Math.round(base.g * (1 - alpha) + overlay.g * alpha);
    const b = Math.round(base.b * (1 - alpha) + overlay.b * alpha);
    
    return '#' + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0');
  }

  function formatMass(mass) {
    if (mass > 1e18) return `${(mass / 1e18).toFixed(2)} Eg`;
    if (mass > 1e15) return `${(mass / 1e15).toFixed(2)} Pg`;
    if (mass > 1e12) return `${(mass / 1e12).toFixed(2)} Tg`;
    if (mass > 1e9) return `${(mass / 1e9).toFixed(2)} Gg`;
    return `${mass.toFixed(2)} kg`;
  }

  // ============================================
  // Climate Calculations (TerraSim-style)
  // ============================================

  function calculateClimateZones(tempK, pressureBar) {
    const Ts = tempK;
    const Tp = Ts - 75 / (1 + 5 * pressureBar);
    const Tt = Ts * 1.1;
    
    let iceLat = 0;
    let habRatio = 0;
    
    if (Tt > 273 && Tp < 273) {
      habRatio = Math.pow((Tt - 273) / (Tt - Tp), 0.666667);
      iceLat = Math.asin(habRatio) * 180 / Math.PI;
    } else if (Tt < 273) {
      habRatio = 0;
      iceLat = 90;
    } else {
      habRatio = 1;
      iceLat = 0;
    }
    
    return {
      surfaceTemp: Ts,
      polarTemp: Tp,
      tropicalTemp: Tt,
      iceLatitude: iceLat,
      habitableRatio: habRatio,
      polarZone: iceLat,
      temperateZone: Math.max(iceLat + 30, 45),
      tropicalZone: Math.max(iceLat + 60, 75)
    };
  }

  // ============================================
  // Color Classification Functions
  // ============================================

  function getTerrainColorScheme(pData) {
    const type = pData.type;
    const atmosphere = pData.atmosphere;
    const surfaceTemp = pData.surface_temperature || pData.temperature || 288;
    const geologicalActivity = pData.geological_activity || pData.geosphere_attributes?.geological_activity || 50;
    const gravity = pData.gravity || 1.0;
    const name = (pData.name || '').toLowerCase();
    
    // Red/Black (lava worlds)
    if (surfaceTemp > 700 && geologicalActivity > 80) {
      return { low: '#1a0000', high: '#ff4500' };
    }
    
    // Orange (Venus-like)
    if (atmosphere && atmosphere.pressure > 10 && surfaceTemp > 400) {
      return { low: '#8b4513', high: '#ffa500' };
    }
    
    // Rust (Mars-like)
    if (name === 'mars' || 
        (atmosphere && atmosphere.pressure > 0.001 && atmosphere.pressure < 0.1 && 
         surfaceTemp < 280 && surfaceTemp > 150 && gravity > 2 && gravity < 5)) {
      return { low: '#4a2810', high: '#cd5c3c' };
    }
    
    // Grey (truly airless)
    if ((atmosphere && atmosphere.pressure < 0.001) || 
        (!atmosphere) ||
        gravity < 0.3 || 
        type?.includes('moon') || 
        type?.includes('asteroid') || 
        type?.includes('dwarf_planet') ||
        name === 'luna' || name === 'moon' || name === 'mercury') {
      return { low: '#4a4a4a', high: '#d0d0d0' };
    }
    
    // Dark Grey (carbon worlds)
    if (type?.includes('carbon') || pData.crust_composition?.elements?.C > 25) {
      return { low: '#2f2f2f', high: '#696969' };
    }
    
    // Brown (Earth-like default)
    return { low: '#2d1810', high: '#d2b48c' };
  }

  function getElevationColor(normalizedElevation, pData) {
    if (normalizedElevation === null || normalizedElevation === undefined) {
      return '#000000';
    }
    
    const colorScheme = getTerrainColorScheme(pData);
    const lowRgb = hexToRgb(colorScheme.low);
    const highRgb = hexToRgb(colorScheme.high);
    
    if (!lowRgb || !highRgb) return '#808080';
    
    const r = Math.round(lowRgb.r + (highRgb.r - lowRgb.r) * normalizedElevation);
    const g = Math.round(lowRgb.g + (highRgb.g - lowRgb.g) * normalizedElevation);
    const b = Math.round(lowRgb.b + (highRgb.b - lowRgb.b) * normalizedElevation);
    
    return `rgb(${r}, ${g}, ${b})`;
  }

  function getBiomeColor(biome) {
    // Comprehensive biome color mapping for NASA + FreeCiv canonical names
    const biomeColors = {
      // Deserts (arid)
      'desert': '#DAA520',
      'polar_desert': '#E8DCC8',
      'hot_desert': '#F4A460',
      
      // Grasslands
      'grassland': '#7CCD7C',
      'grasslands': '#7CCD7C',
      'temperate_grassland': '#90EE90',
      'tropical_grassland': '#98FB98',
      'savanna': '#9ACD32',
      
      // Forests
      'forest': '#228B22',
      'temperate_forest': '#228B22',
      'tropical_seasonal_forest': '#006400',
      'tropical_rainforest': '#004000',
      'boreal_forest': '#2E8B57',
      'boreal': '#2E8B57',
      'jungle': '#004400',
      'temperate_rainforest': '#006633',
      
      // Cold biomes
      'tundra': '#B8C4C8',
      'arctic': '#E8E8E8',
      'ice': '#FFFFFF',
      'polar_ice': '#F0FFFF',
      
      // Wetlands
      'swamp': '#556B2F',
      'marsh': '#6B8E23',
      'wetland': '#698B69',
      
      // Plains/steppe
      'plains': '#C4B454',
      'steppe': '#BDB76B',
      
      // Mountains/hills (terrain features rendered as biomes)
      'mountains': '#696969',
      'mountain': '#696969',
      'polar_mountains': '#A9A9A9',
      'tropical_mountains': '#505050',
      'hills': '#8B7355',
      'peaks': '#D3D3D3',
      
      // Volcanic
      'volcanic': '#8B0000',
      'lava': '#FF4500',
      
      // Water (shouldn't typically be rendered as biome)
      'ocean': '#0066cc',
      'coast': '#4682B4',
      'deep_sea': '#003366'
    };
    
    if (biome && biomeColors[biome]) {
      return biomeColors[biome];
    }
    
    // Fallback: try to match partial biome names
    if (biome) {
      if (biome.includes('desert')) return '#DAA520';
      if (biome.includes('forest')) return '#228B22';
      if (biome.includes('grass')) return '#7CCD7C';
      if (biome.includes('tundra')) return '#B8C4C8';
      if (biome.includes('mountain')) return '#696969';
      if (biome.includes('jungle') || biome.includes('rain')) return '#004400';
    }
    
    return '#8B4513'; // Default brown for unknown biomes
  }

  /**
   * Get hydrosphere color based on liquid composition and depth
   * Shallow water = light cyan/turquoise, Deep water = dark blue
   * Mars = ice caps, Titan = orange methane, Earth = blue water
   */
  function getHydrosphereColor(waterDepth, pData) {
    const name = (pData.name || '').toLowerCase();
    const liquid = (pData.liquid_name || 'H2O').toUpperCase();
    const temp = pData.surface_temperature || pData.temperature || 288;
    
    // Normalize depth: 0-200m = shallow, 200-2000m = mid, 2000m+ = deep
    // waterDepth is in meters (difference between sea level and ocean floor)
    const shallowThreshold = 200;
    const deepThreshold = 4000;
    
    // Mars - ice caps (frozen H2O/CO2)
    if (name === 'mars' || name.includes('mars')) {
      const intensity = Math.min(1, waterDepth / 1000);
      const iceValue = Math.round(200 + intensity * 55);
      return `rgba(${iceValue}, ${iceValue}, 255, 0.85)`;
    }
    
    // Titan - methane/ethane lakes (orange)
    if (name === 'titan' || liquid === 'CH4' || liquid === 'C2H6' || 
        liquid.includes('METHANE') || liquid.includes('ETHANE')) {
      const intensity = Math.min(1, waterDepth / 500);
      const r = Math.round(180 + intensity * 75);
      const g = Math.round(80 + intensity * 40);
      return `rgba(${r}, ${g}, 0, 0.8)`;
    }
    
    // Europa/Enceladus - subsurface ocean (pale blue-white ice)
    if (name === 'europa' || name === 'enceladus') {
      const intensity = Math.min(1, waterDepth / 1000);
      const iceBlue = Math.round(220 + intensity * 35);
      return `rgba(${iceBlue}, ${iceBlue}, 255, 0.7)`;
    }
    
    // Nitrogen ice (Pluto/Triton)
    if (liquid === 'N2' || name === 'pluto' || name === 'triton') {
      const intensity = Math.min(1, waterDepth / 500);
      const r = Math.round(230 + intensity * 25);
      const g = Math.round(200 + intensity * 30);
      const b = Math.round(200 + intensity * 30);
      return `rgba(${r}, ${g}, ${b}, 0.75)`;
    }
    
    // Default: H2O water (Earth-like)
    // Shallow = light cyan/turquoise, Deep = dark navy blue
    if (waterDepth < shallowThreshold) {
      // Shallow water: light cyan to medium blue
      // 0m = rgb(100, 200, 255) light cyan
      // 200m = rgb(50, 150, 220) medium blue
      const t = waterDepth / shallowThreshold;
      const r = Math.round(100 - t * 50);
      const g = Math.round(200 - t * 50);
      const b = Math.round(255 - t * 35);
      return `rgba(${r}, ${g}, ${b}, 0.85)`;
    } else if (waterDepth < deepThreshold) {
      // Mid-depth: medium blue to dark blue
      // 200m = rgb(50, 150, 220)
      // 4000m = rgb(0, 50, 150) dark blue
      const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
      const r = Math.round(50 - t * 50);
      const g = Math.round(150 - t * 100);
      const b = Math.round(220 - t * 70);
      return `rgba(${r}, ${g}, ${b}, 0.9)`;
    } else {
      // Deep ocean: dark navy blue
      // 4000m+ = rgb(0, 20, 100) to rgb(0, 10, 80)
      const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
      const g = Math.round(20 - t * 10);
      const b = Math.round(100 - t * 20);
      return `rgba(0, ${g}, ${b}, 0.95)`;
    }
  }

  // ============================================
  // Atmospheric Analysis
  // ============================================

  function analyzeAtmosphericConditions(temperature, pressure, composition) {
    let hasAtmosphere = false;
    let isHabitable = false;
    let dominantGas = 'none';
    let visualEffects = {
      haze: 0,
      colorTint: null,
      aurora: false
    };

    if (pressure > 0.01) {
      hasAtmosphere = true;

      if (composition && typeof composition === 'object') {
        let maxPercentage = 0;
        let dominantGasKey = null;

        Object.keys(composition).forEach(gas => {
          const gasData = composition[gas];
          const percentage = gasData.percentage || gasData;
          if (percentage > maxPercentage) {
            maxPercentage = percentage;
            dominantGasKey = gas;
          }
        });

        if (dominantGasKey) {
          dominantGas = dominantGasKey;

          if (dominantGasKey === 'CO2') {
            visualEffects.haze = 0.8;
            visualEffects.colorTint = '#ffaaaa';
          } else if (dominantGasKey === 'N2' && composition['O2']) {
            const oxygenPercent = composition['O2'].percentage || composition['O2'];
            if (oxygenPercent >= 19.5 && oxygenPercent <= 23.5) {
              isHabitable = true;
              visualEffects.haze = 0.1;
            }
          } else if (dominantGasKey === 'CH4') {
            visualEffects.haze = 0.6;
            visualEffects.colorTint = '#ffffaa';
          }
        }
      }

      if (temperature < 273) {
        visualEffects.haze += 0.2;
      } else if (temperature > 400) {
        visualEffects.haze += 0.3;
      }

      if (pressure > 5) {
        visualEffects.haze += 0.4;
      }

      visualEffects.haze = Math.max(0, Math.min(1, visualEffects.haze));

      if (hasAtmosphere && temperature > 200 && pressure > 0.1) {
        visualEffects.aurora = true;
      }
    }

    return {
      hasAtmosphere,
      isHabitable,
      dominantGas,
      visualEffects,
      temperature,
      pressure,
      composition
    };
  }

  // ============================================
  // Water Layer Calculation (Bathtub Model)
  // ============================================

  function calculateWaterLayerFromHydrosphere(waterCoveragePercent, elevationLayer) {
    if (!elevationLayer || !elevationLayer.grid) {
      return null;
    }

    const width = elevationLayer.width;
    const height = elevationLayer.height;
    const elevationGrid = elevationLayer.grid;

    let waterCoverage = waterCoveragePercent || 0;
    if (waterCoverage > 1) {
      waterCoverage = waterCoverage / 100;
    }

    // No water if coverage is 0 or less
    if (waterCoverage <= 0) {
      return null;
    }

    // Check if we have real elevation data (with negative values for ocean)
    // NASA ETOPO data has negative elevations for ocean, positive for land
    const allElevations = [];
    let hasNegativeElevations = false;
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const elev = elevationGrid[y][x];
        if (elev !== null && elev !== undefined) {
          allElevations.push(elev);
          if (elev < 0) hasNegativeElevations = true;
        }
      }
    }

    let seaLevel = 0;
    
    if (hasNegativeElevations) {
      // Real elevation data (NASA ETOPO style): sea level is 0m
      // Negative elevations = underwater, positive = land
      seaLevel = 0;
      console.log('Using real elevation data: sea level = 0m');
    } else {
      // Normalized/synthetic data: use bathtub algorithm
      // Sort elevations and find the level that covers the desired percentage
      allElevations.sort((a, b) => a - b);
      const seaLevelIndex = Math.floor(allElevations.length * waterCoverage);
      seaLevel = allElevations[Math.min(seaLevelIndex, allElevations.length - 1)];
      console.log(`Using bathtub algorithm: sea level = ${seaLevel} for ${(waterCoverage*100).toFixed(1)}% coverage`);
    }

    const waterGrid = [];
    for (let y = 0; y < height; y++) {
      waterGrid[y] = [];
      for (let x = 0; x < width; x++) {
        const elevation = elevationGrid[y][x];
        if (elevation !== null && elevation !== undefined && elevation < seaLevel) {
          // Water depth is difference between sea level and ocean floor
          waterGrid[y][x] = seaLevel - elevation;
        } else {
          waterGrid[y][x] = 0;  // Land - no water
        }
      }
    }

    return {
      grid: waterGrid,
      width: width,
      height: height,
      layer_type: 'water',
      sea_level: seaLevel,
      water_coverage: waterCoverage
    };
  }

  // ============================================
  // Elevation Calculation
  // ============================================

  function calculateElevation(terrainType, latitude, temperature, pressure, x, y) {
    if (layers.elevation && layers.elevation.grid && 
        layers.elevation.grid[y] && layers.elevation.grid[y][x] !== undefined) {
      const elevationValue = layers.elevation.grid[y][x];
      return Math.max(0, Math.min(1, elevationValue));
    }
    
    const baseElevations = {
      ocean: 0.0,
      deep_sea: -0.1,
      arctic: 0.1,
      tundra: 0.2,
      grasslands: 0.3,
      plains: 0.4,
      forest: 0.5,
      jungle: 0.5,
      desert: 0.4,
      mountains: 0.9,
      rock: 0.7,
      boreal: 0.6,
      swamp: 0.1
    };
    
    let elevation = baseElevations[terrainType] || 0.5;
    elevation += (pressure - 1.0) * 0.1;
    
    const tempOffset = (temperature - 288) / 200;
    elevation += tempOffset * 0.2;
    
    const latFactor = Math.abs(latitude) / 90;
    const polarVariation = Math.sin(latitude * Math.PI / 180 * 4) * 0.2;
    elevation += latFactor * 0.05 + polarVariation;
    
    return Math.max(0, Math.min(1, elevation));
  }

  // ============================================
  // Main Terrain Rendering
  // ============================================

  function renderTerrainMap() {
    const canvas = document.getElementById('planetCanvas');
    if (!canvas) {
      console.error('Canvas element not found');
      return;
    }

    const ctx = canvas.getContext('2d');

    console.log('=== NASA TERRAIN DATA DEBUG ===');
    console.log('terrainData:', terrainData ? 'LOADED' : 'null');
    if (terrainData && terrainData.grid) {
      console.log('Geosphere grid sample:', terrainData.grid[0]?.slice(0, 10));
    }
    console.log('=== END NASA DATA DEBUG ===');

    // Reset layers
    layers = {
      terrain: null,
      water: null,
      biomes: null,
      resources: null,
      elevation: null
    };

    // NASA-first: Extract elevation
    if (terrainData && terrainData.elevation) {
      layers.elevation = {
        grid: terrainData.elevation,
        width: terrainData.elevation[0]?.length || 0,
        height: terrainData.elevation.length,
        layer_type: 'elevation',
        quality: terrainData.quality_score || 'nasa',
        method: terrainData.generation_method || 'nasa_geotiff'
      };
      console.log('Using NASA elevation data:', layers.elevation.quality, layers.elevation.method);
    }

    // NASA-first: Extract biomes
    if (terrainData && terrainData.biomes && Array.isArray(terrainData.biomes) && 
        terrainData.biomes.length > 0 && Array.isArray(terrainData.biomes[0]) &&
        layers.elevation && terrainData.biomes.length === layers.elevation.height && 
        terrainData.biomes[0].length === layers.elevation.width) {
      layers.biomes = {
        grid: terrainData.biomes,
        width: terrainData.biomes[0].length,
        height: terrainData.biomes.length,
        layer_type: 'biomes'
      };
      console.log('Using NASA biome grid data');
    } else {
      console.log('Biomes grid missing - will show pure elevation heightmap');
    }

    // NASA-first: Extract resources
    if (terrainData && terrainData.resource_grid && Array.isArray(terrainData.resource_grid) && terrainData.resource_grid.length > 0) {
      layers.resources = {
        grid: terrainData.resource_grid,
        width: terrainData.resource_grid[0]?.length || 0,
        height: terrainData.resource_grid.length,
        layer_type: 'resources'
      };
      console.log('Using NASA resource data');
    } else {
      console.log('Resource grid missing or empty - resources layer disabled');
    }

    // Calculate water layer from hydrosphere (only if there's water)
    if (layers.elevation && planetData.water_coverage > 0) {
      layers.water = calculateWaterLayerFromHydrosphere(planetData.water_coverage, layers.elevation);
      console.log('Calculated water layer from hydrosphere data');
    }

    // Use decomposed layers if available
    if (terrainData && terrainData.decomposed_layers) {
      terrainData = terrainData.decomposed_layers;
      console.log('Using decomposed terrain layers');
    }

    // Fallback
    if (!layers.terrain && terrainData) {
      layers.terrain = terrainData;
    }

    console.log('Celestial body:', planetName);
    console.log('Layers extracted:', layers);

    // No elevation data - show message
    if (!layers.elevation) {
      console.warn('No elevation data available');
      logConsole('No elevation data available for rendering', 'warning');
      
      ctx.fillStyle = '#000000';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      
      ctx.fillStyle = '#ffffff';
      ctx.font = '16px monospace';
      ctx.textAlign = 'center';
      ctx.fillText('NO TERRAIN DATA', canvas.width / 2, canvas.height / 2 - 20);
      ctx.fillText('AVAILABLE', canvas.width / 2, canvas.height / 2 + 10);
      ctx.fillText('Generate terrain map to view planetary surface', canvas.width / 2, canvas.height / 2 + 40);
      
      return;
    }

    const width = layers.elevation.width;
    const height = layers.elevation.height;
    const elevationData = layers.elevation.grid;

    console.log('NASA-first rendering:', width, 'x', height);
    console.log('Elevation sample:', elevationData[0]?.slice(0, 5));

    if (width === 0 || height === 0) {
      console.error('Invalid terrain dimensions');
      return;
    }

    const tileSize = 8;
    canvas.width = width * tileSize;
    canvas.height = height * tileSize;
    
    // Set container size to match canvas for proper scrolling
    const canvasContainer = document.getElementById('canvasContainer');
    if (canvasContainer) {
      canvasContainer.style.width = canvas.width + 'px';
      canvasContainer.style.height = canvas.height + 'px';
    }
    
    console.log('Canvas size:', canvas.width, 'x', canvas.height);

    // Calculate min/max elevation
    let minElevation = Infinity;
    let maxElevation = -Infinity;
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const elev = elevationData[y][x];
        if (elev !== null && elev !== undefined) {
          minElevation = Math.min(minElevation, elev);
          maxElevation = Math.max(maxElevation, elev);
        }
      }
    }
    if (minElevation === Infinity) minElevation = 0;
    if (maxElevation === -Infinity) maxElevation = 1000;

    console.log('Elevation range:', minElevation, 'to', maxElevation);

    // Clear canvas
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // SimEarth-style layered rendering
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const rawElevation = elevationData[y][x];
        const elevationRange = maxElevation - minElevation;
        const normalizedElevation = elevationRange > 0 ? (rawElevation - minElevation) / elevationRange : 0.5;

        // Check for biosphere once per cell
        const hasBiosphere = planetData.has_biosphere || false;

        // BASE LAYER: Pure elevation heightmap (only when water layer is not active)
        let color = null; // transparent by default
        
        // LAYER 1: Water overlay
        if (visibleLayers.has('water') && layers.water && layers.water.grid[y][x] > 0) {
          const waterDepth = layers.water.grid[y][x];
          color = getHydrosphereColor(waterDepth, planetData);
        } else if (!visibleLayers.has('water')) {
          // Only show base terrain when water layer is not active
          color = getElevationColor(normalizedElevation, planetData);
        }

        // LAYER 2: Biome overlay (only for planets with biospheres)
        // Barren planets like Mars shouldn't show Earth-like green biomes
        if (visibleLayers.has('biomes') && hasBiosphere && layers.biomes && layers.biomes.grid[y][x]) {
          const biome = layers.biomes.grid[y][x];
          if (biome && biome !== 'ocean' && biome !== 'none') {
            // Check if this cell is underwater (regardless of whether water layer is visible)
            // This prevents biomes from rendering over ocean areas when hydrosphere is toggled off
            const isUnderwater = layers.water && layers.water.grid[y] && layers.water.grid[y][x] > 0;
            if (!isUnderwater) {
              color = getBiomeColor(biome);
            }
          }
        }

        // LAYER 3: Resources overlay
        if (visibleLayers.has('resources') && layers.resources && layers.resources.grid[y][x]) {
          const resource = layers.resources.grid[y][x];
          if (resource && resource !== 'none') {
            color = blendColors(color, '#FFFF00', 0.4);
          }
        }

        // LAYER 4: Temperature overlay
        if (visibleLayers.has('temperature')) {
          const latitude = (y / height - 0.5) * 180; // Convert y to latitude (-90 to 90)
          const tempColor = layerOverlays.temperature.getOverlayColor(
            latitude, 
            normalizedElevation, 
            planetData.surface_temperature || planetData.temperature || 288,
            planetData.atmosphere?.pressure || 1.0
          );
          color = tempColor;
        }

        // LAYER 5: Rainfall overlay (biome-based precipitation estimate)
        // Only show rainfall on planets with biospheres
        if (visibleLayers.has('rainfall') && hasBiosphere && layers.biomes && layers.biomes.grid[y][x]) {
          const biome = layers.biomes.grid[y][x];
          // Check if we have a direct mapping for this biome
          if (biome && layerOverlays.rainfall.terrainColors[biome]) {
            color = layerOverlays.rainfall.terrainColors[biome];
          } else if (biome) {
            // Fallback: estimate rainfall from biome name patterns
            if (biome.includes('rain') || biome.includes('jungle')) {
              color = '#0055ff';  // High rainfall
            } else if (biome.includes('forest')) {
              color = '#3388ff';  // Medium-high
            } else if (biome.includes('grass') || biome.includes('plain')) {
              color = '#77ccff';  // Medium
            } else if (biome.includes('desert') || biome.includes('tundra')) {
              color = '#ffcc00';  // Low rainfall
            } else if (biome.includes('ocean') || biome.includes('coast')) {
              color = '#004488';  // Ocean
            }
          }
        }

        // LAYER 6: Features overlay (geological features - mountains, hills, volcanic)
        // Only show features on planets with biospheres
        if (visibleLayers.has('features') && hasBiosphere) {
          const biome = layers.biomes?.grid[y]?.[x];
          // Use helper function or direct check
          if (biome && layerOverlays.features.isFeature(biome)) {
            // Use specific color if available, otherwise rock gray
            color = layerOverlays.features.terrainColors[biome] || 
                    layerOverlays.features.terrainColors['rock'];
          } else if (normalizedElevation > 0.85) {
            // Also highlight very high elevations as features (peaks)
            color = '#808080';  // Gray for high elevation
          }
        }

        if (color) {
          ctx.fillStyle = color;
          ctx.fillRect(x * tileSize, y * tileSize, tileSize, tileSize);
        }
      }
    }

    // Log summary
    const elevations = elevationData.flat();
    const minElev = Math.min(...elevations);
    const maxElev = Math.max(...elevations);
    console.log(`NASA-first terrain rendered: ${width}x${height}`);
    logConsole(`NASA terrain rendered: ${width}x${height} (elevation: ${minElev.toFixed(0)}-${maxElev.toFixed(0)}m)`, 'success');
    
    // Center the map view after rendering
    setTimeout(() => {
      centerMapView();
    }, 50);
  }

  // ============================================
  // UI Setup Functions
  // ============================================

  function setupAITestButtons() {
    document.querySelectorAll('.tool-button[data-test]').forEach(btn => {
      btn.addEventListener('click', function() {
        const testType = this.dataset.test;
        runAITest(testType);
      });
    });
  }

  function runAITest(testType) {
    logConsole(`Starting AI test: ${testType}`, 'info');
    
    fetch(`/admin/celestial_bodies/${planetId}/run_ai_test`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ test_type: testType })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        logConsole(data.message, 'success');
        logConsole(`Test completed: ${JSON.stringify(data)}`, 'info');
      } else {
        logConsole(`Test failed: ${data.error}`, 'error');
      }
    })
    .catch(error => {
      logConsole(`Error running test: ${error.message}`, 'error');
    });
  }

  function setupZoomControl() {
    const zoomInput = document.getElementById('zoom');
    const zoomValue = document.getElementById('zoomValue');
    const canvas = document.getElementById('planetCanvas');
    const canvasWrapper = document.getElementById('canvasWrapper');
    const canvasContainer = document.getElementById('canvasContainer');
    
    if (!zoomInput) return;
    
    zoomInput.addEventListener('input', function() {
      const zoom = parseFloat(this.value);
      zoomValue.textContent = zoom.toFixed(1) + 'x';
      
      if (zoom === 1.0) {
        canvas.style.transform = 'none';
      } else {
        canvas.style.transform = `scale(${zoom})`;
        canvas.style.transformOrigin = 'top left';
      }
      
      // Update container size to match scaled canvas for proper scrolling
      if (canvasContainer) {
        canvasContainer.style.width = (canvas.width * zoom) + 'px';
        canvasContainer.style.height = (canvas.height * zoom) + 'px';
      }
    });
    
    zoomValue.textContent = '1.0x';
    canvas.style.transform = 'none';
  }

  function setupPanControl() {
    const canvasWrapper = document.getElementById('canvasWrapper');
    const canvas = document.getElementById('planetCanvas');
    
    if (!canvasWrapper || !canvas) return;
    
    let isPanning = false;
    let startX, startY, scrollLeft, scrollTop;
    
    // Mouse drag to pan
    canvas.addEventListener('mousedown', (e) => {
      isPanning = true;
      canvas.style.cursor = 'grabbing';
      startX = e.pageX - canvasWrapper.offsetLeft;
      startY = e.pageY - canvasWrapper.offsetTop;
      scrollLeft = canvasWrapper.scrollLeft;
      scrollTop = canvasWrapper.scrollTop;
    });
    
    canvas.addEventListener('mouseleave', () => {
      isPanning = false;
      canvas.style.cursor = 'grab';
    });
    
    canvas.addEventListener('mouseup', () => {
      isPanning = false;
      canvas.style.cursor = 'grab';
    });
    
    canvas.addEventListener('mousemove', (e) => {
      if (!isPanning) return;
      e.preventDefault();
      const x = e.pageX - canvasWrapper.offsetLeft;
      const y = e.pageY - canvasWrapper.offsetTop;
      const walkX = (x - startX) * 1.5; // Scroll speed multiplier
      const walkY = (y - startY) * 1.5;
      canvasWrapper.scrollLeft = scrollLeft - walkX;
      canvasWrapper.scrollTop = scrollTop - walkY;
    });
    
    // Reset view button
    const resetBtn = document.getElementById('resetViewBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        resetMapView();
      });
    }
    
    // Center map initially after rendering
    setTimeout(() => {
      centerMapView();
    }, 100);
  }
  
  function centerMapView() {
    const canvasWrapper = document.getElementById('canvasWrapper');
    const canvas = document.getElementById('planetCanvas');
    
    if (!canvasWrapper || !canvas) return;
    
    // Center the scroll position
    const scrollX = (canvas.width - canvasWrapper.clientWidth) / 2;
    const scrollY = (canvas.height - canvasWrapper.clientHeight) / 2;
    
    canvasWrapper.scrollLeft = Math.max(0, scrollX);
    canvasWrapper.scrollTop = Math.max(0, scrollY);
  }
  
  function resetMapView() {
    const zoomInput = document.getElementById('zoom');
    const zoomValue = document.getElementById('zoomValue');
    const canvas = document.getElementById('planetCanvas');
    const canvasContainer = document.getElementById('canvasContainer');
    
    // Reset zoom to 1.0
    if (zoomInput) {
      zoomInput.value = 1;
      zoomValue.textContent = '1.0x';
    }
    
    if (canvas) {
      canvas.style.transform = 'none';
    }
    
    if (canvasContainer) {
      canvasContainer.style.width = canvas.width + 'px';
      canvasContainer.style.height = canvas.height + 'px';
    }
    
    // Center the view
    centerMapView();
    
    logConsole('Map view reset to center', 'info');
  }

  function setupLayerToggles() {
    document.querySelectorAll('.layer-btn').forEach(btn => {
      btn.addEventListener('click', function() {
        const layer = this.dataset.layer;
        toggleLayer(layer);
        updateLayerButtons();
      });
    });
  }

  function toggleLayer(layerName) {
    if (layerName === 'terrain') {
      visibleLayers.clear();
      visibleLayers.add('terrain');
      logConsole('Reset to base terrain (bare planet lithosphere)', 'info');
    } else {
      if (visibleLayers.has(layerName)) {
        visibleLayers.delete(layerName);
        logConsole(`${layerName} overlay hidden`, 'info');
      } else {
        visibleLayers.add(layerName);
        logConsole(`${layerName} overlay shown`, 'info');
      }
    }

    renderTerrainMap();
    updateLayerButtons();
  }

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

  function startDataPolling() {
    updateInterval = setInterval(updateSphereData, 5000);
  }

  function updateSphereData() {
    fetch(`/admin/celestial_bodies/${planetId}/sphere_data`)
      .then(response => response.json())
      .then(data => {
        if (data.atmosphere.pressure !== undefined) {
          updateElement('atmo-pressure', `${data.atmosphere.pressure.toFixed(4)} bar`);
          updateElement('atmo-temp', `${data.atmosphere.temperature.toFixed(1)} K`);
          updateElement('atmo-mass', formatMass(data.atmosphere.total_mass));
        }
        
        if (data.hydrosphere.water_coverage !== undefined) {
          updateElement('hydro-coverage', `${data.hydrosphere.water_coverage.toFixed(1)}%`);
          updateElement('hydro-ocean', formatMass(data.hydrosphere.ocean_mass));
          updateElement('hydro-ice', formatMass(data.hydrosphere.ice_mass));
        }
        
        if (data.biosphere.biodiversity_index !== undefined) {
          updateElement('bio-diversity', `${data.biosphere.biodiversity_index.toFixed(1)}%`);
          updateProgressBar('bio-diversity-bar', data.biosphere.biodiversity_index);
          updateElement('bio-habitability', `${data.biosphere.habitable_ratio.toFixed(1)}%`);
          updateProgressBar('bio-habitability-bar', data.biosphere.habitable_ratio);
          updateElement('bio-lifeforms', data.biosphere.life_forms_count);
        }
        
        if (data.geosphere.geological_activity !== undefined) {
          updateElement('geo-activity', `${data.geosphere.geological_activity}/100`);
          updateElement('geo-tectonic', data.geosphere.tectonic_active ? 'Yes' : 'No');
          updateElement('geo-volcano', data.geosphere.volcanic_activity);
        }
      })
      .catch(error => {
        console.error('Error updating sphere data:', error);
      });
  }

  function updateElement(id, value) {
    const element = document.getElementById(id);
    if (element) element.textContent = value;
  }

  function updateProgressBar(id, percentage) {
    const element = document.getElementById(id);
    if (element) element.style.width = `${percentage}%`;
  }

  function logConsole(message, type = 'info') {
    const consoleEl = document.getElementById('console');
    if (!consoleEl) return;
    
    const line = document.createElement('div');
    line.className = `console-line ${type}`;
    const timestamp = new Date().toLocaleTimeString();
    line.textContent = `[${timestamp}] > ${message}`;
    consoleEl.appendChild(line);
    consoleEl.scrollTop = consoleEl.scrollHeight;
    
    while (consoleEl.children.length > 50) {
      consoleEl.removeChild(consoleEl.firstChild);
    }
  }

  // ============================================
  // Sphere CRUD Operations
  // ============================================

  function createSphere(sphereType) {
    logConsole(`Creating ${sphereType}...`, 'info');
    
    fetch(`/admin/celestial_bodies/${planetId}/spheres`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ 
        sphere_type: sphereType,
        sphere: { 
          temperature: sphereType.includes('hydro') ? 300 : 200,
          pressure: sphereType === 'atmosphere' ? 1.0 : 0,
          thickness: sphereType === 'cryosphere' ? 10000 : null
        }
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        logConsole(`${sphereType} created successfully`, 'success');
        location.reload();
      } else {
        logConsole(`Failed to create ${sphereType}: ${data.error}`, 'error');
      }
    })
    .catch(error => {
      logConsole(`Error creating ${sphereType}: ${error.message}`, 'error');
    });
  }

  function editSphere(sphereId, sphereType) {
    logConsole(`Editing ${sphereType}...`, 'info');
    window.location.href = `/admin/celestial_bodies/${planetId}/spheres/${sphereId}/edit?type=${sphereType}`;
  }

  function deleteSphere(sphereId, sphereType) {
    logConsole(`Deleting ${sphereType}...`, 'warning');
    
    fetch(`/admin/celestial_bodies/${planetId}/spheres/${sphereId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        logConsole(`${sphereType} deleted successfully`, 'success');
        location.reload();
      } else {
        logConsole(`Failed to delete ${sphereType}: ${data.error}`, 'error');
      }
    })
    .catch(error => {
      logConsole(`Error deleting ${sphereType}: ${error.message}`, 'error');
    });
  }

  // ============================================
  // Initialization
  // ============================================

  function init() {
    // Prevent multiple initializations
    if (window.monitorScriptLoaded) {
      console.log('Monitor script already loaded, skipping...');
      if (window.monitorUpdateInterval) {
        clearInterval(window.monitorUpdateInterval);
      }
      return;
    }
    window.monitorScriptLoaded = true;

    // Load data from JSON element
    const dataElement = document.getElementById('monitor-data');
    if (!dataElement) {
      console.error('Monitor data element not found');
      return;
    }

    try {
      const data = JSON.parse(dataElement.textContent);
      
      planetId = data.planet_id;
      planetName = data.planet_name;
      planetType = data.planet_type;
      terrainData = data.terrain_data;
      planetData = data.planet_data;
      
      // Set default visible layers based on planet
      visibleLayers = new Set(['terrain']);
      if (planetName.toLowerCase() === 'earth') {
        // Earth shows water and biomes by default for realistic appearance
        visibleLayers.add('water');
        visibleLayers.add('biomes');
      }
      
      // Calculate climate zones
      const planetTemp = data.atmosphere_temperature || data.surface_temperature || 288;
      const planetPressure = data.atmosphere_pressure || 1.0;
      climate = calculateClimateZones(planetTemp, planetPressure);
      
      console.log('Monitor initialized for:', planetName);
    } catch (e) {
      console.error('Error parsing monitor data:', e);
      return;
    }

    // Setup UI
    setupAITestButtons();
    setupLayerToggles();
    updateLayerButtons();
    setupZoomControl();
    setupPanControl();
    startDataPolling();
    renderTerrainMap();
    logConsole('System initialized', 'info');

    // Cleanup on unload
    window.addEventListener('beforeunload', function() {
      if (updateInterval) clearInterval(updateInterval);
      window.monitorUpdateInterval = null;
    });

    window.monitorUpdateInterval = updateInterval;
  }

  // Public API
  return {
    init: init,
    renderTerrainMap: renderTerrainMap,
    toggleLayer: toggleLayer,
    createSphere: createSphere,
    editSphere: editSphere,
    deleteSphere: deleteSphere,
    logConsole: logConsole
  };

})();

// Auto-initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', function() {
  AdminMonitor.init();
});

// Also initialize on Turbo load (for Rails 7+)
document.addEventListener('turbo:load', function() {
  AdminMonitor.init();
});
