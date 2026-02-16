# spec/services/ai_manager/station_cost_benefit_analyzer_spec.rb
require 'rails_helper'
require_relative '../../../app/services/ai_manager/station_cost_benefit_analyzer'

RSpec.describe AIManager::StationCostBenefitAnalyzer, type: :service do
  let(:shared_context) { instance_double(AIManager::SharedContext) }
  let(:analyzer) { described_class.new(shared_context) }

  let(:sample_construction_options) do
    [
      {
        construction_type: :full_space_station,
        name: 'Full Space Station Construction',
        estimated_cost: 100_000_000,
        construction_time: 11.months,
        capability_score: 80,
        risk_level: :medium,
        resource_requirements: {
          materials: { steel: 50000, aluminum: 30000 },
          personnel: { engineers: 50, technicians: 100 }
        }
      },
      {
        construction_type: :asteroid_conversion,
        name: 'Asteroid Conversion - Ceres',
        estimated_cost: 60_000_000,
        construction_time: 10.months,
        capability_score: 65,
        risk_level: :high,
        resource_requirements: {
          materials: { steel: 20000, explosives: 5000 },
          personnel: { engineers: 30, mining_crew: 100 }
        }
      },
      {
        construction_type: :orbital_construction,
        name: 'Orbital Station - Earth',
        estimated_cost: 85_000_000,
        construction_time: 8.months,
        capability_score: 75,
        risk_level: :low,
        resource_requirements: {
          materials: { steel: 40000, composites: 15000 },
          personnel: { engineers: 40, assembly_crew: 80 }
        }
      }
    ]
  end

  let(:available_resources) { { steel: 100000, aluminum: 50000, explosives: 10000 } }
  let(:strategic_requirements) do
    {
      purpose: :wormhole_anchor,
      capability_requirements: [:wormhole_stabilization, :energy_generation, :defensive_systems],
      risk_tolerance: :medium,
      timeline_requirements: { critical: 12.months, optimal: 9.months }
    }
  end

  describe '#select_optimal_strategy' do
    it 'analyzes all construction options and selects the best one' do
      result = analyzer.select_optimal_strategy(
        sample_construction_options,
        available_resources,
        strategic_requirements
      )

      expect(result).to have_key(:optimal_strategy)
      expect(result).to have_key(:analysis)
      expect(result).to have_key(:ranking)

      expect(result[:ranking].length).to eq(3)
      expect(result[:ranking].first[:score]).to be >= result[:ranking].last[:score]
    end

    it 'includes comprehensive analysis in the result' do
      result = analyzer.select_optimal_strategy(
        sample_construction_options,
        available_resources,
        strategic_requirements
      )

      analysis = result[:analysis]
      expect(analysis).to have_key(:financial_analysis)
      expect(analysis).to have_key(:operational_analysis)
      expect(analysis).to have_key(:risk_analysis)
      expect(analysis).to have_key(:strategic_analysis)
      expect(analysis).to have_key(:timeline_analysis)
      expect(analysis).to have_key(:composite_score)
    end
  end

  describe '#analyze_construction_option' do
    let(:option) { sample_construction_options.first }

    it 'performs complete analysis of a construction option' do
      result = analyzer.analyze_construction_option(
        option,
        available_resources,
        strategic_requirements
      )

      expect(result).to have_key(:option)
      expect(result).to have_key(:financial_analysis)
      expect(result).to have_key(:operational_analysis)
      expect(result).to have_key(:risk_analysis)
      expect(result).to have_key(:strategic_analysis)
      expect(result).to have_key(:timeline_analysis)
      expect(result).to have_key(:composite_score)
      expect(result).to have_key(:recommendation)
    end

    it 'calculates composite score between 0 and 100' do
      result = analyzer.analyze_construction_option(
        option,
        available_resources,
        strategic_requirements
      )

      expect(result[:composite_score]).to be_between(0, 100)
    end
  end

  describe 'financial analysis' do
    let(:option) { sample_construction_options.first }

    describe '#calculate_financial_metrics' do
      it 'calculates NPV, ROI, and break-even point' do
        financial = analyzer.send(:calculate_financial_metrics, option, available_resources)

        expect(financial).to have_key(:capital_cost)
        expect(financial).to have_key(:npv)
        expect(financial).to have_key(:roi)
        expect(financial).to have_key(:break_even_months)
        expect(financial).to have_key(:resource_efficiency)
        expect(financial).to have_key(:profitability_score)
      end

      it 'calculates positive NPV for profitable projects' do
        financial = analyzer.send(:calculate_financial_metrics, option, available_resources)
        expect(financial[:npv]).to be > 0
      end

      it 'calculates resource efficiency based on availability' do
        low_resources = { steel: 1000, aluminum: 500 } # Limited resources
        high_resources = { steel: 100000, aluminum: 100000 } # Abundant resources

        low_efficiency = analyzer.send(:calculate_financial_metrics, option, low_resources)[:resource_efficiency]
        high_efficiency = analyzer.send(:calculate_financial_metrics, option, high_resources)[:resource_efficiency]

        expect(high_efficiency).to be > low_efficiency
      end
    end

    describe '#calculate_npv' do
      it 'calculates net present value over 20 year horizon' do
        npv = analyzer.send(:calculate_npv, 100_000_000, 11.months, option)
        expect(npv).to be_a(Numeric)
        expect(npv).to be > -100_000_000 # Should not be worse than initial investment
      end
    end

    describe '#calculate_roi' do
      it 'calculates return on investment as percentage' do
        roi = analyzer.send(:calculate_roi, 100_000_000, option)
        expect(roi).to be_a(Numeric)
        expect(roi).to be > 0
      end
    end

    describe '#calculate_break_even_point' do
      it 'calculates months to break even' do
        break_even = analyzer.send(:calculate_break_even_point, 100_000_000, option)
        expect(break_even).to be_a(Numeric)
        expect(break_even).to be > 0
      end
    end
  end

  describe 'operational analysis' do
    let(:option) { sample_construction_options.first }

    describe '#calculate_operational_benefits' do
      it 'calculates capability fulfillment and operational metrics' do
        operational = analyzer.send(:calculate_operational_benefits, option, strategic_requirements)

        expect(operational).to have_key(:capability_fulfillment)
        expect(operational).to have_key(:operational_efficiency)
        expect(operational).to have_key(:scalability_potential)
        expect(operational).to have_key(:annual_maintenance_cost)
        expect(operational).to have_key(:operational_lifetime_years)
        expect(operational).to have_key(:net_operational_benefit)
      end

      it 'calculates capability fulfillment as percentage' do
        operational = analyzer.send(:calculate_operational_benefits, option, strategic_requirements)
        expect(operational[:capability_fulfillment]).to be_between(0, 100)
      end
    end

    describe '#calculate_capability_fulfillment' do
      it 'returns 100% for full stations with any requirements' do
        fulfillment = analyzer.send(:calculate_capability_fulfillment, option, strategic_requirements)
        expect(fulfillment).to eq(100)
      end

      it 'calculates partial fulfillment for specialized stations' do
        asteroid_option = sample_construction_options.second
        fulfillment = analyzer.send(:calculate_capability_fulfillment, asteroid_option, strategic_requirements)
        expect(fulfillment).to be_between(0, 100)
        expect(fulfillment).to be < 100 # Should not be 100% for asteroid conversion
      end
    end

    describe '#calculate_operational_efficiency' do
      it 'returns efficiency score between 0 and 100' do
        efficiency = analyzer.send(:calculate_operational_efficiency, option)
        expect(efficiency).to be_between(0, 100)
      end

      it 'gives higher scores to full space stations' do
        full_station_efficiency = analyzer.send(:calculate_operational_efficiency, sample_construction_options.first)
        asteroid_efficiency = analyzer.send(:calculate_operational_efficiency, sample_construction_options.second)

        expect(full_station_efficiency).to be > asteroid_efficiency
      end
    end
  end

  describe 'risk analysis' do
    let(:option) { sample_construction_options.first }

    describe '#calculate_risk_adjustments' do
      it 'calculates risk-adjusted metrics' do
        risk = analyzer.send(:calculate_risk_adjustments, option, strategic_requirements)

        expect(risk).to have_key(:base_risk_score)
        expect(risk).to have_key(:adjusted_risk_score)
        expect(risk).to have_key(:risk_adjusted_npv)
        expect(risk).to have_key(:risk_mitigation_costs)
        expect(risk).to have_key(:risk_adjusted_score)
      end

      it 'adjusts risk score based on risk tolerance' do
        low_tolerance_reqs = strategic_requirements.merge(risk_tolerance: :low)
        high_tolerance_reqs = strategic_requirements.merge(risk_tolerance: :high)

        low_tolerance_risk = analyzer.send(:calculate_risk_adjustments, option, low_tolerance_reqs)
        high_tolerance_risk = analyzer.send(:calculate_risk_adjustments, option, high_tolerance_reqs)

        expect(low_tolerance_risk[:adjusted_risk_score]).to be > high_tolerance_risk[:adjusted_risk_score]
      end
    end

    describe '#calculate_risk_adjusted_npv' do
      it 'reduces NPV based on risk level' do
        base_npv = analyzer.send(:calculate_npv, option[:estimated_cost], option[:construction_time], option)
        risk_adjusted_npv = analyzer.send(:calculate_risk_adjusted_npv, option, 50) # 50% risk

        expect(risk_adjusted_npv).to be < base_npv
      end
    end
  end

  describe 'strategic alignment analysis' do
    let(:option) { sample_construction_options.first }

    describe '#calculate_strategic_alignment' do
      it 'calculates alignment scores for different aspects' do
        strategic = analyzer.send(:calculate_strategic_alignment, option, strategic_requirements)

        expect(strategic).to have_key(:purpose_alignment)
        expect(strategic).to have_key(:timeline_alignment)
        expect(strategic).to have_key(:capability_alignment)
        expect(strategic).to have_key(:strategic_score)
      end

      it 'calculates purpose alignment based on construction type and purpose' do
        wormhole_alignment = analyzer.send(:calculate_purpose_alignment, option, :wormhole_anchor)
        research_alignment = analyzer.send(:calculate_purpose_alignment, option, :research_outpost)

        expect(wormhole_alignment).to be_a(Numeric)
        expect(research_alignment).to be_a(Numeric)
      end
    end

    describe '#calculate_timeline_alignment' do
      it 'gives perfect score for projects within optimal timeline' do
        on_time_reqs = { optimal: 12.months, critical: 15.months }
        alignment = analyzer.send(:calculate_timeline_alignment, option, on_time_reqs)

        expect(alignment).to eq(100)
      end

      it 'reduces score for projects exceeding timeline' do
        delayed_option = option.merge(construction_time: 15.months)
        delayed_reqs = { optimal: 12.months, critical: 14.months }
        alignment = analyzer.send(:calculate_timeline_alignment, delayed_option, delayed_reqs)

        expect(alignment).to be < 100
      end
    end
  end

  describe 'timeline efficiency analysis' do
    let(:option) { sample_construction_options.first }

    describe '#calculate_timeline_efficiency' do
      it 'calculates efficiency relative to strategic requirements' do
        timeline = analyzer.send(:calculate_timeline_efficiency, option, strategic_requirements)

        expect(timeline).to have_key(:construction_efficiency)
        expect(timeline).to have_key(:time_value_benefit)
        expect(timeline).to have_key(:overall_timeline_score)
      end

      it 'calculates time value benefit based on when benefits start' do
        benefit = analyzer.send(:calculate_time_value_benefit, option, 11.months)
        expect(benefit).to be_between(0, 100)
      end
    end
  end

  describe 'composite scoring' do
    let(:mock_financial) { { profitability_score: 80 } }
    let(:mock_operational) { { net_operational_benefit: 1_000_000 } }
    let(:mock_risk) { { risk_adjusted_score: 70 } }
    let(:mock_strategic) { { strategic_score: 85 } }
    let(:mock_timeline) { { overall_timeline_score: 75 } }

    describe '#calculate_composite_score' do
      it 'calculates weighted composite score' do
        score = analyzer.send(:calculate_composite_score,
          mock_financial, mock_operational, mock_risk, mock_strategic, mock_timeline)

        expect(score).to be_a(Float)
        expect(score).to be_between(0, 100)
      end

      it 'weights financial analysis highest' do
        high_financial = mock_financial.merge(profitability_score: 100)
        low_financial = mock_financial.merge(profitability_score: 0)

        high_score = analyzer.send(:calculate_composite_score,
          high_financial, mock_operational, mock_risk, mock_strategic, mock_timeline)
        low_score = analyzer.send(:calculate_composite_score,
          low_financial, mock_operational, mock_risk, mock_strategic, mock_timeline)

        expect(high_score).to be > low_score
      end
    end

    describe '#rank_options_by_score' do
      let(:analyzed_options) do
        [
          { composite_score: 70, option: { name: 'Option B' } },
          { composite_score: 85, option: { name: 'Option A' } },
          { composite_score: 60, option: { name: 'Option C' } }
        ]
      end

      it 'ranks options by composite score in descending order' do
        ranked = analyzer.send(:rank_options_by_score, analyzed_options)

        expect(ranked.first[:composite_score]).to eq(85)
        expect(ranked.last[:composite_score]).to eq(60)
        expect(ranked.first[:option][:name]).to eq('Option A')
      end
    end
  end

  describe 'recommendation generation' do
    describe '#generate_recommendation' do
      it 'generates appropriate recommendations based on score' do
        expect(analyzer.send(:generate_recommendation, 90, {})).to include('Highly recommended')
        expect(analyzer.send(:generate_recommendation, 70, {})).to include('Recommended')
        expect(analyzer.send(:generate_recommendation, 55, {})).to include('Consider with modifications')
        expect(analyzer.send(:generate_recommendation, 30, {})).to include('Not recommended')
      end
    end
  end

  describe 'benefit estimation' do
    describe '#estimate_annual_benefits' do
      it 'estimates benefits based on construction type' do
        full_station_benefits = analyzer.send(:estimate_annual_benefits, sample_construction_options.first)
        asteroid_benefits = analyzer.send(:estimate_annual_benefits, sample_construction_options.second)

        expect(full_station_benefits).to be > asteroid_benefits
        expect(full_station_benefits).to be > 10_000_000
      end

      it 'adjusts benefits based on capability score' do
        high_capability_option = sample_construction_options.first.merge(capability_score: 100)
        low_capability_option = sample_construction_options.first.merge(capability_score: 25)

        high_benefits = analyzer.send(:estimate_annual_benefits, high_capability_option)
        low_benefits = analyzer.send(:estimate_annual_benefits, low_capability_option)

        expect(high_benefits).to be > low_benefits
      end
    end
  end
end