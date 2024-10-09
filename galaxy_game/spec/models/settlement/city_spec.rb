# spec/models/city_spec.rb
require 'rails_helper'

RSpec.describe City, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  let(:city) { build(:city, celestial_body: celestial_body, current_population: 100, food_per_person: 2, water_per_person: 1, energy_per_person: 3) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(city).to be_valid
    end

    it 'is not valid without a celestial body' do
      city.celestial_body = nil
      expect(city).to_not be_valid
    end
  end

  describe '#resource_requirements' do
    it 'calculates resource requirements correctly' do
      expect(city.resource_requirements).to eq({
        food: 220, # 100 * 2 * 1.1
        water: 100,
        energy: 300
      })
    end
  end
end
