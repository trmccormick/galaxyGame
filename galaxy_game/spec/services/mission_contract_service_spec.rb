# spec/services/mission_contract_service_spec.rb
require 'rails_helper'

RSpec.describe MissionContractService do
  let(:supplier) { double('AiColonyManager', id: 1, name: 'Supplier AI') }
  let(:buyer) { double('AiColonyManager', id: 2, name: 'Buyer AI') }
  let(:contractor) { double('Organization', id: 3, name: 'Construction Corp') }
  let(:client) { double('Organization', id: 4, name: 'Client Corp') }
  let(:player) { double('Player', id: 5) }
  let(:supplier_settlement) { double('Settlement') }
  let(:buyer_settlement) { double('Settlement') }
  let(:supplier_location) { double('Location', x: 100, y: 200) }
  let(:buyer_location) { double('Location', x: 150, y: 250) }

  before do
    allow(supplier).to receive(:settlement).and_return(supplier_settlement)
    allow(buyer).to receive(:settlement).and_return(buyer_settlement)
    allow(supplier).to receive(:reliability_score).and_return(0.9)
    allow(buyer).to receive(:reliability_score).and_return(0.8)
    allow(supplier_settlement).to receive(:location).and_return(supplier_location)
    allow(buyer_settlement).to receive(:location).and_return(buyer_location)
    allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(50.0)
  end

  describe '.create_supply_contract' do
    it 'creates a supply contract with correct requirements and reward' do
      expect(MissionContract).to receive(:create!).with(
        mission_id: match(/^supply_oxygen_\w+$/),
        name: 'Supply Contract: 1000kg oxygen',
        description: 'Supplier AI to supply 1000kg of oxygen to Buyer AI',
        requirements: {
          'resource' => 'oxygen',
          'quantity' => 1000,
          'delivery_location' => 'Luna Base',
          'deadline' => anything
        },
        reward: {
          'type' => 'credits',
          'amount' => be > 0,
          'description' => 'Supply contract payment for 1000kg oxygen',
          'market_adjusted' => true
        },
        offered_by: supplier,
        status: :open,
        operational_data: {
          'contract_type' => 'supply',
          'supplier_id' => 1,
          'buyer_id' => 2,
          'terms' => { 'location' => 'Luna Base', 'urgency' => 'high' }
        }
      )

      described_class.create_supply_contract(
        supplier, buyer, 'oxygen', 1000,
        { 'location' => 'Luna Base', 'urgency' => 'high' }
      )
    end
  end

  describe '.create_construction_contract' do
    let(:project_spec) do
      {
        'name' => 'Habitat Module',
        'complexity' => 1.5,
        'required_skills' => ['construction', 'life_support']
      }
    end

    it 'creates a construction contract with project specifications' do
      expect(MissionContract).to receive(:create!).with(
        mission_id: match(/^construction_\w+$/),
        name: 'Construction Contract: Habitat Module',
        description: 'Construction Corp to complete Habitat Module for Client Corp',
        requirements: {
          'project_spec' => project_spec,
          'completion_deadline' => anything,
          'quality_standards' => 'standard'
        },
        reward: {
          'type' => 'credits',
          'amount' => 50000,
          'payment_terms' => 'completion'
        },
        offered_by: client,
        status: :open,
        operational_data: {
          'contract_type' => 'construction',
          'contractor_id' => 3,
          'client_id' => 4,
          'project_spec' => project_spec
        }
      )

      described_class.create_construction_contract(
        contractor, client, project_spec,
        { 'amount' => 50000, 'deadline' => 60.days.from_now }
      )
    end
  end

  describe '.accept' do
    let(:contract) { double('MissionContract', status: :open, offered_by: supplier, accepted_by: nil) }

    before do
      allow(contract).to receive(:open?).and_return(true)
      allow(contract).to receive(:update!)
      allow(contract).to receive(:reload)
      allow(contract).to receive(:operational_data).and_return({})
      allow(described_class).to receive(:eligible_to_accept?).and_return(true)
      allow(described_class).to receive(:calculate_deadline).and_return(30.days.from_now.to_s)
      allow(described_class).to receive(:notify_parties)
    end

    context 'when eligible accepter' do
      it 'accepts the contract and updates status' do
        expect(contract).to receive(:update!).with(
          accepted_by: player,
          status: :accepted,
          operational_data: hash_including('accepted_at' => anything, 'deadline' => anything)
        )

        result = described_class.accept(contract, player)
        expect(result).to be true
      end
    end

    context 'when ineligible accepter' do
      before do
        allow(described_class).to receive(:eligible_to_accept?).and_return(false)
      end

      it 'does not accept the contract' do
        expect(contract).not_to receive(:update!)

        result = described_class.accept(contract, player)
        expect(result).to be false
      end
    end
  end

  describe '.complete' do
    let(:contract) do
      double('MissionContract',
             status: :accepted,
             accepted_by: player,
             requirements: { 'quantity' => 100 },
             reward: { 'type' => 'credits', 'amount' => 1000 },
             operational_data: {})
    end

    before do
      allow(contract).to receive(:accepted?).and_return(true)
      allow(contract).to receive(:update!)
      allow(contract).to receive(:reload)
      allow(contract).to receive(:operational_data).and_return({})
      allow(RewardService).to receive(:pay_out).and_return(true)
      allow(described_class).to receive(:notify_parties)
      allow(described_class).to receive(:validate_completion).and_return(true)
    end

    context 'with valid delivery' do
      before do
        allow(described_class).to receive(:validate_completion).and_return(true)
      end

      it 'completes the contract and pays reward' do
        delivery_data = { 'delivered_quantity' => 100 }

        expect(contract).to receive(:update!).with(
          status: :completed,
          operational_data: hash_including('completed_at' => anything, 'delivery_data' => delivery_data)
        )
        expect(RewardService).to receive(:pay_out).with(contract.reward, player)

        result = described_class.complete(contract, delivery_data)
        expect(result).to be true
      end
    end

    context 'with invalid delivery' do
      before do
        allow(described_class).to receive(:validate_completion).and_return(false)
      end

      it 'does not complete the contract' do
        expect(contract).not_to receive(:update!)
        expect(RewardService).not_to receive(:pay_out)

        result = described_class.complete(contract, {})
        expect(result).to be false
      end
    end
  end

  describe '.cancel' do
    let(:contract) do
      double('MissionContract',
             status: :accepted,
             offered_by: supplier,
             accepted_by: player,
             operational_data: {})
    end

    before do
      allow(contract).to receive(:open?).and_return(false)
      allow(contract).to receive(:accepted?).and_return(true)
      allow(contract).to receive(:update!)
      allow(contract).to receive(:reload)
      allow(contract).to receive(:operational_data).and_return({})
      allow(described_class).to receive(:notify_parties)
    end

    it 'cancels the contract and updates status' do
      expect(contract).to receive(:update!).with(
        status: :failed,
        operational_data: hash_including('cancelled_at' => anything, 'cancellation_reason' => 'Buyer withdrew')
      )

      result = described_class.cancel(contract, 'Buyer withdrew')
      expect(result).to be true
    end
  end

  describe '.check_expirations' do
    let!(:expired_contract) do
      double('MissionContract',
             status: :accepted,
             operational_data: { 'deadline' => 1.day.ago.to_s })
    end

    let!(:active_contract) do
      double('MissionContract',
             status: :accepted,
             operational_data: { 'deadline' => 1.day.from_now.to_s })
    end

    before do
      allow(MissionContract).to receive(:where).and_return([expired_contract, active_contract])
      allow(expired_contract).to receive(:update!)
      allow(described_class).to receive(:notify_parties)
    end

    it 'expires overdue contracts' do
      expect(expired_contract).to receive(:update!).with(status: :expired)

      described_class.check_expirations
    end
  end

  describe 'private methods' do
    describe '.calculate_supply_reward' do
      it 'calculates reward based on market price and contract terms' do
        reward = described_class.send(:calculate_supply_reward, supplier, buyer, 'oxygen', 100, { 'urgency' => 'high' })

        expect(reward['type']).to eq('credits')
        expect(reward['amount']).to be > 0
        expect(reward['market_adjusted']).to be true
      end
    end

    describe '.calculate_delivery_risk' do
      it 'calculates risk premium based on distance and reliability' do
        allow(supplier).to receive(:reliability_score).and_return(0.9)
        allow(described_class).to receive(:calculate_distance_factor).and_return(0.5)

        risk = described_class.send(:calculate_delivery_risk, buyer, supplier)

        expect(risk).to be > 0
        expect(risk).to be <= 0.5
      end
    end
  end
end