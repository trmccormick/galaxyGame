require 'rails_helper'

RSpec.describe Logistics::ContractService do
  let(:provider) { create(:logistics_provider) }
  let(:from_settlement) { create(:base_settlement, name: 'Supplier Base') }
  let(:to_settlement) { create(:base_settlement, name: 'Consumer Base') }
  let(:material) { 'oxygen' }
  let(:quantity) { 1000 }

  describe '.create_internal_transfer' do
    context 'with valid settlements' do
      before do
        allow(described_class).to receive(:find_provider).and_return(provider)
        allow(from_settlement).to receive_message_chain(:inventory, :current_storage_of)
          .with(material).and_return(2000)
        allow(to_settlement).to receive_message_chain(:inventory, :current_storage_of)
          .with(material).and_return(100)
      end

      it 'creates a logistics contract for internal transfer' do
        # Ensure provider exists before running the service
        provider
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
        expect(contract.provider).to be_present
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

  def make_provider_with_caps(caps)
    Logistics::Provider.create!(
      name: "Test Provider #{caps}",
      identifier: "TP-#{rand(10000)}",
      organization: create(:organization),
      reliability_rating: 4.5,
      base_fee_per_kg: 10.0,
      speed_multiplier: 1.0,
      capabilities: caps,
      cost_modifiers: {},
      time_modifiers: {}
    )
  end

  describe '.find_provider' do
    it 'finds provider with Ruby array capabilities' do
      provider = make_provider_with_caps(['orbital_transfer'])
      found = described_class.find_provider(from_settlement, to_settlement, :orbital_transfer)
      expect(found).to eq(provider)
    end

    it 'finds provider with JSON string capabilities' do
      provider = make_provider_with_caps('["orbital_transfer"]')
      found = described_class.find_provider(from_settlement, to_settlement, :orbital_transfer)
      expect(found).to eq(provider)
    end

    it 'finds provider with plain string capabilities' do
      provider = make_provider_with_caps('orbital_transfer')
      found = described_class.find_provider(from_settlement, to_settlement, :orbital_transfer)
      expect(found).to eq(provider)
    end

    it 'returns nil if no provider matches' do
      make_provider_with_caps(['surface_conveyance'])
      found = described_class.find_provider(from_settlement, to_settlement, :orbital_transfer)
      expect(found).to be_nil
    end

    it 'handles nil capabilities' do
      provider = make_provider_with_caps(nil)
      found = described_class.find_provider(from_settlement, to_settlement, :orbital_transfer)
      expect(found).to be_nil
    end

    it 'handles empty array capabilities' do
      provider = make_provider_with_caps([])
      found = described_class.find_provider(from_settlement, to_settlement, :orbital_transfer)
      expect(found).to be_nil
    end
  end
end
