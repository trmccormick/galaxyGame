# NOTE: Celestial body radius is stored in METERS in the database and JSON files.
# Example: Earth's radius is stored as 6371000.0, not 6371.0

module CelestialBodies
  class CelestialBody < ApplicationRecord
    include OrbitalMechanics
    include MaterialManagementConcern  # Add this line

    belongs_to :solar_system, optional: true
    before_save :run_terra_sim, if: :simulation_relevant_changes?
    before_create :set_calculated_values

    # Spheres               
    has_one :atmosphere, class_name: 'CelestialBodies::Spheres::Atmosphere', dependent: :destroy
    has_one :biosphere, class_name: 'CelestialBodies::Spheres::Biosphere', dependent: :destroy
    has_one :geosphere, class_name: 'CelestialBodies::Spheres::Geosphere', dependent: :destroy
    has_one :hydrosphere, class_name: 'CelestialBodies::Spheres::Hydrosphere', dependent: :destroy

    # has_many :orbital_relationships
    # has_many :orbits, through: :orbital_relationships, source: :celestial_body
    # has_many :orbiting_bodies, class_name: 'OrbitalRelationship', foreign_key: :star_id
    
    has_many :colonies
    has_many :base_settlements
    has_many :materials

    has_one :spatial_location, as: :spatial_context, 
            class_name: 'Location::SpatialLocation',
            dependent: :destroy
   
    has_many :locations,
             as: :locationable,
             class_name: 'Location::CelestialLocation',
             dependent: :destroy

    # Star relationships
    has_many :star_distances, class_name: 'CelestialBodies::StarDistance', dependent: :destroy
    has_many :stars, through: :star_distances

    validates :identifier, presence: true, uniqueness: true   
    validates :size, presence: true, numericality: { greater_than: 0 }
    validates :gravity, :density, :radius, :orbital_period, numericality: { greater_than_or_equal_to: 0 }
    # Validates that mass is a valid number, allowing for scientific notation
    validates :mass, format: { 
      with: /\A-?\d+(\.\d+)?([eE][-+]?\d+)?\z/, 
      message: "must be a valid number" 
    }
    validates :known_pressure, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    enum status: { active: 0, mined_out: 1 }

    before_validation :set_defaults

    # Callbacks

    # updated setup
    after_create :initialize_associations

    def name
      super.presence || identifier
    end

    def surface_area
      return 0 unless radius.present?
      4 * Math::PI * (radius ** 2)
    end

    def volume
      return 0 unless radius.present?
      (4.0 / 3) * Math::PI * (radius ** 3)
    end

    def density
      return nil if mass.nil? || volume.nil?
      mass_float = mass.to_f
      mass_float / volume
    end

    def calculate_gravity
      return nil unless radius.present? && mass.present?
      mass_float = mass.to_f
      (GameConstants::GRAVITATIONAL_CONSTANT * mass_float) / (radius ** 2)
    end

    def update_gravity
      return if new_record? # Don't calculate for new records - use seeded value
      
      # Only calculate if mass or radius changed
      if (saved_changes.keys & ['mass', 'radius']).any?
        self.gravity = calculate_gravity
        save!
      end
    end

    def calculate_pressure
      return nil unless atmosphere&.gases.present?
      # Pressure calculation based on current atmospheric composition
      # Used when atmosphere is modified or for generated planets
    end

    def calculate_temperature
      return nil unless distance_from_star.present? && albedo.present?
      # Temperature calculation based on current conditions
      # Used when conditions change or for generated planets
    end

    def in_solar_system?
      solar_system.present?
    end

    def distance_from_star?
      star_distances.any?
    end

    def validate_distance_from_star
      if in_solar_system? && star_distances.empty?
        errors.add(:star_distances, "must be present if part of a solar system")
      elsif solar_system&.stars&.empty?
        errors.add(:star_distances, "cannot be validated without stars in the solar system")
      end
    end

    def available_materials
      parse_json(materials)
    end

    def parse_json(attribute)
      if attribute.is_a?(String)
        JSON.parse(attribute || '{}') rescue {}
      elsif attribute.is_a?(Hash)
        attribute
      else
        {}
      end
    end

    def solar_constant
      return nil unless in_solar_system?
      star_distances.sum do |star_distance|
        next 0 unless star_distance.star.luminosity
        star_distance.star.luminosity / (4 * Math::PI * star_distance.distance**2)
      end
    end

    # def material_composition
    #   available_materials
    # end

    accepts_nested_attributes_for :geosphere

    def surface_composition
      geosphere&.crust_composition || {}
    end

    def material_distribution
      return {} unless respond_to?(:materials)
      
      # Group by location and state
      grouped = materials.group(:location, :state).sum(:amount)
      
      # Format into a nested hash
      result = {
        atmosphere: { gas: 0, liquid: 0, solid: 0 },
        geosphere: { gas: 0, liquid: 0, solid: 0 },
        hydrosphere: { gas: 0, liquid: 0, solid: 0 }
      }
      
      grouped.each do |keys, amount|
        location, state = keys
        result[location.to_sym][state.to_sym] = amount
      end
      
      # Calculate total by location
      result[:atmosphere][:total] = result[:atmosphere].values.sum
      result[:geosphere][:total] = result[:geosphere].values.sum
      result[:hydrosphere][:total] = result[:hydrosphere].values.sum
      
      # Overall total
      result[:total] = result[:atmosphere][:total] + 
                       result[:geosphere][:total] + 
                       result[:hydrosphere][:total]
      
      result
    end
    
    def material_summary
      distribution = material_distribution
      return "No materials tracked" if distribution.empty?
      
      summary = []
      summary << "Total Mass: #{GameFormatters::AtmosphericData.format_mass(distribution[:total])}"
      summary << "  Atmosphere: #{GameFormatters::AtmosphericData.format_mass(distribution[:atmosphere][:total])}"
      summary << "  Geosphere: #{GameFormatters::AtmosphericData.format_mass(distribution[:geosphere][:total])}"
      summary << "  Hydrosphere: #{GameFormatters::AtmosphericData.format_mass(distribution[:hydrosphere][:total])}"
      
      # Top materials by mass
      top_materials = materials.group(:name).sum(:amount)
                      .sort_by { |_, amount| -amount }
                      .first(5)
                      
      if top_materials.any?
        summary << "\nTop Materials:"
        top_materials.each do |name, amount|
          summary << "  #{name}: #{GameFormatters::AtmosphericData.format_mass(amount)}"
        end
      end
      
      summary.join("\n")
    end

    def calculate_total_mass
      # Base mass from the mass attribute
      base_mass = self.mass || 0
      
      # Add atmosphere mass if present
      atmo_mass = atmosphere&.total_atmospheric_mass || 0
      
      # Add hydrosphere mass if present
      hydro_mass = hydrosphere&.total_water_mass || 0
      
      # Add geosphere mass if present
      geo_mass = 0
      if geosphere.present?
        geo_mass += geosphere.total_crust_mass if geosphere.respond_to?(:total_crust_mass)
        geo_mass += geosphere.total_mantle_mass if geosphere.respond_to?(:total_mantle_mass)
        geo_mass += geosphere.total_core_mass if geosphere.respond_to?(:total_core_mass)
      end
      
      # Return the total
      base_mass + atmo_mass + hydro_mass + geo_mass
    end

    # def body_category
    #   self.class.name.demodulize.underscore
    # end

    # Add a helper method to get a simplified type
    def body_category
      if type.to_s.include?('Moon')
        'moon'
      elsif type.to_s.include?('TerrestrialPlanet')
        'terrestrial_planet'
      elsif type.to_s.include?('GasGiant')
        'gas_giant'
      elsif type.to_s.include?('IceGiant')
        'ice_giant' 
      elsif type.to_s.include?('DwarfPlanet')
        'dwarf_planet'
      else
        'unknown'
      end
    end    

    # Add this method to bridge the gap during refactoring
    def planet_type
      case self
      # New planet types
      # when CelestialBodies::Planets::Rocky::CarbonPlanet then 'carbon_planet'
      # when CelestialBodies::Planets::Rocky::LavaWorld then 'lava_world'  
      # when CelestialBodies::Planets::Rocky::SuperEarth then 'super_earth'
      when CelestialBodies::Planets::Rocky::TerrestrialPlanet then 'terrestrial'
      when CelestialBodies::Planets::Gaseous::GasGiant then 'gas_giant'
      # when CelestialBodies::Planets::Gaseous::HotJupiter then 'hot_jupiter'
      # when CelestialBodies::Planets::Gaseous::IceGiant then 'ice_giant'
      # when CelestialBodies::Planets::Ocean::HyceanPlanet then 'hycean'
      # when CelestialBodies::Planets::Ocean::OceanWorld then 'ocean_world'
      # when CelestialBodies::Planets::Ocean::WaterWorld then 'water_world'
      # when CelestialBodies::Planets::Other::DwarfPlanet then 'dwarf_planet'
      # when CelestialBodies::Planets::Other::RoguePlanet then 'rogue_planet'
      
      # Legacy types for compatibility
      when CelestialBodies::TerrestrialPlanet then 'terrestrial'
      when CelestialBodies::GasGiant then 'gas_giant'
      when CelestialBodies::IceGiant then 'ice_giant'
      when CelestialBodies::Moon then 'moon'
      when CelestialBodies::DwarfPlanet then 'dwarf_planet'
      else
        'celestial_body'  # Default
      end
    end    

    # Add this method to the CelestialBody class
    def luminosity
      properties.try(:[], 'luminosity') || 1.0
    end

    def luminosity=(value)
      self.properties = (properties || {}).merge('luminosity' => value)
    end

    private
    def set_defaults
      # self.temperature ||= DEFAULT_TEMPERATURE
      # self.known_pressure ||= 0
      self.status ||= :active
      # self.radius ||= 1.0
      self.materials ||= '{}'
    end

    def initialize_associations
      create_atmosphere unless atmosphere.present?
      # create_biosphere unless biosphere.present?
      # create_geosphere unless geosphere.present?
      # create_hydrosphere unless hydrosphere.present?

      # Set default values for atmosphere to prevent nil errors
      if atmosphere.present?
        atmosphere.update!(
          temperature: surface_temperature,
          pressure: 0,
          composition: {},
          total_atmospheric_mass: 0,
          pollution: 0,
          dust: {}
        )

        atmosphere.initialize_gases
      end

      # Set default values for biosphere to prevent nil errors
      # biosphere.update!(
      #   temperature_tropical: 0,
      #   temperature_polar: 0
      # )

      # Set default values for geosphere to prevent nil errors
      # geosphere.update!(
      #   rock_types: {},
      #   geological_activity: 0
      # )
      
      # Set default values for hydrosphere to prevent nil errors
      # hydrosphere.update!(
      #   liquid_name: 'unknown',
      #   liquid_volume: 0,
      #   lakes: 0,
      #   rivers: 0,
      #   oceans: 0,
      #   ice: 0
      # )
    end    

    def run_terra_sim
      return if @simulating
      @simulating = true
      TerraSim::Simulator.new(self).calc_current
      @simulating = false
    end
  
    def simulation_relevant_changes?
      return false if new_record?
      atmosphere&.changed? || 
        hydrosphere&.changed? || 
        geosphere&.changed? || 
        changed.include?('mass') || 
        changed.include?('albedo')
    end

    def calculate_surface_area
      return 0 unless radius.present?
      4 * Math::PI * (radius ** 2)
    end

    def calculate_escape_velocity
      return 0 unless mass.present? && radius.present?
      # v_escape = sqrt(2GM/R)
      Math.sqrt(2 * GameConstants::GRAVITATIONAL_CONSTANT * mass.to_f / radius)
    end

    def set_calculated_values
      self.surface_area = calculate_surface_area if radius && !surface_area
      self.volume = calculate_volume if radius && !volume
      self.escape_velocity = calculate_escape_velocity if mass && radius && !escape_velocity
    end

    # def update_atmosphere(gas, amount)
    #   self.atmosphere ||= Atmosphere.new(temperature: default_temperature)

    #   if amount > 0
    #     atmosphere.add_gas(gas)
    #   else
    #     atmosphere.remove_gas(gas.name)
    #   end

    #   run_terra_simulation
    # end

    # def update_geosphere
    #   @geosphere.update_geological_activity if @geosphere
    # end

    # def update_hydrosphere
    #   @hydrosphere.update_water_cycle if @hydrosphere
    # end  

    # Add this method to determine if a body is a moon
    def is_moon
      self.type.to_s.include?('Moon')
    end
  end
end
