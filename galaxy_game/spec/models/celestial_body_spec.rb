require 'rails_helper'

RSpec.describe CelestialBody, type: :model do
  let(:celestial_body) do
    CelestialBody.create!(
      name: "Earth",
      size: 1.0,
      gravity: 9.8,
      density: 5.5,
      orbital_period: 365.25,
      mass: 5.972e24, # Example mass in kg
      radius: 6.37e6, # Example radius in meters
      gas_quantities: { "Nitrogen" => 780800, "Oxygen" => 209500 },
      materials: { "Iron" => 1000 },
      temperature: 288.15 # Default temperature
    )
  end

  describe '#add_gas' do
    it 'adds gas and updates the mass' do
      initial_mass = celestial_body.mass
      celestial_body.add_gas('Oxygen', 1000)
      expect(celestial_body.available_gas_quantities['Oxygen']).to eq(210500)
      expect(celestial_body.mass).to be > initial_mass
    end
  end

  describe '#remove_gas' do
    it 'removes gas and updates the mass' do
      initial_mass = celestial_body.mass
      celestial_body.remove_gas('Oxygen', 500)
      expect(celestial_body.available_gas_quantities['Oxygen']).to eq(209000)
      expect(celestial_body.mass).to be < initial_mass
    end
  end

  describe '#add_material' do
    it 'adds material and updates the mass' do
      initial_mass = celestial_body.mass
      celestial_body.add_material('Gold', 500)
      expect(celestial_body.available_materials['Gold']).to eq(500)
      expect(celestial_body.mass).to be > initial_mass
    end
  end

  describe '#remove_material' do
    it 'removes material and updates the mass' do
      initial_mass = celestial_body.mass
      celestial_body.remove_material('Iron', 200)
      expect(celestial_body.available_materials['Iron']).to eq(800)
      expect(celestial_body.mass).to be < initial_mass
    end
  end

  describe '#update_biomes' do
    it 'updates biomes based on temperature and atmospheric pressure' do
      celestial_body.temperature = 290.15 # Example temperature
      celestial_body.calculate_total_pressure
      celestial_body.update_biomes
      expect(celestial_body.biomes).to include('Tropical Rainforest')
    end

    it 'sets the correct biome for a cold desert' do
      celestial_body.temperature = -50 # Set temperature for cold desert
      celestial_body.calculate_total_pressure
      celestial_body.update_biomes
      expect(celestial_body.biomes).to include('Cold Desert')
    end
  end

  describe '#update_gravity' do
    it 'calculates and updates the gravity based on mass and radius' do
      celestial_body.update_gravity
      expected_gravity = (6.67430e-11 * celestial_body.mass) / (celestial_body.radius ** 2)
      expect(celestial_body.gravity).to be_within(0.01).of(expected_gravity)
    end
  end

  describe '#habitability_score' do
    it 'returns a habitability score based on temperature and atmospheric pressure' do
      celestial_body.temperature = 290.15 # Example temperature
      allow(celestial_body).to receive(:atmospheric_pressure).and_return(1.0)
      expect(celestial_body.habitability_score).to eq('Habitable')
    end

    it 'returns non-habitable when conditions are extreme' do
      celestial_body.temperature = 400.15 # Example extreme temperature
      allow(celestial_body).to receive(:atmospheric_pressure).and_return(0.5)
      expect(celestial_body.habitability_score).to eq('Non-Habitable')
    end
  end

  describe '#calculate_total_pressure' do
    it 'calculates total atmospheric pressure based on gas quantities' do
      celestial_body.calculate_total_pressure
      total_moles = celestial_body.gas_quantities.values.sum
      expected_pressure = total_moles * CelestialBody::IDEAL_GAS_CONSTANT * CelestialBody::TEMPERATURE / CelestialBody::VOLUME
      expect(celestial_body.total_pressure).to eq(expected_pressure)
    end
  end
end