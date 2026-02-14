# spec/services/ai_manager/strategy_selector_spec.rb
require 'rails_helper'

RSpec.describe AIManager::StrategySelector, type: :service do
  let(:settlement) { create(:base_settlement) }
  let(:shared_context) { AIManager::SharedContext.new(settlement: settlement) }
  let(:service_coordinator) { AIManager::ServiceCoordinator.new(shared_context) }
  let(:strategy_selector) { AIManager::StrategySelector.new(shared_context, service_coordinator) }

  describe '#evaluate_next_action' do
    context 'with critical resource needs' do
      before do
        # Mock critical resource shortage
        allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return({
          resource_needs: { critical: ['energy'], needed: [] },
          scouting_opportunities: { high_value: [], strategic: [] },
          expansion_readiness: 0.5,
          infrastructure_needs: { critical: [], needed: [] },
          acquisition_capability: 0.8,
          scouting_capability: 0.6,
          building_resources: 0.7,
          economic_health: 0.6,
          strategic_position: 0.7
        })
      end

      it 'prioritizes resource acquisition for critical needs' do
        action = strategy_selector.evaluate_next_action(settlement)

        expect(action[:type]).to eq(:resource_acquisition)
        expect(action[:priority]).to eq(:critical)
        expect(action[:resources]).to include('energy')
        expect(action[:score]).to be > 0
      end
    end

    context 'with high expansion readiness' do
      before do
        allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return({
          resource_needs: { critical: [], needed: [] },
          scouting_opportunities: { high_value: [], strategic: [] },
          expansion_readiness: 0.9,
          infrastructure_needs: { critical: [], needed: [] },
          acquisition_capability: 0.8,
          scouting_capability: 0.6,
          building_resources: 0.7,
          economic_health: 0.8,
          strategic_position: 0.7
        })
      end

      it 'recommends settlement expansion' do
        action = strategy_selector.evaluate_next_action(settlement)

        expect(action[:type]).to eq(:settlement_expansion)
        expect(action[:priority]).to eq(:high)
        expect(action[:score]).to be > 0
      end
    end

    context 'with scouting opportunities' do
      before do
        allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return({
          resource_needs: { critical: [], needed: [] },
          scouting_opportunities: { high_value: [{ id: 'test_system' }], strategic: [] },
          expansion_readiness: 0.5,
          infrastructure_needs: { critical: [], needed: [] },
          acquisition_capability: 0.8,
          scouting_capability: 0.8,
          building_resources: 0.7,
          economic_health: 0.7,
          strategic_position: 0.7
        })
      end

      it 'recommends system scouting' do
        action = strategy_selector.evaluate_next_action(settlement)

        expect(action[:type]).to eq(:system_scouting)
        expect(action[:priority]).to eq(:high)
        expect(action[:score]).to be > 0
      end
    end

    context 'with no viable actions' do
      before do
        allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return({
          resource_needs: { critical: [], needed: [] },
          scouting_opportunities: { high_value: [], strategic: [] },
          expansion_readiness: 0.3,
          infrastructure_needs: { critical: [], needed: [] },
          acquisition_capability: 0.2,
          scouting_capability: 0.2,
          building_resources: 0.2,
          economic_health: 0.3,
          strategic_position: 0.4
        })
      end

      it 'returns wait action' do
        action = strategy_selector.evaluate_next_action(settlement)

        expect(action[:type]).to eq(:wait)
        expect(action[:score]).to eq(0)
      end
    end
  end

  describe '#execute_action' do
    context 'resource acquisition action' do
      let(:action) { { type: :resource_acquisition, resources: ['steel', 'titanium'] } }

      it 'calls service coordinator to acquire resources' do
        expect(service_coordinator).to receive(:acquire_resource).with('steel', 100, settlement)
        expect(service_coordinator).to receive(:acquire_resource).with('titanium', 100, settlement)

        result = strategy_selector.execute_action(action, settlement)
        expect(result).to be true
      end
    end

    context 'system scouting action' do
      let(:action) { { type: :system_scouting, systems: [{ id: 'test_system' }] } }

      it 'calls service coordinator to scout systems' do
        expect(service_coordinator).to receive(:scout_system).with({ id: 'test_system' })

        result = strategy_selector.execute_action(action, settlement)
        expect(result).to be true
      end
    end

    context 'settlement expansion action' do
      let(:action) { { type: :settlement_expansion } }

      it 'logs expansion initiation' do
        expect(Rails.logger).to receive(:info).with(/Initiating settlement expansion/)

        result = strategy_selector.execute_action(action, settlement)
        expect(result).to be true
      end
    end

    context 'infrastructure building action' do
      let(:action) { { type: :infrastructure_building } }

      it 'logs building initiation' do
        expect(Rails.logger).to receive(:info).with(/Initiating infrastructure building/)

        result = strategy_selector.execute_action(action, settlement)
        expect(result).to be true
      end
    end

    context 'unknown action type' do
      let(:action) { { type: :unknown_action } }

      it 'logs warning and returns false' do
        expect(Rails.logger).to receive(:warn).with(/Unknown action type/)

        result = strategy_selector.execute_action(action, settlement)
        expect(result).to be false
      end
    end
  end

  describe 'mission option generation' do
    it 'generates resource acquisition options for critical needs' do
      state_analysis = {
        resource_needs: { critical: ['energy'], needed: [] },
        scouting_opportunities: { high_value: [], strategic: [] },
        expansion_readiness: 0.5,
        infrastructure_needs: { critical: [], needed: [] }
      }

      options = strategy_selector.send(:generate_mission_options, settlement, state_analysis)

      expect(options).to include(hash_including(type: :resource_acquisition, priority: :critical))
    end

    it 'generates scouting options for high-value opportunities' do
      state_analysis = {
        resource_needs: { critical: [], needed: [] },
        scouting_opportunities: { high_value: [{ id: 'valuable_system' }], strategic: [] },
        expansion_readiness: 0.5,
        infrastructure_needs: { critical: [], needed: [] }
      }

      options = strategy_selector.send(:generate_mission_options, settlement, state_analysis)

      expect(options).to include(hash_including(type: :system_scouting, priority: :high))
    end

    it 'generates expansion options when readiness is high' do
      state_analysis = {
        resource_needs: { critical: [], needed: [] },
        scouting_opportunities: { high_value: [], strategic: [] },
        expansion_readiness: 0.9,
        infrastructure_needs: { critical: [], needed: [] }
      }

      options = strategy_selector.send(:generate_mission_options, settlement, state_analysis)

      expect(options).to include(hash_including(type: :settlement_expansion, priority: :high))
    end
  end

  describe 'mission scoring' do
    let(:state_analysis) do
      {
        resource_needs: { critical: [], needed: [] },
        scouting_opportunities: { high_value: [], strategic: [] },
        expansion_readiness: 0.5,
        infrastructure_needs: { critical: [], needed: [] },
        acquisition_capability: 0.8,
        scouting_capability: 0.6,
        building_resources: 0.7,
        economic_health: 0.6,
        strategic_position: 0.7
      }
    end

    it 'scores critical priority actions higher' do
      critical_option = { type: :resource_acquisition, priority: :critical, resources: ['energy'] }
      high_option = { type: :resource_acquisition, priority: :high, resources: ['steel'] }

      critical_score = strategy_selector.send(:score_mission_options, [critical_option], state_analysis).first[:score]
      high_score = strategy_selector.send(:score_mission_options, [high_option], state_analysis).first[:score]

      expect(critical_score).to be > high_score
    end

    it 'prioritizes settlement expansion when readiness is high' do
      expansion_option = { type: :settlement_expansion, priority: :high }
      scouting_option = { type: :system_scouting, priority: :high, systems: [{ id: 'test' }] }

      state_with_high_readiness = state_analysis.merge(expansion_readiness: 0.9)

      scored_options = strategy_selector.send(:score_mission_options, [expansion_option, scouting_option], state_with_high_readiness)
      top_option = scored_options.first

      expect(top_option[:type]).to eq(:settlement_expansion)
    end
  end
end