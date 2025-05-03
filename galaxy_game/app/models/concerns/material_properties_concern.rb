# app/models/concerns/material_properties_concern.rb
module MaterialPropertiesConcern
  extend ActiveSupport::Concern
  
  included do
    # Common validations
    validates :name, presence: true
    
    # Common callbacks
    before_validation :set_molar_mass_from_material, if: :respond_to?
  end
  
  # Common instance methods
  
  # Look up material properties from the material service
  def properties
    @properties ||= Lookup::MaterialLookupService.new.find_material(name)
  end
  
  # Get state at given temperature and pressure
  def state_at(temperature, pressure = 1.0)
    return default_state unless temperature
    
    melting_point = properties&.dig('properties', 'melting_point')
    boiling_point = properties&.dig('properties', 'boiling_point')
    
    # Use defaults if points are missing
    melting_point ||= 273.15 # 0°C
    boiling_point ||= 373.15 # 100°C
    
    # Simplistic model
    return 'solid' if temperature < melting_point
    return 'gas' if temperature > boiling_point
    'liquid'
  end
  
  # Retrieve molar mass from properties
  def molar_mass_from_properties
    properties&.dig('properties', 'molar_mass') || properties&.dig('molar_mass')
  end
  
  # Get state helper methods
  def solid?(temperature = nil, pressure = 1.0)
    if temperature
      state_at(temperature, pressure) == 'solid'
    else
      default_state == 'solid'
    end
  end
  
  def liquid?(temperature = nil, pressure = 1.0)
    if temperature
      state_at(temperature, pressure) == 'liquid'
    else
      default_state == 'liquid'
    end
  end
  
  def gas?(temperature = nil, pressure = 1.0)
    if temperature
      state_at(temperature, pressure) == 'gas'
    else
      default_state == 'gas'
    end
  end
  
  # Set molar mass from material properties if not already set
  def set_molar_mass_from_material
    return unless respond_to?(:molar_mass=)
    
    if molar_mass.blank? || (molar_mass.is_a?(Numeric) && molar_mass == 0)
      material_molar_mass = molar_mass_from_properties
      self.molar_mass = material_molar_mass if material_molar_mass
    end
  end
  
  private
  
  # Default state of the material (can be overridden in classes)
  def default_state
    properties&.dig('properties', 'state_at_room_temp') || 'solid'
  end
end