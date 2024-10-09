require 'rails_helper'

RSpec.describe CelestialBodies::CelestialBody, type: :model do
  let(:star) { FactoryBot.create(:star) }
  let(:solar_system) { FactoryBot.create(:solar_system, current_star: star) }
  let(:mars) { FactoryBot.create(:celestial_body, :with_solar_system, solar_system: solar_system) }
  let(:brown_dwarf) { FactoryBot.create(:brown_dwarf) }

  context 'when part of a solar system' do
    it 'validates distance_from_star presence' do
      expect(mars).to be_valid
    end
  end

  context 'when not part of a solar system' do
    it 'allows distance_from_star to be nil' do
      expect(brown_dwarf).to be_valid
      expect(brown_dwarf.distance_from_star).to be_nil
      expect(brown_dwarf.solar_system).to be_nil
    end
  end

  describe '#add_material' do
    it 'creates a new material if it does not exist' do
      expect { mars.add_material('Oxygen', 100) }.to change { mars.materials.count }.by(1)
      expect(mars.materials.last.name).to eq('Oxygen')
      expect(mars.materials.last.amount).to eq(100)
    end

    it 'updates the amount of an existing material' do
      mars.add_material('Nitrogen', 100)

      puts mars.materials.inspect

      expect { mars.add_material('Nitrogen', 50) }.not_to change { mars.materials.count }
      expect(mars.materials.find_by(name: 'Nitrogen').amount).to eq(150)
    end
  end

  # describe '#remove_material' do
  #   it 'removes material and updates the mass' do
  #     mars.materials['Iron'] = 1000
  #     initial_mass = mars.mass
  #     mars.remove_material('Iron', 200)
  #     expect(mars.materials['Iron']).to eq(800)
  #     expect(mars.mass).to be < initial_mass
  #   end
  # end

  # describe '#update_biomes' do
  #   it 'updates biomes based on temperature and atmospheric composition' do
  #     mars.temperature = 220.15
  #     mars.calculate_atmospheric_composition
  #     mars.update_biomes
  #     expect(mars.biomes).to include('Desert')
  #   end

  #   it 'sets the correct biome for a cold desert' do
  #     mars.temperature = 150.15
  #     mars.calculate_atmospheric_composition
  #     mars.update_biomes
  #     expect(mars.biomes).to include('Cold Desert')
  #   end
  # end

  describe '#update_gravity' do
    it 'calculates and updates the gravity based on mass and radius' do
      mars.update_gravity
      expected_gravity = (6.67430e-11 * mars.mass) / (mars.radius ** 2)
      expect(mars.gravity).to be_within(0.01).of(expected_gravity)
    end
  end

  # describe '#habitability_score' do
  #   it 'returns a habitability score based on temperature and atmospheric composition' do
  #     mars.temperature = 220.15
  #     allow(mars).to receive(:calculate_atmospheric_composition).and_return(true)
  #     expect(mars.habitability_score).to eq('Potentially Habitable')
  #   end

  #   it 'returns non-habitable when conditions are extreme' do
  #     mars.temperature = 400.15
  #     allow(mars).to receive(:calculate_atmospheric_composition).and_return(false)
  #     expect(mars.habitability_score).to eq('Non-Habitable')
  #   end
  # end

  # describe '#calculate_atmospheric_composition' do
  #   it 'calculates the atmospheric composition based on materials and temperature' do
  #     mars.calculate_atmospheric_composition
  #     expect(mars.atmosphere_composition).to include('CarbonDioxide')
  #     expect(mars.atmosphere_composition).to include('Nitrogen')
  #   end
  # end
end