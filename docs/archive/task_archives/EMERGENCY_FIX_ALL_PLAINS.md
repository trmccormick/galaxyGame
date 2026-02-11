# Emergency Fix - All Terrain Showing as 'Plains'

## 🔴 Critical Issue Identified

**Symptom**: Map renders but shows only 'plains' everywhere
```
Terrain types found: ['plains']
Sample grid data: ['plains', 'plains', 'plains', 'plains', 'plains']
```

**Expected**: Should show varied terrain like `['grasslands', 'ocean', 'desert', 'forest', ...]`

---

## 🔍 Root Cause Analysis

### The Problem Chain:

1. **Generated JSON has biome codes** ('g', 'o', 'p', 'f', 'd')
2. **Monitor expects full names** ('grasslands', 'ocean', 'plains', 'forest', 'desert')
3. **Conversion is happening but BACKWARDS**

### The Evidence:

**From console logs**:
```javascript
Sample grid data: ['plains', 'plains', 'plains', 'plains', 'plains']
```

**This means**:
- All terrain is being normalized to 'plains'
- The original biome codes ('g', 'o', 'f', etc.) are being lost
- Something is converting EVERYTHING to 'plains'

---

## 🐛 The Bug Location

### In monitor.html.erb - normalizeTerrainType function

**Current code** (likely):
```javascript
function normalizeTerrainType(code) {
  const freecivTerrainMap = {
    'g': 'grasslands',
    'p': 'plains',
    'f': 'forest',
    'd': 'desert',
    'o': 'ocean',
    // ... etc
  };
  
  // If code is already a full name, return as-is
  if (Object.values(freecivTerrainMap).includes(code)) {
    return code;
  }
  
  // Otherwise convert code to name
  return freecivTerrainMap[code] || 'plains';  // ← DEFAULT TO 'plains'
}
```

**The Problem**:
- Generated map has codes: `['g', 'o', 'p', 'f', 'd']`
- These should be converted to names
- BUT: If the input is NOT in the map, it defaults to 'plains'
- This means **the codes aren't being recognized!**

---

## 🔬 Detailed Diagnosis

### Check What's Actually in terrain_map:

Add this debug to monitor.html.erb:

```javascript
// RIGHT AFTER: layers = extractLayers(...)
console.log("=== TERRAIN DATA DEEP DEBUG ===");
console.log("Raw terrain layer:", layers.terrain);

if (layers.terrain && layers.terrain.grid) {
  console.log("Terrain grid first row:", layers.terrain.grid[0]);
  console.log("First 5 values RAW:", layers.terrain.grid[0].slice(0, 5));
  
  // Check data types
  console.log("Type of first value:", typeof layers.terrain.grid[0][0]);
  console.log("First value is:", JSON.stringify(layers.terrain.grid[0][0]));
  
  // Try normalization
  console.log("After normalization:", 
    layers.terrain.grid[0].slice(0, 5).map(normalizeTerrainType)
  );
}

console.log("=== END DEBUG ===");
```

### Possible Issues:

#### Issue 1: Data is Already Full Names
```javascript
// If terrain_map.terrain contains:
[['plains', 'plains', 'grasslands', ...], ...]

// Then normalization sees 'plains', checks if it's in values:
Object.values(freecivTerrainMap).includes('plains')  // true

// Returns 'plains' as-is ✅

// BUT if there's a typo or extra space:
'plains ' !== 'plains'  // false
// Falls through to default → 'plains' ❌
```

#### Issue 2: Data is Symbols Not Strings
```javascript
// If terrain_map.terrain contains:
[[:plains, :plains, :grasslands, ...], ...]

// Then:
typeof :plains  // 'symbol'
freecivTerrainMap[:plains]  // undefined
// Falls through to default → 'plains' ❌
```

#### Issue 3: Data is Uppercase
```javascript
// If terrain_map.terrain contains:
[['PLAINS', 'PLAINS', 'GRASSLANDS', ...], ...]

// Then:
'PLAINS' !== 'plains'
// Falls through to default → 'plains' ❌
```

---

## ✅ The Fix

### Option 1: Check Actual Data Structure First

```javascript
function normalizeTerrainType(code) {
  // Handle null/undefined
  if (!code) return 'plains';
  
  // Convert symbol to string if needed
  if (typeof code === 'symbol') {
    code = code.toString().replace('Symbol(', '').replace(')', '');
  }
  
  // Convert to lowercase for comparison
  const lowerCode = code.toString().toLowerCase().trim();
  
  const freecivTerrainMap = {
    'g': 'grasslands',
    'p': 'plains',
    'f': 'forest',
    'd': 'desert',
    'o': 'ocean',
    't': 'tundra',
    'a': 'arctic',
    's': 'swamp',
    'j': 'jungle',
    'h': 'hills',
    'm': 'mountains',
    'r': 'rocky'
  };
  
  // Check if it's a single-character code
  if (lowerCode.length === 1 && freecivTerrainMap[lowerCode]) {
    return freecivTerrainMap[lowerCode];
  }
  
  // Check if it's already a full name
  const validTerrainNames = Object.values(freecivTerrainMap);
  if (validTerrainNames.includes(lowerCode)) {
    return lowerCode;
  }
  
  // Check if it's a capitalized version
  if (validTerrainNames.map(t => t.toUpperCase()).includes(code.toUpperCase())) {
    return lowerCode;
  }
  
  // Log unknown terrain types for debugging
  console.warn("Unknown terrain type:", code, "- defaulting to plains");
  return 'plains';
}
```

### Option 2: Check the Source Data

The problem might be earlier - in how `apply_map_to_celestial_body` stores the data.

**In MapStudioController** (line 299-318):
```ruby
def apply_map_to_celestial_body(celestial_body, map_data)
  geosphere = celestial_body.geosphere || celestial_body.build_geosphere

  # Apply terrain map
  if map_data['terrain_grid']
    terrain_map_data = {
      grid: map_data['terrain_grid'],  # ← What's in here?
      width: map_data.dig('metadata', 'width') || map_data['terrain_grid'].first&.size || 0,
      height: map_data.dig('metadata', 'height') || map_data['terrain_grid'].size,
      biome_counts: map_data['biome_counts'] || {}
    }
    geosphere.update!(terrain_map: terrain_map_data)
  end
  
  # ...
end
```

**Issue**: This stores `terrain_grid` in `geosphere.terrain_map.grid`

**But monitor extracts** from `geosphere.terrain_map` differently!

---

## 🔧 Emergency Fix Steps

### Step 1: Check What's Actually Stored

```ruby
# In Rails console
earth = CelestialBody.find_by(name: 'Earth')
terrain_map = earth.geosphere.terrain_map

# Check structure
puts "Keys: #{terrain_map.keys}"
# Should show: ["grid", "width", "height", "biome_counts"]

# Check first row
puts "First row: #{terrain_map['grid'][0].first(10).inspect}"
# What does this show?

# Check data type
puts "Type: #{terrain_map['grid'][0][0].class}"
# String? Symbol?

# Check actual values
puts "Sample values:"
terrain_map['grid'][0].first(20).each_with_index do |val, i|
  puts "  [#{i}]: #{val.inspect} (#{val.class})"
end
```

### Step 2: Fix Based on What's Found

**If all values are 'p'**:
```ruby
# Problem: Generator is converting everything to 'p' (plains code)
# Fix: Check apply_source_to_grid in PlanetaryMapGenerator
# Make sure biome_code conversion is working correctly
```

**If values are symbols** (:plains):
```ruby
# Problem: Symbols not converted to strings
# Fix in apply_map_to_celestial_body:

if map_data['terrain_grid']
  # Convert symbols to strings
  grid = map_data['terrain_grid'].map do |row|
    row.map { |cell| cell.is_a?(Symbol) ? cell.to_s : cell }
  end
  
  terrain_map_data = {
    grid: grid,  # ← Converted grid
    # ...
  }
end
```

**If values are correct codes** ('g', 'o', 'f'):
```ruby
# Problem: Monitor's normalizeTerrainType isn't recognizing them
# Fix: Update normalizeTerrainType function as shown in Option 1 above
```

### Step 3: Quick Test

```javascript
// In browser console on monitor page
console.log("Testing normalization:");
['g', 'o', 'p', 'f', 'd', 't', 'plains', 'ocean'].forEach(code => {
  console.log(`  ${code} → ${normalizeTerrainType(code)}`);
});

// Should show:
//   g → grasslands
//   o → ocean
//   p → plains
//   f → forest
//   d → desert
//   t → tundra
//   plains → plains
//   ocean → ocean
```

---

## 🎯 Most Likely Issue

Based on the logs showing **ONLY 'plains'**, my bet is:

**The biome_code conversion in PlanetaryMapGenerator isn't working**

### Check apply_source_to_grid:

```ruby
# Line ~112 in planetary_map_generator.rb
biome = row[source_x]

# Convert biome to code if it's a symbol
biome_code = biome.is_a?(Symbol) ? convert_biome_to_code(biome) : biome
```

**Problem**: If `biome` is `:plains`, `convert_biome_to_code` returns 'p'
**Then**: All plains stay as 'p' ✅
**BUT**: If ALL biomes are `:plains` in source, ALL output is 'p' ❌

### The Real Problem:

**Source map has symbols**: `[[:plains, :plains, :plains, ...], ...]`
**All same biome**: Only plains in the source!

**This means**: The source map itself is bad - it doesn't have varied terrain!

---

## 🚨 Immediate Action

### Check the Source Map:

```ruby
# In Rails console
# Load the actual source map
processor = Import::FreecivMapProcessor.new
data = processor.process(Rails.root.join('data/maps/freeciv/earth-180x90-v1-3.sav').to_s)

# Check biomes
puts "Biomes sample:"
puts data[:biomes][0].first(20).inspect

# Count biome variety
all_biomes = data[:biomes].flatten.uniq
puts "Unique biomes found: #{all_biomes.inspect}"
puts "Count: #{all_biomes.size}"

# Should show multiple types!
# If it shows only [:plains], the processor is broken!
```

---

## 💡 Quick Fix for Grok

**Most likely issue**: Source map processing returning all plains

**Tell Grok**:

1. Add this debug to **beginning** of `combine_source_maps` in PlanetaryMapGenerator:

```ruby
def combine_source_maps(sources, planet, options)
  Rails.logger.info "=== SOURCE MAP DEBUG ==="
  
  sources.each_with_index do |source, i|
    source_biomes = source.dig(:data, :biomes)
    
    if source_biomes
      sample = source_biomes[0].first(10)
      unique = source_biomes.flatten.uniq
      
      Rails.logger.info "Source #{i}: #{source[:filename]}"
      Rails.logger.info "  Sample row: #{sample.inspect}"
      Rails.logger.info "  Unique biomes: #{unique.inspect} (#{unique.size} types)"
    end
  end
  
  # ... rest of method
end
```

2. Generate a map and check Rails logs for "Unique biomes:"

3. **If shows only [:plains]**: The FreecivMapProcessor is broken
   **If shows varied biomes**: The conversion is broken

Then we'll know exactly where to fix! 🎯
