# spec/models/biome_spec.rb

require 'rails_helper'

RSpec.describe Biome, type: :model do
  let(:biome) { Biome.create(name: "Tropical Rainforest", temperature_range: "25..30", humidity_range: "70..90", description: "A hot and humid biome") }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(biome).to be_valid
    end

    it 'is not valid without a name' do
      biome.name = nil
      expect(biome).to_not be_valid
    end

    it 'is not valid without a temperature range' do
      biome.temperature_range = nil
      expect(biome).to_not be_valid
    end

    it 'is not valid without a humidity range' do
      biome.humidity_range = nil
      expect(biome).to_not be_valid
    end

    it 'is not valid with a duplicate name' do
      another_biome = Biome.new(name: "Tropical Rainforest", temperature_range: "25..30", humidity_range: "70..90")
      expect(another_biome).to_not be_valid
    end
  end

  describe 'associations' do
    it 'has many environments' do
      should have_many(:environments)
    end
  end
end
