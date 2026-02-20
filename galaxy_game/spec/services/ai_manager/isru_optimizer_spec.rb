# spec/services/ai_manager/isru_optimizer_spec.rb
require "./app/services/ai_manager/isru_optimizer"
require 'rails_helper'

RSpec.describe AIManager::IsruOptimizer do
  let(:shared_context) { double('SharedContext') }
  let(:optimizer) { described_class.new(shared_context) }

  let(:settlement_plan) do
    {
      mission_type: 'mining_outpost',
      requirements: {
        critical_resources: [:water, :oxygen, :materials],
        personnel: 12
      }
    }
  end

  let(:target_system) do
    {
      identifier: 'SOL-LUNA',
      resource_profile: {
        water_ice: 200,
        regolith: 800,
        minerals: ['iron', 'titanium'],
        mineral_concentrations: { iron: 0.15, titanium: 0.08 },
        energy_potential: { solar: 0.95, geothermal: 0.2 }
      },
      environmental_data: {
        atmosphere_composition: { 'CO2' => 0.001, 'N2' => 0.999 },
        atmospheric_density: 0.00002,
        surface_accessibility: 'high'
      }
    }
  end

  describe '#optimize_isru_priorities' do
    it 'provides comprehensive ISRU optimization analysis' do
      result = optimizer.optimize_isru_priorities(target_system, settlement_plan)

      expect(result).to include(
        :resource_analysis,
        :opportunity_scores,
        :isru_roadmap,
        :economic_impact,
        :implementation_priority
      )
    end

    it 'analyzes local resources accurately' do
      result = optimizer.optimize_isru_priorities(target_system, settlement_plan)

      analysis = result[:resource_analysis]
      expect(analysis[:water_ice][:available]).to be true
      expect(analysis[:regolith][:available]).to be true
      expect(analysis[:atmosphere][:available]).to be true
      expect(analysis[:richness_score]).to be > 0
      expect(analysis[:isru_potential]).to be_in([:low, :medium, :high, :excellent])
    end

    it 'calculates opportunity scores based on value and feasibility' do
      result = optimizer.optimize_isru_priorities(target_system, settlement_plan)

      scores = result[:opportunity_scores]
      expect(scores[:water_extraction][:priority_score]).to be > 0
      expect(scores[:material_production][:priority_score]).to be > 0

      # Water should have high priority for mining outposts
      expect(scores[:water_extraction][:value_score]).to be > 0.8
    end

    it 'generates phased ISRU roadmap' do
      result = optimizer.optimize_isru_priorities(target_system, settlement_plan)

      roadmap = result[:isru_roadmap]
      expect(roadmap).to include(:phase_1, :phase_2, :phase_3, :phase_4)

      # Should have opportunities in early phases
      expect(roadmap[:phase_1].size + roadmap[:phase_2].size).to be > 0
    end

    it 'calculates economic impact of ISRU implementation' do
      result = optimizer.optimize_isru_priorities(target_system, settlement_plan)

      impact = result[:economic_impact]
      expect(impact[:total_capital_investment]).to be > 0
      expect(impact[:annual_operational_savings]).to be > 0
      expect(impact[:import_reduction_percentage]).to be > 0
      expect(impact[:payback_period_months]).to be > 0
    end

    it 'determines appropriate implementation priority' do
      result = optimizer.optimize_isru_priorities(target_system, settlement_plan)

      priority = result[:implementation_priority]
      expect(priority).to be_in([:low, :medium, :high])
    end
  end

  describe '#prioritize_isru_opportunities' do
    it 'returns opportunities sorted by priority score' do
      settlement_requirements = { critical_resources: [:water, :oxygen] }
      opportunities = optimizer.prioritize_isru_opportunities(target_system, settlement_requirements)

      expect(opportunities).to be_an(Array)
      expect(opportunities.size).to be > 0

      # Should be sorted by priority score descending
      scores = opportunities.map { |opp| opp[:priority_score] }
      expect(scores).to eq(scores.sort.reverse)
    end

    it 'scores opportunities based on settlement needs' do
      settlement_requirements = { critical_resources: [:water] }
      opportunities = optimizer.prioritize_isru_opportunities(target_system, settlement_requirements)

      water_opportunity = opportunities.find { |opp| opp[:type] == :water_extraction }
      expect(water_opportunity[:need_multiplier]).to be > 1.0
    end
  end

  describe 'private methods' do
    describe '#analyze_local_resources' do
      it 'correctly assesses resource availability' do
        analysis = optimizer.send(:analyze_local_resources, target_system)

        expect(analysis[:water_ice][:available]).to be true
        expect(analysis[:water_ice][:quantity]).to eq(200)
        expect(analysis[:regolith][:available]).to be true
        expect(analysis[:atmosphere][:available]).to be true
        expect(analysis[:minerals][:available]).to be true
      end

      it 'calculates richness score appropriately' do
        analysis = optimizer.send(:analyze_local_resources, target_system)

        expect(analysis[:richness_score]).to be >= 4 # water + regolith + atmosphere + minerals
        expect(analysis[:isru_potential]).to be_in([:medium, :high, :excellent])
      end
    end

    describe '#calculate_opportunity_scores' do
      it 'scores opportunities based on multiple factors' do
        resource_analysis = optimizer.send(:analyze_local_resources, target_system)
        scores = optimizer.send(:calculate_opportunity_scores, resource_analysis, settlement_plan)

        expect(scores[:water_extraction][:value_score]).to be > 0
        expect(scores[:water_extraction][:feasibility_score]).to be > 0
        expect(scores[:water_extraction][:timeline_score]).to be > 0
        expect(scores[:water_extraction][:priority_score]).to be > 0
      end

      it 'prioritizes water extraction for mining outposts' do
        resource_analysis = optimizer.send(:analyze_local_resources, target_system)
        scores = optimizer.send(:calculate_opportunity_scores, resource_analysis, settlement_plan)

        water_score = scores[:water_extraction][:priority_score]
        material_score = scores[:material_production][:priority_score]

        expect(water_score).to be > material_score
      end
    end

    describe '#generate_isru_roadmap' do
      it 'organizes opportunities into implementation phases' do
        opportunity_scores = {
          water_extraction: { priority_score: 0.8, value_score: 0.9, feasibility_score: 0.8, timeline_score: 0.7 },
          material_production: { priority_score: 0.7, value_score: 0.7, feasibility_score: 0.9, timeline_score: 0.8 }
        }

        roadmap = optimizer.send(:generate_isru_roadmap, opportunity_scores, settlement_plan)

        expect(roadmap[:phase_1]).to include(hash_including(opportunity: :water_extraction))
        expect(roadmap[:phase_2]).to include(hash_including(opportunity: :material_production))
      end

      it 'includes cost and benefit estimates' do
        opportunity_scores = { water_extraction: { priority_score: 0.8 } }
        roadmap = optimizer.send(:generate_isru_roadmap, opportunity_scores, settlement_plan)

        opportunity_data = roadmap[:phase_1].first
        expect(opportunity_data[:estimated_cost]).to be > 0
        expect(opportunity_data[:expected_benefits]).to be > 0
        expect(opportunity_data[:timeline]).to eq('0-3 months')
      end
    end

    describe '#calculate_economic_impact' do
      let(:isru_roadmap) do
        {
          phase_1: [{ estimated_cost: 50000, expected_benefits: 25000 }],
          phase_2: [{ estimated_cost: 30000, expected_benefits: 15000 }]
        }
      end

      it 'calculates total capital investment' do
        impact = optimizer.send(:calculate_economic_impact, isru_roadmap, settlement_plan)

        expect(impact[:total_capital_investment]).to eq(80000) # 50k + 30k
      end

      it 'estimates operational savings and payback' do
        impact = optimizer.send(:calculate_economic_impact, isru_roadmap, settlement_plan)

        expect(impact[:annual_operational_savings]).to be > 0
        expect(impact[:payback_period_months]).to be > 0
        expect(impact[:import_reduction_percentage]).to be > 0
      end
    end

    describe '#determine_implementation_priority' do
      it 'returns high priority for rich ISRU opportunities' do
        rich_roadmap = {
          phase_1: [{}, {}], # 2 opportunities in phase 1
          phase_2: [{}, {}]  # 2 more in phase 2
        }

        priority = optimizer.send(:determine_implementation_priority, rich_roadmap)
        expect(priority).to eq(:high)
      end

      it 'returns medium priority for moderate opportunities' do
        moderate_roadmap = {
          phase_1: [{}],     # 1 opportunity in phase 1
          phase_2: [{}],     # 1 more in phase 2
          phase_3: []
        }

        priority = optimizer.send(:determine_implementation_priority, moderate_roadmap)
        expect(priority).to eq(:medium)
      end
    end
  end

  describe 'scoring calculations' do
    describe '#calculate_value_score' do
      it 'adjusts scores based on mission type' do
        mining_score = optimizer.send(:calculate_value_score, :water, settlement_plan)
        research_plan = settlement_plan.merge(mission_type: 'research_station')
        research_score = optimizer.send(:calculate_value_score, :water, research_plan)

        expect(mining_score).to be > research_score
      end

      it 'provides appropriate base scores' do
        oxygen_score = optimizer.send(:calculate_value_score, :oxygen, settlement_plan)
        materials_score = optimizer.send(:calculate_value_score, :materials, settlement_plan)

        expect(oxygen_score).to be > materials_score
        expect(oxygen_score).to be > 0.9 # Oxygen is critical
      end
    end

    describe '#calculate_feasibility_score' do
      it 'factors in accessibility and complexity' do
        water_data = { accessibility: 0.9, extraction_complexity: :medium }
        score = optimizer.send(:calculate_feasibility_score, water_data)

        expect(score).to be > 0.5 # Good accessibility minus medium complexity
        expect(score).to be < 0.9
      end

      it 'penalizes high complexity resources' do
        complex_resource = { accessibility: 0.8, extraction_complexity: :high }
        simple_resource = { accessibility: 0.8, extraction_complexity: :low }

        complex_score = optimizer.send(:calculate_feasibility_score, complex_resource)
        simple_score = optimizer.send(:calculate_feasibility_score, simple_resource)

        expect(simple_score).to be > complex_score
      end
    end

    describe '#calculate_timeline_score' do
      it 'favors faster implementation opportunities' do
        water_score = optimizer.send(:calculate_timeline_score, :water_extraction)
        fuel_score = optimizer.send(:calculate_timeline_score, :fuel_production)

        expect(water_score).to be > fuel_score
      end
    end
  end

  describe 'opportunity identification' do
    describe '#identify_isru_opportunities' do
      it 'identifies appropriate opportunities for resource-rich systems' do
        opportunities = optimizer.send(:identify_isru_opportunities, target_system)

        expect(opportunities.size).to be >= 2 # water and regolith at minimum

        water_opp = opportunities.find { |opp| opp[:type] == :water_extraction }
        expect(water_opp[:potential_yield]).to eq(160) # 200 * 0.8
        expect(water_opp[:complexity]).to eq(:medium)
      end

      it 'includes atmospheric processing when CO2 is available' do
        opportunities = optimizer.send(:identify_isru_opportunities, target_system)

        co2_opp = opportunities.find { |opp| opp[:type] == :atmospheric_processing }
        expect(co2_opp).to be_present
        expect(co2_opp[:resource]).to eq(:co2)
      end
    end

    describe '#score_opportunity' do
      let(:opportunity) { { type: :water_extraction, potential_yield: 150, complexity: :medium } }
      let(:settlement_requirements) { { critical_resources: [:water] } }

      it 'calculates comprehensive opportunity score' do
        scored = optimizer.send(:score_opportunity, opportunity, settlement_requirements, target_system)

        expect(scored[:priority_score]).to be > 0
        expect(scored[:need_multiplier]).to be > 1.0 # Water is critical
        expect(scored[:abundance_multiplier]).to eq(1.0) # Yield < 1000
      end

      it 'boosts score for high-yield opportunities' do
        high_yield_opp = opportunity.merge(potential_yield: 1500)
        scored = optimizer.send(:score_opportunity, high_yield_opp, settlement_requirements, target_system)

        expect(scored[:abundance_multiplier]).to eq(1.2)
      end
    end
  end
end