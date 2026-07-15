# frozen_string_literal: true

module StarSim
  # Generates biosphere attributes for procedurally-generated worlds
  # Supports multiple life complexity levels for varied scenarios:
  # - none: No biosphere (dead worlds)
  # - primitive: Simple microbes or early-stage life (ancient Mars, early Earth)
  # - basic: Established ecosystems with multiple life forms
  # - complex: Earth-like with high biodiversity and multiple biomes
  #
  # Data-driven approach: outputs biosphere_attributes that SystemBuilderService will use
  # to populate the biosphere record in the database.
  class BiosphereGeneratorService
    COMPLEXITY_LEVELS = {
      none: { habitable_ratio: 0.0, biodiversity_index: 0.0 },
      primitive: { habitable_ratio: 0.05..0.15, biodiversity_index: 0.02..0.10 },
      basic: { habitable_ratio: 0.30..0.60, biodiversity_index: 0.40..0.70 },
      complex: { habitable_ratio: 0.85..0.95, biodiversity_index: 0.80..1.0 }
    }.freeze

    LIFE_FORMS = {
      primitive: {
        primary_producers: ['cyanobacteria', 'archaea'],
        consumers: ['anaerobic bacteria'],
        decomposers: ['bacteria', 'microorganisms']
      },
      basic: {
        primary_producers: ['plants', 'phytoplankton', 'algae'],
        consumers: ['insects', 'small animals', 'zooplankton'],
        decomposers: ['bacteria', 'fungi', 'decomposer organisms']
      },
      complex: {
        primary_producers: ['plants', 'phytoplankton', 'algae', 'mosses'],
        consumers: ['animals', 'zooplankton', 'insects', 'fish', 'birds', 'mammals'],
        decomposers: ['bacteria', 'fungi', 'microorganisms', 'detritivores']
      }
    }.freeze

    BIOME_PATTERNS = {
      tropical: {
        temperate: 0.0,
        tropical: 0.8..1.0,
        desert: 0.0..0.1,
        ocean: 0.0..0.2
      },
      temperate: {
        temperate: 0.4..0.6,
        tropical: 0.0..0.1,
        desert: 0.1..0.3,
        ocean: 0.2..0.5
      },
      cold: {
        temperate: 0.1..0.2,
        tropical: 0.0,
        desert: 0.2..0.4,
        tundra: 0.2..0.4,
        ocean: 0.2..0.5
      },
      dry: {
        temperate: 0.05..0.15,
        tropical: 0.0,
        desert: 0.6..0.9,
        ocean: 0.0..0.2
      }
    }.freeze

    def initialize
      @complexity_levels = COMPLEXITY_LEVELS
      @life_forms = LIFE_FORMS
      @biome_patterns = BIOME_PATTERNS
    end

    # Generate biosphere attributes for a planet based on habitability conditions
    # @param planet_data [Hash] Planet data including temperature, pressure, gravity, hydrosphere
    # @param complexity_level [Symbol] :none, :primitive, :basic, or :complex
    # @param seed_era [Symbol] Optional: :early_solar_system, :present_day, etc.
    # @return [Hash, nil] biosphere_attributes hash or nil if no biosphere should exist
    def generate(planet_data, complexity_level: :auto, seed_era: :present_day)
      # Auto-detect complexity based on habitability if not specified
      complexity_level = detect_complexity(planet_data) if complexity_level == :auto

      # No biosphere case
      return nil if complexity_level == :none

      # Build biosphere attributes
      biosphere_attrs = build_biosphere_attributes(planet_data, complexity_level, seed_era)

      biosphere_attrs
    end

    # Detect appropriate complexity level based on planet conditions
    # @param planet_data [Hash] Planet data
    # @return [Symbol] Detected complexity level
    def detect_complexity(planet_data)
      temp = planet_data['surface_temperature'].to_f
      pressure = planet_data.dig('atmosphere', 'pressure').to_f
      gravity = planet_data['gravity'].to_f
      liquid_water = planet_data.dig('hydrosphere', 'state_distribution', 'liquid').to_f || 0

      # No liquid water = no biosphere
      return :none if liquid_water < 0.01

      # Check conditions for habitability
      temp_ok = temp.between?(260, 320)
      pressure_ok = pressure.between?(0.5, 2.0)
      gravity_ok = gravity.between?(0.5, 1.5)
      water_ok = liquid_water > 0.1  # Strict threshold: more than 10% liquid water

      case [temp_ok, pressure_ok, gravity_ok, water_ok].count(true)
      when 4
        :complex  # Optimal conditions = Earth-like complexity
      when 3
        :basic    # Most conditions good = established ecosystem
      when 2
        :primitive # Marginal conditions = simple microbes
      else
        :none     # Insufficient conditions = no life
      end
    end

    private

    def build_biosphere_attributes(planet_data, complexity_level, seed_era)
      habitable_range = @complexity_levels[complexity_level][:habitable_ratio]
      biodiversity_range = @complexity_levels[complexity_level][:biodiversity_index]

      # Terraformed worlds start with enhanced habitability
      if seed_era == :terraformed && habitable_range.is_a?(Range)
        habitable_range = (habitable_range.min + 0.3)..(habitable_range.max + 0.3)
        habitable_range = (habitable_range.min)..[1.0, habitable_range.max].min  # Cap at 1.0
      end

      habitable_ratio = range_value(habitable_range)
      biodiversity_index = range_value(biodiversity_range)

      # Base attributes
      attrs = {
        habitable_ratio: habitable_ratio,
        biodiversity_index: biodiversity_index,
        vegetation_cover: range_value(complexity_level == :primitive ? 0.0..0.05 : 0.1..0.8),
        biome_count: biome_count_for_complexity(complexity_level),
        soil_health: range_value(complexity_level == :primitive ? 0.1..0.3 : 0.5..0.9),
        soil_organic_content: range_value(complexity_level == :primitive ? 0.001..0.01 : 0.05..0.15),
        soil_microbial_activity: range_value(complexity_level == :primitive ? 0.1..0.3 : 0.6..0.95)
      }

      # Add life forms based on complexity
      if complexity_level != :none
        life_forms = @life_forms[complexity_level]
        attrs.merge!(
          primary_producers: life_forms[:primary_producers],
          consumers: life_forms[:consumers],
          decomposers: life_forms[:decomposers]
        )
      end

      # Add biome distribution based on temperature and complexity
      temp = planet_data['surface_temperature'].to_f
      biome_pattern = detect_biome_pattern(temp, complexity_level)
      attrs[:biome_distribution] = generate_biome_distribution(biome_pattern)

      # Era-specific adjustments
      case seed_era
      when :early_solar_system
        # Ancient Mars: primitive microbial life, reduced oxygen
        attrs[:atmosphere_notes] = 'Primordial atmosphere - low oxygen, high CO2'
        attrs[:biodiversity_index] *= 0.5
        attrs[:oxygen_producing] = false
      when :terraformed
        # Human-terraformed world: enhanced habitability (range is already increased above)
        attrs[:terraformation_index] = range_value(0.3..0.8)
      end

      # Estimate species count based on complexity and biodiversity
      attrs[:estimated_species_count] = estimate_species_count(complexity_level, biodiversity_index)

      attrs
    end

    def detect_biome_pattern(temperature, complexity_level)
      return :tropical if temperature > 300
      return :temperate if temperature.between?(280, 300)
      return :cold if temperature.between?(260, 280)
      return :dry if temperature < 260

      :temperate
    end

    def generate_biome_distribution(biome_pattern)
      pattern = @biome_patterns[biome_pattern]
      distribution = {}

      pattern.each do |biome_type, range|
        distribution[biome_type.to_s] = range_value(range)
      end

      # Normalize to sum to 1.0
      total = distribution.values.sum
      distribution.each { |k, v| distribution[k] = (v / total).round(3) }
      distribution
    end

    def biome_count_for_complexity(complexity_level)
      case complexity_level
      when :primitive
        rand(1..2)
      when :basic
        rand(3..6)
      when :complex
        rand(8..15)
      else
        0
      end
    end

    def estimate_species_count(complexity_level, biodiversity_index)
      base_counts = {
        primitive: 100..10_000,
        basic: 10_000..1_000_000,
        complex: 1_000_000..20_000_000,
        none: 0
      }

      range = base_counts[complexity_level] || 0
      return 0 if range == 0 || complexity_level == :none

      count = range_value(range).to_i
      # Adjust by biodiversity_index
      (count * biodiversity_index).to_i
    end

    def range_value(range_or_value)
      return range_or_value unless range_or_value.is_a?(Range)

      if range_or_value.first.is_a?(Integer)
        rand(range_or_value)
      else
        (range_or_value.min + (rand * (range_or_value.max - range_or_value.min))).round(4)
      end
    end
  end
end
