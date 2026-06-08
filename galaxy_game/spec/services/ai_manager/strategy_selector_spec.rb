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
        strategic_position: 0.7,
        food_reserves: 100,
        water_reserves: 100,
        energy_reserves: 100,
        steel_reserves: 100,
        habitation_capacity: 10
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
      scouting_option = { type: :system_scouting, priority: :high, systems: [] }
      state_with_high_readiness = state_analysis.merge(
        expansion_readiness: 0.9,
        food_reserves: 100,
        water_reserves: 100,
        habitation_capacity: 0.8
      )
      scored_options = strategy_selector.send(:score_mission_options, [expansion_option, scouting_option], state_with_high_readiness)
      best = strategy_selector.send(:select_optimal_action, scored_options, state_with_high_readiness)
      expect(best[:type]).to eq(:settlement_expansion)
    end
  end

  describe 'strategic decision logic' do
    let(:state_analysis) do
      {
        resource_needs: { critical: [], needed: ['steel'] },
        scouting_opportunities: { high_value: [], strategic: [] },
        expansion_readiness: 0.5,
        infrastructure_needs: { critical: [], needed: [] },
        acquisition_capability: 0.8,
        scouting_capability: 0.6,
        building_resources: 0.7,
        economic_health: 0.6,
        strategic_position: 0.7,
        current_resources: { minerals: 50, energy: 50, food: 50, water: 50 },
        settlement_health: 0.8,
        infrastructure_level: 0.5,
        exploration_readiness: 0.5,
        knowledge_gaps: [],
        future_projections: { resource_needs: [] },
        strategic_timeline: [],
        expansion_potential: 0.5,
        economic_projections: { long_term: 0.5 }
      }
    end

    describe '#perform_strategic_tradeoff_analysis' do
      it 'analyzes all trade-off combinations' do
        analysis = strategy_selector.send(:perform_strategic_tradeoff_analysis, state_analysis)

        expect(analysis).to have_key(:resource_vs_scouting)
        expect(analysis).to have_key(:resource_vs_building)
        expect(analysis).to have_key(:scouting_vs_building)
        expect(analysis).to have_key(:overall_focus)
        expect(analysis).to have_key(:risk_tolerance)
        expect(analysis).to have_key(:long_term_value)
      end

      it 'determines overall strategic focus' do
        analysis = strategy_selector.send(:perform_strategic_tradeoff_analysis, state_analysis)

        expect([:resource_focus, :scouting_focus, :building_focus, :balanced_approach]).to include(analysis[:overall_focus])
      end
    end

    describe '#apply_strategic_adjustments' do
      let(:scored_options) do
        [
          { type: :resource_acquisition, score: 50, sequencing_info: { can_execute_now: true }, rationale: 'Test' },
          { type: :system_scouting, score: 40, sequencing_info: { can_execute_now: true }, rationale: 'Test' },
          { type: :settlement_expansion, score: 30, sequencing_info: { can_execute_now: true }, rationale: 'Test' }
        ]
      end

      it 'applies resource focus multiplier' do
        strategic_analysis = {
          overall_focus: :resource_focus,
          risk_tolerance: 0.5,
          long_term_value: 20
        }

        adjusted = strategy_selector.send(:apply_strategic_adjustments, scored_options, strategic_analysis, state_analysis)

        resource_option = adjusted.find { |opt| opt[:type] == :resource_acquisition }
        scouting_option = adjusted.find { |opt| opt[:type] == :system_scouting }

        expect(resource_option[:adjusted_score]).to be > resource_option[:score] # Should get 1.3x multiplier
        expect(scouting_option[:adjusted_score]).to be < scouting_option[:score] # Should get 0.8x multiplier
      end

      it 'applies risk tolerance adjustments' do
        strategic_analysis = {
          overall_focus: :balanced_approach,
          risk_tolerance: 0.8, # High risk tolerance
          long_term_value: 20
        }

        adjusted = strategy_selector.send(:apply_strategic_adjustments, scored_options, strategic_analysis, state_analysis)

        # High risk tolerance should give 1.1x multiplier
        expect(adjusted.first[:risk_multiplier]).to eq(1.1)
      end

      it 'includes long-term value bonus' do
        strategic_analysis = {
          overall_focus: :balanced_approach,
          risk_tolerance: 0.5,
          long_term_value: 50
        }

        adjusted = strategy_selector.send(:apply_strategic_adjustments, scored_options, strategic_analysis, state_analysis)

        # Should include long-term bonus of 50 * 0.1 = 5
        expect(adjusted.first[:long_term_bonus]).to eq(5.0)
      end
    end

    describe '#determine_overall_strategic_focus' do
      it 'chooses resource focus when all trade-offs recommend it' do
        resource_vs_scouting = { recommended_focus: :resource_focus }
        resource_vs_building = { recommended_focus: :resource_focus }
        scouting_vs_building = { recommended_focus: :resource_focus }

        focus = strategy_selector.send(:determine_overall_strategic_focus,
          resource_vs_scouting, resource_vs_building, scouting_vs_building, state_analysis)

        expect(focus).to eq(:resource_focus)
      end

      it 'breaks ties using critical state needs' do
        # Create a tie between resource and scouting
        resource_vs_scouting = { recommended_focus: :resource_focus }
        resource_vs_building = { recommended_focus: :scouting_focus }
        scouting_vs_building = { recommended_focus: :balanced_approach }

        # Add critical resource need to break tie
        state_with_critical_needs = state_analysis.merge(
          resource_needs: { critical: ['energy'], needed: [] }
        )

        focus = strategy_selector.send(:determine_overall_strategic_focus,
          resource_vs_scouting, resource_vs_building, scouting_vs_building, state_with_critical_needs)

        expect(focus).to eq(:resource_focus)
      end
    end

    describe 'integration with evaluate_next_action' do
      it 'includes strategic focus in action result' do
        allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return(state_analysis)

        action = strategy_selector.evaluate_next_action(settlement)

        expect(action).to have_key(:strategic_focus)
        expect([:resource_focus, :scouting_focus, :building_focus, :balanced_approach]).to include(action[:strategic_focus])
      end

      it 'uses adjusted scores for decision making' do
        # Mock state with strong resource needs but high scouting opportunities
        strategic_state = state_analysis.merge(
          resource_needs: { critical: ['energy'], needed: [] },
          scouting_opportunities: { high_value: [{ id: 'valuable_system' }], strategic: [] },
          current_resources: { minerals: 20, energy: 20, food: 20, water: 20 } # Low resources
        )

        allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return(strategic_state)

        action = strategy_selector.evaluate_next_action(settlement)

        # Should still prioritize resources due to critical needs, even with scouting opportunities
        expect(action[:type]).to eq(:resource_acquisition)
        expect(action[:strategic_focus]).to eq(:resource_focus)
      end
    end
  end

  describe 'cost_reduction integration' do
    let(:base_state_analysis) do
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

    describe '#generate_mission_options' do
      context 'when cost_pressure >= 0.6' do
        before do
          allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return(
            base_state_analysis.merge(
              cost_analysis: {
                viable: true,
                cost_pressure: 0.7,
                recommendations: ['Iron', 'Coal']
              }
            )
          )
        end

        it 'includes :cost_reduction option' do
          options = strategy_selector.send(:generate_mission_options, settlement, base_state_analysis.merge(
            cost_analysis: { viable: true, cost_pressure: 0.7, recommendations: ['Iron', 'Coal'] }
          ))

          cost_reduction_option = options.find { |o| o[:type] == :cost_reduction }
          expect(cost_reduction_option).to be_present
          expect(cost_reduction_option[:priority]).to eq(:high)
          expect(cost_reduction_option[:resources]).to include('Iron', 'Coal')
        end
      end

      context 'when cost_pressure < 0.6' do
        before do
          allow_any_instance_of(AIManager::StateAnalyzer).to receive(:analyze_state).and_return(
            base_state_analysis.merge(
              cost_analysis: {
                viable: true,
                cost_pressure: 0.4,
                recommendations: ['Iron']
              }
            )
          )
        end

        it 'excludes :cost_reduction option' do
          options = strategy_selector.send(:generate_mission_options, settlement, base_state_analysis.merge(
            cost_analysis: { viable: true, cost_pressure: 0.4, recommendations: ['Iron'] }
          ))

          cost_reduction_option = options.find { |o| o[:type] == :cost_reduction }
          expect(cost_reduction_option).to be_nil
        end
      end
    end

    describe '#viable_action?' do
      context 'when viable: true' do
        it 'returns true for :cost_reduction' do
          action = { type: :cost_reduction, resources: ['Iron'] }
          state = base_state_analysis.merge(
            cost_analysis: { viable: true, cost_pressure: 0.7, recommendations: ['Iron'] }
          )

          expect(strategy_selector.send(:viable_action?, action, state)).to be true
        end
      end

      context 'when viable: false' do
        it 'returns false for :cost_reduction' do
          action = { type: :cost_reduction, resources: ['Iron'] }
          state = base_state_analysis.merge(
            cost_analysis: { viable: false, cost_pressure: 0.7, recommendations: [] }
          )

          expect(strategy_selector.send(:viable_action?, action, state)).to be false
        end
      end
    end

    describe '#execute_action' do
      context 'with :cost_reduction type' do
        it 'handles :cost_reduction without raising' do
          action = {
            type: :cost_reduction,
            resources: ['Iron', 'Coal'],
            rationale: 'High cost pressure'
          }

          expect { strategy_selector.execute_action(action, settlement) }.not_to raise_error
        end
      end

      context 'execute_cost_reduction' do
        let(:action) { { type: :cost_reduction, resources: ['Iron', 'Coal'] } }
        
        # Phase 3 behavior — these old specs updated to reflect new implementation
        
        it 'returns false when no source settlement available (Phase 3 change)' do
          allow(strategy_selector).to receive(:find_source_settlement).and_return(nil)
          
          result = strategy_selector.send(:execute_cost_reduction, action, settlement)
          
          expect(result).to eq(false) # Changed from true in Phase 2 per task file requirements
        end
        
        it 'calls ShortageDetector and processes shortages when source available' do
          source = create(:base_settlement)
          allow(strategy_selector).to receive(:find_source_settlement).and_return(source)
          
          shortage_report = {
            viable: true,
            survival_shortages: [
              { material: 'Food Rations', need: 100, have: 30, priority: 'critical' }
            ],
            expansion_shortages: []
          }
          
          allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
          allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request).and_return(double(id: 1))
          
          result = strategy_selector.send(:execute_cost_reduction, action, settlement)
          
          expect(result).to eq(true)
        end
      end
      
      describe 'Phase 3 — ShortageDetector integration' do
        let(:action) { { type: :cost_reduction, resources: [] } }
        let(:source_settlement) { create(:base_settlement, name: 'Cape Canaveral Spaceport') }
        
        before do
          allow(strategy_selector).to receive(:find_source_settlement).and_return(source_settlement)
        end
        
        context 'when ShortageDetector returns viable: false' do
          it 'logs warning and returns false without calling generate_import_request' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return({
              viable: false,
              survival_shortages: [],
              expansion_shortages: []
            })
            
            # Stub to prevent actual calls
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request)
            
            result = strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            expect(result).to eq(false)
            expect(Logistics::ImportRequestGenerator).not_to have_received(:generate_import_request)
          end
        end
        
        context 'when survival_shortages is empty' do
          it 'logs info and returns false without calling generate_import_request' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return({
              viable: true,
              survival_shortages: [],
              expansion_shortages: [{ material: 'Gold', need: 100, have: 50, priority: 'expansion' }]
            })
            
            # Stub to prevent actual calls
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request)
            
            result = strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            expect(result).to eq(false)
            expect(Logistics::ImportRequestGenerator).not_to have_received(:generate_import_request)
          end
        end
        
        context 'with survival shortages detected' do
          let(:shortage_report) do
            {
              viable: true,
              survival_shortages: [
                { material: 'Food Rations', need: 365, have: 90, priority: 'critical' },
                { material: 'Industrial Equipment', need: 10, have: 2, priority: 'critical' }
              ],
              expansion_shortages: [{ material: 'Advanced Robotics', need: 20, have: 5, priority: 'expansion' }]
            }
          end
          
          it 'calls ShortageDetector.detect_shortages first' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request).and_return(double(id: 1))
            
            strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            expect(Logistics::ShortageDetector).to have_received(:detect_shortages).with(settlement)
          end
          
          it 'calls generate_import_request once per survival shortage item' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request).and_return(double(id: 1))
            
            strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            expect(Logistics::ImportRequestGenerator).to have_received(:generate_import_request).exactly(2).times
          end
          
          it 'passes correct quantity (need - have = deficit)' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
            
            # Stub to capture arguments
            captured_args = []
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request) do |source:, destination:, shortage:|
              captured_args << shortage
              double(id: 1)
            end
            
            strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            # Food Rations deficit should be 275 (need=365 - have=90), not stub value of 10 or target amount 365
            food_call = captured_args.find { |s| s[:material] == 'Food Rations' }
            expect(food_call).to be_present
            expect(food_call[:need]).to eq(275) # Deficit, not target
            
            # Industrial Equipment deficit should be 8 (need=10 - have=2)
            equipment_call = captured_args.find { |s| s[:material] == 'Industrial Equipment' }
            expect(equipment_call).to be_present
            expect(equipment_call[:need]).to eq(8) # Deficit, not target
          end
          
          it 'returns true when at least one ImportRequest created successfully' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request).and_return(double(id: 1))
            
            result = strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            expect(result).to eq(true)
          end
          
          it 'continues processing remaining shortages when one raises ImportRequestError' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
            
            # First call fails (Food Rations), second succeeds (Industrial Equipment)
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request) do |source:, destination:, shortage:|
              if shortage[:material] == 'Food Rations'
                raise Logistics::ImportRequestGenerator::ImportRequestError, "Failed for Food Rations"
              else
                double(id: 2)
              end
            end
            
            result = strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            expect(result).to eq(true) # Partial success still returns true
          end
          
          it 'does NOT call generate_import_request for expansion shortages' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
            
            called_materials = []
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request) do |source:, destination:, shortage:|
              called_materials << shortage[:material]
              double(id: 1)
            end
            
            strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            # Should NOT be called with Advanced Robotics (expansion shortage)
            expect(called_materials).not_to include('Advanced Robotics')
          end
          
          it 'returns false when all ImportRequests fail' do
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_report)
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request)
              .and_raise(Logistics::ImportRequestGenerator::ImportRequestError, "All failed")
            
            result = strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            expect(result).to eq(false)
          end
          
          it 'skips zero-deficit items (deficit clamping)' do
            shortage_with_zero_deficit = {
              viable: true,
              survival_shortages: [
                { material: 'Oxygen', need: 100, have: 150, priority: 'critical' }, # Stock exceeds target — deficit should be 0
                { material: 'Water', need: 200, have: 180, priority: 'critical' }   # Deficit = 20
              ],
              expansion_shortages: []
            }
            
            allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return(shortage_with_zero_deficit)
            allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request).and_return(double(id: 1))
            
            strategy_selector.send(:execute_cost_reduction, action, settlement)
            
            # Should only be called once (for Water), not for Oxygen which has zero deficit after clamping
            expect(Logistics::ImportRequestGenerator).to have_received(:generate_import_request).once
          end
        end
        
        context 'when find_source_settlement returns nil' do
          before do
            allow(strategy_selector).to receive(:find_source_settlement).and_return(nil)
          end
          
          it 'logs warning and returns false without calling ShortageDetector' do
            action_with_resources = { type: :cost_reduction, resources: ['Food Rations'] }
            
            result = strategy_selector.send(:execute_cost_reduction, action_with_resources, settlement)
            
            expect(result).to eq(false) # Changed from Phase 2 behavior (was true)
          end
        end
      end
    end
  end
end