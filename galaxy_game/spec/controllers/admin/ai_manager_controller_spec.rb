require 'rails_helper'
require_relative '../../../app/services/ai_manager'

RSpec.describe Admin::AiManagerController, type: :controller do
  let!(:earth) { CelestialBodies::CelestialBody.find_by!(identifier: 'EARTH-01') }
  let!(:mars) { CelestialBodies::CelestialBody.find_by!(identifier: 'MARS-01') }
  # Add more planets as needed for your tests

  before(:each) do
    # Only mock external services, not celestial bodies
    allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)
    allow(Logistics::TransportCostService).to receive(:calculate_cost_per_kg).and_return(50.0)
  end
  
  describe "GET #index" do
    let!(:active_mission) { create(:mission, identifier: 'active_mission', status: :in_progress, progress: 50) }
    let!(:completed_mission) { create(:mission, identifier: 'completed_mission', status: :completed, progress: 100) }
    let!(:failed_mission) { create(:mission, identifier: 'failed_mission', status: :failed, progress: 0) }
    
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it "assigns system status data" do
      get :index
      expect(assigns(:system_status)).to be_a(Hash)
      expect(assigns(:system_status)).to have_key(:active_missions)
      expect(assigns(:system_status)).to have_key(:completed_missions)
      expect(assigns(:system_status)).to have_key(:failed_missions)
      expect(assigns(:system_status)).to have_key(:total_missions)
      expect(assigns(:system_status)).to have_key(:ai_services_status)
      expect(assigns(:system_status)).to have_key(:last_activity)
    end
    
    it "assigns active missions (limited to 5)" do
      # Create more than 5 active missions
      6.times do |i|
        create(:mission, identifier: "active_mission_#{i}", status: :in_progress, progress: 10)
      end
      
      get :index
      expect(assigns(:active_missions).length).to eq(5)
    end
    
    it "assigns performance metrics" do
      get :index
      expect(assigns(:performance_metrics)).to be_a(Hash)
      expect(assigns(:performance_metrics)).to have_key(:success_rate)
      expect(assigns(:performance_metrics)).to have_key(:average_timeline)
      expect(assigns(:performance_metrics)).to have_key(:resource_efficiency)
    end
    
    it "assigns system alerts" do
      get :index
      expect(assigns(:system_alerts)).to be_an(Array)
    end
    
    it "assigns quick actions data" do
      get :index
      expect(assigns(:quick_actions)).to be_a(Hash)
      expect(assigns(:quick_actions)).to have_key(:planner)
      expect(assigns(:quick_actions)).to have_key(:decisions)
      expect(assigns(:quick_actions)).to have_key(:patterns)
      expect(assigns(:quick_actions)).to have_key(:performance)
      
      # Check that each quick action has required keys
      assigns(:quick_actions).each do |key, action|
        expect(action).to have_key(:path)
        expect(action).to have_key(:title)
        expect(action).to have_key(:description)
      end
    end
    
    it "calculates correct mission counts" do
      get :index
      
      expect(assigns(:system_status)[:active_missions]).to eq(1)
      expect(assigns(:system_status)[:completed_missions]).to eq(1)
      expect(assigns(:system_status)[:failed_missions]).to eq(1)
      expect(assigns(:system_status)[:total_missions]).to eq(3)
    end
    
    it "includes AI services status" do
      get :index
      
      ai_status = assigns(:system_status)[:ai_services_status]
      expect(ai_status).to be_a(Hash)
      expect(ai_status).to have_key(:mission_planner)
      expect(ai_status).to have_key(:economic_forecaster)
      expect(ai_status).to have_key(:station_construction)
      
      # Each service should be either :operational or :error
      ai_status.each_value do |status|
        expect([:operational, :error]).to include(status)
      end
    end
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
      expect(assigns(:decisions)).to be_an(ActiveRecord::Relation)
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