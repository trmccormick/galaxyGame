require 'rails_helper'

RSpec.describe Blueprint, type: :model do
  let(:player) { create(:player) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:current_research_level).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:material_efficiency).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:time_efficiency).is_greater_than_or_equal_to(0) }
  end

  describe '#materials' do
    it 'returns a hash of required materials from JSON' do
      blueprint = create(:blueprint, name: 'Small Fuel Tank', player: player)
      materials = blueprint.materials
      expect(materials).to be_a(Hash)
      expect(materials.keys).to include('titanium_alloy', 'composite_insulation', 'pressure_valves', 'electronics')
      expect(materials['titanium_alloy']).to eq(80)
    end
  end

  describe '#calculate_efficiencies' do
    it 'calculates material and time efficiencies based on research level' do
      blueprint = create(:blueprint, name: 'Small Fuel Tank', player: player, current_research_level: 2)
      allow_any_instance_of(Lookup::BlueprintLookupService).to receive(:find_blueprint).and_return({
        'research_effects' => {
          'material_efficiency' => { 'start_value' => 0.9, 'improvement_percentage_per_research_level' => 0.02 },
          'time_efficiency' => { 'start_value' => 0.8, 'improvement_percentage_per_research_level' => 0.03 }
        }
      })
      blueprint.calculate_efficiencies
      expect(blueprint.material_efficiency).to be_within(0.00001).of(0.94)
      expect(blueprint.time_efficiency).to be_within(0.00001).of(0.86)
    end
  end
end
