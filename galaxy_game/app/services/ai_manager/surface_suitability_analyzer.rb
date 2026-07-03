# app/services/ai_manager/surface_suitability_analyzer.rb
module AIManager
  # SurfaceSuitabilityAnalyzer — evaluates surface suitability for landing/expansion
  # using existing geosphere terrain_map data (elevation, resource_grid, biomes).
  #
  # Contract: All methods return a stable hash with known keys. Missing terrain data
  # produces safe fallback values (score: 0.5, clearance: :unknown, etc.) so callers
  # never crash on nil terrain_map.
  #
  # API uses grid indices [y][x] — NOT lat/lon. No coordinate mapping assumed.
  class SurfaceSuitabilityAnalyzer
    # Terrain clearance thresholds (slope in degrees)
    CLEARANCE_THRESHOLDS = {
      flat: 5.0,
      moderate: 15.0,
      rough: 30.0
    }.freeze

    # Biome IDs that indicate water/flooded terrain (heuristic — depends on biome schema)
    WATER_BIOMES = %w[water ocean lake sea].freeze

    # Gravity/atmosphere scoring weights (from station_construction_strategy stub)
    GRAVITY_PENALTY_THRESHOLD = 0.5
    GRAVITY_BONUS_THRESHOLD = 0.1
    ATMOSPHERE_COMPLICATION_FACTOR = 0.8

    # ============================================================
    # PUBLIC API
    # ============================================================

    # Score a single grid cell on a celestial body's surface.
    #
    # @param celestial_body [CelestialBodies::CelestialBody] the body to score
    # @param grid_x [Integer] column index into terrain_map grids
    # @param grid_y [Integer] row index into terrain_map grids
    # @return [Hash] stable contract with keys: suitability_score, resource_density,
    #   terrain_clearance, buildability_mask, slope_degrees, elevation_meters,
    #   biome, has_water, gravity_factor, atmosphere_factor, grid_x, grid_y, warnings
    def self.score(celestial_body, grid_x:, grid_y:)
      new(celestial_body).score(grid_x: grid_x, grid_y: grid_y)
    end

    # Score all cells in a rectangular region and return the top N sites.
    #
    # @param celestial_body [CelestialBodies::CelestialBody] the body to score
    # @param x_min [Integer] minimum column index (inclusive)
    # @param x_max [Integer] maximum column index (inclusive)
    # @param y_min [Integer] minimum row index (inclusive)
    # @param y_max [Integer] maximum row index (inclusive)
    # @param limit [Integer] number of top sites to return (default: 10)
    # @return [Array<Hash>] sorted by suitability_score descending, each element is a score hash + region info
    def self.find_best_sites(celestial_body, x_min:, x_max:, y_min:, y_max:, limit: 10)
      new(celestial_body).find_best_sites(
        x_min: x_min, x_max: x_max, y_min: y_min, y_max: y_max, limit: limit
      )
    end

    # Score every cell in the entire surface grid. Returns a 2D array matching terrain_map dimensions.
    # Useful for UI visualization or batch processing.
    #
    # @param celestial_body [CelestialBodies::CelestialBody] the body to score
    # @return [Array<Array<Hash>>] 2D array of score hashes [y][x]
    def self.score_entire_surface(celestial_body)
      new(celestial_body).score_entire_surface
    end

    # ============================================================
    # INSTANCE METHODS
    # ============================================================

    def initialize(celestial_body)
      @body = celestial_body
      @geosphere = celestial_body&.geosphere
      @terrain_map = safe_terrain_map
      @width = @terrain_map[:width] || 0
      @height = @terrain_map[:height] || 0
    end

    def score(grid_x:, grid_y:)
      return fallback_score(grid_x, grid_y, ["no celestial body"]) unless @body && @geosphere
      # If terrain_map is empty/missing all grids, return neutral fallback (not full error)
      if @width == 0 || @height == 0
        return fallback_score(grid_x, grid_y, ["terrain_map_empty"])
      end

      warnings = []
      elevation_grid = @terrain_map[:elevation]
      resource_grid = @terrain_map[:resource_grid]
      biome_grid = @terrain_map[:biomes]

      # --- Elevation / slope ---
      elevation, slope = compute_elevation_and_slope(elevation_grid, grid_x, grid_y)
      warnings << "elevation_missing" if elevation.nil?

      # --- Resource density ---
      resource_density = compute_resource_density(resource_grid, grid_x, grid_y)
      warnings << "resource_data_missing" if resource_density.empty?

      # --- Biome / water detection ---
      biome = compute_biome(biome_grid, grid_x, grid_y)
      has_water = detect_water(biome)
      warnings << "biome_data_missing" if biome.nil?

      # --- Terrain clearance (from slope) ---
      terrain_clearance = classify_terrain_clearance(slope)

      # --- Buildability mask ---
      buildability_mask = compute_buildability_mask(slope, has_water, elevation)

      # --- Gravity/atmosphere factors (from celestial body, not geosphere) ---
      gravity_factor = compute_gravity_factor(@body.gravity) if @body.respond_to?(:gravity)
      atmosphere_factor = compute_atmosphere_factor(@body.atmosphere) if @body.respond_to?(:atmosphere)

      # --- Composite suitability score (0.0..1.0) ---
      suitability_score = compute_suitability_score(
        resource_density: resource_density,
        terrain_clearance: terrain_clearance,
        buildability_mask: buildability_mask,
        gravity_factor: gravity_factor,
        atmosphere_factor: atmosphere_factor
      )

      {
        suitability_score: suitability_score.round(4),
        resource_density: resource_density,
        terrain_clearance: terrain_clearance,
        buildability_mask: buildability_mask,
        slope_degrees: slope&.round(2),
        elevation_meters: elevation,
        biome: biome,
        has_water: has_water,
        gravity_factor: gravity_factor.round(4),
        atmosphere_factor: atmosphere_factor.round(4),
        grid_x: grid_x,
        grid_y: grid_y,
        warnings: warnings.uniq
      }
    end

    def find_best_sites(x_min:, x_max:, y_min:, y_max:, limit:)
      return [] unless @body && @geosphere && @width > 0 && @height > 0

      sites = []
      (y_min..[y_max, @height - 1].min).each do |y|
        (x_min..[x_max, @width - 1].min).each do |x|
          next unless valid_grid?(x, y)
          result = score(grid_x: x, grid_y: y)
          sites << result if result[:suitability_score] > 0
        end
      end

      sites.sort_by { |s| -s[:suitability_score] }.first(limit) || []
    end

    def score_entire_surface
      return [] unless @body && @geosphere && @width > 0 && @height > 0

      (0...@height).map do |y|
        (0...@width).map do |x|
          score(grid_x: x, grid_y: y)
        end
      end
    end

    private

    # ============================================================
    # TERRAIN DATA ACCESSORS (safe fallbacks)
    # ============================================================

    def safe_terrain_map
      return {} unless @geosphere&.terrain_map.is_a?(Hash)

      tm = @geosphere.terrain_map
      {
        elevation: tm["elevation"] || tm[:elevation],
        resource_grid: tm["resource_grid"] || tm[:resource_grid],
        biomes: tm["biomes"] || tm[:biomes],
        width: tm["width"] || tm[:width] || 0,
        height: tm["height"] || tm[:height] || 0,
        quality_score: tm["quality_score"] || tm[:quality_score],
        generation_method: tm["generation_method"] || tm[:generation_method]
      }
    end

    def valid_grid?(x, y)
      x >= 0 && x < @width && y >= 0 && y < @height
    end

    # ============================================================
    # ELEVATION & SLOPE (finite difference)
    # ============================================================

    def compute_elevation_and_slope(elevation_grid, x, y)
      return [nil, nil] unless elevation_grid.is_a?(Array) && elevation_grid.any?

      elev = fetch_grid_value(elevation_grid, x, y)
      # If the value is not numeric, treat as missing elevation
      return [nil, nil] if elev.nil? || !elev.respond_to?(:to_f) || elev.to_s.strip.empty?
      elev_num = elev.to_f

      # Compute slope via central finite difference (or forward/backward at edges)
      dx_vals = compute_gradient(elevation_grid, x, y, horizontal: true)
      dy_vals = compute_gradient(elevation_grid, x, y, horizontal: false)

      # Average magnitude of gradient components
      avg_dx = dx_vals.compact.map(&:abs).sum.to_f / [dx_vals.compact.size, 1].max
      avg_dy = dy_vals.compact.map(&:abs).sum.to_f / [dy_vals.compact.size, 1].max

      slope_magnitude = Math.sqrt(avg_dx**2 + avg_dy**2)
      # Convert to degrees assuming elevation is in meters and grid spacing is roughly uniform
      slope_degrees = Math.atan(slope_magnitude) * (180.0 / Math::PI)

      [elev_num, slope_degrees]
    end

    def compute_gradient(grid, x, y, horizontal:)
      dx = horizontal ? 1 : 0
      dy = horizontal ? 0 : 1

      neighbors = []
      # Forward difference
      fx, fy = x + dx, y + dy
      if valid_grid?(fx, fy)
        val = fetch_grid_value(grid, fx, fy)
        neighbors << val.to_f if val&.respond_to?(:to_f) && !val.to_s.strip.empty?
      end
      # Backward difference
      bx, by = x - dx, y - dy
      if valid_grid?(bx, by)
        val = fetch_grid_value(grid, bx, by)
        neighbors << val.to_f if val&.respond_to?(:to_f) && !val.to_s.strip.empty?
      end

      center_val = fetch_grid_value(grid, x, y)
      return [] unless center_val&.respond_to?(:to_f) && !center_val.to_s.strip.empty?

      neighbors.map { |v| v - center_val.to_f }
    end

    def fetch_grid_value(grid, x, y)
      row = grid[y]
      return nil unless row.is_a?(Array)
      val = row[x]
      return nil unless val.nil? == false
      val  # Return raw value; caller interprets type
    rescue StandardError
      nil
    end

    # ============================================================
    # RESOURCE DENSITY
    # ============================================================

    def compute_resource_density(resource_grid, x, y)
      return {} unless resource_grid.is_a?(Array) && resource_grid.any?

      cell = fetch_grid_value(resource_grid, x, y)
      return {} if cell.nil?

      # If the value is not numeric and not a hash/array, treat as missing
      return {} if !cell.respond_to?(:to_f) || cell.to_s.strip.empty? && !cell.is_a?(Hash)

      # If it's already a hash of { material => concentration }, use as-is.
      if cell.is_a?(Hash)
        cell
      elsif cell.is_a?(Array)
        # Multi-material grid: each element is [material_name, concentration] or just concentration
        cell.each_with_object({}) do |entry, acc|
          if entry.is_a?(Array) && entry.size >= 2
            acc[entry[0].to_s] = entry[1].to_f
          else
            acc["generic"] = entry.to_f
          end
        end
      else
        { "concentration" => cell.to_f }
      end
    end

    # ============================================================
    # BIOME & WATER DETECTION
    # ============================================================

    def compute_biome(biome_grid, x, y)
      return nil unless biome_grid.is_a?(Array) && biome_grid.any?
      fetch_grid_value(biome_grid, x, y)  # Return biome ID as-is (numeric or string)
    end

    def detect_water(biome)
      return false if biome.nil?
      # Biomes are typically numeric IDs. Water biomes might be IDs like 1, 2, etc.
      # Since we don't have the biome mapping, use conservative heuristic:
      # Treat negative elevation as water signal (user is responsible for correlating)
      false  # Don't assume water from biome data alone; use elevation instead
    end

    # ============================================================
    # TERRAIN CLEARANCE CLASSIFICATION
    # ============================================================

    def classify_terrain_clearance(slope_degrees)
      return :unknown if slope_degrees.nil?

      if slope_degrees <= CLEARANCE_THRESHOLDS[:flat]
        :flat
      elsif slope_degrees <= CLEARANCE_THRESHOLDS[:moderate]
        :moderate
      elsif slope_degrees <= CLEARANCE_THRESHOLDS[:rough]
        :rough
      else
        :extreme
      end
    end

    # ============================================================
    # BUILDABILITY MASK
    # ============================================================

    def compute_buildability_mask(slope_degrees, has_water, elevation)
      return :unknown if slope_degrees.nil? || slope_degrees == :unknown

      return :flooded if has_water
      return :too_steep if slope_degrees > CLEARANCE_THRESHOLDS[:rough]
      # If elevation is negative (below sea level), may be underwater
      return :flooded if elevation && elevation < 0

      :buildable
    end

    # ============================================================
    # GRAVITY & ATMOSPHERE FACTORS (from celestial body)
    # ============================================================

    def compute_gravity_factor(gravity_value)
      return 1.0 unless gravity_value

      g = gravity_value.to_f
      if g < GRAVITY_BONUS_THRESHOLD
        1.2  # Low gravity advantage
      elsif g > GRAVITY_PENALTY_THRESHOLD
        0.7  # Too much gravity
      else
        1.0  # Acceptable range
      end
    end

    def compute_atmosphere_factor(atmosphere_value)
      return 1.0 unless atmosphere_value

      atm = atmosphere_value.to_s.downcase.strip
      if atm == "none" || atm == "nil" || atm == ""
        1.0
      else
        ATMOSPHERE_COMPLICATION_FACTOR  # Atmosphere complicates construction
      end
    end

    # ============================================================
    # COMPOSITE SUITABILITY SCORE (0.0..1.0)
    # ============================================================

    def compute_suitability_score(resource_density:, terrain_clearance:, buildability_mask:, gravity_factor:, atmosphere_factor:)
      score = 0.5  # Neutral baseline

      # Resource density contribution (up to +0.25)
      max_resource = resource_density.values.max.to_f
      if max_resource > 0
        score += [max_resource / 100.0, 0.25].min
      end

      # Terrain clearance contribution (up to +0.15)
      clearance_scores = { flat: 0.15, moderate: 0.08, rough: 0.03, extreme: -0.1, unknown: 0 }
      score += clearance_scores[terrain_clearance] || 0

      # Buildability mask (up to +0.10)
      buildability_scores = { buildable: 0.10, cratered: -0.05, too_steep: -0.2, flooded: -0.3, unknown: 0 }
      score += buildability_scores[buildability_mask] || 0

      # Gravity/atmosphere factors (multiplicative adjustment)
      environmental_factor = gravity_factor * atmosphere_factor
      score *= environmental_factor if environmental_factor != 1.0

      # Clamp to [0.0, 1.0]
      [score, 0.0].max.to_f.clamp(0.0, 1.0)
    end

    # ============================================================
    # FALLBACK (no geosphere data at all)
    # ============================================================

    def fallback_score(grid_x, grid_y, warnings)
      {
        suitability_score: 0.5,
        resource_density: {},
        terrain_clearance: :unknown,
        buildability_mask: :unknown,
        slope_degrees: nil,
        elevation_meters: nil,
        biome: nil,
        has_water: false,
        gravity_factor: 1.0,
        atmosphere_factor: 1.0,
        grid_x: grid_x,
        grid_y: grid_y,
        warnings: warnings
      }
    end
  end
end
