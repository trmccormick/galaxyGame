# spec/models/plant_environment_spec.rb

require 'rails_helper'

RSpec.describe PlantEnvironment, type: :model do
  let(:biome) { Biome.create(name: "Tropical Rainforest", temperature_range: "25..30", humidity_range: "70..90") }
  let(:planet) do
    cb = CelestialBodies::CelestialBody.create(name: "Earth", size: 1.0, materials: { "Iron" => 1000 })
    cb.create_atmosphere(composition: { "Nitrogen" => 78.08, "Oxygen" => 20.95 })
    cb
  end
  let(:environment) { Environment.create(biome: biome, celestial_body: planet, temperature: 28.0, pressure: 1.0, humidity: 85.0) }
  let(:plant) { Plant.create(name: "Fern", growth_temperature_range: "20..30", growth_humidity_range: "50..80") }
  let(:plant_environment) { PlantEnvironment.create(plant: plant, environment: environment) }
  
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(plant_environment).to be_valid
    end

    it 'is not valid without a plant' do
      plant_environment.plant = nil
      expect(plant_environment).to_not be_valid
    end

    it 'is not valid without an environment' do
      plant_environment.environment = nil
      expect(plant_environment).to_not be_valid
    end

    it 'is not valid with duplicate plant and environment pair' do
      duplicate = PlantEnvironment.new(plant: plant, environment: environment)
      expect(duplicate).to_not be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a plant' do
      should belong_to(:plant)
    end

    it 'belongs to an environment' do
      should belong_to(:environment)
    end
  end
end
