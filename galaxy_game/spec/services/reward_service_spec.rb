# spec/services/reward_service_spec.rb
require 'rails_helper'

RSpec.describe RewardService do
  let(:player) { double('Player', id: 1) }
  let(:organization) { double('Organization', id: 2) }
  let(:settlement) { double('Settlement') }
  let(:system_account) { double('Account', id: 999) }
  let(:player_account) { double('Account', id: 100) }

  before do
    allow(player).to receive(:financial_account).and_return(player_account)
    allow(organization).to receive(:account).and_return(player_account)
    allow(player).to receive(:primary_settlement).and_return(settlement)
    allow(settlement).to receive(:add_inventory)
    allow(described_class).to receive(:system_account).and_return(system_account)
    allow(described_class).to receive(:recipient_account).and_return(player_account)
    allow(described_class).to receive(:find_recipient_settlement).and_return(settlement)
  end

  describe '.pay_out' do
    context 'with credits reward' do
      let(:reward_data) do
        {
          'type' => 'credits',
          'amount' => 1000.0,
          'description' => 'Test reward'
        }
      end

      it 'creates a transaction for the player' do
        expect(Transaction).to receive(:create!).with(
          from_account: system_account,
          to_account: player_account,
          amount: 1000.0,
          description: 'Test reward',
          transaction_type: :reward
        )

        result = described_class.pay_out(reward_data, player)
        expect(result).to be true
      end

      it 'applies market adjustment when specified' do
        adjusted_reward = reward_data.merge('market_adjusted' => true, 'adjustment_factor' => 1.1)

        expect(Transaction).to receive(:create!).with(
          from_account: system_account,
          to_account: player_account,
          amount: 1100.0,
          description: 'Test reward',
          transaction_type: :reward
        )

        result = described_class.pay_out(adjusted_reward, player)
        expect(result).to be true
      end
    end

    context 'with resources reward' do
      let(:reward_data) do
        {
          'type' => 'resources',
          'resources' => { 'oxygen' => 100, 'water' => 50 }
        }
      end

      it 'adds resources to the settlement inventory' do
        expect(settlement).to receive(:add_inventory).with('oxygen', 100)
        expect(settlement).to receive(:add_inventory).with('water', 50)

        result = described_class.pay_out(reward_data, player)
        expect(result).to be true
      end
    end

    context 'with mixed reward' do
      let(:reward_data) do
        {
          'type' => 'mixed',
          'amount' => 500.0,
          'resources' => { 'oxygen' => 25 }
        }
      end

      it 'pays both credits and resources' do
        expect(Transaction).to receive(:create!).with(
          from_account: system_account,
          to_account: player_account,
          amount: 500.0,
          description: anything,
          transaction_type: :reward
        )
        expect(settlement).to receive(:add_inventory).with('oxygen', 25)

        result = described_class.pay_out(reward_data, player)
        expect(result).to be true
      end
    end

    context 'with invalid reward data' do
      it 'returns false for nil reward' do
        result = described_class.pay_out(nil, player)
        expect(result).to be false
      end

      it 'returns false for unknown reward type' do
        reward_data = { 'type' => 'unknown' }
        result = described_class.pay_out(reward_data, player)
        expect(result).to be false
      end
    end
  end
end