# spec/services/ai_manager/strategic_evaluator_spec.rb
require "./app/services/ai_manager/strategic_evaluator"
require 'rails_helper'

RSpec.describe AIManager::StrategicEvaluator do
  let(:shared_context) { double('SharedContext') }
  let(:evaluator) { described_class.new(shared_context) }

  describe '#evaluate_system' do
    let(:system_data) do
      {
        tei_score: 85,
        resource_profile: {
          metal_richness: 0.8,
          volatile_availability: 0.7,
          rare_earth_potential: 0.6,
          energy_potential: { solar: 0.9, geothermal: 0.5, fusion_fuel: 0.3 }
        },
        wormhole_data: { network_centrality: 0.8 },
        star_data: { primary_star: { type_of_star: 'G-type' } }
      }
    end

    let(:settlement_context) do
      {
        resource_needs: { critical: ['energy'], needed: ['metals'] },
        expansion_readiness: 0.9
      }
    end

    it 'returns comprehensive evaluation results' do
      result = evaluator.evaluate_system(system_data, settlement_context)

      expect(result).to include(
        :system_classification,
        :strategic_value,
        :risk_assessment,
        :economic_forecast,
        :expansion_priority,
        :development_timeline,
        :resource_synergies
      )
    end

    it 'classifies prize worlds correctly' do
      prize_system = system_data.merge(tei_score: 85)
      result = evaluator.evaluate_system(prize_system)

      expect(result[:system_classification][:category]).to eq(:prize_world)
      expect(result[:system_classification][:priority]).to eq(:critical)
    end

    it 'classifies resource worlds correctly' do
      resource_system = system_data.merge(
        tei_score: 50,
        resource_profile: {
          metal_richness: 0.9,
          volatile_availability: 0.8,
          rare_earth_potential: 0.8
        },
        wormhole_data: { network_centrality: 0.3 }  # Override to avoid wormhole classification
      )
      result = evaluator.evaluate_system(resource_system)

      expect(result[:system_classification][:category]).to eq(:resource_world)
      expect(result[:system_classification][:priority]).to eq(:high)
    end

    it 'classifies brown dwarf hubs correctly' do
      brown_dwarf_system = system_data.merge(
        tei_score: 45,
        star_data: { primary_star: { type_of_star: 'Brown Dwarf' } }
      )
      result = evaluator.evaluate_system(brown_dwarf_system)

      expect(result[:system_classification][:category]).to eq(:brown_dwarf_hub)
      expect(result[:system_classification][:priority]).to eq(:high)
    end

    it 'classifies wormhole nexuses correctly' do
      nexus_system = system_data.merge(
        tei_score: 40,
        wormhole_data: { network_centrality: 0.8 }
      )
      result = evaluator.evaluate_system(nexus_system)

      expect(result[:system_classification][:category]).to eq(:wormhole_nexus)
      expect(result[:system_classification][:priority]).to eq(:high)
    end

    it 'classifies marginal worlds correctly' do
      marginal_system = system_data.merge(
        tei_score: 20,
        resource_profile: { metal_richness: 0.2, volatile_availability: 0.1 },        wormhole_data: { network_centrality: 0.3 }
      )
      result = evaluator.evaluate_system(marginal_system)

      expect(result[:system_classification][:category]).to eq(:marginal_world)
      expect(result[:system_classification][:priority]).to eq(:low)
    end
  end

  describe '#classify_system' do
    it 'identifies prize worlds with TEI > 80' do
      system_data = { tei_score: 85 }
      result = evaluator.classify_system(system_data)

      expect(result[:category]).to eq(:prize_world)
      expect(result[:confidence]).to eq(0.95)
      expect(result[:priority]).to eq(:critical)
    end

    it 'identifies resource worlds with high resource scores' do
      system_data = {
        tei_score: 50,
        resource_profile: {
          metal_richness: 0.9,
          volatile_availability: 0.8,
          rare_earth_potential: 0.8
        }
      }
      result = evaluator.classify_system(system_data)

      expect(result[:category]).to eq(:resource_world)
      expect(result[:confidence]).to eq(0.9)
    end

    it 'identifies brown dwarf systems' do
      system_data = {
        star_data: { primary_star: { type_of_star: 'Brown Dwarf' } }
      }
      result = evaluator.classify_system(system_data)

      expect(result[:category]).to eq(:brown_dwarf_hub)
      expect(result[:confidence]).to eq(0.85)
    end

    it 'identifies wormhole nexuses' do
      system_data = {
        wormhole_data: { network_centrality: 0.8 }
      }
      result = evaluator.classify_system(system_data)

      expect(result[:category]).to eq(:wormhole_nexus)
      expect(result[:confidence]).to eq(0.8)
    end

    it 'defaults to marginal world for low-value systems' do
      system_data = { tei_score: 15 }
      result = evaluator.classify_system(system_data)

      expect(result[:category]).to eq(:marginal_world)
      expect(result[:confidence]).to eq(0.4)
    end
  end

  describe '#calculate_strategic_value' do
    it 'calculates comprehensive strategic value' do
      system_data = {
        tei_score: 80,
        resource_profile: {
          metal_richness: 0.8,
          volatile_availability: 0.7,
          rare_earth_potential: 0.6,
          energy_potential: { solar: 0.9, geothermal: 0.5, fusion_fuel: 0.3 }
        },
        wormhole_data: { network_centrality: 0.6 }
      }

      value = evaluator.calculate_strategic_value(system_data)

      # TEI (80/100 * 0.4) = 0.32
      # Resources (2.1/3 * 0.3) = 0.21
      # Connectivity (0.6 * 0.15) = 0.09
      # Energy (1.7/3 * 0.1) = 0.0567
      # Total should be around 0.6767
      expect(value).to be_within(0.01).of(0.68)
    end

    it 'applies settlement context modifiers' do
      system_data = {
        resource_profile: { metal_richness: 0.8, energy_potential: { solar: 0.5 } }
      }
      settlement_context = {
        resource_needs: { critical: ['energy'], needed: ['metals'] }
      }

      value_with_context = evaluator.calculate_strategic_value(system_data, settlement_context)
      value_without_context = evaluator.calculate_strategic_value(system_data)

      expect(value_with_context).to be > value_without_context
    end

    it 'caps strategic value at 1.0' do
      system_data = {
        tei_score: 100,
        resource_profile: {
          metal_richness: 1.0,
          volatile_availability: 1.0,
          rare_earth_potential: 1.0,
          energy_potential: { solar: 1.0, geothermal: 1.0, fusion_fuel: 1.0 }
        },
        wormhole_data: { network_centrality: 1.0 }
      }

      value = evaluator.calculate_strategic_value(system_data)
      expect(value).to be_within(0.1).of(1.0)
    end
  end

  describe '#assess_colonization_risks' do
    it 'identifies high terraforming risk for low TEI' do
      system_data = { tei_score: 20 }
      risks = evaluator.assess_colonization_risks(system_data)

      expect(risks[:overall_risk]).to be > 0
      expect(risks[:risk_factors]).to include(
        hash_including(type: :terraforming_difficulty, severity: :high)
      )
    end

    it 'identifies resource scarcity risk' do
      system_data = {
        resource_profile: { metal_richness: 0.2, volatile_availability: 0.1 },        wormhole_data: { network_centrality: 0.3 }
      }
      risks = evaluator.assess_colonization_risks(system_data)

      expect(risks[:risk_factors]).to include(
        hash_including(type: :resource_scarcity, severity: :medium)
      )
    end

    it 'identifies logistical challenges for distant systems' do
      system_data = { wormhole_distance: 3 }
      risks = evaluator.assess_colonization_risks(system_data)

      expect(risks[:risk_factors]).to include(
        hash_including(type: :logistical_challenge, severity: :medium)
      )
    end

    it 'calculates risk mitigation costs' do
      system_data = { tei_score: 20 }
      risks = evaluator.assess_colonization_risks(system_data)

      expect(risks[:risk_mitigation_cost]).to be > 0
    end
  end

  describe '#forecast_economic_potential' do
    it 'forecasts high revenue for prize worlds' do
      system_data = { tei_score: 85 }
      forecast = evaluator.forecast_economic_potential(system_data)

      expect(forecast[:projected_revenue]).to eq(500_000_000)
      expect(forecast[:development_costs]).to eq(100_000_000)
      expect(forecast[:break_even_year]).to eq(2)
    end

    it 'forecasts resource world economics' do
      system_data = {
        tei_score: 50,
        resource_profile: {
          metal_richness: 0.9,
          volatile_availability: 0.8,
          rare_earth_potential: 0.8
        }
      }
      forecast = evaluator.forecast_economic_potential(system_data)

      expect(forecast[:projected_revenue]).to eq(300_000_000)
      expect(forecast[:development_costs]).to eq(150_000_000)
    end

    it 'calculates profitability scores' do
      system_data = { tei_score: 85 }
      forecast = evaluator.forecast_economic_potential(system_data)

      expect(forecast[:profitability_score]).to be > 0
      expect(forecast[:annual_profit]).to be > 0
    end

    it 'applies economic context modifiers' do
      system_data = { tei_score: 85 }
      settlement_context = { synergy_multiplier: 1.1 }

      forecast_with_context = evaluator.forecast_economic_potential(system_data, settlement_context)
      forecast_without_context = evaluator.forecast_economic_potential(system_data)

      expect(forecast_with_context[:projected_revenue]).to be > forecast_without_context[:projected_revenue]
    end
  end

  describe '#calculate_expansion_priority' do
    it 'calculates priority based on multiple factors' do
      system_data = {
        tei_score: 80,
        resource_profile: { metal_richness: 0.8 }
      }
      settlement_context = {
        resource_needs: { critical: ['energy'] },
        expansion_readiness: 0.9
      }

      priority = evaluator.calculate_expansion_priority(system_data, settlement_context)

      expect(priority).to be_between(0.0, 1.0)
    end

    it 'prioritizes systems with high strategic value' do
      high_value_system = { tei_score: 90 }
      low_value_system = { tei_score: 30 }

      high_priority = evaluator.calculate_expansion_priority(high_value_system)
      low_priority = evaluator.calculate_expansion_priority(low_value_system)

      expect(high_priority).to be > low_priority
    end

    it 'reduces priority for high-risk systems' do
      low_risk_system = { tei_score: 80 }
      high_risk_system = { tei_score: 20 }

      low_risk_priority = evaluator.calculate_expansion_priority(low_risk_system)
      high_risk_priority = evaluator.calculate_expansion_priority(high_risk_system)

      expect(low_risk_priority).to be > high_risk_priority
    end
  end

  describe '#estimate_development_timeline' do
    it 'estimates short timeline for prize worlds' do
      system_data = { tei_score: 85 }
      timeline = evaluator.send(:estimate_development_timeline, system_data)

      expect(timeline[:years]).to eq(2)
      expect(timeline[:phases]).to include(:terraforming, :settlement)
    end

    it 'estimates longer timeline for marginal worlds' do
      system_data = { tei_score: 20 }
      timeline = evaluator.send(:estimate_development_timeline, system_data)

      expect(timeline[:years]).to eq(7)
      expect(timeline[:phases]).to include(:survival_setup)
    end
  end

  describe '#analyze_resource_synergies' do
    it 'identifies energy synergies' do
      system_data = {
        resource_profile: {
          energy_potential: { solar: 0.8 }
        }
      }
      settlement_context = {
        resource_needs: { critical: ['energy'] }
      }

      synergies = evaluator.send(:analyze_resource_synergies, system_data, settlement_context)

      expect(synergies).to include(
        hash_including(type: :energy_independence, benefit: :high)
      )
    end

    it 'identifies industrial capacity synergies' do
      system_data = {
        resource_profile: { metal_richness: 0.9 }
      }
      settlement_context = {
        resource_needs: { needed: ['metals'] }
      }

      synergies = evaluator.send(:analyze_resource_synergies, system_data, settlement_context)

      expect(synergies).to include(
        hash_including(type: :industrial_capacity, benefit: :high)
      )
    end

    it 'returns empty array without settlement context' do
      system_data = { resource_profile: { metal_richness: 0.9 } }
      synergies = evaluator.send(:analyze_resource_synergies, system_data, nil)

      expect(synergies).to eq([])
    end
  end

  describe 'private methods' do
    describe '#calculate_urgency_modifier' do
      it 'increases urgency for critical resource needs' do
        system_data = {
          resource_profile: {
            energy_potential: { solar: 0.5 },
            volatile_availability: 0.7
          }
        }
        settlement_context = {
          resource_needs: { critical: ['energy', 'water'] },
          expansion_readiness: 0.9
        }

        modifier = evaluator.send(:calculate_urgency_modifier, system_data, settlement_context)

        expect(modifier).to be > 0
      end

      it 'accounts for population pressure' do
        system_data = {}
        settlement_context = { expansion_readiness: 0.9 }

        modifier = evaluator.send(:calculate_urgency_modifier, system_data, settlement_context)

        expect(modifier).to eq(0.1)
      end
    end

    describe '#calculate_risk_mitigation_cost' do
      it 'calculates total mitigation costs' do
        risks = [
          { mitigation_cost: :high },
          { mitigation_cost: :medium },
          { mitigation_cost: :low }
        ]

        cost = evaluator.send(:calculate_risk_mitigation_cost, risks)

        expect(cost).to eq(50_000_000 + 25_000_000 + 10_000_000)
      end
    end

    describe '#calculate_profitability_score' do
      it 'returns 0 for unprofitable systems' do
        score = evaluator.send(:calculate_profitability_score, -100_000, 200_000, 5)
        expect(score).to eq(0)
      end

      it 'calculates score based on profit margin and timeline' do
        score = evaluator.send(:calculate_profitability_score, 200_000, 100_000, 2)
        expect(score).to be > 0
      end
    end
  end
end
