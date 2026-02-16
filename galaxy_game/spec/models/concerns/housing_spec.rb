require 'rails_helper'

RSpec.describe Housing, type: :concern do
  # Use BaseSettlement which includes the Housing concern
  let(:test_object) { build(:base_settlement) }
  
  let(:mock_base_units) { double('base_units') }
  
  let(:mock_base_units) { double('base_units') }
  
  before do
    allow(test_object).to receive(:base_units).and_return(mock_base_units)
  end
  
  describe 'population management' do
    let(:habitat_unit) { 
      build(:base_unit, 
        unit_type: 'habitat_unit',
        operational_data: { 'capacity' => 100 }
      ) 
    }
    
    let(:starship_habitat) { 
      build(:base_unit, 
        unit_type: 'starship_habitat_unit',
        operational_data: { 'capacity' => { 'passenger_capacity' => 50 } }
      ) 
    }
    
    let(:non_habitat) { 
      build(:base_unit, 
        unit_type: 'storage_unit',
        operational_data: { 'capacity' => 1000 }
      ) 
    }
    
    before do
    allow(test_object).to receive(:base_units).and_return(mock_base_units)
        .and_return([habitat_unit, starship_habitat])
      allow(mock_base_units).to receive(:sum) do |&block|
        [habitat_unit, starship_habitat, non_habitat].sum(&block)
      end
    end
    
    it 'calculates population capacity from habitat units' do
      expect(test_object.population_capacity).to eq(150) # 100 + 50
    end
    
    it 'uses alias total_capacity for population_capacity' do
      expect(test_object.total_capacity).to eq(150)
    end
    
    it 'calculates available capacity' do
      test_object.current_population = 50
      expect(test_object.available_capacity).to eq(100) # 150 - 50
    end
    
    it 'checks if it has capacity for additional population' do
      test_object.current_population = 100
      expect(test_object.has_capacity_for?(40)).to be true
      expect(test_object.has_capacity_for?(60)).to be false
    end
    
    it 'ignores non-habitat units when calculating capacity' do
      # The storage unit with 1000 capacity should not count
      expect(test_object.population_capacity).to eq(150)
    end
    
    it 'calculates total population from base units' do
      allow(test_object).to receive(:base_units).and_return(mock_base_units)
      allow(mock_base_units).to receive(:sum).and_return(50) # 30 + 20
      expect(test_object.total_population).to eq(50)
    end
  end
end