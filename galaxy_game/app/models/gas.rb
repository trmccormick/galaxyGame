# app/models/gas.rb
class Gas < ApplicationRecord
  belongs_to :atmosphere, class_name: 'CelestialBodies::Atmosphere'

  # Explicitly specify the table name if necessary
  self.table_name = 'gases'

  # Attributes
  validates :name, presence: true
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :ppm, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :mass, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :molar_mass, presence: true # Ensure molar_mass is validated

  # Calculate moles of gas based on the material's amount and molar mass
  def moles(amount)
    return 0 unless amount && molar_mass
    (amount / molar_mass).to_f
  end

  # Determine the state of the gas based on the temperature and pressure
  # def state(temperature, pressure)
  #   return 'unknown' unless material
  #   material.state_at(temperature, pressure)
  # end
end