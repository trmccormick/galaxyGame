# spec/models/environment_spec.rb

require 'rails_helper'

RSpec.describe Environment, type: :model do
  let(:biome) { Biome.create(name: "Tropical Rainforest", temperature_range: "25..30", humidity_range: "70..90") }
  let!(:planet) { CelestialBodies::CelestialBody.create(identifier: "EARTH-1", name: "Earth", size: 1.0, mass: 5.972e24) }
  let(:environment) { Environment.create(biome: biome, celestial_body: planet, temperature: 28.0, pressure: 1.0, humidity: 85.0) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(environment).to be_valid
    end

    it 'is not valid without a biome' do
      environment.biome = nil
      expect(environment).to_not be_valid
    end

    it 'is not valid without a planet' do
      environment.celestial_body = nil
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

    it 'belongs to a celestial_body' do
      should belong_to(:celestial_body)
    end
  end
end
