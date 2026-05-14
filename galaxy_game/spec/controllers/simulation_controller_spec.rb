# spec/controllers/simulation_controller_spec.rb
require 'rails_helper'

RSpec.describe SimulationController, type: :controller do
  describe "GET #index" do
    context "with existing solar system" do
      # Sol is always present as a world constant — SolarSystem.first returns Sol
      let!(:solar_system) { SolarSystem.first }
      let!(:planet) { CelestialBodies::CelestialBody.find_by!(identifier: 'EARTH-01') }

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
        allow(SolarSystem).to receive(:includes).and_return(
          double('relation', first: nil)
        )
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
      expect(response).to redirect_to(simulation_path)
      expect(flash[:notice]).to include(celestial_body.name)
    end
    
    it "handles errors gracefully" do
      allow(simulator_mock).to receive(:calc_current).and_raise("Simulation error")
      
      get :run, params: { id: celestial_body.id }
      
      expect(response).to redirect_to(simulation_path)
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
        expect(response).to redirect_to(simulation_path)
        expect(flash[:notice]).to include("all celestial bodies")
      end
    end
    
    context "without solar system" do
      before do
        allow(SolarSystem).to receive(:first).and_return(nil)
        allow(SolarSystem).to receive(:includes).and_return(
          double('relation', first: nil)
        )
      end

      it "handles missing solar system gracefully" do
        get :run_all

        expect(response).to redirect_to(simulation_path)
        expect(flash[:alert]).to include("No solar system found")
      end
    end
  end
end