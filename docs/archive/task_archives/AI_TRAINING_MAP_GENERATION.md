# AI-Powered Map Generation Strategy - Learning from Training Data

## 🎯 Core Philosophy Shift

**OLD APPROACH** ❌:
- Try to perfectly import Civ4/FreeCiv maps
- Fix all their data issues (elevation, water, biomes)
- Apply bathtub logic that doesn't work right
- Struggle with missing/incorrect data

**NEW APPROACH** ✅:
- Use Civ4/FreeCiv/GeoTIFF as **TRAINING DATA**
- **Learn patterns** from these maps
- **Generate native Galaxy Game maps** using learned patterns
- Maps are PURPOSE-BUILT for our system from day one

---

## 🎓 AI Training Data Sources

### Training Set #1: GeoTIFF (Real Earth Data)
**Use For**: Ground truth elevation, landmass patterns, realistic coastlines

**Data Available**:
- SRTM elevation (90m resolution)
- Real coastlines
- Actual terrain features
- TRUE water vs land

**What AI Learns**:
- "Coastlines are fractal with bays and peninsulas"
- "Mountains form in chains, not randomly"
- "Rivers flow downhill from mountains to ocean"
- "Deserts often have internal drainage basins"
- "Islands cluster near continents"

**Implementation**:
```ruby
class GeoTIFFTrainingExtractor
  def extract_patterns(geotiff_data)
    patterns = {
      coastline_fractality: analyze_coastline_complexity(geotiff_data),
      mountain_chains: detect_mountain_ranges(geotiff_data),
      river_networks: trace_drainage_patterns(geotiff_data),
      landmass_distribution: analyze_continent_placement(geotiff_data),
      elevation_gradients: measure_slope_distributions(geotiff_data)
    }
    
    save_learned_patterns('geotiff_earth', patterns)
  end
  
  private
  
  def analyze_coastline_complexity(data)
    # Measure fractal dimension of coastlines
    coastline_tiles = find_coastline_tiles(data)
    
    {
      fractal_dimension: calculate_fractal_dimension(coastline_tiles),
      bay_frequency: count_bays_per_100km(coastline_tiles),
      peninsula_ratio: measure_peninsula_frequency(coastline_tiles),
      island_proximity: measure_island_clustering(data)
    }
  end
  
  def detect_mountain_ranges(data)
    # Find connected high-elevation regions
    peaks = find_peaks(data, threshold: 0.7)
    chains = cluster_peaks_into_chains(peaks)
    
    {
      average_chain_length: chains.map(&:length).sum / chains.size.to_f,
      chain_orientation: measure_chain_directions(chains),
      peak_density: peaks.size / data.total_area.to_f,
      valley_patterns: analyze_valleys_between_chains(data, chains)
    }
  end
end
```

### Training Set #2: Civ4 Maps (Strategic Placement)
**Use For**: Settlement locations, resource distribution, strategic balance

**Data Available**:
- Starting locations (StartingX, StartingY)
- Resource positions (BonusType)
- River placements
- Strategic chokepoints

**What AI Learns**:
- "Settlements spawn near: rivers + resources + defensible terrain"
- "Resources cluster in specific biomes (iron in hills, gold in mountains)"
- "Strategic balance: similar start positions for fairness"
- "Accessibility: navigable paths between major regions"

**Implementation**:
```ruby
class Civ4StrategicLearner
  def learn_settlement_patterns(civ4_maps)
    patterns = {
      settlement_preferences: {},
      resource_clustering: {},
      balance_metrics: {}
    }
    
    civ4_maps.each do |map|
      map.starting_locations.each do |start|
        # Analyze 5-tile radius around each start
        local_terrain = analyze_area_around(map, start, radius: 5)
        
        patterns[:settlement_preferences][start.civilization] = {
          nearby_water: local_terrain.water_tiles.size,
          nearby_resources: local_terrain.bonus_types,
          elevation: local_terrain.avg_elevation,
          defensibility: calculate_defensibility(local_terrain),
          fertility: count_fertile_tiles(local_terrain)
        }
      end
      
      # Learn resource distribution
      map.resources.group_by(&:type).each do |resource_type, locations|
        patterns[:resource_clustering][resource_type] = {
          preferred_biome: most_common_biome(locations, map),
          preferred_elevation: avg_elevation(locations, map),
          clustering_factor: measure_clustering(locations)
        }
      end
    end
    
    save_learned_patterns('civ4_strategic', patterns)
  end
end
```

### Training Set #3: FreeCiv Maps (Biome Placement)
**Use For**: Climate zones, biome distribution, vegetation patterns

**Data Available**:
- Biome types per tile
- Climate patterns (temperature, rainfall implied)
- Vegetation distribution

**What AI Learns**:
- "Deserts cluster around 30° latitude (Hadley cells)"
- "Forests appear in temperate zones with rainfall"
- "Tundra only in polar regions"
- "Grasslands transition between desert and forest"
- "Jungles require equatorial heat + rainfall"

**Implementation**:
```ruby
class FreecivBiomeLearner
  def learn_biome_patterns(freeciv_maps)
    patterns = {
      latitude_biome_map: {},
      transition_zones: {},
      climate_rules: {}
    }
    
    freeciv_maps.each do |map|
      # Analyze biome distribution by latitude
      map.height.times do |y|
        latitude = ((y / map.height.to_f) - 0.5) * 180
        lat_band = (latitude / 10).round * 10  # 10-degree bands
        
        patterns[:latitude_biome_map][lat_band] ||= Hash.new(0)
        
        map.width.times do |x|
          biome = map.biomes[y][x]
          patterns[:latitude_biome_map][lat_band][biome] += 1
        end
      end
      
      # Learn transition patterns (desert → grassland → forest)
      detect_biome_transitions(map, patterns)
    end
    
    save_learned_patterns('freeciv_biomes', patterns)
  end
  
  private
  
  def detect_biome_transitions(map, patterns)
    # Find where biomes change
    map.biomes.each_with_index do |row, y|
      row.each_with_index do |biome, x|
        neighbors = get_neighbors(map, x, y)
        
        neighbors.each do |neighbor_biome|
          if neighbor_biome != biome
            transition_key = [biome, neighbor_biome].sort.join('_to_')
            patterns[:transition_zones][transition_key] ||= 0
            patterns[:transition_zones][transition_key] += 1
          end
        end
      end
    end
  end
end
```

---

## 🤖 AI Map Generator (Using Learned Patterns)

### Phase 1: Generate Base Topology

```ruby
class AIMapGenerator
  def generate_planet_map(planet, options = {})
    # Load learned patterns from training data
    geotiff_patterns = load_learned_patterns('geotiff_earth')
    
    # Step 1: Generate base elevation using learned gradients
    elevation = generate_elevation_from_patterns(
      width: planet.scaled_width,
      height: planet.scaled_height,
      patterns: geotiff_patterns[:elevation_gradients],
      planet_type: planet.type
    )
    
    # Step 2: Generate coastlines using learned fractality
    landmass = generate_landmass(
      elevation: elevation,
      patterns: geotiff_patterns[:coastline_fractality],
      water_coverage: planet.hydrosphere.water_coverage
    )
    
    # Step 3: Place mountain chains using learned patterns
    mountains = place_mountain_chains(
      elevation: elevation,
      patterns: geotiff_patterns[:mountain_chains]
    )
    
    {
      elevation: elevation,
      landmass: landmass,
      mountains: mountains
    }
  end
  
  private
  
  def generate_elevation_from_patterns(width:, height:, patterns:, planet_type:)
    # Use multi-octave Perlin noise with learned parameters
    noise = PerlinNoise.new(
      octaves: patterns[:recommended_octaves] || 6,
      persistence: patterns[:persistence] || 0.5,
      lacunarity: patterns[:lacunarity] || 2.0
    )
    
    elevation = Array.new(height) { Array.new(width) }
    
    height.times do |y|
      width.times do |x|
        # Generate base noise
        base = noise.octave_noise(x, y, width, height)
        
        # Apply learned gradient distribution
        elevation[y][x] = apply_elevation_curve(base, patterns[:distribution_curve])
      end
    end
    
    elevation
  end
  
  def generate_landmass(elevation:, patterns:, water_coverage:)
    # Calculate water level from coverage percentage
    all_elevations = elevation.flatten.sort
    water_level_index = (all_elevations.size * water_coverage / 100.0).to_i
    water_level = all_elevations[water_level_index]
    
    # Create landmass map (simple bathtub fill)
    landmass = elevation.map do |row|
      row.map { |elev| elev > water_level ? :land : :water }
    end
    
    # Apply learned coastline fractality
    add_fractal_detail_to_coastlines(landmass, patterns)
    
    landmass
  end
  
  def place_mountain_chains(elevation:, patterns:)
    # Find potential mountain locations (high elevation)
    potential_peaks = []
    
    elevation.each_with_index do |row, y|
      row.each_with_index do |elev, x|
        potential_peaks << [x, y] if elev > 0.7
      end
    end
    
    # Cluster into chains using learned orientation
    chains = cluster_into_chains(
      potential_peaks,
      preferred_orientation: patterns[:chain_orientation],
      average_length: patterns[:average_chain_length]
    )
    
    chains
  end
end
```

### Phase 2: Apply Climate & Biomes

```ruby
class AIBiomeGenerator
  def generate_biomes(topology, planet)
    # Load learned biome patterns
    freeciv_patterns = load_learned_patterns('freeciv_biomes')
    
    biomes = Array.new(topology[:height]) { Array.new(topology[:width]) }
    
    topology[:height].times do |y|
      topology[:width].times do |x|
        # Calculate latitude
        latitude = ((y / topology[:height].to_f) - 0.5) * 180
        
        # Get elevation
        elevation = topology[:elevation][y][x]
        
        # Get landmass type
        is_land = topology[:landmass][y][x] == :land
        
        # Determine biome using learned patterns
        biome = if !is_land
                  :ocean
                elsif elevation > 0.8
                  :mountains
                else
                  # Use learned latitude-biome mapping
                  select_biome_from_patterns(
                    latitude: latitude,
                    elevation: elevation,
                    temperature: planet.surface_temperature,
                    patterns: freeciv_patterns[:latitude_biome_map]
                  )
                end
        
        biomes[y][x] = biome
      end
    end
    
    # Apply learned transition smoothing
    smooth_biome_transitions(biomes, freeciv_patterns[:transition_zones])
    
    biomes
  end
  
  private
  
  def select_biome_from_patterns(latitude:, elevation:, temperature:, patterns:)
    # Find closest latitude band
    lat_band = (latitude / 10).round * 10
    
    # Get biome probabilities for this latitude
    biome_probs = patterns[lat_band] || patterns[0]  # Fallback to equator
    
    # Adjust for elevation
    if elevation > 0.6
      # High elevation: prefer tundra/alpine
      biome_probs = biome_probs.merge(tundra: biome_probs[:tundra] * 3)
    elsif elevation < 0.3
      # Low elevation: prefer grasslands
      biome_probs = biome_probs.merge(grasslands: biome_probs[:grasslands] * 2)
    end
    
    # Adjust for temperature
    if temperature > 300  # Hot planet
      biome_probs = biome_probs.merge(desert: biome_probs[:desert] * 2)
    elsif temperature < 260  # Cold planet
      biome_probs = biome_probs.merge(tundra: biome_probs[:tundra] * 3)
    end
    
    # Weighted random selection
    weighted_random_select(biome_probs)
  end
end
```

### Phase 3: Place Strategic Features

```ruby
class AIStrategicPlacer
  def place_features(topology, biomes, planet)
    # Load learned strategic patterns
    civ4_patterns = load_learned_patterns('civ4_strategic')
    
    features = {
      settlements: [],
      resources: [],
      rivers: []
    }
    
    # Place settlement sites using learned preferences
    features[:settlements] = place_settlements(
      topology: topology,
      biomes: biomes,
      patterns: civ4_patterns[:settlement_preferences],
      count: calculate_settlement_count(planet)
    )
    
    # Place resources using learned clustering
    features[:resources] = place_resources(
      topology: topology,
      biomes: biomes,
      patterns: civ4_patterns[:resource_clustering],
      planet: planet
    )
    
    # Generate rivers using drainage patterns
    features[:rivers] = generate_rivers(
      elevation: topology[:elevation],
      landmass: topology[:landmass]
    )
    
    features
  end
  
  private
  
  def place_settlements(topology:, biomes:, patterns:, count:)
    settlements = []
    
    # Find all potential settlement sites
    candidates = []
    
    topology[:height].times do |y|
      topology[:width].times do |x|
        next if topology[:landmass][y][x] != :land
        
        # Score this location using learned preferences
        score = calculate_settlement_score(
          x: x, y: y,
          topology: topology,
          biomes: biomes,
          patterns: patterns
        )
        
        candidates << { x: x, y: y, score: score }
      end
    end
    
    # Select top N locations, ensuring minimum distance
    candidates.sort_by { |c| -c[:score] }.each do |candidate|
      break if settlements.size >= count
      
      # Ensure minimum distance from other settlements
      min_distance = Math.sqrt(topology[:width] * topology[:height]) / 10
      
      if settlements.all? { |s| distance(s, candidate) > min_distance }
        settlements << candidate
      end
    end
    
    settlements
  end
  
  def calculate_settlement_score(x:, y:, topology:, biomes:, patterns:)
    score = 0
    
    # Analyze 5-tile radius
    nearby_water = count_nearby_tiles(x, y, topology[:landmass], :water, radius: 5)
    nearby_elevation = avg_nearby_elevation(x, y, topology[:elevation], radius: 5)
    nearby_biomes = count_nearby_biomes(x, y, biomes, radius: 5)
    
    # Apply learned preferences
    score += nearby_water * patterns[:water_value] || 10
    score += (1 - (nearby_elevation - 0.4).abs) * 100  # Prefer moderate elevation
    score += nearby_biomes[:grasslands] * 5  # Grasslands = good farming
    score += nearby_biomes[:forest] * 3      # Forests = good production
    
    score
  end
end
```

---

## 🎯 Complete Pipeline

### Training Phase (One-Time Setup):

```ruby
# 1. Extract patterns from training data
geotiff_extractor = GeoTIFFTrainingExtractor.new
geotiff_extractor.extract_patterns(load_srtm_earth)

freeciv_learner = FreecivBiomeLearner.new
freeciv_learner.learn_biome_patterns(load_all_freeciv_maps)

civ4_learner = Civ4StrategicLearner.new
civ4_learner.learn_settlement_patterns(load_all_civ4_maps)

# Patterns are saved to: data/ai_patterns/
```

### Generation Phase (Per Planet):

```ruby
# 2. Generate map using learned patterns
planet = CelestialBody.find_by(name: 'Kepler-442b')

generator = AIMapGenerator.new
topology = generator.generate_planet_map(planet)

biome_gen = AIBiomeGenerator.new
biomes = biome_gen.generate_biomes(topology, planet)

strategic = AIStrategicPlacer.new
features = strategic.place_features(topology, biomes, planet)

# 3. Save to planet
planet.geosphere.update!(
  terrain_map: {
    elevation: topology[:elevation],
    landmass: topology[:landmass],
    biomes: biomes,
    mountains: topology[:mountains],
    settlements: features[:settlements],
    resources: features[:resources],
    rivers: features[:rivers],
    metadata: {
      generated_at: Time.current,
      method: 'ai_learned_patterns',
      training_sources: ['geotiff_earth', 'freeciv_maps', 'civ4_maps'],
      planet_radius: planet.radius,
      water_coverage: planet.hydrosphere.water_coverage,
      temperature: planet.surface_temperature
    }
  }
)
```

---

## 📊 Advantages of This Approach

### ✅ Pros:

1. **Native Format**: Maps are PURPOSE-BUILT for Galaxy Game
   - No import/export issues
   - No missing data
   - No format translation bugs

2. **Scalable**: Works for ANY planet size
   - Automatic radius scaling (already implemented!)
   - 180×90 Earth, 131×66 Mars, 94×47 Moon, 42×26 Europa, etc.

3. **Realistic**: Learns from REAL Earth data
   - Coastlines have realistic fractality
   - Mountains form in chains
   - Biomes follow climate rules

4. **Balanced**: Learns from GAME maps (Civ4/FreeCiv)
   - Settlements spawn in good locations
   - Resources are strategically placed
   - Fairness and playability built-in

5. **Flexible**: Can blend patterns
   - Earth-like planets: 80% GeoTIFF, 20% procedural
   - Alien planets: 20% GeoTIFF, 80% procedural
   - Terraformed planets: Evolve over time

6. **No Bathtub Issues**: Water level calculated PROPERLY
   - Sort all elevations
   - Find Nth percentile for water coverage
   - Everything below = water, everything above = land
   - No weird flooding of inland basins

### ❌ Import Approach Problems (That We Avoid):

- Civ4: Missing elevation detail, binary PlotType
- FreeCiv: No real elevation data at all
- Both: Not designed for our system
- Bathtub: Fills Sahara, Great Basin, Dead Sea area (all below sea level but not ocean)

---

## 🚀 Implementation Priority

### Phase 1: Core Generator (This Week)

- [ ] Implement AIMapGenerator.generate_planet_map
- [ ] Use existing Perlin noise (already have this!)
- [ ] Calculate water level from sorted elevations
- [ ] Test on Earth, Mars, Luna

### Phase 2: Pattern Learning (Next Week)

- [ ] Implement GeoTIFFTrainingExtractor
- [ ] Load SRTM Earth data
- [ ] Extract coastline/mountain/elevation patterns
- [ ] Save to data/ai_patterns/geotiff_earth.json

### Phase 3: Biome Intelligence (Week 3)

- [ ] Implement FreecivBiomeLearner
- [ ] Analyze existing FreeCiv maps
- [ ] Learn latitude→biome mappings
- [ ] Integrate into generation

### Phase 4: Strategic Features (Week 4)

- [ ] Implement Civ4StrategicLearner
- [ ] Extract settlement preferences
- [ ] Learn resource clustering
- [ ] Add to generation pipeline

---

## 🎯 Expected Results

### Generated Earth Map:

```
Dimensions: 180×90 (scaled from radius)
Water Coverage: 71% (from planet.hydrosphere.water_coverage)
Elevation Range: 0.05-0.95 (realistic distribution)
Biomes:
  - Oceans: 71% (dark blue)
  - Grasslands: 12% (light green)
  - Desert: 8% (yellow-brown)
  - Forest: 5% (dark green)
  - Tundra: 3% (white-grey)
  - Mountains: 1% (white peaks)

Features:
  - 12 settlement sites (learned from Civ4)
  - 250 resource deposits (iron in hills, gold in mountains)
  - 45 rivers (flowing downhill to ocean)
  - Realistic coastlines (fractal bays and peninsulas)
```

### Generated Kepler-442b (Exoplanet):

```
Dimensions: 94×59 (scaled from radius: 1.34× Earth)
Water Coverage: 45% (from spectrographic analysis)
Temperature: 233K (cold!)
Elevation Range: 0.1-0.9 (learned distribution)
Biomes:
  - Ice Sheets: 60% (frozen water)
  - Tundra: 25% (cold but livable)
  - Boreal Forest: 10% (hardy trees)
  - Rocky Barrens: 5% (exposed rock)

Features:
  - 8 potential settlement sites
  - Ice deposits (water source)
  - Geothermal vents (heat source)
  - Realistic icy coastlines
```

This approach gives you the BEST of all worlds:
- Real Earth data patterns
- Game balance from Civ4/FreeCiv
- Native Galaxy Game format
- Scalable to any planet! 🌍→🪐
