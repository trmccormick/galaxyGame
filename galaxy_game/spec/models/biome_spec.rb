# spec/models/biome_spec.rb

require 'rails_helper'

RSpec.describe Biome, type: :model do
  let(:biome) { FactoryBot.build(:biome) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(biome).to be_valid
    end

    it 'is not valid without a name' do
      biome = FactoryBot.build(:biome, :without_name)
      expect(biome).to_not be_valid
      expect(biome.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a temperature range' do
      biome = FactoryBot.build(:biome, :without_temperature_range)
      expect(biome).to_not be_valid
      expect(biome.errors[:temperature_range]).to include("can't be blank")
    end

    it 'is not valid without a humidity range' do
      biome = FactoryBot.build(:biome, :without_humidity_range)
      expect(biome).to_not be_valid
      expect(biome.errors[:humidity_range]).to include("can't be blank")
    end

    it 'is not valid with a duplicate name' do
      FactoryBot.create(:biome, name: "Tropical Rainforest", temperature_range: 25..30, humidity_range: 70..90)
      another_biome = FactoryBot.build(:biome, name: "Tropical Rainforest", temperature_range: 20..25, humidity_range: 60..80)

      expect(another_biome).to_not be_valid
      expect(another_biome.errors[:name]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it 'has many planet_biomes' do
      expect(biome).to have_many(:planet_biomes)
    end

    it 'has many celestial_bodies through planet_biomes' do
      expect(biome).to have_many(:celestial_bodies).through(:planet_biomes)
    end
  end

  describe '.biomes_for_conditions' do
    let!(:matching_biome) { FactoryBot.create(:biome, temperature_range: 25..30, humidity_range: 70..90) }

    it 'returns biomes matching the temperature and humidity conditions' do
      result = Biome.biomes_for_conditions(27, 75)
      expect(result).to include(matching_biome)
    end

    it 'returns an empty array when no biomes match the conditions' do
      result = Biome.biomes_for_conditions(5, 20)
      expect(result).to be_empty
    end
  end

  describe 'suitability' do
    it 'returns true when the biome is suitable for the given conditions' do
      expect(biome.suitable_for?(28, 80)).to be_truthy
    end

    it 'returns false when the biome is not suitable for the given conditions' do
      expect(biome.suitable_for?(35, 50)).to be_falsey
    end
  end
end