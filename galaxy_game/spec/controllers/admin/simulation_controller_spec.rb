# spec/controllers/admin/simulation_controller_spec.rb
require 'rails_helper'

RSpec.describe Admin::SimulationController, type: :controller do
  describe "GET #index" do
    context "with existing solar system" do
      # Sol is always present as a world constant — use same lookup as controller
      let!(:solar_system) { SolarSystem.includes(:stars, :celestial_bodies).find_by(identifier: 'SOL-01') || SolarSystem.includes(:stars, :celestial_bodies).first }
      let!(:planet) { solar_system.celestial_bodies.first }

      it "assigns solar system and its celestial bodies" do
        get :index

        expect(assigns(:solar_system)).to eq(solar_system)
        expect(assigns(:celestial_bodies)).to include(planet)
      end

      it "assigns the primary star" do
        get :index
        expect(assigns(:star)).not_to be_nil
      end
    end
    
    context "without solar system" do
      let!(:celestial_body) { create(:celestial_body) }
      
      before do
        allow(SolarSystem).to receive(:first).and_return(nil)
        allow(SolarSystem).to receive(:find_by).and_return(nil)
        relation_double = double('relation')
        allow(relation_double).to receive(:find_by).and_return(nil)
        allow(relation_double).to receive(:first).and_return(nil)
        allow(SolarSystem).to receive(:includes).and_return(relation_double)
      end
      
      it "assigns all celestial bodies" do
        get :index
        
        expect(assigns(:solar_system)).to be_nil
        expect(assigns(:celestial_bodies)).to include(celestial_body)
      end
    end
  end
  
  describe "GET #run" do
    let!(:celestial_body) { create(:celestial_body) }
    let(:simulator_mock) { instance_double(TerraSim::Simulator) }
    
    before do
      allow(TerraSim::Simulator).to receive(:new).with(celestial_body).and_return(simulator_mock)
      allow(simulator_mock).to receive(:calc_current)
    end
    
    it "runs simulation for specific celestial body" do
      get :run, params: { id: celestial_body.id }
      
      expect(TerraSim::Simulator).to have_received(:new).with(celestial_body)
      expect(simulator_mock).to have_received(:calc_current)
      expect(response).to redirect_to(admin_simulation_path)
      expect(flash[:notice]).to include(celestial_body.name)
    end
    
    it "handles errors gracefully" do
      allow(simulator_mock).to receive(:calc_current).and_raise("Simulation error")
      
      get :run, params: { id: celestial_body.id }
      
      expect(response).to redirect_to(admin_simulation_path)
      expect(flash[:alert]).to include("Simulation failed")
    end
  end
  
  describe "GET #run_all" do
    context "with existing solar system" do
      # Sol is always present as a world constant
      let!(:solar_system) { SolarSystem.find_by!(identifier: 'SOL-01') }
      let(:expected_body_count) { solar_system.celestial_bodies.count }

      before do
        allow(TerraSim::Simulator).to receive(:new).and_return(double("simulator", calc_current: nil))
      end

      it "runs simulation for all celestial bodies" do
        get :run_all

        expect(TerraSim::Simulator).to have_received(:new).exactly(expected_body_count).times
        expect(response).to redirect_to(admin_simulation_path)
        expect(flash[:notice]).to include("all celestial bodies")
      end
    end
    
    context "without solar system" do
      before do
        allow(SolarSystem).to receive(:first).and_return(nil)
        allow(SolarSystem).to receive(:find_by).and_return(nil)
        allow(SolarSystem).to receive(:includes).and_return(
          double('relation', first: nil)
        )
      end
      
      it "handles missing solar system gracefully" do
        get :run_all
        
        expect(response).to redirect_to(admin_simulation_path)
        expect(flash[:alert]).to include("No solar system found")
      end
    end
  end

  describe "POST #update_ai_priorities" do
    let(:ai_priority_system) { instance_double(AIManager::AiPrioritySystem) }

    before do
      allow(AIManager::AiPrioritySystem).to receive(:instance).and_return(ai_priority_system)
      allow(ai_priority_system).to receive(:set_critical_multiplier)
      allow(ai_priority_system).to receive(:set_operational_multiplier)
    end

    context "with valid parameters" do
      let(:params) do
        {
          critical_multiplier: 2.5,
          operational_multiplier: 1.8
        }
      end

      it "updates AI priority multipliers" do
        post :update_ai_priorities, params: params, format: :json

        expect(ai_priority_system).to have_received(:set_critical_multiplier).with(2.5)
        expect(ai_priority_system).to have_received(:set_operational_multiplier).with(1.8)
      end

      it "returns success response in JSON format" do
        post :update_ai_priorities, params: params, format: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['message']).to include('AI priorities updated')
      end

      it "returns success response in HTML format" do
        post :update_ai_priorities, params: params

        expect(response).to redirect_to(admin_simulation_path)
        expect(flash[:notice]).to include('AI priorities updated')
      end
    end

    context "with invalid parameters" do
      it "handles missing critical_multiplier gracefully" do
        post :update_ai_priorities, params: { operational_multiplier: 1.5 }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('Missing required parameters')
      end

      it "handles missing operational_multiplier gracefully" do
        post :update_ai_priorities, params: { critical_multiplier: 2.0 }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('Missing required parameters')
      end

      it "handles non-numeric multipliers gracefully" do
        post :update_ai_priorities, params: {
          critical_multiplier: 'invalid',
          operational_multiplier: 1.5
        }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('Invalid parameters')
      end
    end

    context "when AI priority system raises an error" do
      before do
        allow(ai_priority_system).to receive(:set_critical_multiplier).and_raise("Priority system error")
      end

      it "handles errors gracefully in JSON format" do
        post :update_ai_priorities, params: {
          critical_multiplier: 2.0,
          operational_multiplier: 1.5
        }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('Failed to update AI priorities')
      end

      it "handles errors gracefully in HTML format" do
        post :update_ai_priorities, params: {
          critical_multiplier: 2.0,
          operational_multiplier: 1.5
        }

        expect(response).to redirect_to(admin_simulation_path)
        expect(flash[:alert]).to include('Failed to update AI priorities')
      end
    end
  end

  describe "POST #reset_ai_priorities" do
    let(:ai_priority_system) { instance_double(AIManager::AiPrioritySystem) }

    before do
      allow(AIManager::AiPrioritySystem).to receive(:instance).and_return(ai_priority_system)
      allow(ai_priority_system).to receive(:set_critical_multiplier)
      allow(ai_priority_system).to receive(:set_operational_multiplier)
    end

    it "resets AI priority multipliers to default values" do
      post :reset_ai_priorities, format: :json

      expect(ai_priority_system).to have_received(:set_critical_multiplier).with(1.0)
      expect(ai_priority_system).to have_received(:set_operational_multiplier).with(1.0)
    end

    it "returns success response in JSON format" do
      post :reset_ai_priorities, format: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['message']).to include('AI priorities reset')
    end

    it "returns success response in HTML format" do
      post :reset_ai_priorities

      expect(response).to redirect_to(admin_simulation_path)
      expect(flash[:notice]).to include('AI priorities reset')
    end

    context "when AI priority system raises an error" do
      before do
        allow(ai_priority_system).to receive(:set_critical_multiplier).and_raise("Reset error")
      end

      it "handles errors gracefully in JSON format" do
        post :reset_ai_priorities, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('Failed to reset AI priorities')
      end

      it "handles errors gracefully in HTML format" do
        post :reset_ai_priorities

        expect(response).to redirect_to(admin_simulation_path)
        expect(flash[:alert]).to include('Failed to reset AI priorities')
      end
    end
  end
end