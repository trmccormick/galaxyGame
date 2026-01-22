class CelestialBodies::Spheres::Cryosphere < ApplicationRecord
  self.table_name = 'celestial_bodies_spheres_cryospheres'
  
  belongs_to :celestial_body
  
  store :properties, coder: JSON
  serialize :composition, Hash
  
  validates :thickness, numericality: { greater_than: 0 }, allow_nil: true
  validates :shell_type, inclusion: { in: ['ice', 'metallic', 'carbon_composite', 'ceramic', 'hybrid'] }, allow_nil: true
  
  # Predefined shell configurations
  SHELL_CONFIGS = {
    'natural_ice' => {
      shell_type: 'ice',
      artificial: false,
      thermal_conductivity: 2.2, # W/m·K for ice
      density: 917, # kg/m³
      composition: { 'H2O' => 100.0 }
    },
    'metallic_habitat' => {
      shell_type: 'metallic',
      artificial: true,
      thermal_conductivity: 50.0, # aluminum
      density: 2700,
      composition: { 'Al' => 100.0 }
    },
    'carbon_composite' => {
      shell_type: 'carbon_composite',
      artificial: true,
      thermal_conductivity: 100.0, # carbon fiber
      density: 1600,
      composition: { 'C' => 70.0, 'resin' => 30.0 }
    }
  }
  
  def self.create_natural_ice_shell(celestial_body, thickness: nil, composition: nil)
    config = SHELL_CONFIGS['natural_ice'].merge(
      thickness: thickness || calculate_natural_thickness(celestial_body),
      composition: composition || determine_ice_composition(celestial_body)
    )
    
    celestial_body.create_cryosphere!(config)
  end
  
  def self.create_artificial_shell(celestial_body, shell_type, thickness:, materials:)
    config = SHELL_CONFIGS[shell_type].merge(
      thickness: thickness,
      composition: materials
    )
    
    celestial_body.create_cryosphere!(config)
  end
  
  private
  
  def self.calculate_natural_thickness(celestial_body)
    # Estimate ice shell thickness based on body characteristics
    # This is a simplified model - real thickness depends on many factors
    base_thickness = 10_000 # 10km base
    
    # Thicker shells for larger tidal heating
    if celestial_body.is_a?(CelestialBodies::Satellites::Moon)
      tidal_factor = celestial_body.orbital_period ? (1.0 / celestial_body.orbital_period) * 1000 : 1
      base_thickness * [tidal_factor, 0.1].max
    else
      base_thickness
    end
  end
  
  def self.determine_ice_composition(celestial_body)
    temp = celestial_body.surface_temperature.to_f
    
    if temp < 100
      # Very cold - pure water ice
      { 'H2O' => 100.0 }
    elsif temp < 150
      # Cold - water ice with ammonia
      { 'H2O' => 95.0, 'NH3' => 5.0 }
    else
      # Warmer - complex ice mixtures
      { 'H2O' => 90.0, 'CH4' => 5.0, 'N2' => 3.0, 'CO2' => 2.0 }
    end
  end
end
