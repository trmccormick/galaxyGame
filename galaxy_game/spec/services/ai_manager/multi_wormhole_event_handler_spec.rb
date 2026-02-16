# spec/services/ai_manager/multi_wormhole_event_handler_spec.rb
require 'rails_helper'
require './app/services/ai_manager/multi_wormhole_event_handler'

RSpec.describe AIManager::MultiWormholeEventHandler, type: :service do
  let(:shared_context) { instance_double(AIManager::SharedContext) }
  let(:handler) { described_class.new(shared_context) }

  let(:event_data) do
    {
      system_a: { id: 1, name: 'System A', em_richness: 150, connectivity_score: 80 },
      system_b: { id: 2, name: 'System B', em_richness: 120, connectivity_score: 60 },
      counterbalance_quality: 1.2,
      stabilization_efforts: 2,
      existing_aws: [{ id: 1, location: 'System A' }, { id: 2, location: 'System B' }]
    }
  end

  describe '#handle_double_wormhole_event' do
    let(:mock_assessments) { { system_a: { total_value: 200 }, system_b: { total_value: 150 } } }
    let(:mock_decisions) { { primary_target: :system_a, stabilization_method: :hammer_and_reconnect } }
    let(:mock_results) { { success: true, em_harvested: 1000 } }
    let(:mock_learning) { { adaptive_scouting: { effectiveness: 0.85 } } }

    before do
      allow(handler).to receive(:assess_dual_systems).and_return(mock_assessments)
      allow(handler).to receive(:make_strategic_decisions).and_return(mock_decisions)
      allow(handler).to receive(:execute_stabilization_plan).and_return(mock_results)
      allow(handler).to receive(:capture_adaptive_patterns).and_return(mock_learning)
      allow(handler).to receive(:update_story_progression)
    end

    it 'processes the complete event workflow' do
      result = handler.handle_double_wormhole_event(event_data)

      expect(result).to include(
        assessments: mock_assessments,
        decisions: mock_decisions,
        results: mock_results,
        learning: mock_learning,
        story_progression: :adaptive_multi_wormhole_mastery
      )
    end

    it 'calls all workflow methods in sequence' do
      expect(handler).to receive(:assess_dual_systems).ordered
      expect(handler).to receive(:make_strategic_decisions).ordered
      expect(handler).to receive(:execute_stabilization_plan).ordered
      expect(handler).to receive(:capture_adaptive_patterns).ordered
      expect(handler).to receive(:update_story_progression).ordered

      handler.handle_double_wormhole_event(event_data)
    end
  end

  describe '#calculate_stability_window' do
    it 'calculates base stability window' do
      event_data = { counterbalance_quality: 1.0, stabilization_efforts: 0 }
      result = handler.send(:calculate_stability_window, event_data)

      expect(result).to eq(48.hours.to_i)
    end

    it 'adjusts stability based on counterbalance quality' do
      event_data = { counterbalance_quality: 1.5, stabilization_efforts: 0 }
      result = handler.send(:calculate_stability_window, event_data)

      expect(result).to eq((48.hours * 1.5).to_i)
    end

    it 'adjusts stability based on stabilization efforts' do
      event_data = { counterbalance_quality: 1.0, stabilization_efforts: 5 }
      result = handler.send(:calculate_stability_window, event_data)

      expect(result).to eq((48.hours * 1.5).to_i) # 1.0 + (5 * 0.1) = 1.5
    end

    it 'clamps stability multiplier between 0.5x and 1.5x' do
      # Test lower bound
      event_data = { counterbalance_quality: 0.2, stabilization_efforts: 0 }
      result = handler.send(:calculate_stability_window, event_data)
      expect(result).to eq((48.hours * 0.5).to_i)

      # Test upper bound
      event_data = { counterbalance_quality: 2.0, stabilization_efforts: 0 }
      result = handler.send(:calculate_stability_window, event_data)
      expect(result).to eq((48.hours * 1.5).to_i)
    end
  end

  describe '#assess_dual_systems' do
    let(:system_a) { { id: 1, name: 'System A' } }
    let(:system_b) { { id: 2, name: 'System B' } }
    let(:stability_window) { 48.hours.to_i }

    before do
      allow(handler).to receive(:assess_system_value).and_return(
        { total_value: 100, strategic_value: { score: 50 }, em_potential: 30, connectivity_value: 20 }
      )
      allow(handler).to receive(:calculate_dual_connection_em_bonus).and_return(375)
    end

    it 'assesses both systems' do
      result = handler.send(:assess_dual_systems, system_a, system_b, stability_window)

      expect(result).to include(:system_a, :system_b, :assessment_duration, :dual_connection_bonus)
      expect(result[:system_a]).to include(:total_value, :strategic_value, :em_potential, :connectivity_value)
      expect(result[:system_b]).to include(:total_value, :strategic_value, :em_potential, :connectivity_value)
    end

    it 'calculates appropriate assessment time' do
      # Test with long stability window
      long_window = 100.hours.to_i
      result = handler.send(:assess_dual_systems, system_a, system_b, long_window)
      expect(result[:assessment_duration]).to eq(8.hours.to_i) # Max 8 hours

      # Test with short stability window
      short_window = 10.hours.to_i
      result = handler.send(:assess_dual_systems, system_a, system_b, short_window)
      expect(result[:assessment_duration]).to eq(3.hours.to_i) # 30% of 10 hours
    end
  end

  describe '#make_strategic_decisions' do
    let(:assessments) do
      {
        system_a: { total_value: 200 },
        system_b: { total_value: 150 },
        dual_connection_bonus: 375
      }
    end

    before do
      allow(handler).to receive(:analyze_aws_cost_benefit).and_return({
        retargeting_cost: 1000,
        new_connection_cost: 800,
        recommended_strategy: :open_new,
        cost_savings: 800
      })
      allow(handler).to receive(:choose_stabilization_method).and_return(:hammer_and_reconnect)
      allow(handler).to receive(:allocate_em_resources).and_return({
        stabilization: 262.5,
        expansion: 112.5,
        total_available: 375
      })
      allow(handler).to receive(:predict_stabilization_outcomes).and_return({
        expected_success_rate: 0.9,
        expected_em_harvest: 525
      })
    end

    it 'makes comprehensive strategic decisions' do
      result = handler.send(:make_strategic_decisions, assessments, event_data)

      expect(result).to include(
        :primary_target,
        :stabilization_method,
        :aws_strategy,
        :em_allocation,
        :expected_outcomes
      )
      expect(result[:primary_target]).to eq(:system_a) # Higher value system
    end

    it 'chooses system A as primary target when it has higher value' do
      result = handler.send(:make_strategic_decisions, assessments, event_data)
      expect(result[:primary_target]).to eq(:system_a)
    end

    it 'chooses system B as primary target when it has higher value' do
      assessments_b_higher = assessments.merge(
        system_a: { total_value: 100 },
        system_b: { total_value: 200 }
      )

      result = handler.send(:make_strategic_decisions, assessments_b_higher, event_data)
      expect(result[:primary_target]).to eq(:system_b)
    end
  end

  describe '#analyze_aws_cost_benefit' do
    it 'compares retargeting vs new connection costs' do
      result = handler.send(:analyze_aws_cost_benefit, event_data)

      expect(result).to include(
        :retargeting_cost,
        :new_connection_cost,
        :retargeting_benefit,
        :new_connection_benefit,
        :recommended_strategy,
        :cost_savings
      )
    end

    it 'recommends retargeting when cheaper' do
      event_data_low_cost = event_data.merge(existing_aws: [{ id: 1 }]) # Only 1 AWS, lower cost
      result = handler.send(:analyze_aws_cost_benefit, event_data_low_cost)

      expect(result[:recommended_strategy]).to eq(:retarget_existing)
    end

    it 'recommends new connections when cheaper' do
      event_data_high_cost = event_data.merge(existing_aws: (1..10).map { |i| { id: i } }) # 10 AWS, high cost
      result = handler.send(:analyze_aws_cost_benefit, event_data_high_cost)

      expect(result[:recommended_strategy]).to eq(:open_new)
    end
  end

  describe '#execute_stabilization_plan' do
    let(:decisions) do
      {
        stabilization_method: :hammer_and_reconnect,
        primary_target: :system_a,
        aws_strategy: :retarget_existing,
        em_allocation: { stabilization: 200, expansion: 100 }
      }
    end

    it 'executes hammer and reconnect strategy' do
      allow(handler).to receive(:execute_hammer_and_reconnect).and_return({
        method: :hammer_and_reconnect,
        stabilization_success: true,
        em_harvested: 2500
      })

      result = handler.send(:execute_stabilization_plan, decisions, event_data)

      expect(result[:method]).to eq(:hammer_and_reconnect)
      expect(result[:stabilization_success]).to eq(true)
    end

    it 'executes direct stabilization strategy' do
      decisions_direct = decisions.merge(stabilization_method: :direct_stabilization)

      allow(handler).to receive(:execute_direct_stabilization).and_return({
        method: :direct_stabilization,
        stabilization_success: true,
        em_harvested: 1000
      })

      result = handler.send(:execute_stabilization_plan, decisions_direct, event_data)

      expect(result[:method]).to eq(:direct_stabilization)
      expect(result[:stabilization_success]).to eq(true)
    end
  end

  describe '#capture_adaptive_patterns' do
    let(:decisions) { { primary_target: :system_a, stabilization_method: :hammer_and_reconnect } }
    let(:results) do
      {
        assessment_accuracy: 0.85,
        decision_quality: 0.9,
        stability_prediction: 0.75,
        cost_savings: 0.3,
        strategic_alignment: 0.9
      }
    end

    before do
      allow(handler).to receive(:update_ai_knowledge_base)
    end

    it 'captures comprehensive learning patterns' do
      patterns = handler.send(:capture_adaptive_patterns, decisions, results)

      expect(patterns).to include(
        :adaptive_scouting,
        :dual_system_valuation,
        :counterbalance_assessment,
        :aws_cost_benefit_analysis,
        :natural_wh_stabilization_choice,
        :stabilization_method_evaluation,
        :aws_network_optimization,
        :simultaneous_operations,
        :connection_pair_management,
        :local_bubble_expansion
      )
    end

    it 'includes effectiveness metrics in patterns' do
      patterns = handler.send(:capture_adaptive_patterns, decisions, results)

      expect(patterns[:adaptive_scouting][:effectiveness]).to eq(0.85)
      expect(patterns[:dual_system_valuation][:decision_quality]).to eq(0.9)
      expect(patterns[:counterbalance_assessment][:prediction_accuracy]).to eq(0.75)
    end

    it 'updates AI knowledge base' do
      expect(handler).to receive(:update_ai_knowledge_base)

      handler.send(:capture_adaptive_patterns, decisions, results)
    end
  end

  describe '#update_story_progression' do
    it 'logs story milestone and AI learning progress' do
      expect(Rails.logger).to receive(:info).with("[MultiWormholeEventHandler] Story milestone: AI mastered adaptive multi-wormhole management")
      expect(Rails.logger).to receive(:info).with("[MultiWormholeEventHandler] AI learning: Recorded 2 multi-wormhole adaptive patterns")

      learning_patterns = { pattern1: {}, pattern2: {} }
      handler.send(:update_story_progression, learning_patterns)
    end
  end

  describe 'helper calculation methods' do
    describe '#calculate_em_harvesting_potential' do
      it 'returns base EM value when not specified' do
        system = { id: 1, name: 'Test System' }
        result = handler.send(:calculate_em_harvesting_potential, system)

        expect(result).to eq(100)
      end

      it 'returns specified EM richness' do
        system = { id: 1, name: 'Test System', em_richness: 250 }
        result = handler.send(:calculate_em_harvesting_potential, system)

        expect(result).to eq(250)
      end
    end

    describe '#assess_network_connectivity_value' do
      it 'returns base connectivity value when not specified' do
        system = { id: 1, name: 'Test System' }
        result = handler.send(:assess_network_connectivity_value, system)

        expect(result).to eq(50)
      end

      it 'returns specified connectivity score' do
        system = { id: 1, name: 'Test System', connectivity_score: 75 }
        result = handler.send(:assess_network_connectivity_value, system)

        expect(result).to eq(75)
      end
    end
  end
end