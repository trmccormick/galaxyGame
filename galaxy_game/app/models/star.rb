class Star < ApplicationRecord
  attr_accessor :name, :type_of_star, :age, :mass, :radius, :temperature, :luminosity

  # Validations
  validates :name, presence: true
  validates :type_of_star, presence: true
  validates :age, presence: true
  validates :mass, presence: true, numericality: { greater_than: 0 }
  validates :radius, presence: true
  validates :temperature, presence: true, numericality: { greater_than: 0 }

  # Enum for different star types
  enum type_of_star: {
    sun: 0,
    red_dwarf: 1,
    white_dwarf: 2,
    neutron_star: 3,
    supergiant: 4
  }

  # Set default luminosity before saving
  before_save :set_default_luminosity

  private

  def set_default_luminosity
    self.luminosity ||= default_luminosity
  end

  def default_luminosity
    case type_of_star
    when 'sun'
      3.828e26
    when 'red_dwarf'
      0.01 * 3.828e26
    when 'white_dwarf'
      0.001 * 3.828e26
    when 'supergiant'
      1.0e5 * 3.828e26
    else
      3.828e26 # Default to solar luminosity if type_of_star is unknown
    end
  end
end
