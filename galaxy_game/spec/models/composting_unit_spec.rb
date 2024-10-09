# spec/models/composting_unit_spec.rb
require 'rails_helper'

RSpec.describe Units::CompostingUnit, type: :model do
  let(:composting_unit) do
    CompostingUnit.new(
      name: 'Basic Composting Unit',
      material_list: { 'organic_waste' => 40, 'compost_output' => 25 },
      energy_cost: 15  # Updated to use energy_cost
    )
  end

  let(:available_resources) do
    { 'organic_waste' => 60, 'energy' => 30, 'compost' => 0 }  # Updated to use energy
  end

  describe '#operate' do
    it 'consumes organic waste and energy, producing compost' do
      expect(composting_unit.operate(available_resources)).to be_truthy
      expect(available_resources['organic_waste']).to eq(20) # After consuming 40
      expect(available_resources['energy']).to eq(15)        # After consuming 15 energy
      expect(available_resources['compost']).to eq(25)       # After producing 25 compost
    end

    it 'returns false if insufficient organic waste is available' do
      available_resources['organic_waste'] = 10
      expect(composting_unit.operate(available_resources)).to be_falsey
    end

    it 'returns false if insufficient energy is available' do
      available_resources['energy'] = 10
      expect(composting_unit.operate(available_resources)).to be_falsey
    end
  end
end

