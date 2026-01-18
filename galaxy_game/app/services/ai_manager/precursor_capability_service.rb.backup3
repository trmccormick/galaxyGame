# app/services/ai_manager/precursor_capability_service.rb
module AIManager
  # Service to determine what resources can be produced locally based on
  # actual celestial body data rather than hardcoded world lists.
  # Replaces hardcoded case statements in MissionPlannerService.
  class PrecursorCapabilityService
    attr_reader :celestial_body

    def initialize(celestial_body)
      @celestial_body = celestial_body
    end

    # Check if a specific resource can be produced locally via ISRU
    # @param resource [String] Resource name to check
    # @return [Boolean] True if resource can be locally sourced
    def can_produce_locally?(resource)
      return false unless celestial_body

      resource_normalized = resource.to_s.downcase

      # Check against actual celestial body data
      local_resources.any? do |available_resource|
        resource_normalized.include?(available_resource.downcase) ||
          available_resource.downcase.include?(resource_normalized)
      end
    end

    # Get list of all locally available resources from celestial body data
    # @return [Array<String>] List of resource identifiers
    def local_resources
      @local_resources ||= extract_local_resources
    end

    # Get production capabilities summary
    # @return [Hash] Capabilities by resource type
    def production_capabilities
      {
        atmosphere: atmospheric_resources,
        surface: surface_resources,
        subsurface: subsurface_resources,
        regolith: regolith_composition
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

    private

    def extract_local_resources
      resources = []

      # Atmospheric resources
      resources.concat(atmospheric_resources) if celestial_body.atmosphere

      # Surface resources from geosphere
      resources.concat(surface_resources) if celestial_body.geosphere

      # Subsurface resources
      resources.concat(subsurface_resources) if celestial_body.geosphere

      # Water resources from hydrosphere
      resources.concat(water_resources) if celestial_body.hydrosphere

      # Always include regolith for solid bodies
      resources << 'regolith' if celestial_body.has_solid_surface?

      resources.uniq.compact
    end

    def atmospheric_resources
      return [] unless celestial_body.atmosphere

      atmo = celestial_body.atmosphere
      resources = []

      # Extract from composition (JSONB field)
      if atmo.composition.present?
        composition = atmo.composition
        resources << 'co2' if composition['CO2'].to_f > 0.01
        resources << 'nitrogen' if composition['N2'].to_f > 0.01
        resources << 'methane' if composition['CH4'].to_f > 0.01
        resources << 'oxygen' if composition['O2'].to_f > 0.01
        resources << 'argon' if composition['Ar'].to_f > 0.001
      end

      resources
    end

    def surface_resources
      return [] unless celestial_body.geosphere

      geo = celestial_body.geosphere
      resources = []

      # Surface composition from geosphere
      if geo.surface_composition.present?
        composition = geo.surface_composition
        resources << 'iron_oxide' if composition['iron_oxide'].to_f > 0.01
        resources << 'silicon' if composition['silicon'].to_f > 0.01
        resources << 'aluminum' if composition['aluminum'].to_f > 0.01
        resources << 'titanium' if composition['titanium'].to_f > 0.01
      end

      # Volatile deposits
      if geo.volatile_reservoirs.present?
        reservoirs = geo.volatile_reservoirs
        resources << 'water_ice' if reservoirs['H2O'].to_f > 0
        resources << 'frozen_co2' if reservoirs['CO2'].to_f > 0
        resources << 'methane_ice' if reservoirs['CH4'].to_f > 0
      end

      resources
    end

    def subsurface_resources
      return [] unless celestial_body.geosphere

      geo = celestial_body.geosphere
      resources = []

      # Subsurface water
      if geo.subsurface_water_mass.to_f > 0
        resources << 'subsurface_water'
        resources << 'water_ice'
      end

      # Subsurface ocean (Europa-style)
      if celestial_body.hydrosphere&.ocean_coverage.to_f > 0
        resources << 'subsurface_ocean'
      end

      resources
    end

    def water_resources
      return [] unless celestial_body.hydrosphere

      hydro = celestial_body.hydrosphere
      resources = []

      resources << 'water' if hydro.ocean_coverage.to_f > 0
      resources << 'water_ice' if hydro.ice_mass.to_f > 0 || hydro.polar_ice_mass.to_f > 0

      resources
    end

    def regolith_composition
      return [] unless celestial_body.geosphere

      geo = celestial_body.geosphere
      resources = []

      # Regolith is universal for solid bodies
      resources << 'regolith'

      # Check regolith enrichment
      if geo.surface_composition.present?
        composition = geo.surface_composition
        resources << 'he3' if composition['he3'].to_f > 0.00001 # Luna-specific
        resources << 'rare_earth_elements' if composition['rare_earths'].to_f > 0.01
      end

      resources
    end

    # Capability checks for precursor phases

    def can_extract_oxygen?
      # From atmosphere (Mars MOXIE-style)
      return true if atmospheric_resources.include?('co2')

      # From water electrolysis
      return true if can_extract_water?

      # From regolith processing (Luna-style)
      return true if surface_resources.include?('iron_oxide')

      false
    end

    def can_extract_water?
      water_resources.any? ||
        subsurface_resources.include?('subsurface_water') ||
        surface_resources.include?('water_ice')
    end

    def can_extract_fuel?
      # Methane from atmosphere (Titan)
      return true if atmospheric_resources.include?('methane')

      # Hydrogen from water electrolysis
      return true if can_extract_water?

      false
    end

    def can_extract_metals?
      surface_resources.any? { |r| ['iron_oxide', 'aluminum', 'titanium', 'silicon'].include?(r) }
    end

    def has_regolith?
      celestial_body.has_solid_surface?
    end
  end
end
