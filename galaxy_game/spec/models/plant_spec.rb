# spec/models/plant_spec.rb

require 'rails_helper'

RSpec.describe Plant, type: :model do
  let(:plant) { Plant.create(name: "Cactus", growth_temperature_range: 20..30, growth_humidity_range: 10..30, description: "A hardy plant adapted to dry environments") }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(plant).to be_valid
    end

    it 'is not valid without a name' do
      plant.name = nil
      expect(plant).to_not be_valid
    end

    it 'is not valid without a growth temperature range' do
      plant.growth_temperature_range = nil
      expect(plant).to_not be_valid
    end

    it 'is not valid without a growth humidity range' do
      plant.growth_humidity_range = nil
      expect(plant).to_not be_valid
    end

    it 'is not valid with a duplicate name' do
      another_plant = Plant.new(name: "Cactus", growth_temperature_range: "20..30", growth_humidity_range: "10..30")
      expect(another_plant).to_not be_valid
    end
  end

  describe 'methods' do
    it 'can grow in a given environment if conditions are met' do
      biome = Biome.create(name: "Desert", temperature_range: "20..35", humidity_range: "5..25")
      environment = Environment.create(biome: biome, planet: Planet.first, temperature: 25.0, pressure: 1.0, humidity: 20.0)
      expect(plant.can_grow_in?(environment)).to be true
    end

    it 'cannot grow in a given environment if conditions are not met' do
      biome = Biome.create(name: "Tropical Rainforest", temperature_range: "25..30", humidity_range: "70..90")
      environment = Environment.create(biome: biome, planet: Planet.first, temperature: 35.0, pressure: 1.0, humidity: 80.0)
      expect(plant.can_grow_in?(environment)).to be false
    end
  end
end
