require 'rails_helper'

RSpec.describe AIManager::ResourceAcquisitionService, type: :service do
  describe '.player_sell_orders_exceed_eap?' do
    let(:settlement) { instance_double('Settlement::BaseSettlement', name: 'Test Settlement') }
    let(:material) { 'oxygen' }

    context 'when evaluate_strategy returns a reference_cost' do
      before do
        allow(Market::NpcPriceCalculator).to receive(:evaluate_strategy).with(
          material: material,
          location: settlement,
          context: {}
        ).and_return(OpenStruct.new(strategy_type: 'cost_based', reference_cost: 150.0, feasible: true))
      end

      it 'does not call calculate_eap_ceiling' do
        expect(Market::NpcPriceCalculator).not_to receive(:send).with(:calculate_eap_ceiling, anything, anything)
        described_class.player_sell_orders_exceed_eap?(settlement, material)
      end

      it 'returns false (placeholder for future order-check logic)' do
        expect(described_class.player_sell_orders_exceed_eap?(settlement, material)).to be false
      end
    end

    context 'when evaluate_strategy returns nil or no reference_cost' do
      before do
        allow(Market::NpcPriceCalculator).to receive(:evaluate_strategy).and_return(OpenStruct.new(reference_cost: nil))
      end

      it 'returns false' do
        expect(described_class.player_sell_orders_exceed_eap?(settlement, material)).to be false
      end
    end
  end
end
