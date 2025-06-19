# This is for enclosed/artificial atmospheres (habitats, ships, etc)
class Atmosphere < ApplicationRecord
  # ✅ EXISTING: Three optional associations
  belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody', optional: true
  belongs_to :craft, class_name: 'Craft::BaseCraft', optional: true
  belongs_to :structure, class_name: 'Structures::BaseStructure', optional: true
  has_many :gases, class_name: 'CelestialBodies::Materials::Gas', dependent: :destroy
  
  include AtmosphereConcern
  
  # ✅ EXISTING: Validations
  validates :temperature, presence: true, numericality: { greater_than: 0 }
  validates :pressure, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :environment_type, presence: true
  validates :total_atmospheric_mass, numericality: { greater_than_or_equal_to: 0 }
  
  # ✅ ADD: Ensure exactly one parent is set
  validate :has_exactly_one_parent
  
  enum environment_type: {
    planetary: 'planetary',
    enclosed: 'enclosed', 
    artificial: 'artificial',
    hybrid: 'hybrid'
  }
  
  after_initialize :set_defaults, if: :new_record?
  
  # Volume calculation from container
  def volume
    if celestial_body&.respond_to?(:volume)
      celestial_body.volume
    elsif structure&.respond_to?(:volume)
      structure.volume
    elsif craft&.respond_to?(:volume)
      craft.volume
    else
      0
    end
  end
  
  # Sealing methods
  def sealed?
    sealing_status
  end
  
  def seal!
    update!(sealing_status: true)
  end
  
  def unseal!
    update!(sealing_status: false)
  end

  def habitable?
    return false if pressure < 50.0
    return false if pressure > 500.0  
    return false if o2_percentage < 16.0
    return false if co2_percentage > 0.5
    return false if temperature < 273.15 || temperature > 313.15
    true
  end

  def o2_percentage
    composition.dig('O2') || 0.0
  end

  def co2_percentage
    composition.dig('CO2') || 0.0
  end

  def n2_percentage
    composition.dig('N2') || 0.0
  end
  
  private

  def set_defaults
    self.composition ||= {}
    self.dust ||= {}
    self.gas_changes ||= {}
    self.base_values ||= {}
    self.temperature_data ||= {}
    self.environment_type ||= 'enclosed'  # Default for this model
  end
  
  # ✅ ADD: Validation method
  def has_exactly_one_parent
    parents = [celestial_body_id, craft_id, structure_id].compact
    
    if parents.empty?
      errors.add(:base, "Atmosphere must belong to either a celestial_body, craft, or structure")
    elsif parents.size > 1
      errors.add(:base, "Atmosphere can only belong to one parent (celestial_body, craft, or structure)")
    end
  end
end