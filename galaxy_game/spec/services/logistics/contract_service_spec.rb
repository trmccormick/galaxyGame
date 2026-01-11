require 'rails_helper'

RSpec.describe Logistics::ContractService do
  let(:from_settlement) { create(:base_settlement, name: 'Supplier Base') }
  let(:to_settlement) { create(:base_settlement, name: 'Consumer Base') }
  let(:material) { 'oxygen' }
  let(:quantity) { 1000 }

  describe '.create_internal_transfer' do
    context 'with valid settlements' do
      before do
        allow(from_settlement).to receive_message_chain(:inventory, :current_storage_of)
          .with(material).and_return(2000)
        allow(to_settlement).to receive_message_chain(:inventory, :current_storage_of)
          .with(material).and_return(100)
      end

      it 'creates a logistics contract for internal transfer' do
        contract = described_class.create_internal_transfer(
          from_settlement, to_settlement, material, quantity
        )

        expect(contract).to be_persisted
        expect(contract.from_settlement).to eq(from_settlement)
        expect(contract.to_settlement).to eq(to_settlement)
        expect(contract.material).to eq(material)
        expect(contract.quantity).to eq(quantity)
        expect(contract.status).to eq('pending')
        expect(contract.transport_method).to eq('orbital_transfer')
        expect(contract.operational_data['purpose']).to eq('internal_b2b_transfer')
      end
    end

    context 'with invalid settlements' do
      it 'returns nil when from_settlement is not an NPC' do
        player_settlement = create(:base_settlement)
        allow(player_settlement).to receive(:owner).and_return(create(:player))

        result = described_class.create_internal_transfer(
          player_settlement, to_settlement, material, quantity
        )

        expect(result).to be_nil
      end
    end
  end
end
