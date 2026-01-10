require 'rails_helper'

RSpec.describe Settlement::Settlement, type: :model do
  # Use the :independent trait to avoid colony validation issues
  let(:settlement) { build(:settlement, :independent, name: "New Earth Base") }
  let(:habitat_unit) { 
    build(:base_unit, 
      unit_type: 'habitat_unit',
      operational_data: { 'capacity' => 500 }
    ) 
  }

  before do
    settlement.base_units << habitat_unit
    settlement.current_population = 0
    settlement.save
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(settlement).to be_valid
    end

    it 'is not valid without a name' do
      settlement.name = nil
      expect(settlement).to_not be_valid
      expect(settlement.errors[:name]).to include("can't be blank")
    end
  end

  describe 'population capacity' do
    it 'calculates total capacity from habitat units' do
      expect(settlement.population_capacity).to eq(500)
      expect(settlement.total_capacity).to eq(500) # Test the alias
    end

    it 'calculates available capacity correctly' do
      settlement.current_population = 200
      expect(settlement.available_capacity).to eq(300) # 500 - 200
    end

    it 'checks if it has capacity for additional population' do
      settlement.current_population = 300
      expect(settlement.has_capacity_for?(150)).to be true
      expect(settlement.has_capacity_for?(250)).to be false
    end
  end
end
