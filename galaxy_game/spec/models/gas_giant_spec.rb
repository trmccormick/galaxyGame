require 'rails_helper'

RSpec.describe CelestialBodies::GasGiant, type: :model do
  let(:gas_giant) do
    GasGiant.create!(
      name: "Jupiter",
      size: 11.2,
      gravity: 24.79,
      density: 1.33,
      orbital_period: 4331,
      mass: 1.898e27, # Example mass in kg
      radius: 6.99e7, # Example radius in meters
      gas_quantities: { "Hydrogen" => 8580000, "Helium" => 1520000 },
      temperature: 165.0 # Example temperature
    )
  end

  describe '#calculate_atmospheric_pressure' do
    it 'calculates atmospheric pressure based on gas quantities' do
      gas_giant.calculate_atmospheric_pressure
      # Add expectations based on pressure calculation
    end
  end

  describe '#calculate_gravity' do
    it 'calculates gravity based on mass and radius' do
      gas_giant.calculate_gravity
      expected_gravity = (6.67430e-11 * gas_giant.mass) / (gas_giant.radius ** 2)
      expect(gas_giant.gravity).to be_within(0.01).of(expected_gravity)
    end
  end
end
