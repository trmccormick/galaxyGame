# spec/models/environment_spec.rb

require 'rails_helper'

RSpec.describe Environment, type: :model do
  let(:biome) { Biome.create(name: "Tropical Rainforest", temperature_range: "25..30", humidity_range: "70..90") }
  let(:planet) { Planet.create(name: "Earth", size: 1.0, atmosphere: { "Nitrogen" => 78.08, "Oxygen" => 20.95 }, materials: { "Iron" => 1000 }) }
  let(:environment) { Environment.create(biome: biome, planet: planet, temperature: 28.0, pressure: 1.0, humidity: 85.0) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(environment).to be_valid
    end

    it 'is not valid without a biome' do
      environment.biome = nil
      expect(environment).to_not be_valid
    end

    it 'is not valid without a planet' do
      environment.planet = nil
      expect(environment).to_not be_valid
    end

    it 'is not valid without a temperature' do
      environment.temperature = nil
      expect(environment).to_not be_valid
    end

    it 'is not valid without a pressure' do
      environment.pressure = nil
      expect(environment).to_not be_valid
    end

    it 'is not valid without a humidity' do
      environment.humidity = nil
      expect(environment).to_not be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a biome' do
      should belong_to(:biome)
    end

    it 'belongs to a planet' do
      should belong_to(:planet)
    end
  end
end
