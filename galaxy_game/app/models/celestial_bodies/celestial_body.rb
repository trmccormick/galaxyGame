# NOTE: Celestial body radius is stored in METERS in the database and JSON files.
# Example: Earth's radius is stored as 6371000.0, not 6371.0

module CelestialBodies
  class CelestialBody < ApplicationRecord
    include OrbitalMechanics
    include MaterialManagementConcern

    belongs_to :solar_system, optional: true
    before_save :run_terra_sim, if: :simulation_relevant_changes?
    before_create :set_calculated_values
    after_create :ensure_spatial_location
    after_create :initialize_associations

    # Spheres               
    has_one :atmosphere, class_name: 'CelestialBodies::Spheres::Atmosphere', dependent: :destroy
    has_one :biosphere, class_name: 'CelestialBodies::Spheres::Biosphere', dependent: :destroy
    has_one :geosphere, class_name: 'CelestialBodies::Spheres::Geosphere', dependent: :destroy
    has_one :hydrosphere, class_name: 'CelestialBodies::Spheres::Hydrosphere', dependent: :destroy

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

    has_many :orbiting_craft,
         class_name: 'Craft::BaseCraft',
         foreign_key: :orbiting_celestial_body_id,
         inverse_of: :orbiting_celestial_body,
         dependent: :nullify         

    # Star relationships
    has_many :star_distances, class_name: 'CelestialBodies::StarDistance', dependent: :destroy
    has_many :stars, through: :star_distances

    validates :identifier, presence: true, uniqueness: true   
    validates :size, presence: true, numericality: { greater_than: 0 }
    validates :gravity, :density, :radius, :orbital_period, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :mass, format: { 
      with: /\A-?\d+(\.\d+)?([eE][-+]?\d+)?\z/, 
      message: "must be a valid number" 
    }
    validates :known_pressure, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    enum status: { active: 0, mined_out: 1 }

    before_validation :set_defaults
    before_validation :ensure_properties
    before_save :ensure_properties

    # JSONB field accessors
    store_accessor :properties, :has_magnetosphere, :preservation_mode
    
    def name
      self[:name] || identifier
    end

    # Methods that should delegate to SolidBodyConcern for solid bodies
    # but still work for gas giants
    
    def surface_area
      return 4 * Math::PI * (radius ** 2) if radius.present?
      0
    end
    
    def volume
      return (4.0 / 3) * Math::PI * (radius ** 3) if radius.present?
      0
    end
    
    def calculated_density
      return nil if mass.nil? || volume.nil? || volume.zero?
      mass.to_f / volume
    end
    
    def calculate_gravity
      return nil unless radius.present? && mass.present?
      (GameConstants::GRAVITATIONAL_CONSTANT * mass.to_f) / (radius ** 2)
    end
    
    def calculate_escape_velocity
      return 0 unless mass.present? && radius.present?
      Math.sqrt(2 * GameConstants::GRAVITATIONAL_CONSTANT * mass.to_f / radius)
    end
    
    def has_solid_surface?
      false # Default to false, overridden in SolidBodyConcern
    end
    
    def surface_composition
      {} # Default empty, overridden in SolidBodyConcern
    end

    def atmospheric_composition
      # Get composition from associated Atmosphere model
      if atmosphere&.gases.present?
        atmosphere.gases.pluck(:name, :percentage).to_h
      else
        {}
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

    # Accessor methods for view compatibility
    def temperature
      # Try to get temperature from properties first
      return properties['temperature'] if properties && properties['temperature'].present?
      
      # For stars, temperature is a direct attribute
      return self[:temperature] if has_attribute?(:temperature) && self[:temperature].present?
      
      # Try to get from atmosphere (surface temperature)
      return atmosphere&.temperature if atmosphere&.temperature.present?
      
      # Calculate based on stellar flux and albedo if we have the data
      if stars.any? && albedo.present?
        star = stars.first
        distance = star_distances.find_by(star: star)&.distance
        if distance && star.luminosity.present?
          # Simplified blackbody temperature calculation
          stellar_flux = star.luminosity / (4 * Math::PI * (distance * 1000)**2)  # Convert km to m
          equilibrium_temp = ((stellar_flux * (1 - albedo)) / (4 * 5.67e-8))**0.25 - 273.15
          return equilibrium_temp.round(1)
        end
      end
      
      nil
    end

    def surface_temperature
      temperature  # Alias for compatibility
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
      hydro_mass = hydrosphere&.total_hydrosphere_mass || 0
      
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

    # Add a helper method to get a simplified type
    def body_category
      case type.to_s
      # Stars
      when /Star$/
        'star'
      when /BrownDwarf$/
        'brown_dwarf'

      # Planets - Rocky
      when /TerrestrialPlanet$/
        'terrestrial_planet'
      when /CarbonPlanet$/
        'carbon_planet'
      when /LavaWorld$/
        'lava_world'
      when /SuperEarth$/
        'super_earth'

      # Planets - Gaseous
      when /GasGiant$/
        'gas_giant'
      when /IceGiant$/
        'ice_giant'
      when /HotJupiter$/
        'hot_jupiter'

      # Planets - Ocean
      when /HyceanPlanet$/
        'hycean_planet'
      when /OceanPlanet$/
        'ocean_planet'
      when /WaterWorld$/
        'water_world'

      # Satellites/Moons
      when /Moon$/
        'moon'
      when /LargeMoon$/
        'large_moon'
      when /SmallMoon$/
        'small_moon'
      when /IceMoon$/
        'ice_moon'

      # Minor Bodies
      when /Asteroid$/
        'asteroid'
      when /Comet$/
        'comet'
      when /DwarfPlanet$/
        'dwarf_planet'
      when /KuiperBeltObject$/
        'kuiper_belt_object'

      # Other
      when /AlienLifeForm$/
        'alien_life_form'
      when /Material$/
        'material'

      else
        'unknown'
      end
    end    

    # Update the planet_type method
    def planet_type
      case self
      # New planet types
      when CelestialBodies::Planets::Rocky::CarbonPlanet then 'carbon_planet'
      when CelestialBodies::Planets::Rocky::LavaWorld then 'lava_world'  
      when CelestialBodies::Planets::Rocky::SuperEarth then 'super_earth'
      when CelestialBodies::Planets::Rocky::TerrestrialPlanet then 'terrestrial'
      when CelestialBodies::Planets::Gaseous::GasGiant then 'gas_giant'
      when CelestialBodies::Planets::Gaseous::HotJupiter then 'hot_jupiter'
      when CelestialBodies::Planets::Gaseous::IceGiant then 'ice_giant'
      when CelestialBodies::Planets::Ocean::HyceanPlanet then 'hycean'
      when CelestialBodies::Planets::Ocean::OceanPlanet then 'ocean_planet'
      when CelestialBodies::Planets::Ocean::WaterWorld then 'water_world'
      when CelestialBodies::MinorBodies::DwarfPlanet then 'dwarf_planet'
      
      # Legacy types for compatibility
      when CelestialBodies::TerrestrialPlanet then 'terrestrial'
      when CelestialBodies::GasGiant then 'gas_giant'
      when CelestialBodies::IceGiant then 'ice_giant'
      when CelestialBodies::Moon then 'moon'
      when CelestialBodies::DwarfPlanet then 'dwarf_planet'
      
      # Satellite types
      when CelestialBodies::Satellites::Satellite then 'satellite'
      when CelestialBodies::Satellites::Moon then 'moon'
      when CelestialBodies::Satellites::LargeMoon then 'large_moon'
      when CelestialBodies::Satellites::SmallMoon then 'small_moon'
      when CelestialBodies::Satellites::IceMoon then 'ice_moon'
      else
        'celestial_body'  # Default
      end
    end    

    # Add this method to bridge the gap during refactoring
    def luminosity
      properties.try(:[], 'luminosity') || 1.0
    end

    def luminosity=(value)
      self.properties = (properties || {}).merge('luminosity' => value)
    end

    # Add this method to determine if a body is a moon
    def distance_from_star
      star_distance = star_distances.first
      star_distance&.distance
    end

    def is_moon
      self.type.to_s.include?('Moon')
    end  
    
    def is_orbiting_star?
      solar_system.present? && star_distances.any?
    end   
    
    # Move these methods from private to public
    def body_type
      properties['body_type'] if properties
    end

    def body_type=(value)
      self.properties ||= {}
      self.properties['body_type'] = value
    end    

    # Generate a description for the celestial body
    def description
      return properties['description'] if properties && properties['description'].present?
      
      # Generate description based on type and properties
      case body_category
      when 'star'
        generate_star_description
      when 'brown_dwarf'
        generate_brown_dwarf_description
      when 'terrestrial_planet'
        generate_terrestrial_planet_description
      when 'gas_giant'
        generate_gas_giant_description
      when 'ice_giant'
        generate_ice_giant_description
      when 'carbon_planet'
        generate_carbon_planet_description
      when 'lava_world'
        generate_lava_world_description
      when 'super_earth'
        generate_super_earth_description
      when 'hycean_planet'
        generate_hycean_planet_description
      when 'ocean_planet'
        generate_ocean_planet_description
      when 'water_world'
        generate_water_world_description
      when 'hot_jupiter'
        generate_hot_jupiter_description
      when 'moon'
        generate_moon_description
      when 'large_moon'
        generate_large_moon_description
      when 'small_moon'
        generate_small_moon_description
      when 'ice_moon'
        generate_ice_moon_description
      when 'asteroid'
        generate_asteroid_description
      when 'comet'
        generate_comet_description
      when 'dwarf_planet'
        generate_dwarf_planet_description
      when 'kuiper_belt_object'
        generate_kuiper_belt_description
      when 'alien_life_form'
        generate_alien_life_form_description
      when 'material'
        generate_material_description
      else
        "A celestial body of type #{type}. #{body_type.present? ? "Body type: #{body_type}." : ''}"
      end
    end

    private

    def generate_star_description
      spectral_info = properties.try(:[], 'spectral_class') || 'unknown'
      "A star with spectral class #{spectral_info}. Mass: #{mass.present? ? "#{(mass / 1.989e30).round(2)} solar masses" : 'unknown'}. Temperature: #{temperature.present? ? "#{temperature}°C" : 'unknown'}."
    end

    def generate_brown_dwarf_description
      "A brown dwarf star, too small to sustain hydrogen fusion. Mass: #{mass.present? ? "#{(mass / 1.989e30).round(3)} solar masses" : 'unknown'}. Temperature: #{temperature.present? ? "#{temperature}°C" : 'unknown'}."
    end

    def generate_terrestrial_planet_description
      atmosphere_info = atmosphere.present? ? "Has an atmosphere." : "No significant atmosphere."
      "A terrestrial planet with a solid surface. #{atmosphere_info} Mass: #{mass.present? ? "#{(mass / 5.972e24).round(2)} Earth masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_gas_giant_description
      "A massive gas giant planet composed primarily of hydrogen and helium. Mass: #{mass.present? ? "#{(mass / 1.898e27).round(2)} Jupiter masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_ice_giant_description
      "An ice giant planet with a thick atmosphere of volatile compounds. Mass: #{mass.present? ? "#{(mass / 1.898e27).round(2)} Jupiter masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_carbon_planet_description
      "A carbon-rich planet with a surface composed primarily of graphite and carbides. Mass: #{mass.present? ? "#{(mass / 5.972e24).round(2)} Earth masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_lava_world_description
      "A lava world with extensive volcanic activity and a surface covered in molten rock. Mass: #{mass.present? ? "#{(mass / 5.972e24).round(2)} Earth masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_super_earth_description
      "A super-Earth planet, larger than Earth but smaller than ice giants. Mass: #{mass.present? ? "#{(mass / 5.972e24).round(2)} Earth masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_hycean_planet_description
      "A Hycean planet with a global ocean beneath a hydrogen-rich atmosphere. Mass: #{mass.present? ? "#{(mass / 5.972e24).round(2)} Earth masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_ocean_planet_description
      "An ocean planet with a surface completely covered by liquid water. Mass: #{mass.present? ? "#{(mass / 5.972e24).round(2)} Earth masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_water_world_description
      "A water world with vast oceans covering most of its surface. Mass: #{mass.present? ? "#{(mass / 5.972e24).round(2)} Earth masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_hot_jupiter_description
      "A hot Jupiter gas giant orbiting very close to its star. Mass: #{mass.present? ? "#{(mass / 1.898e27).round(2)} Jupiter masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_moon_description
      "A natural satellite orbiting a planet. Mass: #{mass.present? ? "#{(mass / 7.342e22).round(2)} lunar masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_large_moon_description
      "A large moon, comparable in size to some planets. Mass: #{mass.present? ? "#{(mass / 7.342e22).round(2)} lunar masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_small_moon_description
      "A small natural satellite. Mass: #{mass.present? ? "#{(mass / 7.342e22).round(3)} lunar masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_ice_moon_description
      "An ice-covered moon with potential subsurface oceans. Mass: #{mass.present? ? "#{(mass / 7.342e22).round(2)} lunar masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_asteroid_description
      "A rocky asteroid, remnant from the early solar system. Mass: #{mass.present? ? "#{(mass / 1e12).round(0)} kg" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(1)} km" : 'unknown'}."
    end

    def generate_comet_description
      "A comet with a volatile-rich nucleus and extended tail when near the sun. Mass: #{mass.present? ? "#{(mass / 1e12).round(0)} kg" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(1)} km" : 'unknown'}."
    end

    def generate_dwarf_planet_description
      "A dwarf planet, spherical but not massive enough to clear its orbital path. Mass: #{mass.present? ? "#{(mass / 1.3e22).round(2)} Pluto masses" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(0)} km" : 'unknown'}."
    end

    def generate_kuiper_belt_description
      "A Kuiper Belt object, located beyond Neptune's orbit. Mass: #{mass.present? ? "#{(mass / 1e12).round(0)} kg" : 'unknown'}. Radius: #{radius.present? ? "#{(radius / 1000).round(1)} km" : 'unknown'}."
    end

    def generate_alien_life_form_description
      "An extraterrestrial life form. #{body_type.present? ? "Type: #{body_type}." : ''}"
    end

    def generate_material_description
      "A celestial material resource. #{body_type.present? ? "Type: #{body_type}." : ''}"
    end
    def rogue?
      solar_system_id.nil? && planet_class?
    end

    # Helper to identify if this is any type of planet
    def planet_class?
      return false if type.nil?
      type.include?('::Planets::') || type.include?('::MinorBodies::DwarfPlanet')
    end

    # Method to handle ejection events
    def ejection_event!(velocity_factor = 1.0)
      previous_system = solar_system
      update(solar_system_id: nil)
      
      if respond_to?(:cool_from_ejection)
        cool_from_ejection(previous_system)
      end
      
      Rails.logger.info "#{name} has been ejected from #{previous_system&.name || 'its system'}"
    end

    def last_simulated_at
      value = properties['last_simulated_at']
      value.is_a?(String) ? Time.parse(value) : value
    end

    def last_simulated_at=(time)
      self.properties ||= {}
      self.properties['last_simulated_at'] = time&.iso8601
    end


    # Determines if the celestial body should be simulated during the game loop
    def should_simulate?
      # Basic checks: must be active, have a meaningful radius, and be a planet or moon type
      return false unless active?
      return false unless radius.present? && radius > 1000  # arbitrary threshold (1 km)
      
      # Use planet_class? (includes rocky planets, dwarf planets, etc) or moon check
      return true if planet_class? || is_moon

      # Additionally, allow explicit override in properties JSON
      # e.g., properties['force_simulate'] = true to always simulate
      if properties.is_a?(Hash) && properties['force_simulate'] == true
        return true
      end

      false
    end    

    # Determines if this celestial body can generate specific gases locally
    def can_generate_locally?(gas_symbol)
      case gas_symbol.to_sym
      when :O2
        # Can generate O2 from CO2 using energy (MOXIE/Sabatier process)
        # Either Mars specifically, or any planet with very high CO2 (>90%)
        name.downcase == 'mars' || (atmosphere&.composition&.dig('CO2').to_f > 90.0)
      when :Ar
        # Can extract Ar from atmosphere
        # Either Mars specifically, or any planet with significant Ar (>1%)
        name.downcase == 'mars' || (atmosphere&.composition&.dig('Ar').to_f > 1.0)
      else
        false
      end
    end

    private

    def set_defaults
      self.status ||= :active
      self.materials ||= '{}'
    end

    def ensure_properties
      self.properties ||= {}
    end

    # ✅ Simplified initialization - spheres handle themselves
    def initialize_associations
      create_atmosphere unless atmosphere.present?
      create_spatial_location unless spatial_location.present?

      # ✅ Only set essential atmosphere defaults
      if atmosphere.present?
        atmosphere.update!(
          temperature: surface_temperature || 288.0,  # Reasonable default
          pressure: 0.0,
          composition: {},
          total_atmospheric_mass: 0.0,
          pollution: 0.0,
          dust: {}
        )

        atmosphere.initialize_gases if atmosphere.respond_to?(:initialize_gases)
      end
      
      # ✅ All other spheres initialize themselves via their own callbacks
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

    def set_calculated_values
      if radius.present?
        if surface_area.nil? || surface_area == 0
          self.surface_area = calculate_surface_area
        end
        
        if volume.nil? || volume == 0
          self.volume = (4.0 / 3) * Math::PI * (radius ** 3)
        end
      end
      
      if mass.present? && radius.present?
        if escape_velocity.nil? || escape_velocity == 0
          self.escape_velocity = calculate_escape_velocity
        end
      end
    end
    
    # Add this method to the public section
    def ensure_spatial_location
      if spatial_location.nil?
        create_spatial_location(
          x_coordinate: 0.0,
          y_coordinate: 0.0,
          z_coordinate: 0.0
        )
      end
    end
    
    # Example for load_gas_giant
    def load_gas_giant(params)
      body_type = params.delete(:body_type)
      gas_giant = gas_giants.find_or_create_by(name: params[:name])
      
      params[:identifier] ||= "GG-#{SecureRandom.hex(4)}"
      params[:gravity] ||= 0
      params[:density] ||= 0
      params[:radius] ||= 0
      params[:orbital_period] ||= 0
      params[:mass] ||= 0
      
      props = gas_giant.properties || {}
      props['body_type'] = 'gas_giant'
      params[:properties] = props
      
      gas_giant.update!(params)
      gas_giant
    end

  end
end
