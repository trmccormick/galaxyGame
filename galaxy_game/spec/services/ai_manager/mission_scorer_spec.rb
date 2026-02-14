# spec/services/ai_manager/mission_scorer_spec.rb
require 'rails_helper'

RSpec.describe AIManager::MissionScorer, type: :service do
  let(:shared_context) { AIManager::SharedContext.new(settlement: create(:base_settlement)) }
  let(:mission_scorer) { AIManager::MissionScorer.new(shared_context) }

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

  describe 'trade-off analysis' do
    describe '#analyze_resource_vs_scouting_tradeoffs' do
      it 'returns complete trade-off analysis' do
        analysis = mission_scorer.analyze_resource_vs_scouting_tradeoffs(state_analysis)

        expect(analysis).to have_key(:resource_score)
        expect(analysis).to have_key(:scouting_score)
        expect(analysis).to have_key(:opportunity_cost)
        expect(analysis).to have_key(:risk_adjustment)
        expect(analysis).to have_key(:long_term_value)
        expect(analysis).to have_key(:recommended_focus)
      end

      it 'recommends resource focus when resources are critically low' do
        critical_state = state_analysis.merge(
          current_resources: { minerals: 10, energy: 10, food: 10, water: 10 },
          resource_needs: { critical: ['energy', 'food'], needed: [] }
        )

        analysis = mission_scorer.analyze_resource_vs_scouting_tradeoffs(critical_state)

        expect(analysis[:recommended_focus]).to eq(:focus_a) # resource focus
        expect(analysis[:resource_score]).to be > analysis[:scouting_score]
      end

      it 'recommends scouting focus when opportunities are abundant' do
        scouting_state = state_analysis.merge(
          scouting_opportunities: {
            high_value: [{ id: 'system1' }, { id: 'system2' }],
            strategic: [{ id: 'system3' }]
          },
          strategic_position: 0.3 # Weak position increases scouting value
        )

        analysis = mission_scorer.analyze_resource_vs_scouting_tradeoffs(scouting_state)

        expect(analysis[:recommended_focus]).to eq(:focus_b) # scouting focus
        expect(analysis[:scouting_score]).to be > analysis[:resource_score]
      end
    end

    describe '#analyze_resource_vs_building_tradeoffs' do
      it 'recommends building focus when infrastructure is critical' do
        building_state = state_analysis.merge(
          infrastructure_needs: { critical: ['power_plant', 'habitation'], needed: [] },
          settlement_health: 0.4, # Poor health increases building priority
          infrastructure_level: 0.2 # Low infrastructure increases score
        )

        analysis = mission_scorer.analyze_resource_vs_building_tradeoffs(building_state)

        expect(analysis[:recommended_focus]).to eq(:focus_b) # building focus
        expect(analysis[:building_score]).to be > analysis[:resource_score]
      end
    end

    describe '#analyze_scouting_vs_building_tradeoffs' do
      it 'balances scouting and building based on opportunities' do
        balanced_state = state_analysis.merge(
          scouting_opportunities: { high_value: [{ id: 'system1' }], strategic: [] },
          infrastructure_needs: { critical: [], needed: ['storage'] },
          expansion_readiness: 0.7
        )

        analysis = mission_scorer.analyze_scouting_vs_building_tradeoffs(balanced_state)

        expect(analysis[:recommended_focus]).to eq(:balanced_approach)
      end
    end

    describe '#calculate_resource_acquisition_score' do
      it 'scores higher with critical resource needs' do
        critical_state = state_analysis.merge(
          resource_needs: { critical: ['energy', 'food'], needed: [] }
        )

        score = mission_scorer.send(:calculate_resource_acquisition_score, critical_state)

        expect(score).to be > 50 # Should be high due to critical needs
      end

      it 'scores higher when economic health is poor' do
        poor_economy_state = state_analysis.merge(
          economic_health: 0.2,
          resource_needs: { critical: [], needed: ['steel'] }
        )

        score = mission_scorer.send(:calculate_resource_acquisition_score, poor_economy_state)

        # Poor economic health should increase resource acquisition priority
        normal_score = mission_scorer.send(:calculate_resource_acquisition_score, state_analysis)
        expect(score).to be > normal_score
      end
    end

    describe '#calculate_scouting_score' do
      it 'scores higher with valuable opportunities' do
        opportunity_state = state_analysis.merge(
          scouting_opportunities: {
            high_value: [{ id: 'system1' }, { id: 'system2' }],
            strategic: [{ id: 'system3' }]
          }
        )

        score = mission_scorer.send(:calculate_scouting_score, opportunity_state)

        expect(score).to be > 30 # Should be high due to opportunities
      end

      it 'scores higher when strategic position is weak' do
        weak_position_state = state_analysis.merge(
          strategic_position: 0.2, # Weak position
          scouting_opportunities: { high_value: [], strategic: [] }
        )

        score = mission_scorer.send(:calculate_scouting_score, weak_position_state)

        # Weak strategic position should increase scouting value
        normal_score = mission_scorer.send(:calculate_scouting_score, state_analysis)
        expect(score).to be > normal_score
      end
    end

    describe '#calculate_building_score' do
      it 'scores higher with critical infrastructure needs' do
        critical_building_state = state_analysis.merge(
          infrastructure_needs: { critical: ['power_plant'], needed: [] },
          settlement_health: 0.8
        )

        score = mission_scorer.send(:calculate_building_score, critical_building_state)

        expect(score).to be > 40 # Should be high due to critical infrastructure
      end

      it 'scores higher when settlement health is poor' do
        poor_health_state = state_analysis.merge(
          settlement_health: 0.3, # Poor health
          infrastructure_needs: { critical: [], needed: [] }
        )

        score = mission_scorer.send(:calculate_building_score, poor_health_state)

        # Poor settlement health should increase building priority
        normal_score = mission_scorer.send(:calculate_building_score, state_analysis)
        expect(score).to be > normal_score
      end
    end

    describe '#assess_risk_tolerance' do
      it 'returns lower tolerance when settlement health is poor' do
        poor_health_state = state_analysis.merge(settlement_health: 0.3)

        tolerance = mission_scorer.send(:assess_risk_tolerance, poor_health_state)

        expect(tolerance).to be < 0.5 # Should be more conservative
      end

      it 'returns higher tolerance when resources are abundant' do
        abundant_state = state_analysis.merge(
          current_resources: { minerals: 150, energy: 150, food: 150, water: 150 }
        )

        tolerance = mission_scorer.send(:assess_risk_tolerance, abundant_state)

        expect(tolerance).to be > 0.5 # Should be more aggressive
      end
    end

    describe '#calculate_long_term_planning_score' do
      it 'scores higher with future resource projections' do
        future_focused_state = state_analysis.merge(
          future_projections: { resource_needs: ['rare_minerals', 'advanced_components'] },
          strategic_timeline: [{ type: 'expansion', timeline: '6_months' }],
          expansion_potential: 0.8,
          economic_projections: { long_term: 0.8 }
        )

        score = mission_scorer.send(:calculate_long_term_planning_score, future_focused_state)

        expect(score).to be > 20 # Should be high due to future considerations
      end
    end

    describe '#determine_optimal_focus' do
      it 'chooses focus_a when score difference is significant' do
        focus = mission_scorer.send(:determine_optimal_focus, 80, 50, 5, 0.5, 20)

        expect(focus).to eq(:focus_a)
      end

      it 'chooses balanced approach when scores are close' do
        focus = mission_scorer.send(:determine_optimal_focus, 55, 50, 2, 0.5, 15)

        expect(focus).to eq(:balanced_approach)
      end
    end
  end
end