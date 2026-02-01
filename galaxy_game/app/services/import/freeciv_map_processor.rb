# app/services/import/freeciv_map_processor.rb
module Import
  class FreecivMapProcessor
    BIOME_ELEVATION_HINTS = {
      ocean: 0.10,
      deep_sea: 0.05,
      swamp: 0.30,
      grasslands: 0.45,
      plains: 0.45,
      desert: 0.50,
      forest: 0.55,
      jungle: 0.40,
      tundra: 0.65,
      boreal: 0.70,
      arctic: 0.75,
      rocky: 0.80
    }.freeze

    def process(freeciv_file_path)
      Rails.logger.info "[FreecivMapProcessor] Processing FreeCiv map: #{freeciv_file_path}"

      # Step 1: Import raw FreeCiv data
      raw_data = FreecivSavImportService.new(freeciv_file_path).import

      # Step 2: Extract biomes (exact from character codes)
      biomes = raw_data[:grid]

      # Step 3: Infer elevation hints from biomes
      elevation_hints = infer_elevation_from_biomes(biomes)

      # Step 4: Generate realistic elevation using constrained Perlin noise
      elevation = generate_constrained_elevation(
        elevation_hints,
        raw_data[:width],
        raw_data[:height]
      )

      # Step 5: Apply smoothing for continuity
      elevation = smooth_elevation(elevation, passes: 3)

      # Step 6: Extract strategic markers for AI learning
      strategic_markers = extract_strategic_markers_from_biomes(biomes)

      # Step 7: Return comprehensive data structure
      {
        lithosphere: {
          elevation: elevation,
          method: 'freeciv_perlin_constrained',
          quality: 'medium_60_70_percent',
          width: raw_data[:width],
          height: raw_data[:height]
        },
        biomes: biomes,
        strategic_markers: strategic_markers,
        source_file: freeciv_file_path,
        metadata: {
          format: 'freeciv_scenario',
          extraction_quality: 'medium',
          ai_learning_potential: 'good'
        }
      }
    end

    private

    def infer_elevation_from_biomes(biome_grid)
      # Convert biome grid to elevation hint grid
      biome_grid.map do |row|
        row.map do |biome_char|
          galaxy_biome = map_freeciv_char_to_galaxy_biome(biome_char)
          BIOME_ELEVATION_HINTS[galaxy_biome] || 0.5
        end
      end
    end

    def map_freeciv_char_to_galaxy_biome(char)
      case char
      when 'a' then :arctic
      when 'd' then :desert
      when 'p' then :plains
      when 'g' then :grasslands
      when 'f' then :forest
      when 'j' then :jungle
      when 'h' then :rocky  # hills
      when 'm' then :rocky  # mountains
      when 's' then :swamp
      when 'o' then :ocean
      when '-' then :deep_sea
      else :plains  # default
      end
    end

    def generate_constrained_elevation(elevation_hints, width, height)
      # Generate Perlin noise constrained by biome elevation hints
      elevation_map = Array.new(height) { Array.new(width) }

      # Simple constrained noise generation
      height.times do |y|
        width.times do |x|
          hint = elevation_hints[y][x]

          # Generate noise around the hint
          noise = generate_perlin_noise(x, y, width, height)
          constrained_noise = constrain_noise_to_hint(noise, hint)

          elevation_map[y][x] = constrained_noise
        end
      end

      elevation_map
    end

    def generate_perlin_noise(x, y, width, height)
      # Simple pseudo-Perlin noise implementation
      # In production, you'd use a proper Perlin noise library

      # Scale coordinates for noise
      scale = 0.05
      nx = x * scale
      ny = y * scale

      # Simple noise function (replace with proper Perlin)
      noise = Math.sin(nx) * Math.cos(ny) * 0.5 + 0.5

      # Add some octaves for more detail
      octave2 = Math.sin(nx * 2) * Math.cos(ny * 2) * 0.25
      octave3 = Math.sin(nx * 4) * Math.cos(ny * 4) * 0.125

      (noise + octave2 + octave3) * 0.5 + 0.25  # Normalize to 0-1 range
    end

    def constrain_noise_to_hint(noise, hint)
      # Constrain noise to be within reasonable range of hint
      range = 0.2  # Allow ±20% variation
      min_val = [hint - range, 0.0].max
      max_val = [hint + range, 1.0].min

      [[noise, min_val].max, max_val].min
    end

    def smooth_elevation(elevation_map, passes: 1)
      passes.times do
        elevation_map = apply_smoothing_pass(elevation_map)
      end
      elevation_map
    end

    def apply_smoothing_pass(elevation_map)
      height = elevation_map.size
      width = elevation_map.first.size

      smoothed = Array.new(height) { Array.new(width) }

      height.times do |y|
        width.times do |x|
          neighbors = get_neighbor_values(elevation_map, x, y)
          current = elevation_map[y][x]

          if neighbors.size > 0
            # Weighted average: current value has more weight
            neighbor_avg = neighbors.sum / neighbors.size.to_f
            smoothed[y][x] = (current * 0.6) + (neighbor_avg * 0.4)
          else
            smoothed[y][x] = current
          end
        end
      end

      smoothed
    end

    def get_neighbor_values(grid, x, y)
      neighbors = []
      [-1, 0, 1].each do |dy|
        [-1, 0, 1].each do |dx|
          next if dx == 0 && dy == 0
          nx, ny = x + dx, y + dy
          if nx >= 0 && nx < grid.first.size && ny >= 0 && ny < grid.size
            neighbors << grid[ny][nx] if grid[ny][nx]
          end
        end
      end
      neighbors
    end

    def extract_strategic_markers_from_biomes(biome_grid)
      markers = {
        resource_deposits: [],
        settlement_sites: [],
        strategic_locations: []
      }

      height = biome_grid.size
      width = biome_grid.first.size

      height.times do |y|
        width.times do |x|
          biome_char = biome_grid[y][x]
          galaxy_biome = map_freeciv_char_to_galaxy_biome(biome_char)

          # Identify potential resource locations based on biome
          if is_resource_rich_biome?(galaxy_biome)
            resource_marker = generate_resource_marker(x, y, galaxy_biome)
            markers[:resource_deposits] << resource_marker
          end

          # Identify settlement sites
          if is_good_settlement_biome?(galaxy_biome)
            settlement_marker = {
              location: [x, y],
              biome: galaxy_biome,
              advantages: analyze_biome_advantages(galaxy_biome),
              priority: calculate_biome_settlement_priority(galaxy_biome)
            }
            markers[:settlement_sites] << settlement_marker
          end

          # Mark strategic locations
          if is_strategic_biome?(galaxy_biome)
            strategic_marker = {
              location: [x, y],
              biome: galaxy_biome,
              type: identify_biome_strategic_type(galaxy_biome),
              value: assess_biome_strategic_value(galaxy_biome)
            }
            markers[:strategic_locations] << strategic_marker
          end
        end
      end

      markers
    end

    def is_resource_rich_biome?(biome)
      # Biomes likely to have resources
      [:rocky, :desert, :tundra, :arctic].include?(biome)
    end

    def is_good_settlement_biome?(biome)
      # Biomes suitable for settlements
      [:grasslands, :plains, :forest].include?(biome)
    end

    def is_strategic_biome?(biome)
      # Biomes with strategic value
      [:coast, :rocky].include?(biome)
    end

    def generate_resource_marker(x, y, biome)
      # Generate plausible resources based on biome
      resource_types = {
        rocky: ['iron_ore', 'copper_ore', 'aluminum_ore'],
        desert: ['rare_earth_elements', 'radioactive_materials'],
        tundra: ['precious_metals', 'hydrocarbons'],
        arctic: ['water_ice', 'methane_deposits']
      }

      possible_resources = resource_types[biome] || ['generic_resources']
      selected_resource = possible_resources.sample

      {
        location: [x, y],
        biome: biome,
        resource: selected_resource,
        quality: ['low', 'medium', 'high'].sample,
        size: ['small', 'medium', 'large'].sample,
        confidence: 0.6  # Lower confidence since inferred from biome
      }
    end

    # Placeholder methods (to be implemented)
    def analyze_biome_advantages(biome); {}; end
    def calculate_biome_settlement_priority(biome); 1; end
    def identify_biome_strategic_type(biome); :unknown; end
    def assess_biome_strategic_value(biome); 1; end
  end
end