# frozen_string_literal: true

require 'rails_helper'
require 'ai_manager/planetary_map_generator'

RSpec.describe Admin::MapStudioController, type: :controller do
  # No authentication required for admin controllers in this system

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns source maps count' do
      allow_any_instance_of(described_class).to receive(:find_all_source_maps).and_return([double, double])
      get :index
      expect(assigns(:source_maps_count)).to eq(2)
    end

    it 'assigns generated maps count' do
      maps = [
        { planet_type: 'terrestrial', filename: 'map1.json' },
        { planet_type: 'gas_giant', filename: 'map2.json' },
        { planet_type: 'terrestrial', filename: 'map3.json' }
      ]
      allow_any_instance_of(described_class).to receive(:find_generated_maps).and_return(maps)
      get :index
      expect(assigns(:generated_maps_count)).to eq(3)
    end

    it 'assigns celestial bodies count' do
      create_list(:celestial_body, 5) # Assuming you have a celestial_body factory
      get :index
      expect(assigns(:celestial_bodies_count)).to eq(5)
    end

    it 'assigns recent activities' do
      get :index
      expect(assigns(:recent_activities)).to be_an(Array)
      expect(assigns(:recent_activities)).not_to be_empty
    end
  end

  describe 'GET #generate' do
    it 'returns http success' do
      get :generate
      expect(response).to have_http_status(:success)
    end

    it 'assigns target planets' do
      create_list(:celestial_body, 3)
      get :generate
      expect(assigns(:target_planets)).to be_a(ActiveRecord::Relation)
      expect(assigns(:target_planets).size).to eq(3)
    end

    it 'assigns celestial bodies options' do
      celestial_body = create(:celestial_body, name: 'Test Planet')
      get :generate
      expect(assigns(:celestial_bodies_options)).to include(['Test Planet', celestial_body.id])
    end

    it 'assigns available source maps' do
      allow_any_instance_of(described_class).to receive(:find_all_source_maps).and_return([double])
      get :generate
      expect(assigns(:available_source_maps)).to be_an(Array)
    end
  end

  describe 'POST #generate_map' do
    context 'without planet_id' do
      it 'redirects to generate page with alert' do
        post :generate_map, params: { map_name: 'Test Map' }
        expect(response).to redirect_to(admin_map_studio_generate_path)
        expect(flash[:alert]).to eq('Please select a target planet.')
      end
    end

    context 'with valid planet_id' do
      let(:celestial_body) { create(:celestial_body) }

      it 'finds the celestial body' do
        allow(AIManager::PlanetaryMapGenerator).to receive(:new).and_return(double(generate_planetary_map: {}))
        post :generate_map, params: {
          planet_id: celestial_body.id,
          map_name: 'Test Map',
          source_map_ids: ['1', '2']
        }
        expect(assigns(:planet)).to eq(celestial_body)
      end

      it 'initializes the map generator' do
        generator = double
        allow(AIManager::PlanetaryMapGenerator).to receive(:new).and_return(generator)
        allow(generator).to receive(:generate_planetary_map).and_return({})

        post :generate_map, params: {
          planet_id: celestial_body.id,
          map_name: 'Test Map',
          source_map_ids: ['1', '2']
        }

        expect(AIManager::PlanetaryMapGenerator).to have_received(:new)
      end
    end
  end

  describe 'GET #browse' do
    it 'returns http success' do
      get :browse
      expect(response).to have_http_status(:success)
    end

    it 'assigns generated maps' do
      maps = [{ planet_type: 'terrestrial', filename: 'map1.json' }]
      allow_any_instance_of(described_class).to receive(:find_generated_maps).and_return(maps)
      get :browse
      expect(assigns(:generated_maps)).to eq(maps)
    end
  end

  describe 'GET #analyze' do
    it 'returns http success' do
      allow_any_instance_of(described_class).to receive(:load_generated_map_by_id).and_return({ name: 'Test Map' })
      get :analyze, params: { id: '1' }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the map' do
      test_map = { name: 'Test Map', id: '1' }
      allow_any_instance_of(described_class).to receive(:load_generated_map_by_id).and_return(test_map)
      get :analyze, params: { id: '1' }
      expect(assigns(:map)).to eq(test_map)
    end
  end

  describe 'POST #apply_map' do
    let(:celestial_body) { create(:celestial_body) }
    let(:map_data) { { 'terrain_grid' => [[1, 2], [3, 4]], 'metadata' => { 'width' => 2, 'height' => 2 } } }

    it 'redirects to celestial body monitor' do
      allow(File).to receive(:read).and_return(map_data.to_json)
      allow_any_instance_of(described_class).to receive(:apply_map_to_celestial_body)

      post :apply_map, params: { id: '1', celestial_body_id: celestial_body.id }
      expect(response).to redirect_to(monitor_admin_celestial_body_path(celestial_body))
    end
  end
end