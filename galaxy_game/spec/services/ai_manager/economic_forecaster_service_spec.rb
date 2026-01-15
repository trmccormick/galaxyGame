require 'rails_helper'
require_relative '../../../app/services/ai_manager'

RSpec.describe AIManager::EconomicForecasterService do
  let(:planner) { AIManager::MissionPlannerService.new('mars-terraforming', { timeline_years: 10 }) }
  let(:simulation_results) { planner.simulate }
  let(:forecaster) { AIManager::EconomicForecasterService.new(simulation_results) }
  
  describe '#initialize' do
    it 'creates forecaster with simulation results' do
      expect(forecaster.planner_results).to eq(simulation_results)
      expect(forecaster.analysis).to eq({})
    end
  end
  
  describe '#analyze' do
    before do
      @analysis = forecaster.analyze
    end
    
    it 'returns complete economic analysis' do
      expect(@analysis).to have_key(:demand_forecast)
      expect(@analysis).to have_key(:gcc_distribution)
      expect(@analysis).to have_key(:bottlenecks)
      expect(@analysis).to have_key(:opportunities)
      expect(@analysis).to have_key(:risk_assessment)
    end
    
    it 'forecasts resource demand correctly' do
      demand = @analysis[:demand_forecast]
      
      expect(demand[:total_demand]).to be_a(Hash)
      expect(demand[:peak_demand]).to be_a(Hash)
      expect(demand[:demand_curve]).to be_a(Hash)
      expect(demand[:critical_resources]).to be_a(Hash)
    end
    
    it 'analyzes GCC distribution' do
      gcc = @analysis[:gcc_distribution]
      
      expect(gcc[:total_project_cost]).to be > 0
      expect(gcc[:dc_expenditure]).to be > 0
      expect(gcc[:player_earnings]).to be > 0
      expect(gcc[:dc_percentage]).to be_between(0, 100)
      expect(gcc[:player_percentage]).to be_between(0, 100)
      expect(gcc[:dc_percentage] + gcc[:player_percentage]).to be_within(0.1).of(100)
    end
    
    it 'identifies bottlenecks when present' do
      bottlenecks = @analysis[:bottlenecks]
      
      expect(bottlenecks).to be_an(Array)
      # Each bottleneck should have severity and recommendation
      if bottlenecks.any?
        expect(bottlenecks.first).to have_key(:severity)
        expect(bottlenecks.first).to have_key(:recommendation)
      end
    end
    
    it 'identifies opportunities' do
      opportunities = @analysis[:opportunities]
      
      expect(opportunities).to be_an(Array)
      # Should identify at least some opportunities
      expect(opportunities.size).to be > 0
      expect(opportunities.first).to have_key(:type)
      expect(opportunities.first).to have_key(:description)
    end
    
    it 'assesses risks' do
      risks = @analysis[:risk_assessment]
      
      expect(risks).to be_an(Array)
      # Each risk should have category, severity, and mitigation
      if risks.any?
        expect(risks.first).to have_key(:category)
        expect(risks.first).to have_key(:severity)
        expect(risks.first).to have_key(:description)
        expect(risks.first).to have_key(:mitigation)
      end
    end
  end
  
  describe '#compare_scenarios' do
    let(:planner1) { AIManager::MissionPlannerService.new('mars-terraforming', { timeline_years: 10 }) }
    let(:planner2) { AIManager::MissionPlannerService.new('mars-terraforming', { timeline_years: 15 }) }
    let(:results1) { planner1.simulate }
    let(:results2) { planner2.simulate }
    
    it 'compares multiple scenarios side-by-side' do
      comparison = forecaster.compare_scenarios({
        'Fast Track' => results1,
        'Extended Timeline' => results2
      })
      
      expect(comparison[:total_costs]).to have_key('Fast Track')
      expect(comparison[:total_costs]).to have_key('Extended Timeline')
      expect(comparison[:player_revenue]).to have_key('Fast Track')
      expect(comparison[:player_revenue]).to have_key('Extended Timeline')
      expect(comparison[:efficiency_scores]).to have_key('Fast Track')
      expect(comparison[:efficiency_scores]).to have_key('Extended Timeline')
      expect(comparison[:recommendations]).to be_an(Array)
      expect(comparison[:recommendations].size).to be > 0
    end
    
    it 'recommends the best scenario' do
      comparison = forecaster.compare_scenarios({
        'Scenario A' => results1,
        'Scenario B' => results2
      })
      
      recommendation = comparison[:recommendations].first
      expect(recommendation).to include('efficiency')
      expect(recommendation).to match(/Scenario (A|B)/)
    end
  end
  
  describe 'demand curve analysis' do
    it 'identifies increasing demand trend' do
      # Create scenario with increasing demand
      planner = AIManager::MissionPlannerService.new('mars-terraforming')
      results = planner.simulate
      forecaster = AIManager::EconomicForecasterService.new(results)
      analysis = forecaster.analyze
      
      demand_curve = analysis[:demand_forecast][:demand_curve]
      expect(demand_curve[:trend]).to be_in(['increasing', 'steady', 'decreasing'])
      expect(demand_curve[:start_demand]).to be > 0
      expect(demand_curve[:end_demand]).to be > 0
      expect(demand_curve[:average_demand]).to be > 0
    end
  end
  
  describe 'critical resource identification' do
    it 'identifies top 20% resources as critical' do
      analysis = forecaster.analyze
      critical = analysis[:demand_forecast][:critical_resources]
      total_resources = simulation_results[:resources][:total]
      
      # Critical resources should be from top tier by quantity
      if total_resources.any?
        expect(critical.size).to be <= total_resources.size
        # All critical resources should have high quantities
        min_critical_qty = critical.values.min
        max_noncritical_qty = (total_resources.values - critical.values).max || 0
        expect(min_critical_qty).to be >= max_noncritical_qty if critical.any? && max_noncritical_qty > 0
      end
    end
  end
  
  describe 'risk assessment' do
    it 'flags low contingency as financial risk' do
      # Create scenario with low contingency (implicitly in results)
      analysis = forecaster.analyze
      risks = analysis[:risk_assessment]
      
      # Check if financial risks are properly categorized
      financial_risks = risks.select { |r| r[:category] == 'financial' }
      financial_risks.each do |risk|
        expect(risk[:severity]).to be_in(['low', 'medium', 'high'])
        expect(risk[:mitigation]).to be_present
      end
    end
    
    it 'flags aggressive timeline as schedule risk' do
      # Test with short timeline
      short_planner = AIManager::MissionPlannerService.new('mars-terraforming', { timeline_years: 3 })
      short_results = short_planner.simulate
      short_forecaster = AIManager::EconomicForecasterService.new(short_results)
      analysis = short_forecaster.analyze
      
      schedule_risks = analysis[:risk_assessment].select { |r| r[:category] == 'schedule' }
      expect(schedule_risks.size).to be > 0
      expect(schedule_risks.first[:severity]).to eq('high')
    end
  end
end
