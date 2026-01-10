require 'rails_helper'

RSpec.describe Logistics::Contract, type: :model do
  let(:from_settlement) { create(:base_settlement) }
  let(:to_settlement) { create(:base_settlement) }
  let(:provider) { create(:logistics_provider) }

  describe 'validations' do
    it 'is valid with required attributes' do
      contract = Logistics::Contract.new(
        from_settlement: from_settlement,
        to_settlement: to_settlement,
        provider: provider,
        material: 'oxygen',
        quantity: 100,
        transport_method: :orbital_transfer
      )
      expect(contract).to be_valid
    end

    it 'requires material' do
      contract = Logistics::Contract.new(from_settlement: from_settlement, to_settlement: to_settlement, provider: provider)
      expect(contract).not_to be_valid
      expect(contract.errors[:material]).to include("can't be blank")
    end

    it 'requires quantity greater than 0' do
      contract = Logistics::Contract.new(
        from_settlement: from_settlement,
        to_settlement: to_settlement,
        provider: provider,
        material: 'oxygen',
        quantity: 0
      )
      expect(contract).not_to be_valid
      expect(contract.errors[:quantity]).to include("must be greater than 0")
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Logistics::Contract.statuses).to include(
        'pending' => 0,
        'in_transit' => 1,
        'delivered' => 2,
        'failed' => 3,
        'cancelled' => 4
      )
    end

    it 'defines transport_method enum' do
      expect(Logistics::Contract.transport_methods).to include(
        'orbital_transfer' => 0,
        'surface_conveyance' => 1,
        'drone_delivery' => 2
      )
    end
  end

  describe 'scopes' do
    let!(:pending_contract) { create(:logistics_contract, status: :pending) }
    let!(:delivered_contract) { create(:logistics_contract, status: :delivered) }

    it 'has active scope' do
      expect(Logistics::Contract.active).to include(pending_contract)
      expect(Logistics::Contract.active).not_to include(delivered_contract)
    end

    it 'has completed scope' do
      expect(Logistics::Contract.completed).to include(delivered_contract)
      expect(Logistics::Contract.completed).not_to include(pending_contract)
    end
  end

  describe 'instance methods' do
    let(:contract) { create(:logistics_contract, status: :pending) }

    describe '#mark_delivered!' do
      it 'updates status to delivered and sets completed_at' do
        expect { contract.mark_delivered! }.to change { contract.status }.from('pending').to('delivered')
        expect(contract.completed_at).to be_present
      end
    end

    describe '#mark_failed!' do
      it 'updates status to failed and records reason' do
        contract.mark_failed!('transport failure')
        expect(contract.status).to eq('failed')
        expect(contract.operational_data['failure_reason']).to eq('transport failure')
      end
    end
  end
end