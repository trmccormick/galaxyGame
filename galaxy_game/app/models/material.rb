class Material < ApplicationRecord
  belongs_to :celestial_body

  # Validations
  validates :name, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :state, inclusion: { in: %w[solid liquid gas] }, presence: true
  validates :melting_point, :boiling_point, :vapor_pressure, numericality: true, allow_nil: true
  validates :molar_mass, numericality: true, allow_nil: true  

  # Determine the state of the material based on the current temperature and pressure

  def state_at(temperature, pressure)
    return 'gas' if temperature > boiling_point
    return 'liquid' if temperature > melting_point
    'solid'
  end

  # Add the material to the atmosphere, if in gas state
  def add_to_atmosphere(atmosphere)
    current_state = state_at(celestial_body.surface_temperature, celestial_body.known_pressure)
    if current_state == 'gas'
      gas = atmosphere.gases.find { |g| g.name == name }
      if gas
        gas.percentage += amount_to_gas_percentage
      else
        atmosphere.add_gas(Gas.new(name: name, percentage: amount_to_gas_percentage, material: self))
      end
      calculate_gas_pressure(atmosphere)
    end
  end

  # Calculate the percentage of this material that becomes part of the gas in the atmosphere
  def amount_to_gas_percentage
    (amount / celestial_body.total_material_amount) * 100.0
  end

  private

  # Helper method to calculate pressure of the material in the atmosphere
  def calculate_gas_pressure(atmosphere)
    atmosphere.calculate_pressure
  end
end



