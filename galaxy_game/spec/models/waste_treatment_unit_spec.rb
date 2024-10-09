# spec/models/waste_treatment_unit_spec.rb
require 'rails_helper'

RSpec.describe Units::WasteTreatmentUnit, type: :model do
  let(:waste_treatment_unit) do
    Units::WasteTreatmentUnit.new(
      name: 'Basic Waste Treatment Unit',
      material_list: { 'waste' => 30, 'recycled_output' => 15, 'neutralized_output' => 5 },
      energy_cost: 10
    )
  end

  let(:available_resources) do
    { 'waste' => 50, 'energy' => 50, 'recycled_materials' => 0, 'neutralized_waste' => 0 }
  end

  describe '#operate' do
    it 'operates successfully and produces recycled and neutralized output' do
      puts "Before operation: #{available_resources.inspect}"
      expect(waste_treatment_unit.operate(available_resources)).to be_truthy
      expect(available_resources['energy']).to eq(40)
      expect(available_resources['waste']).to eq(20)
      expect(available_resources['recycled_materials']).to eq(15)
      expect(available_resources['neutralized_waste']).to eq(5)
    end

    it 'returns false if insufficient waste is available' do
      available_resources['waste'] = 10
      expect(waste_treatment_unit.operate(available_resources)).to be_falsey
    end

    it 'returns false if insufficient power is available' do
      available_resources['energy'] = 5
      expect(waste_treatment_unit.operate(available_resources)).to be_falsey
    end
  end
end
