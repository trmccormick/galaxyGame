require 'rails_helper'

RSpec.describe SpecialMission, type: :model do
  it { should belong_to(:settlement).class_name('Settlement::BaseSettlement') }

  it { should validate_presence_of(:material) }
  it { should validate_presence_of(:required_quantity) }
  it { should validate_numericality_of(:required_quantity).is_greater_than(0) }
  it { should validate_presence_of(:reward_eap) }
  it { should validate_numericality_of(:reward_eap).is_greater_than(0) }

  describe 'enums' do
    it 'defines status enum' do
      expect(SpecialMission.statuses).to eq(
        'open' => 0,
        'accepted' => 1,
        'completed' => 2,
        'expired' => 3,
        'cancelled' => 4
      )
    end
  end

  describe 'scopes' do
    let!(:open_mission) { create(:special_mission, status: :open) }
    let!(:accepted_mission) { create(:special_mission, status: :accepted) }

    it 'has open scope' do
      expect(SpecialMission.open).to include(open_mission)
      expect(SpecialMission.open).not_to include(accepted_mission)
    end
  end

  describe 'instance methods' do
    let(:mission) { create(:special_mission, status: :open, reward_eap: 1000.0) }

    describe '#accept!' do
      it 'updates status to accepted' do
        mission.accept!(double(id: 1))
        expect(mission.status).to eq('accepted')
      end
    end

    describe '#complete!' do
      it 'updates status to completed' do
        mission.accept!(double(id: 1))
        mission.complete!(double(id: 1))
        expect(mission.status).to eq('completed')
      end
    end

    describe '#total_reward' do
      it 'returns the reward_eap' do
        expect(mission.total_reward).to eq(1000.0)
      end
    end
  end
end