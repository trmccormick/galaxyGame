require 'rails_helper'

RSpec.describe CelestialBodies::Planets::Gaseous::IceGiant, type: :model do
  it_behaves_like "a gaseous planet"

  let(:solar_system) { create(:solar_system) }

  let(:ice_giant) do
    create(:ice_giant,
      solar_system: solar_system,
      mass: 1.024e26,      # Neptune mass (kg)
      radius: 2.4622e7,    # Neptune radius (m)
      density: 1.64,       # Neptune density (g/cm^3)
      orbital_period: 60195, # Neptune orbital period (days)
      size: 2.4622e7,      # Neptune size (m)
      known_pressure: 1.0, # Neptune atmospheric pressure (bar)
      surface_temperature: -214 # Neptune surface temp (C)
    )
  end

  describe '#calculate_gravity' do
    it 'calculates gravity based on mass and radius' do
      expected_gravity = (6.67430e-11 * ice_giant.mass) / (ice_giant.radius ** 2)
      expect(ice_giant.calculate_gravity).to be_within(0.01).of(expected_gravity)
    end
  end

  describe '#habitability_score' do
    it 'returns not habitable for ice giants' do
      expect(ice_giant.habitability_score).to eq("Ice giants are not habitable.")
    end
  end

  # Add more property tests as needed
end