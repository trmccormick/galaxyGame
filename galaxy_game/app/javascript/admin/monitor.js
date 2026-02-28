/**
 * Admin Monitor - Planetary Visualization Module
 *
 * SimEarth-style planetary monitor with layered terrain rendering.
 * Data is injected via #monitor-data JSON element in the view.
 */

window.AdminMonitor = (function() {
  'use strict';

  // ============================================
  // Module state
  // ============================================

  let planetId        = null;
  let planetName      = '';
  let planetType      = '';
  let updateInterval  = null;
  let climate         = null;
  let planetData      = null;
  let terrainData     = null;
  let monitorData     = null;
  let layers          = {};
  let visibleLayers   = new Set(['terrain']);
  
  // Viewport state for pan/zoom
  let viewport = {
    offsetX: 0,
    offsetY: 0,
    scale: 1.0,
    isDragging: false,
    dragStartX: 0,
    dragStartY: 0,
    dragStartOffsetX: 0,
    dragStartOffsetY: 0,
    initialized: false // Track if we've centered for this body
  };

  // ============================================
  // Layer overlay colors (temperature, rainfall, features)
  // ============================================

  const layerOverlays = {
    liquid: {
      // not used directly; liquid color comes from getHydrosphereColor
      terrainColors: {
        coast: '#87CEEB',
        ocean: '#1e3a8a',
        deep_sea: '#000080'
      }
    },
    biomes: {
      terrainColors: {
        forest:   '#228B22',
        jungle:   '#006400',
        grasslands: '#32CD32',
        plains:   '#FFFF00',
        swamp:    '#808000',
        boreal:   '#228B22',
        arctic:   '#ffffff',
        desert:   '#DAA520'
      }
    },
    features: {
      terrainColors: {
        mountains:         '#505050',
        mountain:          '#505050',
        polar_mountains:   '#a0a0a0',
        tropical_mountains:'#606060',
        hills:             '#707050',
        peaks:             '#c0c0c0',
        rock:              '#696969',
        volcanic:          '#8b0000',
        lava:              '#ff4400'
      },
      isFeature: function(biome) {
        if (!biome) return false;
        return (
          biome.includes('mountain') ||
          biome.includes('hill')     ||
          biome.includes('peak')     ||
          biome.includes('volcanic') ||
          biome === 'rock'           ||
          biome === 'lava'
        );
      }
    },
    temperature: {
      getOverlayColor: function(latitude, elevation, globalTemp, pressure) {
        const absLat = Math.abs(latitude);
        let baseTemp;

        if (absLat < 30) {
          baseTemp = globalTemp - 273.15 + 20 - (absLat / 30) * 10;
        } else if (absLat < 60) {
          baseTemp = globalTemp - 273.15 - ((absLat - 30) / 30) * 20;
        } else {
          baseTemp = globalTemp - 273.15 - 20 - ((absLat - 60) / 30) * 30;
        }

        const elevationMeters  = elevation * 8000;
        const elevationCooling = (elevationMeters / 1000) * 6.5;
        const elevationTemp    = baseTemp - elevationCooling;
        const pressureTemp     = elevationTemp * (0.5 + Math.min(pressure, 1.0) * 0.5);

        if (pressureTemp > 35)    return '#ff0000';
        if (pressureTemp > 25)    return '#ff4400';
        if (pressureTemp > 15)    return '#ff8800';
        if (pressureTemp > 5)     return '#ffcc00';
        if (pressureTemp > -5)    return '#88cc44';
        if (pressureTemp > -15)   return '#44aaff';
        if (pressureTemp > -30)   return '#2288ff';
        return '#0066cc';
      },
      terrainColors: {}
    },
    rainfall: {
      terrainColors: {
        tropical_rainforest:      '#0033ff',
        jungle:                   '#0044ff',
        swamp:                    '#0055ff',
        tropical_seasonal_forest: '#0066ff',
        temperate_forest:         '#2288ff',
        temperate_rainforest:     '#1166ff',
        boreal_forest:            '#4499ff',
        forest:                   '#3388ff',
        boreal:                   '#55aaff',
        temperate_grassland:      '#66bbff',
        grassland:                '#77ccff',
        grasslands:               '#77ccff',
        tropical_grassland:       '#88ddff',
        plains:                   '#99eeff',
        tundra:                   '#aaddcc',
        polar_desert:             '#ffee88',
        desert:                   '#ffcc00',
        ocean:                    '#004488',
        coast:                    '#006699'
      }
    },
    resources: {
      terrainColors: {
        rock:   '#ffd700',
        desert: '#daa520'
      }
    }
  };

  // ============================================
  // Utilities
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
    const base    = hexToRgb(baseColor);
    const overlay = hexToRgb(overlayColor);
    if (!base || !overlay) return baseColor;
    const r = Math.round(base.r * (1 - alpha) + overlay.r * alpha);
    const g = Math.round(base.g * (1 - alpha) + overlay.g * alpha);
    const b = Math.round(base.b * (1 - alpha) + overlay.b * alpha);
    return '#' + r.toString(16).padStart(2, '0') +
                 g.toString(16).padStart(2, '0') +
                 b.toString(16).padStart(2, '0');
  }

  function formatMass(mass) {
    if (mass > 1e18) return (mass / 1e18).toFixed(2) + ' Eg';
    if (mass > 1e15) return (mass / 1e15).toFixed(2) + ' Pg';
    if (mass > 1e12) return (mass / 1e12).toFixed(2) + ' Tg';
    if (mass > 1e9)  return (mass / 1e9).toFixed(2)  + ' Gg';
    return mass.toFixed(2) + ' kg';
  }

  // ============================================
  // Climate / color classification
  // ============================================

  function calculateClimateZones(tempK, pressureBar) {
    const Ts = tempK;
    const Tp = Ts - 75 / (1 + 5 * pressureBar);
    const Tt = Ts * 1.1;

    let iceLat  = 0;
    let habRatio = 0;

    if (Tt > 273 && Tp < 273) {
      habRatio = Math.pow((Tt - 273) / (Tt - Tp), 0.666667);
      iceLat   = Math.asin(habRatio) * 180 / Math.PI;
    } else if (Tt < 273) {
      habRatio = 0;
      iceLat   = 90;
    } else {
      habRatio = 1;
      iceLat   = 0;
    }

    return {
      surfaceTemp:   Ts,
      polarTemp:     Tp,
      tropicalTemp:  Tt,
      iceLatitude:   iceLat,
      habitableRatio: habRatio,
      polarZone:     iceLat,
      temperateZone: Math.max(iceLat + 30, 45),
      tropicalZone:  Math.max(iceLat + 60, 75)
    };
  }

  function getTerrainColorScheme(pData) {
    const type       = pData.type;
    const atmosphere = pData.atmosphere;
    const surfaceTemp = pData.surface_temperature || pData.temperature || 288;
    const geologicalActivity =
      pData.geological_activity || pData.geosphere_attributes?.geological_activity || 50;
    const gravity = pData.gravity || 1.0;
    const name    = (pData.name || '').toLowerCase();

    if (surfaceTemp > 700 && geologicalActivity > 80) {
      return { low: '#1a0000', high: '#ff4500' };
    }

    if (atmosphere && atmosphere.pressure > 10 && surfaceTemp > 400) {
      return { low: '#8b4513', high: '#ffa500' };
    }

    if (name === 'mars' ||
        (atmosphere && atmosphere.pressure > 0.001 && atmosphere.pressure < 0.1 &&
         surfaceTemp < 280 && surfaceTemp > 150 && gravity > 2 && gravity < 5)) {
      return { low: '#4a2810', high: '#cd5c3c' };
    }

    if ((atmosphere && atmosphere.pressure < 0.001) ||
        !atmosphere ||
        gravity < 0.3 ||
        type?.includes('moon')     ||
        type?.includes('asteroid') ||
        type?.includes('dwarf_planet') ||
        name === 'luna' || name === 'moon' || name === 'mercury') {
      return { low: '#4a4a4a', high: '#d0d0d0' };
    }

    if (type?.includes('carbon') || pData.crust_composition?.elements?.C > 25) {
      return { low: '#2f2f2f', high: '#696969' };
    }

    return { low: '#2d1810', high: '#d2b48c' };
  }

  function getElevationColor(normalizedElevation, pData) {
    if (normalizedElevation == null) return '#000000';
    const scheme  = getTerrainColorScheme(pData);
    const lowRgb  = hexToRgb(scheme.low);
    const highRgb = hexToRgb(scheme.high);
    if (!lowRgb || !highRgb) return '#808080';
    const r = Math.round(lowRgb.r + (highRgb.r - lowRgb.r) * normalizedElevation);
    const g = Math.round(lowRgb.g + (highRgb.g - lowRgb.g) * normalizedElevation);
    const b = Math.round(lowRgb.b + (highRgb.b - lowRgb.b) * normalizedElevation);
    return `rgb(${r}, ${g}, ${b})`;
  }

  function getBiomeColor(biome) {
    const biomeColors = {
      desert:          '#DAA520',
      polar_desert:    '#E8DCC8',
      hot_desert:      '#F4A460',
      grassland:       '#7CCD7C',
      grasslands:      '#7CCD7C',
      temperate_grassland: '#90EE90',
      tropical_grassland:  '#98FB98',
      savanna:         '#9ACD32',
      forest:          '#228B22',
      temperate_forest:'#228B22',
      tropical_seasonal_forest: '#006400',
      tropical_rainforest:      '#004000',
      boreal_forest:   '#2E8B57',
      boreal:          '#2E8B57',
      jungle:          '#004400',
      temperate_rainforest: '#006633',
      tundra:          '#B8C4C8',
      arctic:          '#E8E8E8',
      ice:             '#E0FFFF',
      polar_ice:       '#F0FFFF',
      snow:            '#FFFAFA',
      swamp:           '#556B2F',
      marsh:           '#6B8E23',
      wetland:         '#698B69',
      wetlands:        '#698B69',
      plains:          '#C4B454',
      steppe:          '#BDB76B',
      lowlands:        '#8FBC8F',
      highlands:       '#BC8F8F',
      mountains:       '#808080',
      mountain:        '#808080',
      polar_mountains: '#A9A9A9',
      tropical_mountains: '#696969',
      hills:           '#8B7765',
      peaks:           '#DCDCDC',
      volcanic:        '#8B0000',
      lava:            '#FF4500',
      maria:           '#3C3C3C',
      ocean:           '#0066cc',
      coast:           '#4682B4',
      deep_sea:        '#003366'
    };

    if (biome && biomeColors[biome]) return biomeColors[biome];

    if (biome) {
      const lower = biome.toLowerCase();
      if (lower.includes('desert'))   return '#DAA520';
      if (lower.includes('forest'))   return '#228B22';
      if (lower.includes('grass'))    return '#7CCD7C';
      if (lower.includes('tundra'))   return '#B8C4C8';
      if (lower.includes('mountain')) return '#808080';
      if (lower.includes('peak'))     return '#DCDCDC';
      if (lower.includes('hill'))     return '#8B7765';
      if (lower.includes('ice') || lower.includes('snow')) return '#E0FFFF';
      if (lower.includes('jungle') || lower.includes('rain')) return '#004400';
      if (lower.includes('savanna'))  return '#9ACD32';
      if (lower.includes('plain'))    return '#C4B454';
    }

    console.warn('Unknown biome type:', biome);
    return '#8B4513';
  }

  // ============================================
  // Hydrosphere color – composition aware
  // ============================================

  function getHydrosphereColor(waterDepth, pData) {
    const name   = (pData.name || '').toLowerCase();
    const liquid = (pData.liquid_name || 'H2O').toUpperCase();
    const temp   = pData.surface_temperature || pData.temperature || 288;

    const shallowThreshold = 200;
    const deepThreshold    = 4000;

    // Ice / frozen surfaces
    if (liquid === 'ICE' || liquid.includes('FROZEN') ||
        (liquid === 'H2O' && temp < 273)) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const v = Math.round(240 - t * 20);
        return `rgba(${v}, ${v}, 255, 0.8)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const v = Math.round(220 - t * 40);
        return `rgba(${v}, ${v}, 255, 0.85)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const v = Math.round(180 - t * 40);
        return `rgba(${v}, ${v}, 255, 0.9)`;
      }
    }

    // Methane/ethane (Titan-like)
    if (liquid === 'CH4' || liquid === 'C2H6' ||
        liquid.includes('METHANE') || liquid.includes('ETHANE')) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const r = Math.round(255 - t * 30);
        const g = Math.round(180 - t * 40);
        const b = Math.round(50  - t * 20);
        return `rgba(${r}, ${g}, ${b}, 0.8)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const r = Math.round(225 - t * 75);
        const g = Math.round(140 - t * 60);
        const b = Math.round(30  - t * 30);
        return `rgba(${r}, ${g}, ${b}, 0.85)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const r = Math.round(150 - t * 50);
        const g = Math.round(80  - t * 40);
        const b = 0;
        return `rgba(${r}, ${g}, ${b}, 0.9)`;
      }
    }

    // Nitrogen
    if (liquid === 'N2' || liquid.includes('NITROGEN')) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const r = Math.round(240 - t * 10);
        const g = Math.round(240 - t * 20);
        const b = Math.round(250 - t * 20);
        return `rgba(${r}, ${g}, ${b}, 0.7)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const r = Math.round(230 - t * 30);
        const g = Math.round(220 - t * 40);
        const b = Math.round(230 - t * 50);
        return `rgba(${r}, ${g}, ${b}, 0.75)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const r = Math.round(200 - t * 30);
        const g = Math.round(180 - t * 40);
        const b = Math.round(180 - t * 40);
        return `rgba(${r}, ${g}, ${b}, 0.8)`;
      }
    }

    // Ammonia
    if (liquid === 'NH3' || liquid.includes('AMMONIA')) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const r = Math.round(200 - t * 30);
        const g = Math.round(150 - t * 50);
        const b = Math.round(255 - t * 30);
        return `rgba(${r}, ${g}, ${b}, 0.75)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const r = Math.round(170 - t * 50);
        const g = Math.round(100 - t * 50);
        const b = Math.round(225 - t * 75);
        return `rgba(${r}, ${g}, ${b}, 0.8)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const r = Math.round(120 - t * 30);
        const g = Math.round(50  - t * 20);
        const b = Math.round(150 - t * 50);
        return `rgba(${r}, ${g}, ${b}, 0.85)`;
      }
    }

    // Default: H2O-like water
    if (waterDepth < shallowThreshold) {
      const t = waterDepth / shallowThreshold;
      const r = Math.round(100 - t * 50);
      const g = Math.round(200 - t * 50);
      const b = Math.round(255 - t * 35);
      return `rgba(${r}, ${g}, ${b}, 0.85)`;
    } else if (waterDepth < deepThreshold) {
      const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
      const r = Math.round(50  - t * 50);
      const g = Math.round(150 - t * 100);
      const b = Math.round(220 - t * 70);
      return `rgba(${r}, ${g}, ${b}, 0.9)`;
    } else {
      const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
      const g = Math.round(20 - t * 10);
      const b = Math.round(100 - t * 20);
      return `rgba(0, ${g}, ${b}, 0.95)`;
    }
  }

  // ============================================
  // Hydrosphere: Bathtub algorithm
  // ============================================

  function calculateWaterLayerFromHydrosphere(elevationLayer) {
    if (!elevationLayer || !elevationLayer.grid) return null;

    const width  = elevationLayer.width;
    const height = elevationLayer.height;
    const elevationGrid = elevationLayer.grid;

    // Single, normalized coverage fraction (0–1) from planetData
    let coverage = 0;

    if (planetData.surface_liquid_coverage != null) {
      coverage = planetData.surface_liquid_coverage;
    } else if (planetData.hydrosphere && planetData.hydrosphere.state_distribution &&
               planetData.hydrosphere.state_distribution.liquid != null) {
      coverage = planetData.hydrosphere.state_distribution.liquid;
    } else if (planetData.water_coverage != null) {
      coverage = planetData.water_coverage;
    }

    if (coverage > 1) coverage /= 100.0;
    coverage = Math.max(0, Math.min(1, coverage));
    if (coverage <= 0) return null;

    // Collect elevations
    const allElevations = [];
    let hasNegative = false;

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const elev = elevationGrid[y][x];
        if (elev != null && elev !== undefined) {
          allElevations.push(elev);
          if (elev < 0) hasNegative = true;
        }
      }
    }

    if (allElevations.length === 0) return null;

    let seaLevel = 0;

    if (hasNegative) {
      // Earth-like DEM: sea level is 0m
      seaLevel = 0;
      console.log('Using real elevation data: sea level = 0m');
    } else {
      // Synthetic / PNG-derived DEM: use bathtub
      allElevations.sort((a, b) => a - b);
      const seaLevelIndex = Math.floor(allElevations.length * coverage);
      seaLevel = allElevations[Math.min(seaLevelIndex, allElevations.length - 1)];
      console.log(`Using bathtub algorithm: sea level = ${seaLevel} for ${(coverage * 100).toFixed(2)}% coverage`);
    }

    const waterGrid = [];
    for (let y = 0; y < height; y++) {
      waterGrid[y] = [];
      for (let x = 0; x < width; x++) {
        const elevation = elevationGrid[y][x];
        if (elevation != null && elevation < seaLevel) {
          waterGrid[y][x] = seaLevel - elevation;
        } else {
          waterGrid[y][x] = 0;
        }
      }
    }

    return {
      grid:          waterGrid,
      width:         width,
      height:        height,
      layer_type:    'liquid',
      sea_level:     seaLevel,
      water_coverage: coverage
    };
  }

  // ============================================
  // Adaptive grid (pixelation fix)
  // ============================================

  function calculateAdaptiveGrid(planetData, terrainData) {
    if (!planetData || !terrainData) {
      return {
        width: 80,
        height: 50,
        tileSize: 8,
        totalWidth: 640,
        totalHeight: 400,
        adaptive: false
      };
    }

    const diameterKm = planetData.diameter || planetData.radius * 2 || 12742;
    const bodyType   = planetData.type || planetData.body_category || 'planet';
    const name       = (planetData.name || '').toLowerCase();

    const earthDiameter = 12742;
    const diameterRatio = Math.max(0.01, diameterKm / earthDiameter);

    let baseGridSize;
    if (diameterKm < 100) {
      baseGridSize = Math.max(40, Math.min(120, 80 * Math.sqrt(1 / diameterRatio)));
    } else if (diameterKm < 1000) {
      baseGridSize = Math.max(50, Math.min(100, 80 * Math.sqrt(1 / diameterRatio)));
    } else if (diameterKm < 5000) {
      baseGridSize = Math.max(60, Math.min(120, 80 * Math.sqrt(diameterRatio)));
    } else {
      baseGridSize = Math.max(70, Math.min(150, 80 * diameterRatio));
    }

    if (name === 'luna' || name === 'moon' || bodyType.includes('moon')) {
      baseGridSize = 60;
    } else if (name === 'mars' || bodyType.includes('terrestrial')) {
      baseGridSize = 90;
    } else if (bodyType.includes('gas_giant') || bodyType.includes('ice_giant')) {
      baseGridSize = Math.min(120, baseGridSize);
    }

    const targetMinResolution = 800;
    let tileSize = Math.max(4, Math.min(24, targetMinResolution / baseGridSize));

    if (diameterKm < 500) {
      tileSize = Math.max(12, tileSize);
    } else if (diameterKm > 10000) {
      tileSize = Math.min(8, tileSize);
    }

    const maxCanvasSize = 4096;
    let totalWidth      = baseGridSize * tileSize;
    let totalHeight     = baseGridSize * 0.625 * tileSize;

    if (totalWidth > maxCanvasSize || totalHeight > maxCanvasSize) {
      const scale = Math.min(maxCanvasSize / totalWidth, maxCanvasSize / totalHeight);
      tileSize = Math.max(4, Math.floor(tileSize * scale));
      totalWidth  = baseGridSize * tileSize;
      totalHeight = baseGridSize * 0.625 * tileSize;
    }

    const finalWidth  = Math.floor(baseGridSize);
    const finalHeight = Math.floor(baseGridSize * 0.625);

    return {
      width:       finalWidth,
      height:      finalHeight,
      tileSize:    tileSize,
      totalWidth:  finalWidth  * tileSize,
      totalHeight: finalHeight * tileSize,
      adaptive:    true,
      diameterKm:  diameterKm,
      bodyType:    bodyType,
      scaling:     diameterRatio
    };
  }

  // ============================================
  // Main terrain rendering
  // ============================================

  function renderTerrainMap() {
    const canvas = document.getElementById('planetCanvas');
    if (!canvas) {
      console.error('Canvas element not found');
      return;
    }

    if (canvas.width === 0 || canvas.height === 0) {
      console.log('Canvas not ready, retrying in 50ms...');
      setTimeout(renderTerrainMap, 50);
      return;
    }

    const ctx = canvas.getContext('2d');

    // Reset layers
    layers = {
      terrain:   null,
      liquid:    null,
      biomes:    null,
      resources: null,
      elevation: null
    };

    // NASA-first: elevation
    if (terrainData && terrainData.elevation) {
      layers.elevation = {
        grid:   terrainData.elevation,
        width:  terrainData.elevation[0]?.length || 0,
        height: terrainData.elevation.length,
        layer_type: 'elevation',
        quality: terrainData.quality_score || 'nasa',
        method:  terrainData.generation_method || 'nasa_geotiff'
      };
      console.log('Using NASA elevation data:', layers.elevation.quality, layers.elevation.method);
    }

    // Biomes
    if (terrainData && terrainData.biomes &&
        Array.isArray(terrainData.biomes) &&
        terrainData.biomes.length > 0 &&
        Array.isArray(terrainData.biomes[0]) &&
        layers.elevation &&
        terrainData.biomes.length === layers.elevation.height &&
        terrainData.biomes[0].length === layers.elevation.width) {

      layers.biomes = {
        grid:   terrainData.biomes,
        width:  terrainData.biomes[0].length,
        height: terrainData.biomes.length,
        layer_type: 'biomes'
      };

      const uniqueBiomes = new Set();
      for (let y = 0; y < terrainData.biomes.length; y++) {
        for (let x = 0; x < terrainData.biomes[y].length; x++) {
          if (terrainData.biomes[y][x]) uniqueBiomes.add(terrainData.biomes[y][x]);
        }
      }
      console.log('Using NASA biome grid data');
      console.log('Unique biome types found:', Array.from(uniqueBiomes));
    } else {
      console.log('Biomes grid missing - will show pure elevation heightmap');
    }

    // Resources
    if (terrainData && terrainData.resource_grid &&
        Array.isArray(terrainData.resource_grid) &&
        terrainData.resource_grid.length > 0) {
      layers.resources = {
        grid:   terrainData.resource_grid,
        width:  terrainData.resource_grid[0]?.length || 0,
        height: terrainData.resource_grid.length,
        layer_type: 'resources'
      };
      console.log('Using NASA resource data');
    } else {
      console.log('Resource grid missing or empty - resources layer disabled');
    }

    // Hydrosphere layer (always named "liquid" internally)
    if (layers.elevation && planetData) {
      layers.liquid = calculateWaterLayerFromHydrosphere(layers.elevation);
      if (layers.liquid) {
        console.log('Hydrosphere layer created as liquid:', {
          coverage: (layers.liquid.water_coverage * 100).toFixed(2) + '%',
          sea_level: layers.liquid.sea_level
        });
      }
    }

    if (terrainData && terrainData.decomposed_layers) {
      terrainData = terrainData.decomposed_layers;
      console.log('Using decomposed terrain layers');
    }

    if (!layers.terrain && terrainData) {
      layers.terrain = terrainData;
    }

    console.log('Celestial body:', planetName);
    console.log('Layers extracted:', layers);

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

    const width         = layers.elevation.width;
    const height        = layers.elevation.height;
    const elevationData = layers.elevation.grid;

    if (width === 0 || height === 0) {
      console.error('Invalid terrain dimensions');
      return;
    }

    const adaptive = calculateAdaptiveGrid(planetData, terrainData);
    const tileSize = adaptive.tileSize;
    canvas.width   = adaptive.totalWidth;
    canvas.height  = adaptive.totalHeight;

    // Center the map only once per body, after canvas size is set
    if (!viewport.initialized) {
      const worldWidth  = width  * tileSize * viewport.scale;
      const worldHeight = height * tileSize * viewport.scale;
      viewport.offsetX = (canvas.width  - worldWidth)  / 2;
      viewport.offsetY = (canvas.height - worldHeight) / 2;
      viewport.initialized = true;
    }

    const canvasContainer = document.getElementById('canvasContainer');
    if (canvasContainer) {
      canvasContainer.style.width  = adaptive.totalWidth  + 'px';
      canvasContainer.style.height = adaptive.totalHeight + 'px';
    }
  // ============================================
  // Auto-center viewport helper
  // ============================================

  function autoCenterViewport(canvas, gridWidth, gridHeight, tileSize) {
    const worldWidth  = gridWidth  * tileSize;
    const worldHeight = gridHeight * tileSize;
    viewport.offsetX = (canvas.width  - worldWidth)  / 2;
    viewport.offsetY = (canvas.height - worldHeight) / 2;
  }

    // Min/max elevation
    let minElevation = Infinity;
    let maxElevation = -Infinity;
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const elev = elevationData[y][x];
        if (elev != null) {
          minElevation = Math.min(minElevation, elev);
          maxElevation = Math.max(maxElevation, elev);
        }
      }
    }
    if (minElevation === Infinity)  minElevation = 0;
    if (maxElevation === -Infinity) maxElevation = 1000;
    console.log('Elevation range:', minElevation, 'to', maxElevation);

    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    const hasBiosphere = planetData?.has_biosphere || false;

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const rawElevation = elevationData[y][x];
        const elevationRange = maxElevation - minElevation;
        const normalizedElevation = elevationRange > 0
          ? (rawElevation - minElevation) / elevationRange
          : 0.5;

        let color = getElevationColor(normalizedElevation, planetData);

        // LAYER 1: liquid (hydrosphere)
        if (visibleLayers.has('liquid') &&
            layers.liquid && layers.liquid.grid &&
            layers.liquid.grid[y] && layers.liquid.grid[y][x] > 0) {

          const waterDepth = layers.liquid.grid[y][x];
          let primaryLiquid = 'H2O';

          if (planetData.hydrosphere && planetData.hydrosphere.composition) {
            const comp = planetData.hydrosphere.composition;
            primaryLiquid = Object.keys(comp).reduce(
              (a, b) => comp[a] > comp[b] ? a : b,
              'H2O'
            );
          } else if (planetData.liquid_name) {
            primaryLiquid = planetData.liquid_name;
          }

          const hydroData = Object.assign({}, planetData, { liquid_name: primaryLiquid });
          color = getHydrosphereColor(waterDepth, hydroData);
        }

        // LAYER 2: biomes
        if (visibleLayers.has('biomes') &&
            hasBiosphere &&
            layers.biomes &&
            layers.biomes.grid[y] &&
            layers.biomes.grid[y][x]) {

          const biome = layers.biomes.grid[y][x];
          if (biome && biome !== 'ocean' && biome !== 'none') {
            const isUnderwater =
              layers.liquid && layers.liquid.grid &&
              layers.liquid.grid[y] && layers.liquid.grid[y][x] > 0;

            if (!isUnderwater) {
              color = getBiomeColor(biome);
            }
          }
        }

        // LAYER 3: resources
        if (visibleLayers.has('resources') &&
            layers.resources &&
            layers.resources.grid[y] &&
            layers.resources.grid[y][x]) {
          const resource = layers.resources.grid[y][x];
          if (resource && resource !== 'none') {
            color = blendColors(color, '#FFFF00', 0.4);
          }
        }

        // LAYER 4: SimEarth-style continuous temperature field
        if (visibleLayers.has('temperature') && 
            !(visibleLayers.has('liquid') && layers.liquid?.grid?.[y]?.[x] > 0)) {
          const latitude = (y / height - 0.5) * 180;
          const absLat = Math.abs(latitude);
          // Base temperature model (SimEarth-style latitudinal gradient)
          let tempC = (planetData.surface_temperature || 288) - 273.15;
          // Latitude cooling (poles colder)
          tempC -= absLat * 0.4;  // 40°C pole-equator drop
          // Elevation lapse rate (6.5°C/km)
          const elevationKm = normalizedElevation * 8;  // Scale to realistic range
          tempC -= elevationKm * 6.5;
          // Pressure modification (thin atmosphere = colder)
          const pressureMod = planetData.atmosphere?.pressure || 1.0;
          tempC *= (0.6 + pressureMod * 0.4);
          // Continuous HSL temperature rainbow (SimEarth authentic)
          const hue = Math.max(0, Math.min(240, 40 - tempC * 3));  // Red→Blue
          const saturation = Math.min(90, 50 + Math.abs(tempC) * 0.8);
          const lightness = Math.max(30, 60 - Math.abs(tempC) * 0.4);
          color = `hsl(${hue}, ${saturation}%, ${lightness}%)`;
        }

        // LAYER 5: Data-driven rainfall overlay
        if (visibleLayers.has('rainfall') && planetData.has_hydrosphere) {
          const latitude = (y / height - 0.5) * 180;
          const absLat = Math.abs(latitude);
          // Determine primary liquid and temp
          let primaryLiquid = 'H2O';
          if (planetData.hydrosphere && planetData.hydrosphere.composition) {
            const comp = planetData.hydrosphere.composition;
            primaryLiquid = Object.keys(comp).reduce(
              (a, b) => comp[a] > comp[b] ? a : b,
              'H2O'
            );
          } else if (planetData.liquid_name) {
            primaryLiquid = planetData.liquid_name;
          }
          const liquidUpper = (primaryLiquid || '').toUpperCase();
          const surfaceTemp = planetData.surface_temperature || planetData.temperature || 288;

          // Titan-like: methane/ethane + cold (<150K) + thick atmosphere (>1.2 bar)
          const isTitanLike = (
            (liquidUpper === 'CH4' || liquidUpper === 'C2H6' || liquidUpper.includes('METHANE') || liquidUpper.includes('ETHANE')) &&
            surfaceTemp < 150 &&
            (planetData.atmosphere?.pressure || 1.0) > 1.2
          );

          if (isTitanLike) {
            // Titan: polar methane rainfall
            let methaneWetness = 0;
            if (absLat > 60) {
              methaneWetness = ((90 - absLat) / 30) ** 0.8;
            }
            methaneWetness *= (1.0 - normalizedElevation * 0.2);
            let methaneBoost = 1.0;
            if (layers.liquid?.grid) {
              for (let dy = -1; dy <= 1; dy++) {
                for (let dx = -1; dx <= 1; dx++) {
                  const ny = Math.max(0, Math.min(height-1, y + dy));
                  const nx = Math.max(0, Math.min(width-1, x + dx));
                  if (layers.liquid.grid[ny]?.[nx] > 0) {
                    methaneBoost = 1.6;
                    break;
                  }
                }
              }
            }
            methaneWetness *= methaneBoost;
            methaneWetness = Math.max(0, Math.min(1, methaneWetness));
            const hue = 260 - methaneWetness * 80;
            const saturation = 70 + methaneWetness * 20;
            const lightness = 40 + methaneWetness * 25;
            color = `hsl(${hue}, ${saturation}%, ${lightness}%)`;
          } else if (planetData.has_atmosphere) {
            // Default: SimEarth-style water cycle
            let wetness = Math.sin((90 - absLat) * Math.PI / 180) ** 1.2;
            wetness = Math.max(0.1, wetness);
            const elevationDryness = Math.min(1.0, normalizedElevation * 0.6);
            wetness *= (1.0 - elevationDryness * 0.5);
            let coastalBoost = 1.0;
            if (layers.liquid?.grid) {
              for (let dy = -1; dy <= 1; dy++) {
                for (let dx = -1; dx <= 1; dx++) {
                  if (dx === 0 && dy === 0) continue;
                  const ny = Math.max(0, Math.min(height-1, y + dy));
                  const nx = Math.max(0, Math.min(width-1, x + dx));
                  if (layers.liquid.grid[ny]?.[nx] > 0) {
                    coastalBoost = 1.4;
                    break;
                  }
                }
                if (coastalBoost > 1.0) break;
              }
            }
            wetness *= coastalBoost;
            wetness = Math.max(0.0, Math.min(1.0, wetness));
            if (wetness >= 0.75) {
              const intensity = 30 + (wetness - 0.75) * 40;
              color = `hsl(220, 80%, ${intensity}%)`;
            } else if (wetness >= 0.50) {
              const intensity = 45 + (wetness - 0.50) * 20;
              color = `hsl(200, 70%, ${intensity}%)`;
            } else if (wetness >= 0.30) {
              const intensity = 60 + (wetness - 0.30) * 15;
              color = `hsl(180, 60%, ${intensity}%)`;
            } else if (wetness >= 0.15) {
              const intensity = 70 - (wetness - 0.15) * 20;
              color = `hsl(60, 75%, ${intensity}%)`;
            } else {
              const intensity = 55 - wetness * 15;
              color = `hsl(30, 70%, ${intensity}%)`;
            }
          }
        }

        // LAYER 6: features (mountains, volcanoes, etc.)
        if (visibleLayers.has('features') && hasBiosphere) {
          const biome = layers.biomes?.grid[y]?.[x];
          if (biome && layerOverlays.features.isFeature(biome)) {
            color =
              layerOverlays.features.terrainColors[biome] ||
              layerOverlays.features.terrainColors['rock'];
          } else if (normalizedElevation > 0.85) {
            color = '#808080';
          }
        }

        if (color) {
          ctx.fillStyle = color;
          const screenX = x * tileSize * viewport.scale + viewport.offsetX;
          const screenY = y * tileSize * viewport.scale + viewport.offsetY;
          const screenSize = tileSize * viewport.scale;
          ctx.fillRect(screenX, screenY, screenSize, screenSize);
        }
      }
    }

    console.log(`NASA-first terrain rendered: ${width}x${height}`);
    logConsole(`NASA terrain rendered: ${width}x${height}`, 'success');

    setTimeout(centerMapView, 50);
  }

  // ============================================
  // UI / console helpers (minimal)
  // ============================================

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

  function centerMapView() {
    const scroller = document.getElementById('canvasScroller');
    const canvas   = document.getElementById('planetCanvas');
    if (!scroller || !canvas) return;
    const dx = (canvas.width  - scroller.clientWidth)  / 2;
    const dy = (canvas.height - scroller.clientHeight) / 2;
    scroller.scrollLeft = Math.max(0, dx);
    scroller.scrollTop  = Math.max(0, dy);
  }

  function updateElement(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
  }

  function updateProgressBar(id, percentage) {
    const el = document.getElementById(id);
    if (el) el.style.width = `${percentage}%`;
  }

  // ============================================
  // Layer toggles
  // ============================================

  function toggleLayer(layerName) {
    if (layerName === 'terrain') {
      logConsole('Terrain is the base layer and cannot be disabled', 'warning');
      return;
    }

    // Map UI layer names to internal keys
    let internalLayer = layerName;
    if (layerName === 'water') internalLayer = 'liquid';

    if (visibleLayers.has(internalLayer)) {
      visibleLayers.delete(internalLayer);
      logConsole(`${internalLayer} overlay hidden`, 'info');
    } else {
      visibleLayers.add(internalLayer);
      logConsole(`${internalLayer} overlay shown`, 'info');
    }

    renderTerrainMap();
    updateLayerButtons();
  }

  function updateLayerButtons() {
    document.querySelectorAll('.layer-btn').forEach(btn => {
      const layer = btn.dataset.layer;
      let internalLayer = layer;
      if (layer === 'water') internalLayer = 'liquid';

      if (visibleLayers.has(internalLayer)) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });
  }

  function setupLayerToggles() {
    document.querySelectorAll('.layer-btn').forEach(btn => {
      const layer = btn.dataset.layer;
      btn.addEventListener('click', function() {
        toggleLayer(layer);
      });
    });
  }

  // ============================================
  // Zoom / pan / scroll – kept simple
  // ============================================

  function setupZoomControl() {
    const zoomInput   = document.getElementById('zoom');
    const zoomValue   = document.getElementById('zoomValue');
    const canvas      = document.getElementById('planetCanvas');
    if (!zoomInput || !canvas) return;

    zoomInput.addEventListener('input', function() {
      viewport.scale = parseFloat(this.value);
      if (zoomValue) zoomValue.textContent = viewport.scale.toFixed(1) + 'x';
      renderTerrainMap(); // Redraw at new scale
    });

    if (zoomValue) zoomValue.textContent = viewport.scale.toFixed(1) + 'x';
  }

  function setupScrollableMap() {
    const wrapper  = document.getElementById('canvasWrapper');
    const scroller = document.getElementById('canvasScroller');
    if (!wrapper || !scroller) return;

    const rect          = wrapper.getBoundingClientRect();
    const overlayHeight = 50;

    scroller.style.width     = rect.width + 'px';
    scroller.style.height    = (rect.height - overlayHeight) + 'px';
    scroller.style.position  = 'absolute';
    scroller.style.top       = overlayHeight + 'px';
    scroller.style.left      = '0';
    scroller.style.overflow  = 'auto';
  }

  function setupPanControl() {
    const canvas = document.getElementById('planetCanvas');
    if (!canvas) return;

    canvas.style.cursor = 'grab';

    // Mouse wheel zoom at cursor position
    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      
      // Get mouse position relative to canvas
      const rect = canvas.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;
      
      // Calculate world position before zoom
      const worldXBefore = (mouseX - viewport.offsetX) / viewport.scale;
      const worldYBefore = (mouseY - viewport.offsetY) / viewport.scale;
      
      // Update scale
      const zoomDelta = e.deltaY > 0 ? 0.9 : 1.1;
      viewport.scale = Math.max(0.5, Math.min(4.0, viewport.scale * zoomDelta));
      
      // Calculate world position after zoom
      const worldXAfter = (mouseX - viewport.offsetX) / viewport.scale;
      const worldYAfter = (mouseY - viewport.offsetY) / viewport.scale;
      
      // Adjust offset to keep mouse position fixed
      viewport.offsetX += (worldXAfter - worldXBefore) * viewport.scale;
      viewport.offsetY += (worldYAfter - worldYBefore) * viewport.scale;
      
      // Update UI
      const zoomInput = document.getElementById('zoom');
      const zoomValue = document.getElementById('zoomValue');
      if (zoomInput) zoomInput.value = viewport.scale;
      if (zoomValue) zoomValue.textContent = viewport.scale.toFixed(1) + 'x';
      
      renderTerrainMap();
    }, { passive: false });

    // Mouse drag pan
    canvas.addEventListener('mousedown', e => {
      viewport.isDragging = true;
      viewport.dragStartX = e.clientX;
      viewport.dragStartY = e.clientY;
      viewport.dragStartOffsetX = viewport.offsetX;
      viewport.dragStartOffsetY = viewport.offsetY;
      canvas.style.cursor = 'grabbing';
    });

    canvas.addEventListener('mousemove', e => {
      if (!viewport.isDragging) return;
      e.preventDefault();
      
      const dx = e.clientX - viewport.dragStartX;
      const dy = e.clientY - viewport.dragStartY;
      
      viewport.offsetX = viewport.dragStartOffsetX + dx;
      viewport.offsetY = viewport.dragStartOffsetY + dy;
      
      renderTerrainMap();
    });

    canvas.addEventListener('mouseup', () => {
      viewport.isDragging = false;
      canvas.style.cursor = 'grab';
    });

    canvas.addEventListener('mouseleave', () => {
      viewport.isDragging = false;
      canvas.style.cursor = 'grab';
    });

    const resetBtn = document.getElementById('resetViewBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', resetMapView);
    }
  }

  function resetMapView() {
    viewport.offsetX = 0;
    viewport.offsetY = 0;
    viewport.scale = 1.0;
    viewport.initialized = false;

    const zoomInput = document.getElementById('zoom');
    const zoomValue = document.getElementById('zoomValue');
    if (zoomInput) zoomInput.value = 1.0;
    if (zoomValue) zoomValue.textContent = '1.0x';

    renderTerrainMap();
  }

  // ============================================
  // Data polling (unchanged in spirit)
  // ============================================

  function startDataPolling() {
    if (updateInterval) clearInterval(updateInterval);
    updateInterval = setInterval(updateSphereData, 5000);
    window.monitorUpdateInterval = updateInterval;
  }

  function updateSphereData() {
    if (!planetId) return;
    fetch(`/admin/celestial_bodies/${planetId}/sphere_data`)
      .then(response => response.json())
      .then(data => {
        if (data.atmosphere?.pressure != null) {
          updateElement('atmo-pressure', `${data.atmosphere.pressure.toFixed(4)} bar`);
          updateElement('atmo-temp', `${data.atmosphere.temperature.toFixed(1)} K`);
          updateElement('atmo-mass', formatMass(data.atmosphere.total_mass));
        }

        if (data.hydrosphere?.water_coverage != null) {
          updateElement('hydro-coverage', `${data.hydrosphere.water_coverage.toFixed(1)}%`);
          updateElement('hydro-ocean', formatMass(data.hydrosphere.ocean_mass));
          updateElement('hydro-ice', formatMass(data.hydrosphere.ice_mass));
        }

        if (data.biosphere?.biodiversity_index != null) {
          updateElement('bio-diversity', `${data.biosphere.biodiversity_index.toFixed(1)}%`);
          updateProgressBar('bio-diversity-bar', data.biosphere.biodiversity_index);
          updateElement('bio-habitability', `${data.biosphere.habitable_ratio.toFixed(1)}%`);
          updateProgressBar('bio-habitability-bar', data.biosphere.habitable_ratio);
          updateElement('bio-lifeforms', data.biosphere.life_forms_count);
        }

        if (data.geosphere?.geological_activity != null) {
          updateElement('geo-activity', `${data.geosphere.geological_activity}/100`);
          updateElement('geo-tectonic', data.geosphere.tectonic_active ? 'Yes' : 'No');
          updateElement('geo-volcano', data.geosphere.volcanic_activity);
        }

        // Terrain updates
        if (data.terrain_data &&
            (!terrainData || JSON.stringify(data.terrain_data) !== JSON.stringify(terrainData))) {
          terrainData = data.terrain_data;
          console.log('Terrain data updated, re-rendering map');
          renderTerrainMap();
        }
      })
      .catch(error => {
        console.error('Error updating sphere data:', error);
      });
  }

  // ============================================
  // Init
  // ============================================

  function init() {
    const dataElement    = document.getElementById('monitor-data');
    const canvas         = document.getElementById('planetCanvas');
    const canvasWrapper  = document.getElementById('canvasWrapper');

    if (!dataElement || !canvas || !canvasWrapper) {
      console.log('Monitor page DOM not found; skipping init');
      return;
    }

    if (window.monitorUpdateInterval) {
      clearInterval(window.monitorUpdateInterval);
      window.monitorUpdateInterval = null;
    }

    try {
      const data = JSON.parse(dataElement.textContent);
      monitorData = data;
      planetId    = data.planet_id;
      planetName  = data.planet_name;
      planetType  = data.planet_type;
      terrainData = data.terrain_data;
      planetData  = data.planet_data;

      visibleLayers = new Set(['terrain']);

      const availableLayers = monitorData.available_layers || {
        biomes:     true,
        water:      true,
        resources:  true,
        temperature:true,
        rainfall:   true,
        features:   true
      };

      if (planetData.has_hydrosphere && availableLayers.water) {
        visibleLayers.add('liquid'); // internal name
      }
      if (availableLayers.biomes) {
        visibleLayers.add('biomes');
      }

      const planetTemp    = data.atmosphere_temperature || data.surface_temperature || 288;
      const planetPressure = data.atmosphere_pressure || 1.0;
      climate = calculateClimateZones(planetTemp, planetPressure);
      console.log('Monitor initialized for:', planetName);
    } catch (e) {
      console.error('Error parsing monitor data:', e);
      return;
    }

    setupLayerToggles();
    updateLayerButtons();
    setupZoomControl();
    setupPanControl();
    setupScrollableMap();
    startDataPolling();

    requestAnimationFrame(function() {
      requestAnimationFrame(function() {
        renderTerrainMap();
        logConsole('System initialized', 'info');
      });
    });

    window.addEventListener('beforeunload', function() {
      if (updateInterval) clearInterval(updateInterval);
      window.monitorUpdateInterval = null;
    });
  }

  return {
    init: init,
    renderTerrainMap: renderTerrainMap,
    toggleLayer: toggleLayer,
    logConsole: logConsole
  };
})();

// Single initialization hookup
if (typeof Turbo !== 'undefined') {
  document.addEventListener('turbo:load', AdminMonitor.init);
} else {
  document.addEventListener('DOMContentLoaded', AdminMonitor.init);
}
