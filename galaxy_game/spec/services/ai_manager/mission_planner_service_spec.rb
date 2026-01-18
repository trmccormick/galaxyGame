require 'rails_helper'
require_relative '../../../app/services/ai_manager'

RSpec.describe AIManager::MissionPlannerService do
  describe '#initialize' do
    it 'creates a planner with pattern and default parameters' do
      planner = AIManager::MissionPlannerService.new('mars-terraforming')
      
      expect(planner.pattern).to eq('mars-terraforming')
      expect(planner.parameters[:tech_level]).to eq('standard')
      expect(planner.parameters[:timeline_years]).to eq(10)
      expect(planner.parameters[:budget_gcc]).to eq(1_000_000)
    end
    
    it 'accepts custom parameters' do
      planner = AIManager::MissionPlannerService.new('venus-industrial', {
        tech_level: 'advanced',
        timeline_years: 15,
        budget_gcc: 2_000_000
      })
      
      expect(planner.parameters[:tech_level]).to eq('advanced')
      expect(planner.parameters[:timeline_years]).to eq(15)
      expect(planner.parameters[:budget_gcc]).to eq(2_000_000)
    end
  end
  
  describe '#simulate' do
    let(:planner) { AIManager::MissionPlannerService.new('mars-terraforming', { timeline_years: 10 }) }
    
    before do
      @results = planner.simulate
    end
    
    it 'returns simulation results with all required sections' do
      expect(@results).to have_key(:timeline)
      expect(@results).to have_key(:resources)
      expect(@results).to have_key(:costs)
      expect(@results).to have_key(:player_revenue)
      expect(@results).to have_key(:planetary_changes)
    end
    
    it 'calculates timeline with phases and milestones' do
      timeline = @results[:timeline]
      
      expect(timeline[:total_years]).to eq(10)
      expect(timeline[:phases]).to be_an(Array)
      expect(timeline[:phases].size).to be > 0
      expect(timeline[:milestones]).to be_an(Array)
    end
    
    it 'calculates resource requirements by year' do
      resources = @results[:resources]
      
      expect(resources[:by_year]).to be_a(Hash)
      expect(resources[:by_year].size).to eq(10)
      expect(resources[:total]).to be_a(Hash)
      expect(resources[:peak_demand]).to have_key(:year)
      expect(resources[:peak_demand]).to have_key(:total_units)
    end
    
    it 'calculates costs with breakdown' do
      costs = @results[:costs]
      
      expect(costs[:total_gcc]).to be > 0
      expect(costs[:breakdown]).to be_a(Hash)
      expect(costs[:contingency]).to eq(costs[:total_gcc] * 0.15)
      expect(costs[:grand_total]).to eq(costs[:total_gcc] * 1.15)
    end
    
    it 'calculates player revenue opportunities' do
      revenue = @results[:player_revenue]
      
      expect(revenue[:total_opportunity_gcc]).to be > 0
      expect(revenue[:contract_count]).to be > 0
      expect(revenue[:average_contract_value]).to be > 0
      expect(revenue[:revenue_timeline]).to be_a(Hash)
    end
    
    it 'includes pattern-specific planetary changes for Mars' do
      changes = @results[:planetary_changes]
      
      expect(changes).to have_key(:atmosphere)
      expect(changes).to have_key(:temperature)
      expect(changes).to have_key(:water)
    end
  end
  
  describe '#simulate with different patterns' do
    it 'returns Venus-specific changes for venus-industrial pattern' do
      planner = AIManager::MissionPlannerService.new('venus-industrial')
      results = planner.simulate
      
      expect(results[:planetary_changes]).to have_key(:cloud_layer)
      expect(results[:planetary_changes]).to have_key(:production)
    end
    
    it 'returns Titan-specific changes for titan-fuel pattern' do
      planner = AIManager::MissionPlannerService.new('titan-fuel')
      results = planner.simulate
      
      expect(results[:planetary_changes]).to have_key(:methane_harvest)
      expect(results[:planetary_changes]).to have_key(:refining)
    end
  end
  
  describe '#create_contracts' do
    let(:planner) { AIManager::MissionPlannerService.new('mars-terraforming') }
    
    before do
      planner.simulate
    end
    
    it 'generates contract data from simulation results' do
      contracts = planner.create_contracts
      
      expect(contracts).to be_an(Array)
      expect(contracts.size).to be > 0
      expect(contracts.first).to have_key(:resource)
      expect(contracts.first).to have_key(:quantity)
      expect(contracts.first).to have_key(:delivery_year)
      expect(contracts.first).to have_key(:reward_gcc)
    end
  end
  
  describe '#export_plan' do
    let(:planner) { AIManager::MissionPlannerService.new('mars-terraforming') }
    
    before do
      planner.simulate
    end
    
    it 'exports plan as JSON with all required fields' do
      json_data = planner.export_plan
      plan = JSON.parse(json_data)
      
      expect(plan['pattern']).to eq('mars-terraforming')
      expect(plan['parameters']).to be_a(Hash)
      expect(plan['results']).to be_a(Hash)
      expect(plan['generated_at']).to be_present
      expect(plan['version']).to eq('1.0')
    end
  end
  
  describe 'data-driven local production' do
    let(:solar_system) { create(:solar_system) }
    let!(:mars) { create(:terrestrial_planet, :mars, solar_system: solar_system) }
    let(:planner) { described_class.new('mars-terraforming') }
    
    before do
      allow(AIManager::PatternTargetMapper).to receive(:target_location).and_return(mars)
    end
    
    it 'uses actual celestial body data for capability detection' do
      results = planner.simulate
      capabilities = results[:local_capabilities]
      
      expect(capabilities[:available]).to be true
      expect(capabilities[:atmosphere]).to include('co2')
      expect(capabilities[:precursor_enables][:oxygen]).to be true
    end
    
    it 'calculates costs using actual sphere data' do
      results = planner.simulate
      costs = results[:costs][:breakdown]
      
      # Resources Mars can produce should be marked local
      if costs['oxygen']
        expect(costs['oxygen'][:source_type]).to eq('local')
      end
      
      # Resources Mars cannot produce should be imports
      if costs['electronics']
        expect(costs['electronics'][:source_type]).to eq('import')
      end
    end
  end
  
  describe 'MaterialLookupService integration' do
    let(:planner) { described_class.new('mars-terraforming') }
    
    before do
      allow(AIManager::PatternTargetMapper).to receive(:target_location).and_return(mars)
    end
    
    it 'uses MaterialLookupService to get chemical formulas' do
      material_lookup = instance_double(Lookup::MaterialLookupService)
      allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
      
      material_data = { 'id' => 'oxygen', 'chemical_formula' => 'O2' }
      allow(material_lookup).to receive(:find_material).with('oxygen').and_return(material_data)
      allow(material_lookup).to receive(:get_material_property).with(material_data, 'chemical_formula').and_return('O2')
      
      # Planner should use O2 formula for capability checks
      planner.send(:calculate_total_delivered_cost, 'oxygen', 1000)
      
      expect(material_lookup).to have_received(:find_material).with('oxygen')
    end
    
    it 'handles materials not in lookup gracefully' do
      results = planner.simulate
      
      # Should not crash if some resources aren't in MaterialLookupService
      expect(results[:costs]).to be_present
    end
  end
end
