# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CelestialBodiesController, type: :controller do
  let!(:solar_system) { create(:solar_system) }
  let!(:terrestrial_planet) do
    planet = create(:terrestrial_planet, solar_system: solar_system)
    
    # Create basic atmosphere
    planet.create_atmosphere!(pressure: 1.0, temperature: 288.0) unless planet.atmosphere
    
    # Create basic hydrosphere
    planet.create_hydrosphere!(total_water_mass: 1.4e21) unless planet.hydrosphere
    
    # Create basic geosphere  
    planet.create_geosphere!(tectonic_activity: true, geological_activity: 75) unless planet.geosphere
    
    # Create basic biosphere
    planet.create_biosphere!(biodiversity_index: 0.85, habitable_ratio: 0.71) unless planet.biosphere
    
    planet
  end

  describe 'GET #monitor' do
    it 'renders the monitor view successfully' do
      get :monitor, params: { id: terrestrial_planet.id }
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:monitor)
    end

    it 'assigns @celestial_body' do
      get :monitor, params: { id: terrestrial_planet.id }
      expect(assigns(:celestial_body)).to eq(terrestrial_planet)
    end

    it 'loads geological features' do
      get :monitor, params: { id: terrestrial_planet.id }
      expect(assigns(:geological_features)).to be_an(Array)
    end

    it 'loads AI missions' do
      get :monitor, params: { id: terrestrial_planet.id }
      expect(assigns(:ai_missions)).to be_an(Array)
    end

    it 'builds sphere summary' do
      get :monitor, params: { id: terrestrial_planet.id }
      sphere_summary = assigns(:sphere_summary)
      expect(sphere_summary).to be_a(Hash)
      expect(sphere_summary[:atmosphere]).to be true
      expect(sphere_summary[:hydrosphere]).to be true
      expect(sphere_summary[:geosphere]).to be true
      expect(sphere_summary[:biosphere]).to be true
    end

    context 'when celestial body not found' do
      it 'redirects to root path' do
        get :monitor, params: { id: 99999 }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #sphere_data' do
    it 'returns JSON with sphere data' do
      get :sphere_data, params: { id: terrestrial_planet.id }, format: :json
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(/application\/json/)
    end

    it 'includes atmosphere data' do
      get :sphere_data, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['atmosphere']).to be_present
      expect(json['atmosphere']).to have_key('pressure')
      expect(json['atmosphere']).to have_key('temperature')
      # Temperature is rounded to 2 decimal places in controller
      expect(json['atmosphere']['temperature']).to be >= 288.0
    end

    it 'includes hydrosphere data' do
      get :sphere_data, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['hydrosphere']).to be_present
      expect(json['hydrosphere']['total_water']).to be_a(Numeric)
    end

    it 'includes geosphere data' do
      get :sphere_data, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['geosphere']).to be_present
      expect(json['geosphere']['geological_activity']).to eq(75)
      expect(json['geosphere']['tectonic_active']).to be true
    end

    it 'includes biosphere data' do
      get :sphere_data, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['biosphere']).to be_present
      expect(json['biosphere']['biodiversity_index']).to eq(85.0)
      expect(json['biosphere']['habitable_ratio']).to eq(71.0)
    end

    it 'includes planet info data' do
      get :sphere_data, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['planet_info']).to be_present
      expect(json['planet_info']['name']).to eq(terrestrial_planet.name)
      expect(json['planet_info']['type']).to eq(terrestrial_planet.type)
    end

    context 'when spheres are missing' do
      let(:barren_planet) { create(:terrestrial_planet, solar_system: solar_system) }

      it 'returns data for spheres even if associations are nil' do
        get :sphere_data, params: { id: barren_planet.id }, format: :json
        json = JSON.parse(response.body)
        # Controller should return hash with keys even if data is minimal
        expect(json).to have_key('atmosphere')
        expect(json).to have_key('hydrosphere')
        expect(json).to have_key('geosphere')
        expect(json).to have_key('biosphere')
      end
    end
  end

  describe 'GET #mission_log' do
    it 'returns JSON with mission data' do
      get :mission_log, params: { id: terrestrial_planet.id }, format: :json
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(/application\/json/)
    end

    it 'includes missions array' do
      get :mission_log, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['missions']).to be_an(Array)
    end

    it 'includes mission statistics' do
      get :mission_log, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['total_missions']).to be_a(Integer)
      expect(json['active_missions']).to be_a(Integer)
    end

    it 'includes mission details' do
      get :mission_log, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      if json['missions'].any?
        mission = json['missions'].first
        expect(mission).to have_key('id')
        expect(mission).to have_key('type')
        expect(mission).to have_key('status')
        expect(mission).to have_key('progress')
      end
    end
  end

  describe 'POST #run_ai_test' do
    it 'runs resource extraction test successfully' do
      post :run_ai_test, params: { id: terrestrial_planet.id, test_type: 'resource_extraction' }, format: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['test_type']).to eq('resource_extraction')
    end

    it 'returns resource extraction results' do
      post :run_ai_test, params: { id: terrestrial_planet.id, test_type: 'resource_extraction' }, format: :json
      json = JSON.parse(response.body)
      expect(json['resources_extracted']).to be_present
      expect(json['resources_extracted']['oxygen']).to be_a(Integer)
      expect(json['isru_efficiency']).to be_a(Float)
    end

    it 'runs base construction test successfully' do
      post :run_ai_test, params: { id: terrestrial_planet.id, test_type: 'base_construction' }, format: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['test_type']).to eq('base_construction')
    end

    it 'returns base construction results' do
      post :run_ai_test, params: { id: terrestrial_planet.id, test_type: 'base_construction' }, format: :json
      json = JSON.parse(response.body)
      expect(json['phases_completed']).to be_a(Integer)
      expect(json['total_phases']).to be_a(Integer)
      expect(json['settlement_gcc']).to be_a(Integer)
    end

    it 'runs ISRU pipeline test successfully' do
      post :run_ai_test, params: { id: terrestrial_planet.id, test_type: 'isru_pipeline' }, format: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['test_type']).to eq('isru_pipeline')
    end

    it 'returns ISRU pipeline results' do
      post :run_ai_test, params: { id: terrestrial_planet.id, test_type: 'isru_pipeline' }, format: :json
      json = JSON.parse(response.body)
      expect(json['oxygen_produced']).to be_a(Integer)
      expect(json['water_produced']).to be_a(Integer)
      expect(json['fuel_produced']).to be_a(Integer)
      expect(json['earth_imports_reduced']).to be_a(Integer)
    end

    it 'handles unknown test type' do
      post :run_ai_test, params: { id: terrestrial_planet.id, test_type: 'unknown' }, format: :json
      json = JSON.parse(response.body)
      expect(json['success']).to be false
      expect(json['error']).to eq('Unknown test type')
    end

    it 'defaults to resource_extraction when no test type specified' do
      post :run_ai_test, params: { id: terrestrial_planet.id }, format: :json
      json = JSON.parse(response.body)
      expect(json['test_type']).to eq('resource_extraction')
    end
  end

  describe 'private methods' do
    describe '#atmosphere_data' do
      it 'returns formatted atmosphere data' do
        controller.instance_variable_set(:@celestial_body, terrestrial_planet)
        data = controller.send(:atmosphere_data)
        
        expect(data[:pressure]).to be_a(Float)
        expect(data[:temperature]).to be_a(Float)
        expect(data[:composition]).to be_a(Hash)
        expect(data[:habitable]).to be_in([true, false])
      end
    end

    describe '#hydrosphere_data' do
      it 'returns formatted hydrosphere data' do
        controller.instance_variable_set(:@celestial_body, terrestrial_planet)
        data = controller.send(:hydrosphere_data)
        
        expect(data[:total_water]).to be_a(Numeric)
        expect(data).to have_key(:water_coverage)
        expect(data).to have_key(:ocean_mass)
      end
    end

    describe '#geosphere_data' do
      it 'returns formatted geosphere data' do
        controller.instance_variable_set(:@celestial_body, terrestrial_planet)
        data = controller.send(:geosphere_data)
        
        expect(data[:geological_activity]).to be_a(Integer)
        expect(data[:tectonic_active]).to be_in([true, false])
        expect(data[:volcanic_activity]).to be_a(String)
      end
    end

    describe '#biosphere_data' do
      it 'returns formatted biosphere data' do
        controller.instance_variable_set(:@celestial_body, terrestrial_planet)
        data = controller.send(:biosphere_data)
        
        expect(data[:biodiversity_index]).to be_a(Float)
        expect(data[:habitable_ratio]).to be_a(Float)
        expect(data).to have_key(:life_forms_count)
      end
    end
  end

  describe 'GET #index' do
    let!(:gas_giant) { create(:gas_giant, solar_system: solar_system) }
    let!(:moon) { create(:moon, solar_system: solar_system, parent_body: terrestrial_planet) }
    let!(:asteroid) { create(:asteroid, solar_system: solar_system) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns all celestial bodies' do
      get :index
      expect(assigns(:celestial_bodies)).to include(terrestrial_planet, gas_giant, moon, asteroid)
    end

    it 'orders celestial bodies by name' do
      get :index
      names = assigns(:celestial_bodies).map(&:name)
      expect(names).to eq(names.sort)
    end

    it 'assigns total count' do
      get :index
      expect(assigns(:total_bodies)).to eq(4)
    end

    it 'groups bodies by type' do
      get :index
      bodies_by_type = assigns(:bodies_by_type)
      expect(bodies_by_type).to be_a(Hash)
      expect(bodies_by_type['terrestrial_planet']).to include(terrestrial_planet)
      expect(bodies_by_type['gas_giant']).to include(gas_giant)
      expect(bodies_by_type['moon']).to include(moon)
      expect(bodies_by_type['asteroid']).to include(asteroid)
    end
  end
end
