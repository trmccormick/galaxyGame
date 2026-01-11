require 'rails_helper'

RSpec.describe SpecialMissionService do
  let(:settlement) { create(:base_settlement, name: 'Critical Base') }
  let(:material) { 'oxygen' }
  let(:required_quantity) { 1000 }

  describe '.generate_critical_mission' do
    context 'when mission should be generated' do
      let(:material_data) do
        {
          'pricing' => {
            'earth_usd' => {
              'base_price_per_kg' => 1.0
            }
          }
        }
      end

      before do
        allow(Market::NpcPriceCalculator).to receive(:send).with(:calculate_eap_ceiling, settlement, material).and_return(200.0)
        allow(described_class).to receive(:should_generate_mission?).and_return(true)
      end

      it 'creates a special mission with EAP-based reward' do
        mission = described_class.generate_critical_mission(settlement, material, required_quantity, :high)

        expect(mission).to be_persisted
        expect(mission.settlement).to eq(settlement)
        expect(mission.material).to eq(material)
        expect(mission.required_quantity).to eq(required_quantity)
        expect(mission.reward_eap).to be > 0
        expect(mission.bonus_multiplier).to eq(1.5) # High urgency
        expect(mission.operational_data['urgency_level']).to eq('high')
        expect(mission.operational_data['expires_at']).to be_present
      end

      it 'applies correct bonus multiplier for different urgency levels' do
        critical_mission = described_class.generate_critical_mission(settlement, material, required_quantity, :critical)
        expect(critical_mission.bonus_multiplier).to eq(2.0)

        medium_mission = described_class.generate_critical_mission(settlement, material, required_quantity, :medium)
        expect(medium_mission.bonus_multiplier).to eq(1.2)
      end

      it 'sets appropriate expiry times' do
        critical_mission = described_class.generate_critical_mission(settlement, material, required_quantity, :critical)
        expect(critical_mission.operational_data['expires_at']).to be_present

        medium_mission = described_class.generate_critical_mission(settlement, material, required_quantity, :medium)
        expect(medium_mission.operational_data['expires_at']).to be_present
      end
    end

    context 'when mission should not be generated' do
      it 'returns nil when EAP cannot be calculated' do
        allow(Market::NpcPriceCalculator).to receive(:send).with(:calculate_eap_ceiling, settlement, material).and_return(nil)

        mission = described_class.generate_critical_mission(settlement, material, required_quantity)
        expect(mission).to be_nil
      end

      it 'returns nil when should_generate_mission? returns false' do
        allow(described_class).to receive(:should_generate_mission?).and_return(false)

        mission = described_class.generate_critical_mission(settlement, material, required_quantity)
        expect(mission).to be_nil
      end
    end
  end

  describe '.check_and_generate_missions' do
    let!(:settlement_with_critical_shortage) { create(:base_settlement) }
    let!(:settlement_with_normal_levels) { create(:base_settlement) }

    before do
      allow(settlement_with_critical_shortage.inventory).to receive(:current_storage_of).and_return(10) # Critical for all
      allow(settlement_with_normal_levels.inventory).to receive(:current_storage_of).and_return(500) # Normal for all

      allow(described_class).to receive(:calculate_required_amount).and_return(1000)
      allow(Market::NpcPriceCalculator).to receive(:send).with(:calculate_eap_ceiling, anything, anything).and_return(200.0)
    end

    it 'generates missions for settlements with critical shortages' do
      allow(Settlement::BaseSettlement).to receive(:find_each).and_yield(settlement_with_critical_shortage)

      expect {
        described_class.check_and_generate_missions
      }.to change(SpecialMission, :count).by(3)

      mission = SpecialMission.last
      expect(mission.settlement).to eq(settlement_with_critical_shortage)
      expect(%w[oxygen water food]).to include(mission.material)
      expect(mission.required_quantity).to eq(990)
      expect(mission.operational_data['urgency_level']).to eq('critical')
    end

    it 'does not generate missions for settlements with normal levels' do
      allow(Settlement::BaseSettlement).to receive(:find_each).and_yield(settlement_with_normal_levels)

      expect {
        described_class.check_and_generate_missions
      }.not_to change(SpecialMission, :count)
    end
  end

  describe 'private methods' do
    describe '.should_generate_mission?' do
      it 'returns false when settlement has sufficient material' do
        allow(settlement.inventory).to receive(:current_storage_of).with(material).and_return(required_quantity + 100)

        result = described_class.send(:should_generate_mission?, settlement, material, required_quantity)
        expect(result).to be_falsey
      end

      it 'returns false when internal logistics can handle the shortage' do
        allow(settlement.inventory).to receive(:current_storage_of).with(material).and_return(0)
        allow(described_class).to receive(:check_internal_logistics_capacity).and_return(true)

        result = described_class.send(:should_generate_mission?, settlement, material, required_quantity)
        expect(result).to be_falsey
      end

      it 'returns false when mission already exists for material' do
        allow(settlement.inventory).to receive(:current_storage_of).with(material).and_return(0)
        allow(described_class).to receive(:check_internal_logistics_capacity).and_return(false)
        create(:special_mission, settlement: settlement, material: material, status: :open)

        result = described_class.send(:should_generate_mission?, settlement, material, required_quantity)
        expect(result).to be_falsey
      end

      it 'returns true when all conditions are met' do
        allow(settlement.inventory).to receive(:current_storage_of).with(material).and_return(0)
        allow(described_class).to receive(:check_internal_logistics_capacity).and_return(false)
        allow(SpecialMission).to receive(:where).and_return(double(exists?: false))

        result = described_class.send(:should_generate_mission?, settlement, material, required_quantity)
        expect(result).to be_truthy
      end
    end
  end
end