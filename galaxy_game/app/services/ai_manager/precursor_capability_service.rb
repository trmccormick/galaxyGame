# app/services/ai_manager/precursor_capability_service.rb

module AIManager
  # Service to determine what resources can be produced locally based on
  # actual celestial body data rather than hardcoded world lists.
  # Replaces hardcoded case statements in MissionPlannerService.
  class PrecursorCapabilityService
    attr_reader :celestial_body

    EARLY_ISRU_STORAGE_MECHANISMS = %w[regolith].freeze
    METAL_OXIDE_FORMULAS = %w[Fe2O3 FeO Al2O3 TiO2 MgO SiO2 CaO].freeze

    def initialize(celestial_body)
      @celestial_body = celestial_body
    end

    # Check if a specific resource can be produced locally via ISRU
    # @param resource [String] Resource name to check
    # @return [Boolean] True if resource can be locally sourced
    def can_produce_locally?(resource)
      return false unless celestial_body
      local_resources.any? do |available_resource|
        available_resource.to_s.downcase == resource.to_s.downcase
      end
    end

    # Get list of all locally available resources from celestial body data
    # @return [Array<String>] List of resource identifiers
    def local_resources
      extract_local_resources
    end

    # Get production capabilities summary
    # @return [Hash] Capabilities by resource type
    def production_capabilities
      {
        atmosphere: atmospheric_resources,
        surface: surface_resources,
        subsurface: subsurface_resources,
        regolith: regolith_composition,
        has_regolith: has_regolith?,
        isru_options: isru_options,
        isru_capable: isru_options.any?
      }
    end

    # Check if precursor phase would enable specific capability
    # @param capability [Symbol] :oxygen, :water, :fuel, :metals, etc.
    # @return [Boolean]
    def precursor_enables?(capability)
      case capability
      when :oxygen
        can_extract_oxygen?
      when :water
        can_extract_water?
      when :fuel
        can_extract_fuel?
      when :metals
        can_extract_metals?
      when :regolith_processing
        has_regolith?
      else
        false
      end
    end

    # Get list of ISRU options enabled by precursor phase
    # @return [Array<Symbol>]
    def isru_options
      [:oxygen, :water, :fuel, :metals, :regolith_processing].select do |capability|
        precursor_enables?(capability)
      end
    end

    private

    # Helper to get stored_volatiles from geosphere, falling back to crust_composition if needed
    def stored_volatiles(geo)
      geo.stored_volatiles.presence || geo.crust_composition&.dig('stored_volatiles') || {}
    end


    def volatile_amount(value)
      return 0.0 if value.nil?
      value.is_a?(Hash) ? value.values.sum.to_f : value.to_f
    end

    def extract_local_resources
      # Reload associated sphere records (preserve object identity for tests)
      if celestial_body
        celestial_body.geosphere&.reload if celestial_body.geosphere.respond_to?(:reload)
        celestial_body.atmosphere&.reload if celestial_body.atmosphere.respond_to?(:reload)
        celestial_body.hydrosphere&.reload if celestial_body.hydrosphere.respond_to?(:reload)
      end
      resources = []
      resources.concat(atmospheric_resources) if celestial_body.atmosphere
      resources.concat(surface_resources) if celestial_body.geosphere
      resources.concat(subsurface_resources) if celestial_body.geosphere
      resources.concat(water_resources) if celestial_body.hydrosphere
      if celestial_body.has_solid_surface?
        resources << 'regolith'
        if celestial_body.geosphere&.crust_composition&.present?
          resources << 'O2'
          resources << 'H2'
        end
      end
      resources.uniq.compact
    end

    def atmospheric_resources
      return [] unless celestial_body.atmosphere

      atmo = celestial_body.atmosphere
      resources = []

      resources << 'CO2' if atmo.gas_percentage('CO2') > 0.01
      resources << 'N2'  if atmo.gas_percentage('N2') > 0.01
      resources << 'CH4' if atmo.gas_percentage('CH4') > 0.01
      resources << 'O2'  if atmo.gas_percentage('O2') > 0.01
      resources << 'Ar'  if atmo.gas_percentage('Ar') > 0.001

      resources
    end

    def surface_resources
      return [] unless celestial_body.geosphere

      geo = celestial_body.geosphere
      resources = []

      # Surface composition from geosphere
      if geo.crust_composition.present?
        composition = geo.crust_composition
        composition.each do |material, percentage|
          resources << material if volatile_amount(percentage) > 0.01
        end
      end

      # Volatile deposits — filter by early ISRU storage mechanisms
      stored_volatiles(geo).each do |compound, storage|
        if storage.is_a?(Hash)
          accessible = storage.keys.any? do |mechanism|
            EARLY_ISRU_STORAGE_MECHANISMS.include?(mechanism)
          end
          resources << compound if accessible
        end
      end

      resources
    end

    def subsurface_resources
      return [] unless celestial_body.geosphere

      geo = celestial_body.geosphere
      resources = []

      # Subsurface water - check if stored_volatiles contains H2O
      vols = stored_volatiles(geo)
      if vols.is_a?(Hash) && vols.key?('H2O')
        resources << 'H2O'
      end

      # Subsurface ocean (Europa-style)
      if celestial_body.hydrosphere&.water_bodies.present?
        resources << 'subsurface_ocean'
      end

      resources
    end

    def water_resources
      return [] unless celestial_body.hydrosphere

      hydro = celestial_body.hydrosphere
      resources = []

      resources << 'H2O' if hydro.water_bodies.present?
      # Removed: ice_mass, polar_ice_mass not in schema

      resources
    end

    def regolith_composition
      return [] unless celestial_body.geosphere
      geo = celestial_body.geosphere
      resources = ['regolith']

      # He3 is stored in regolith as a volatile — read from stored_volatiles
      vols = stored_volatiles(geo)
      he3 = vols['He3']
      resources << 'He3' if volatile_amount(he3) > 0

      resources
    end

    # Capability checks for precursor phases

    def can_extract_oxygen?
      # From atmosphere via MOXIE-style CO2 processing
      return true if atmospheric_resources.include?('CO2')
      # From water electrolysis
      return true if can_extract_water?
      # From regolith metal oxide processing via PVE
      return true if can_extract_metals?
      false
    end

    def can_extract_water?
      water_resources.any? ||
        subsurface_resources.include?('H2O') ||
        surface_resources.include?('H2O')
    end

    def can_extract_fuel?
      # Methane from atmosphere (Titan/Mars Sabatier reaction)
      return true if atmospheric_resources.include?('CH4')
      # H2 from regolith TEU bakeout — primary Luna fuel pathway
      # H2 + O2 (both from regolith) = LH2/LOX bipropellant
      return true if local_resources.include?('H2')
      # Hydrogen from water electrolysis — rationed, last resort
      return true if can_extract_water?
      false
    end

    def can_extract_metals?
      return false unless celestial_body.geosphere
      geo = celestial_body.geosphere
      return false unless geo.crust_composition.present?

      # Check if crust contains known metal oxides
      has_metal_oxides = geo.crust_composition.keys.any? do |mineral|
        METAL_OXIDE_FORMULAS.include?(mineral)
      end
      return true if has_metal_oxides

      # Any significant crust composition on a solid body implies
      # metal extraction potential — anorthosite, norite, troctolite
      # all contain extractable metals via PVE
      geo.crust_composition.values.any? { |v| volatile_amount(v) > 1.0 }
    end

    def has_regolith?
      celestial_body.has_solid_surface?
    end
  end
end