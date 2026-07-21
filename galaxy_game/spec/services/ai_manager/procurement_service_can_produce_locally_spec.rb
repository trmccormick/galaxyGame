require 'rails_helper'

RSpec.describe AIManager::ProcurementService do
  describe '.can_produce_locally?' do
    let(:celestial_body) { CelestialBodies::CelestialBody.find_by(identifier: 'LUNA-01') || create(:celestial_body, :luna) }
    let(:location) { create(:celestial_location, celestial_body: celestial_body) }

    context 'when settlement has nil location' do
      it 'returns false' do
        settlement = Settlement::BaseSettlement.new(name: 'Test Nil Location')
        result = described_class.can_produce_locally?(settlement, 'O2', 1)
        expect(result).to be false
      end
    end

    context 'when settlement has location but no matching equipment' do
      let(:settlement) { create(:base_settlement, location: location) }

      it 'returns false for O2 when no unit produces O2' do
        result = described_class.can_produce_locally?(settlement, 'O2', 1)
        expect(result).to be false
      end
    end

    context 'when settlement has matching equipment' do
      let(:settlement) { create(:base_settlement, location: location) }

      before do
        FactoryBot.create(:base_unit, name: 'O2 Unit', unit_type: 'extractor', settlement: settlement)
      end

      it 'returns true when a unit produces the requested resource' do
        allow_any_instance_of(Units::BaseUnit).to receive(:output_resources).and_return(['O2'])
        result = described_class.can_produce_locally?(settlement, 'O2', 1)
        expect(result).to be true
      end

      it 'returns false for non-matching resource' do
        allow_any_instance_of(Units::BaseUnit).to receive(:output_resources).and_return(['CH4'])
        result = described_class.can_produce_locally?(settlement, 'O2', 1)
        expect(result).to be false
      end
    end
  end
end
