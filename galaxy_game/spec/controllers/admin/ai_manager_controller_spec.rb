require 'rails_helper'
require_relative '../../../app/services/ai_manager'

RSpec.describe Admin::AiManagerController, type: :controller do
  # Mock market and transport services
  before(:each) do
    # Mock CelestialBody lookups
    allow(CelestialBodies::CelestialBody).to receive(:find_by).with(identifier: 'mars').and_return(
      double('Mars', id: 1, identifier: 'mars', name: 'Mars', has_solid_surface?: true,
             atmosphere: double('MarsAtmosphere', composition: {'CO2' => 0.95, 'N2' => 0.03}), 
             geosphere: double('MarsGeosphere', surface_composition: {'iron_oxide' => 0.2, 'silicon' => 0.3}, volatile_reservoirs: {'H2O' => 0.1}, subsurface_water_mass: 0.0), 
             hydrosphere: nil)
    )
    allow(CelestialBodies::CelestialBody).to receive(:find_by).with(identifier: 'earth').and_return(
      double('Earth', id: 2, identifier: 'earth', name: 'Earth', has_solid_surface?: true,
             atmosphere: double('EarthAtmosphere', composition: {'N2' => 0.78, 'O2' => 0.21}), 
             geosphere: double('EarthGeosphere', surface_composition: {'silicon' => 0.3, 'aluminum' => 0.1}, volatile_reservoirs: {}, subsurface_water_mass: 0.0), 
             hydrosphere: double('EarthHydrosphere', ocean_coverage: 0.7))
    )
    
    # Mock settlements
    earth_settlement = double('EarthSettlement', 
      id: 1, 
      name: 'Earth Hub', 
      location: double('EarthLocation', celestial_body_id: 2, celestial_body: double('Earth', id: 2, identifier: 'earth', name: 'Earth'))
    )
    
    # Mock Settlement::BaseSettlement query chains
    empty_relation = double('EmptyRelation')
    allow(empty_relation).to receive(:limit).and_return([])
    
    where_not_relation = double('WhereNotRelation')
    allow(where_not_relation).to receive(:not).and_return(empty_relation)
    allow(where_not_relation).to receive(:limit).and_return([])
    
    joins_relation = double('JoinsRelation')
    allow(joins_relation).to receive(:where).and_return(where_not_relation)
    allow(joins_relation).to receive(:find_by).and_return(earth_settlement)
    
    allow(Settlement::BaseSettlement).to receive(:find_by).and_return(earth_settlement)
    allow(Settlement::BaseSettlement).to receive(:joins).and_return(joins_relation)
    
    # Mock Market::NpcPriceCalculator
    allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)
    
    # Mock Logistics::TransportCostService
    allow(Logistics::TransportCostService).to receive(:calculate_cost_per_kg).and_return(50.0)
  end
  
  describe "GET #missions" do
    it "loads all missions" do
      get :missions
      expect(response).to have_http_status(:success)
      expect(assigns(:missions)).to_not be_nil
    end
    
    it "separates missions by status" do
      get :missions
      expect(assigns(:active_missions)).to_not be_nil
      expect(assigns(:completed_missions)).to_not be_nil
      expect(assigns(:failed_missions)).to_not be_nil
    end
  end
  
  describe "GET #show_mission" do
    let(:settlement) { create(:base_settlement) }
    let(:mission) { Mission.create!(identifier: 'test_mission', settlement: settlement, status: :in_progress, progress: 0) }
    
    context "when mission exists" do
      it "loads the mission" do
        get :show_mission, params: { id: mission.id }
        expect(response).to have_http_status(:success)
        expect(assigns(:mission)).to eq(mission)
      end
    end
    
    context "when mission does not exist" do
      it "redirects with alert" do
        get :show_mission, params: { id: 99999 }
        expect(response).to redirect_to(admin_ai_manager_missions_path)
        expect(flash[:alert]).to eq("Mission not found")
      end
    end
  end
  
  describe "POST #advance_phase" do
    let(:settlement) { create(:base_settlement) }
    let(:mission) { Mission.create!(identifier: 'lunar-precursor', settlement: settlement, status: :in_progress, progress: 0) }
    
    it "advances the mission phase" do
      post :advance_phase, params: { id: mission.id }
      expect(response).to redirect_to(admin_ai_manager_mission_path(mission))
    end
  end
  
  describe "POST #reset_mission" do
    let(:settlement) { create(:base_settlement) }
    let(:mission) { Mission.create!(identifier: 'test_mission', settlement: settlement, status: :completed, progress: 100) }
    
    it "resets mission progress" do
      post :reset_mission, params: { id: mission.id }
      mission.reload
      expect(mission.progress).to eq(0)
      expect(mission.status).to eq('in_progress')
      expect(response).to redirect_to(admin_ai_manager_mission_path(mission))
    end
  end
  
  describe "GET #planner" do
    it "loads available patterns" do
      get :planner
      expect(response).to have_http_status(:success)
      expect(assigns(:available_patterns)).to be_an(Array)
      expect(assigns(:available_patterns)).to include('mars-terraforming', 'venus-industrial', 'titan-fuel')
    end
    
    it "does not run simulation without pattern parameter" do
      get :planner
      expect(assigns(:simulation_result)).to be_nil
      expect(assigns(:forecast)).to be_nil
    end
    
    it "runs simulation when pattern is provided" do
      get :planner, params: { 
        pattern: 'mars-terraforming',
        timeline_years: 10,
        budget_gcc: 1_000_000
      }
      
      expect(assigns(:simulation_result)).to_not be_nil
      expect(assigns(:forecast)).to_not be_nil
      expect(assigns(:planner)).to be_a(AIManager::MissionPlannerService)
      expect(assigns(:forecaster)).to be_a(AIManager::EconomicForecasterService)
    end
    
    it "uses default parameters if not provided" do
      get :planner, params: { pattern: 'mars-terraforming' }
      
      planner = assigns(:planner)
      expect(planner.parameters[:tech_level]).to eq('standard')
      expect(planner.parameters[:timeline_years]).to eq(10)
      expect(planner.parameters[:budget_gcc]).to eq(1_000_000)
    end
  end
  
  describe "POST #export_plan" do
    it "exports simulation plan as JSON" do
      post :export_plan, params: {
        pattern: 'mars-terraforming',
        parameters: { timeline_years: 10 }.to_json
      }
      
      expect(response.content_type).to eq('application/json')
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.headers['Content-Disposition']).to include('mission_plan_mars-terraforming')
      
      json_data = JSON.parse(response.body)
      expect(json_data['pattern']).to eq('mars-terraforming')
      expect(json_data['results']).to be_present
    end
  end

  describe "GET #decisions" do
    it "returns http success" do
      get :decisions
      expect(response).to have_http_status(:success)
    end

    it "assigns decisions data" do
      get :decisions
      expect(assigns(:decisions)).to be_an(Array)
    end
  end

  describe "GET #patterns" do
    it "returns http success" do
      get :patterns
      expect(response).to have_http_status(:success)
    end

    it "assigns patterns data" do
      get :patterns
      expect(assigns(:patterns)).to be_an(Array)
    end
  end

  describe "GET #performance" do
    it "returns http success" do
      get :performance
      expect(response).to have_http_status(:success)
    end

    it "assigns performance metrics" do
      get :performance
      expect(assigns(:metrics)).to be_a(Hash)
      expect(assigns(:metrics)).to have_key(:success_rate)
      expect(assigns(:metrics)).to have_key(:average_timeline)
      expect(assigns(:metrics)).to have_key(:resource_efficiency)
    end
  end
end