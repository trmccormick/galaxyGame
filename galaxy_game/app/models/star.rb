class Star < ApplicationRecord
  belongs_to :solar_system, optional: true

  # Validations
  validates :name, presence: true
  validates :luminosity, presence: true
  validates :mass, presence: true, numericality: { greater_than: 0 }
  validates :life, presence: true
  validates :age, presence: true
  validates :r_ecosphere, presence: true
  validates :type_of_star, presence: true
  validates :radius, presence: true
  validates :temperature, presence: true, numericality: { greater_than: 0 }

  # Set default luminosity if not present
  # after_initialize :set_default_luminosity

  # private

  # def set_default_luminosity
  #   if luminosity.blank?
  #     self.luminosity = calculate_default_luminosity
  #   end
  # end

  # def calculate_default_luminosity
  #   case type_of_star
  #   when 'sun'
  #     3.828e26
  #   when 'red_dwarf'
  #     0.01 * 3.828e26
  #   when 'white_dwarf'
  #     0.001 * 3.828e26
  #   when 'supergiant'
  #     1.0e5 * 3.828e26
  #   else
  #     3.828e26 # Default to solar luminosity if type_of_star is unknown
  #   end
  # end
end

