# spec/models/settlement/city_spec.rb
require 'rails_helper'

RSpec.describe Settlement::City, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  let(:location) { create(:celestial_location, celestial_body: celestial_body) }
  
  # Use the :independent trait to avoid colony validation issues
  let(:city) { 
    build(:city, :independent, 
      location: location, 
      current_population: 100, 
      food_per_person: 2, 
      water_per_person: 1, 
      energy_per_person: 3
    ) 
  }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(city).to be_valid
    end

    it 'is not valid without a location' do
      city.location = nil
      expect(city).to_not be_valid
    end

    it 'is not valid without a name' do
      city.name = nil
      expect(city).not_to be_valid
    end

    it 'is not valid with a negative current population' do
      city.current_population = -1
      expect(city).not_to be_valid
    end

    it 'is not valid with food_per_person less than or equal to zero' do
      city.food_per_person = 0
      expect(city).not_to be_valid
    end

    it 'is not valid with water_per_person less than or equal to zero' do
      city.water_per_person = 0
      expect(city).not_to be_valid
    end

    it 'is not valid with energy_per_person less than or equal to zero' do
      city.energy_per_person = 0
      expect(city).not_to be_valid
    end
  end

  describe '#resource_requirements' do
    it 'calculates resource requirements correctly' do
      expect(city.resource_requirements).to include({
        food: 200, # 100 * 2
        water: 100, # 100 * 1
        energy: 300, # 100 * 3
        waste_processing: 60
      })
      expect(city.resource_requirements).to have_key(:materials)
    end
  end
end
