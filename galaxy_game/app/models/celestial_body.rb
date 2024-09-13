class CelestialBody < ApplicationRecord
  IDEAL_GAS_CONSTANT = 0.0821 # L·atm/(mol·K)
  TEMPERATURE = 288.15 # Kelvin (default temperature)
  VOLUME = 1.0 # Assume a unit volume for simplicity

  # Associations
  has_many :orbital_relationships
  has_many :orbits, through: :orbital_relationships, source: :celestial_body
  has_many :orbiting_bodies, class_name: 'OrbitalRelationship', foreign_key: :sun_id

  # Validations
  validates :name, presence: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :gravity, :density, :radius, :orbital_period, :mass, numericality: { greater_than_or_equal_to: 0 }
  validates :known_pressure, numericality: true, allow_nil: true

  # Accessors for temperature, biomes, status
  attr_accessor :temperature, :biomes, :status
  attr_accessor :greenhouse_temp, :polar_temp, :tropic_temp, :delta_t, :ice_latitude, :habitability_ratio

  # State attribute for mining status
  enum status: { active: 0, mined_out: 1 }

  # Callbacks
  before_validation :set_defaults
  after_initialize :initialize_mass

  # Method to set default values
  def set_defaults
    self.temperature ||= TEMPERATURE
    self.biomes ||= []
    self.status ||= :active
    self.radius ||= 1.0
    self.gas_quantities ||= {}
  end

  def initialize_mass
    self.mass ||= 1.0
  end

  # Calculate the surface area of the celestial body
  def surface_area
    return 0 if radius.nil?
    4 * Math::PI * (radius ** 2)
  end

  # Calculate the volume of the celestial body
  def volume
    return 0 if radius.nil?
    (4.0 / 3) * Math::PI * (radius ** 3)
  end

  # Calculate the density of the celestial body
  def density
    return 0 if volume.zero?
    mass / volume
  end

  # Update gravity based on mass and radius
  def update_gravity
    gravitational_constant = 6.67430e-11 # in m^3 kg^-1 s^-2
    self.gravity = (gravitational_constant * mass) / (radius ** 2) if radius.present? && mass.present?
  end

  # Method to calculate the atmospheric composition
  def atmospheric_composition
    return {} if gas_quantities.empty?

    total_amount = gas_quantities.values.sum.to_f
    gas_quantities.transform_values do |amount|
      ((amount / total_amount) * 100).round(2)
    end
  end

  # Method to calculate atmospheric pressure
  def atmospheric_pressure
    return 0 if gas_quantities.empty?

    total_moles = gas_quantities.values.sum
    pressure = total_moles * IDEAL_GAS_CONSTANT * TEMPERATURE / VOLUME
    pressure / 1.0 # Adjust if needed
  end

  # Method to calculate total pressure
  def calculate_total_pressure
    return 0 if gas_quantities.blank?

    total_moles = gas_quantities.values.sum
    self.total_pressure = total_moles * IDEAL_GAS_CONSTANT * TEMPERATURE / VOLUME
    save!
  end

  # Method to add and remove gases
  def add_gas(gas_name, amount)
    gas_quantities = available_gas_quantities
    gas_quantities[gas_name] = (gas_quantities[gas_name] || 0) + amount.to_f
    update(gas_quantities: gas_quantities.to_json)
    update_mass(amount, is_gas: true)
  end

  def remove_gas(gas_name, amount)
    gas_quantities = available_gas_quantities
    raise ActiveRecord::RecordInvalid.new(self), "Not enough #{gas_name} available." if gas_quantities[gas_name].nil? || gas_quantities[gas_name] < amount

    gas_quantities[gas_name] -= amount
    update(gas_quantities: gas_quantities.to_json)
    update_mass(amount, is_gas: true)
  end

  # Method to update biomes based on conditions
  def update_biomes
    biome_definitions = [
      { name: 'Cold Desert', conditions: { temperature_range: -130..0, minimum_atmosphere: 0.1 } },
      { name: 'Tundra', conditions: { temperature_range: -20..10, minimum_atmosphere: 0.5 } },
      { name: 'Boreal Forest', conditions: { temperature_range: 0..15, minimum_atmosphere: 0.8 } },
      { name: 'Tropical Rainforest', conditions: { temperature_range: 15..30, minimum_atmosphere: 1.0 } }
    ]

    self.biomes = biome_definitions.select do |biome|
      temperature.between?(biome[:conditions][:temperature_range].min, biome[:conditions][:temperature_range].max) &&
        atmospheric_pressure >= biome[:conditions][:minimum_atmosphere]
    end.map { |biome| biome[:name] }

    save!
  end

  # Method to add and remove materials
  def add_material(name, amount)
    material_data = available_materials
    material_data[name] = (material_data[name] || 0) + amount.to_f
    update(materials: material_data.to_json)
    update_mass(amount, is_gas: false)
  end

  def remove_material(material_name, amount)
    material_data = available_materials
    raise ActiveRecord::RecordInvalid.new(self), "Not enough #{material_name} available." if material_data[material_name].nil? || material_data[material_name] < amount

    material_data[material_name] -= amount
    update(materials: material_data.to_json)
    update_mass(-amount, is_gas: false)
  end

  # Helper methods
  def parse_json(attribute)
    if attribute.is_a?(String)
      JSON.parse(attribute || '{}') rescue {}
    elsif attribute.is_a?(Hash)
      attribute
    else
      {}
    end
  end

  def available_materials
    parse_json(materials)
  end

  def available_gas_quantities
    parse_json(gas_quantities)
  end

  # Placeholder for your custom habitability logic
  def habitability_score
    # Example: Basic logic based on temperature and atmospheric pressure
    if temperature.between?(273.15, 300.15) && atmospheric_pressure.between?(0.8, 1.2)
      "Habitable"
    else
      "Non-Habitable"
    end
  end
end
