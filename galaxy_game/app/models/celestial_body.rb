class CelestialBody < ApplicationRecord
  IDEAL_GAS_CONSTANT = 0.0821 # L·atm/(mol·K)
  DEFAULT_TEMPERATURE = 288.15 # Kelvin

  belongs_to :solar_system, optional: true

  attr_accessor :geosphere, :hydrosphere, :atmosphere, :biosphere
  
  # has_one :atmosphere, dependent: :destroy
  # has_one :biosphere, dependent: :destroy
  # has_one :geosphere, dependent: :destroy
  # has_one :hydrosphere, dependent: :destroy

  has_many :orbital_relationships
  has_many :orbits, through: :orbital_relationships, source: :celestial_body
  has_many :orbiting_bodies, class_name: 'OrbitalRelationship', foreign_key: :star_id
  has_many :colonies
  has_many :resources
  has_many :materials

  validates :name, presence: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :gravity, :density, :radius, :orbital_period, :mass, numericality: { greater_than_or_equal_to: 0 }
  validates :known_pressure, numericality: true
  validates :albedo, :insolation, :surface_temperature, presence: true
  validate :validate_distance_from_star

  enum status: { active: 0, mined_out: 1 }

  before_validation :set_defaults
  after_initialize :initialize_attributes
  # after_create :initialize_atmosphere
  # after_create :initialize_geosphere
  # after_create :initialize_hydrosphere
  # after_create :initialize_biosphere

  def set_defaults
    self.temperature ||= DEFAULT_TEMPERATURE
    self.status ||= :active
    self.radius ||= 1.0
    self.materials ||= {}
  end

  def initialize_attributes
    @geosphere ||= Geosphere.new
    @hydrosphere ||= Hydrosphere.new(celestial_body: self)
    @atmosphere ||= Atmosphere.new(
      celestial_body: self,
      temperature: surface_temperature, # Use surface_temperature instead
      pressure: default_pressure,
      atmosphere_composition: default_composition,
      total_atmospheric_mass: default_mass
    )
    @biosphere ||= Biosphere.new
  end

  def initialize_atmosphere
    create_atmosphere(temperature: surface_temperature, pressure: known_pressure)
  end
  
  def initialize_geosphere
    create_geosphere
  end

  def initialize_hydrosphere
    create_hydrosphere
  end

  def initialize_biosphere
    create_biosphere
  end

  def update_environment
    @geosphere.geological_activity
    @hydrosphere.update_water_cycle
    @atmosphere.update_gas_quantities
  end

  def manage_biomes
    biosphere.manage_biomes(temperature, humidity)
  end

  def update_conditions(new_temperature, new_humidity)
    self.temperature = new_temperature
    manage_biomes
  end 

  def in_solar_system?
    solar_system.present?
  end

  def distance_from_star?
    distance_from_star.present?
  end

  def validate_distance_from_star
    if in_solar_system?
      if distance_from_star.blank?
        errors.add(:distance_from_star, "must be present if part of a solar system")
      elsif solar_system.current_star.nil?
        errors.add(:distance_from_star, "cannot be validated without a star in the solar system")
      end
    end
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
    mass / volume
  end

  def update_gravity
    gravitational_constant = 6.67430e-11 # in m^3 kg^-1 s^-2
    if radius.present? && mass.present?
      self.gravity = (gravitational_constant * mass) / (radius ** 2)
    end
  end

  def material_composition
    available_materials
  end

  def atmospheric_pressure
    return nil unless total_pressure.present? && radius.present?
    total_pressure / (2 * radius)
  end

  def total_pressure
    @atmosphere.calculate_pressure
  end

  def add_material(material_name, amount)
    material = materials.find_or_create_by(name: material_name)
    material.update(amount: material.amount + amount)
  end

  def remove_material(name, amount)
    material_data = available_materials
    if material_data[name].nil? || material_data[name] < amount
      raise ActiveRecord::RecordInvalid.new(self), "Not enough #{name} available."
    end

    material_data[name] -= amount
    update(materials: material_data.to_json)
    update_mass(-amount)
    update_related_models(name)
  end

  def update_mass(amount, material_type: :solid)
    density_factors = { gas: 0.001, liquid: 1.0, solid: 1.0 }
    density_factor = density_factors[material_type] || 1.0
    additional_mass = amount * density_factor
    self.mass += additional_mass

    if material_type == :gas
      update_atmosphere_mass(additional_mass)
    else
      save!
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
    return nil unless luminosity.present? && distance_from_star.present? && distance_from_star > 0
    luminosity / (4 * Math::PI * distance_from_star**2)
  end

  def habitability_score
    if temperature.between?(273.15, 300.15) && total_pressure.between?(0.8, 1.2)
      "Habitable"
    else
      "Non-Habitable"
    end
  end 

  private

  def default_pressure
    # Define logic to calculate default pressure if needed
    101325 # Standard atmospheric pressure in Pascals
  end

  def default_composition
    # Define logic to calculate default atmosphere composition if needed
    {}
  end

  def default_mass
    # Define logic to calculate default atmospheric mass if needed
    0.0
  end

  def update_material_data(name, amount)
    material_data = available_materials
    material_data[name] ||= 0
    material_data[name] += amount
    update(materials: material_data.to_json)
  end

  def update_related_models(name)
    update_atmosphere if atmosphere_material?(name)
    update_geosphere if geosphere_material?(name)
    update_hydrosphere if hydrosphere_material?(name)
  end

  def atmosphere_material?(name)
    %w[CO2 O2 N2].include?(name)
  end

  def geosphere_material?(name)
    %w[iron ore sulfur].include?(name)
  end

  def hydrosphere_material?(name)
    %w[water].include?(name)
  end

  def update_atmosphere(gas, amount)
    self.atmosphere ||= Atmosphere.new(temperature: default_temperature)

    if amount > 0
      atmosphere.add_gas(gas)
    else
      atmosphere.remove_gas(gas.name)
    end

    run_terra_simulation
  end

  def run_terra_simulation
    TerraSim.update_environment(self, atmosphere)
    save!
  end

  def update_geosphere
    @geosphere.update_geological_activity if @geosphere
  end

  def update_hydrosphere
    @hydrosphere.update_water_cycle if @hydrosphere
  end  
end
