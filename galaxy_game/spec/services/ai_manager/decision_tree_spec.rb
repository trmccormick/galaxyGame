require 'rails_helper'
require_relative '../../../app/services/ai_manager'
require_relative '../../../app/services/ai_manager/decision_tree'

RSpec.describe AIManager::DecisionTree, type: :service do
  let(:settlement) { create(:base_settlement, :station) }
  let(:game_data_generator) { instance_double(Generators::GameDataGenerator) }
  let(:decision_tree) { described_class.new(settlement, game_data_generator) }

  describe '#make_decisions' do
    context 'when oxygen is critical' do
      before do
        allow_any_instance_of(AIManager::PriorityHeuristic).to receive(:get_priorities).and_return([:refill_oxygen])
      end

      it 'calls handle_oxygen_refill and returns' do
        expect(decision_tree).to receive(:handle_oxygen_refill)
        expect(decision_tree).not_to receive(:handle_debt_repayment)
        expect(decision_tree).not_to receive(:assess_settlement_state)

        decision_tree.make_decisions
      end
    end

    context 'when account is negative' do
      before do
        allow_any_instance_of(AIManager::PriorityHeuristic).to receive(:get_priorities).and_return([:debt_repayment])
      end

      it 'calls handle_debt_repayment and returns' do
        expect(decision_tree).to receive(:handle_debt_repayment)
        expect(decision_tree).not_to receive(:handle_oxygen_refill)
        expect(decision_tree).not_to receive(:assess_settlement_state)

        decision_tree.make_decisions
      end
    end

    context 'when no priorities' do
      before do
        allow_any_instance_of(AIManager::PriorityHeuristic).to receive(:get_priorities).and_return([])
        allow(decision_tree).to receive(:assess_settlement_state).and_return({})
      end

      it 'proceeds with normal decision making' do
        expect(decision_tree).to receive(:assess_settlement_state)
        expect(decision_tree).not_to receive(:handle_oxygen_refill)
        expect(decision_tree).not_to receive(:handle_debt_repayment)

        decision_tree.make_decisions
      end
    end
  end

  describe '#handle_oxygen_refill' do
    it 'calls prioritize_oxygen_refill on resource_planner' do
      expect_any_instance_of(AIManager::ResourcePlanner).to receive(:prioritize_oxygen_refill)

      decision_tree.send(:handle_oxygen_refill)
    end
  end

  describe '#handle_debt_repayment' do
    let(:priority_heuristic) { instance_double(AIManager::PriorityHeuristic) }

    before do
      allow(AIManager::PriorityHeuristic).to receive(:new).and_return(priority_heuristic)
      allow(priority_heuristic).to receive(:calculate_si_ask_price).and_return(95.0)
    end

    it 'sets si_ask_ceiling in settlement operational_data' do
      expect(settlement).to receive(:save)

      decision_tree.send(:handle_debt_repayment)

      expect(settlement.operational_data['market_settings']['si_ask_ceiling']).to eq(95.0)
    end
  end

  describe '#handle_mars_oxygen_maintenance' do
    it 'calls prioritize_energy_for_o2_generation on resource_planner' do
      expect_any_instance_of(AIManager::ResourcePlanner).to receive(:prioritize_energy_for_o2_generation)

      decision_tree.send(:handle_mars_oxygen_maintenance)
    end
  end

  describe '#handle_mars_nitrogen_import' do
    let(:source_settlement) { create(:base_settlement) }

    before do
      allow(decision_tree).to receive(:find_closest_resource_source).and_return(source_settlement)
      allow(decision_tree).to receive(:create_interplanetary_contract)
      allow(decision_tree).to receive(:calculate_critical_resource_needs).and_return(100)
    end

    it 'finds closest resource source and creates interplanetary contract' do
      expect(decision_tree).to receive(:find_closest_resource_source).with('nitrogen')
      expect(decision_tree).to receive(:create_interplanetary_contract).with(source_settlement, 'nitrogen')

      decision_tree.send(:handle_mars_nitrogen_import)
    end
  end

  describe 'Mars planet-aware crisis handling' do
    let(:mars_body) { create(:celestial_body, name: 'Mars') }
    let(:mars_location) { create(:celestial_location, celestial_body: mars_body) }
    let(:mars_settlement) { create(:base_settlement, :station, location: mars_location) }
    let(:mars_decision_tree) { described_class.new(mars_settlement, game_data_generator) }

    context 'when O2 crisis on Mars' do
      before do
        allow_any_instance_of(AIManager::PriorityHeuristic).to receive(:get_priorities).and_return([:local_oxygen_generation])
      end

      it 'handles O2 crisis through local maintenance, not trade' do
        expect(mars_decision_tree).to receive(:handle_local_oxygen_generation)
        expect(mars_decision_tree).not_to receive(:handle_oxygen_refill)

        mars_decision_tree.make_decisions
      end
    end

    context 'when N2 crisis on Mars' do
      let(:earth_body) { create(:celestial_body, name: 'Earth') }
      let(:earth_location) { create(:celestial_location, celestial_body: earth_body) }
      let(:earth_settlement) { create(:base_settlement, :station, location: earth_location) }

      before do
        allow_any_instance_of(AIManager::PriorityHeuristic).to receive(:get_priorities).and_return([:refill_nitrogen])
        allow(mars_decision_tree).to receive(:find_closest_resource_source).and_return(earth_settlement)
        allow(mars_decision_tree).to receive(:create_interplanetary_contract)
      end

      it 'triggers interplanetary contract based on closest source' do
        expect(mars_decision_tree).to receive(:handle_nitrogen_refill)

        mars_decision_tree.make_decisions
      end
    end
  end
end