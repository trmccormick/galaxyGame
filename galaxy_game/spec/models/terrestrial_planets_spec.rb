require 'rails_helper'

RSpec.describe CelestialBodies::TerrestrialPlanet, type: :model do
  let(:star) { create(:star) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:planet) { create(:terrestrial_planet, :mars, solar_system: solar_system) }

  describe '#update_biomes' do
    it 'updates biomes specific to terrestrial planets' do
      planet.temperature = -60 # Example temperature for Mars
      planet.calculate_total_pressure
      planet.update_biomes
      expect(planet.biomes).to include('Cold Desert')
    end
  end

  describe '#add_gas' do
    it 'adds gas and updates the mass' do
      initial_mass = planet.mass
      planet.add_gas('Oxygen', 1000)
      expect(planet.gas_quantities['Oxygen']).to eq(210500)
      expect(planet.mass).to be > initial_mass
    end
  end

  describe '#calculate_surface_conditions' do
    it 'calculates surface conditions specific to terrestrial planets' do
      planet.calculate_surface_conditions
      # Add expectations based on surface conditions calculation
    end
  end

  it 'runs TerraSim on planet creation' do
    expect_any_instance_of(TerraSim).to receive(:calc_current)
    planet = create(:terrestrial_planet, solar_system: solar_system)
    expect(planet).to be_persisted
  end
end

