# HYDROSPHERE COLOR RENDERING - Composition-Based Colors

## Problem
All hydrospheres currently render as blue, regardless of chemical composition. Titan's methane/ethane lakes show as blue instead of orange/amber. Mars shows liquid oceans instead of ice caps.

## Required Fix

### 1. Rename Button
Change "Water" toggle to "Hydrosphere" toggle in monitor view.

### 2. Implement Composition-Based Colors

The hydrosphere rendering needs to check the `composition` field and render appropriate colors:

```javascript
function getHydrosphereColor(composition) {
  // Water-based (Earth, Europa, Enceladus)
  if (composition.H2O && composition.H2O > 90) {
    return '#1e3a8a';  // Deep blue
  }
  
  // Methane/Ethane (Titan)
  if ((composition.CH4 && composition.CH4 > 50) || 
      (composition.C2H6 && composition.C2H6 > 20)) {
    return '#d97706';  // Orange/amber (liquid hydrocarbons)
  }
  
  // Briny/Salty water (Mars subsurface, high-salt oceans)
  if (composition.salts && composition.salts > 20) {
    return '#0891b2';  // Cyan (high salt content)
  }
  
  // Ammonia-water mixtures (some outer moons)
  if (composition.NH3 && composition.NH3 > 10) {
    return '#7c3aed';  // Purple
  }
  
  // Sulfuric acid (Venus atmosphere - theoretical)
  if (composition.H2SO4 && composition.H2SO4 > 50) {
    return '#eab308';  // Yellow
  }
  
  // CO2 ice/liquid (Mars polar caps)
  if (composition.CO2 && composition.CO2 > 50) {
    return '#f0f0f0';  // White/light gray (dry ice)
  }
  
  // Default to medium blue for any water-like liquid
  return '#2563eb';
}
```

### 3. Respect State Distribution

Mars example shows the issue - hydrosphere should check `state_distribution` before rendering:

```javascript
function renderHydrosphere(ctx, planet, terrainMap) {
  const hydro = planet.hydrosphere;
  if (!hydro) return;
  
  const stateDistribution = hydro.state_distribution;
  
  // If mostly solid (>90%), only render ice caps/glaciers
  if (stateDistribution.solid > 90) {
    renderIceCaps(ctx, planet, terrainMap);
    return;
  }
  
  // If significant liquid (>5%), render liquid bodies
  if (stateDistribution.liquid > 5) {
    const color = getHydrosphereColor(hydro.composition);
    renderLiquidBodies(ctx, planet, terrainMap, color);
  }
  
  // Always render any ice coverage
  if (stateDistribution.solid > 0) {
    renderIceCaps(ctx, planet, terrainMap);
  }
}
```

### 4. Ice Caps vs Liquid Bodies

For Mars (95% solid):
- Render white ice caps at poles (5% surface coverage from `ice_caps.coverage`)
- NO blue oceans
- Optional: Show faint ancient paleoshorelines (historical feature)

For Titan (85% liquid, 10% solid):
- Render orange/amber methane lakes (1.5% coverage from `lakes.coverage`)
- Render white/gray methane ice at poles (seasonal)

For Earth (97% liquid):
- Render blue oceans (71% coverage)
- Render white ice caps at poles (2% coverage)

### 5. Coverage Calculation

Use the actual coverage values from hydrosphere data:

```javascript
function calculateHydrosphereCoverage(planet) {
  const hydro = planet.hydrosphere;
  
  // Check for explicit coverage in liquid_bodies
  if (hydro.liquid_bodies) {
    let totalCoverage = 0;
    
    if (hydro.liquid_bodies.oceans) {
      totalCoverage += hydro.liquid_bodies.oceans.coverage || 0;
    }
    if (hydro.liquid_bodies.lakes) {
      totalCoverage += hydro.liquid_bodies.lakes.coverage || 0;
    }
    if (hydro.liquid_bodies.ice_caps) {
      // Ice caps are separate - render as white, not liquid color
      // Don't add to liquid coverage
    }
    
    return totalCoverage;
  }
  
  // Fallback: use state distribution as rough estimate
  // This is NOT accurate - prefer explicit coverage values
  return null;
}
```

## Expected Results

**Earth with Hydrosphere toggle ON:**
- Deep blue oceans covering ~71% of surface
- White ice caps at poles

**Mars with Hydrosphere toggle ON:**
- White ice caps at north and south poles (small areas)
- NO blue oceans anywhere
- Dry brown terrain everywhere else

**Titan with Hydrosphere toggle ON:**
- Orange/amber methane lakes at poles (small areas, ~1.5% coverage)
- Dark terrain everywhere else (no global ocean)
- Possible white methane ice at extreme poles

## Data References

Mars hydrosphere data shows:
```json
"state_distribution": {
  "solid": 95.0,
  "liquid": 4.5,   // Underground briny flows, NOT surface oceans
  "vapor": 0.5
}
"liquid_bodies": {
  "ice_caps": {
    "coverage": 5.0  // Surface coverage percentage
  }
}
```

Titan hydrosphere data shows:
```json
"composition": {
  "CH4": 65.0,
  "C2H6": 30.0,
  "N2": 5.0
}
"liquid_bodies": {
  "lakes": {
    "coverage": 1.5  // Surface coverage percentage
  }
}
```

## Files to Modify

1. **monitor.html.erb** - Hydrosphere rendering function, button label
2. **Any shared rendering utilities** - getHydrosphereColor(), renderHydrosphere()

## Validation

After implementation:
1. Earth: Blue oceans, realistic coverage
2. Mars: White ice caps only, NO liquid oceans
3. Titan: Orange/amber methane lakes at poles, small coverage
4. Toggle OFF: All show base elevation heightmap only
