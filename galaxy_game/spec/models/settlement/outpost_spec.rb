require 'rails_helper'

RSpec.describe Settlement::Outpost, type: :model do
  # Use the :independent trait to avoid colony validation issues
  let(:outpost) { create(:outpost, :independent, name: "Mars Outpost", current_population: 0) }
  let!(:habitat_unit) { 
    create(:base_unit, 
      unit_type: 'habitat_unit',
      operational_data: { 'capacity' => 500 },
      attachable: outpost
    ) 
  }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(outpost).to be_valid
    end

    it 'is not valid without a name' do
      outpost.name = nil
      expect(outpost).to_not be_valid
      expect(outpost.errors[:name]).to include("can't be blank")
    end
  end

  describe 'population capacity' do
    it 'calculates total capacity from habitat units' do
      outpost.reload
      outpost.base_units.reload
      expect(outpost.population_capacity).to eq(500)
      expect(outpost.total_capacity).to eq(500) # Test the alias
    end

    it 'calculates available capacity correctly' do
      outpost.reload
      outpost.current_population = 200
      expect(outpost.available_capacity).to eq(300) # 500 - 200
    end

    it 'checks if it has capacity for additional population' do
      outpost.reload
      outpost.current_population = 300
      expect(outpost.has_capacity_for?(150)).to be true
      expect(outpost.has_capacity_for?(250)).to be false
    end
  end
end
