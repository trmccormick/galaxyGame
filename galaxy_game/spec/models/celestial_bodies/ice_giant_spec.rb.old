require 'rails_helper'

RSpec.describe CelestialBodies::IceGiant, type: :model do
  let(:ice_giant) do
    IceGiant.create!(
      name: "Uranus",
      size: 4.0,
      gravity: 8.69,
      density: 1.27,
      orbital_period: 30660,
      mass: 8.681e25, # Example mass in kg
      radius: 2.54e7, # Example radius in meters
      gas_quantities: { "Hydrogen" => 830000, "Helium" => 140000 },
      temperature: 76.0 # Example temperature
    )
  end

  describe '#calculate_atmospheric_pressure' do
    it 'calculates atmospheric pressure based on gas quantities' do
      ice_giant.calculate_atmospheric_pressure
      # Add expectations based on pressure calculation
    end
  end

  describe '#calculate_gravity' do
    it 'calculates gravity based on mass and radius' do
      ice_giant.calculate_gravity
      expected_gravity = (6.67430e-11 * ice_giant.mass) / (ice_giant.radius ** 2)
      expect(ice_giant.gravity).to be_within(0.01).of(expected_gravity)
    end
  end
end
