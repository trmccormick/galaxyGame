# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CatalogController, type: :controller do
  before(:each) do
    # Create a mock catalog service
    @mock_service = instance_double(CatalogService)
    allow(CatalogService).to receive(:new).and_return(@mock_service)
  end

  describe 'GET #index' do
    let(:mock_entries) {
      [
        { id: 'crafts/space/probes/thermal_probe', name: 'Thermal Probe', type: 'probe', category: 'crafts', subcategory: 'probes', source_type: 'blueprint', file_path: '/path/to/file.json' },
        { id: 'crafts/space/satellites/generic_satellite', name: 'Generic Satellite', type: 'satellite', category: 'crafts', subcategory: 'satellites', source_type: 'blueprint', file_path: '/path/to/file.json' }
      ]
    }

    before do
      allow(@mock_service).to receive(:entries).and_return(mock_entries)
      allow(@mock_service).to receive(:paginated_result).and_return(
        OpenStruct.new(
          to_a: mock_entries,
          total_count: 2,
          total_pages: 1,
          current_page: 1,
          each: mock_entries.each,
          empty?: false
        )
      )
    end

    it 'returns success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns categories' do
      get :index
      expect(assigns(:categories)).to be_an(Array)
      expect(assigns(:categories)).to include('crafts')
    end

    it 'assigns entries' do
      get :index
      expect(assigns(:entries)).to be_truthy
    end

    it 'filters by category' do
      allow(@mock_service).to receive(:entries).and_return(
        mock_entries.select { |e| e[:category] == 'crafts' }
      )
      
      get :index, params: { category: 'crafts' }
      expect(assigns(:selected_category)).to eq('crafts')
    end

    it 'handles search query' do
      get :index, params: { q: 'probe' }
      expect(assigns(:search_query)).to eq('probe')
    end
  end

  describe 'GET #show' do
    let(:mock_entry) {
      {
        id: 'crafts/space/probes/thermal_probe',
        name: 'Thermal Probe',
        type: 'probe',
        category: 'crafts',
        subcategory: 'probes',
        source_type: 'blueprint',
        file_path: '/path/to/file.json',
        data: { 'name' => 'Thermal Probe', 'type' => 'probe' }
      }
    }

    before do
      allow(@mock_service).to receive(:find_entry).with('crafts/space/probes/thermal_probe').and_return(mock_entry)
      allow(@mock_service).to receive(:find_operational_data_by_name).and_return(nil)
    end

    it 'returns success for valid entry' do
      get :show, params: { id: 'crafts/space/probes/thermal_probe' }
      expect(response).to have_http_status(:success)
    end

    it 'renders show template' do
      get :show, params: { id: 'crafts/space/probes/thermal_probe' }
      expect(response).to render_template(:show)
    end

    it 'assigns entry' do
      get :show, params: { id: 'crafts/space/probes/thermal_probe' }
      expect(assigns(:entry)).to eq(mock_entry)
    end

    it 'redirects for non-existent entry' do
      allow(@mock_service).to receive(:find_entry).with('nonexistent').and_return(nil)
      get :show, params: { id: 'nonexistent' }
      expect(response).to redirect_to(admin_catalog_path)
    end
  end

  # C3 — RH-400 Catalog Vertical Slice tests
  describe 'GET #show with B2 catalog contract (C3)' do
    let(:rh400_entry) {
      {
        id: 'crafts/ground/harvesters/regolith_harvester_rover',
        name: 'Regolith Harvester Rover',
        type: 'harvester',
        category: 'crafts',
        subcategory: 'ground',
        source_type: 'blueprint',
        file_path: '/path/to/blueprints/crafts/ground/harvesters/regolith_harvester_rover.json',
        data: { 'id' => 'regolith_harvester_rover', 'name' => 'Regolith Harvester Rover', 'type' => 'harvester' }
      }
    }

    let(:mock_catalog_contract) {
      {
        asset_id: 'VEHICLE_HARVESTER_ROVER_RH400',
        blueprint_id: 'regolith_harvester_rover',
        asset_family: 'vehicle',
        component_class: 'harvester',
        catalog_render_path: '/app/data/images/catalog/crafts/ground/rh400_concept.png',
        inventory_icon_path: nil,
        representation_status: 'partial',
        blueprint_data: { 'id' => 'regolith_harvester_rover', 'name' => 'Regolith Harvester Rover' },
        operational_data: { 'power_consumption' => 500, 'payload' => 'regolith' },
        visual_definition: { 'color_profile' => 'orange', 'tech_level' => 3 }
      }
    }

    before do
      allow(@mock_service).to receive(:find_entry).with('crafts/ground/harvesters/regolith_harvester_rover').and_return(rh400_entry)
      allow(@mock_service).to receive(:find_operational_data_by_name).and_return(nil)
      allow(@mock_service).to receive(:catalog_data).with('VEHICLE_HARVESTER_ROVER_RH400').and_return(mock_catalog_contract)
    end

    it 'assigns @catalog_contract for RH-400 entry' do
      get :show, params: { id: 'crafts/ground/harvesters/regolith_harvester_rover' }
      expect(assigns(:catalog_contract)).to be_a(Hash)
      expect(assigns(:catalog_contract)[:asset_id]).to eq('VEHICLE_HARVESTER_ROVER_RH400')
    end

    it 'returns success when catalog contract is present' do
      get :show, params: { id: 'crafts/ground/harvesters/regolith_harvester_rover' }
      expect(response).to have_http_status(:success)
    end

    it 'renders show template with B2 contract fields' do
      get :show, params: { id: 'crafts/ground/harvesters/regolith_harvester_rover' }
      expect(response).to render_template(:show)
    end

    it 'includes catalog_render_path in contract as serving URL' do
      get :show, params: { id: 'crafts/ground/harvesters/regolith_harvester_rover' }
      # The controller converts file paths to URLs for serving through the catalog_image action
      expect(assigns(:catalog_contract)[:catalog_render_path]).to include('/admin/catalog/image/')
      expect(assigns(:catalog_contract)[:catalog_render_path]).to include('rh400_concept.png')
    end

    it 'includes representation_status in contract' do
      get :show, params: { id: 'crafts/ground/harvesters/regolith_harvester_rover' }
      expect(assigns(:catalog_contract)[:representation_status]).to eq('partial')
    end

    it 'includes operational_data for Units (RH-400 is a Vehicle)' do
      get :show, params: { id: 'crafts/ground/harvesters/regolith_harvester_rover' }
      expect(assigns(:catalog_contract)).to have_key(:operational_data)
      expect(assigns(:catalog_contract)[:operational_data]).to be_a(Hash)
    end

    it 'preserves existing entry and cross_ref assignment' do
      get :show, params: { id: 'crafts/ground/harvesters/regolith_harvester_rover' }
      expect(assigns(:entry)).to eq(rh400_entry)
      expect(assigns(:cross_ref)).to be_nil
    end
  end

  # C3 — RH-400 Catalog Image Serving (fallback when AssetRegistry fails)
  describe 'GET #catalog_image' do
    let(:catalog_image_dir) { Pathname.new("/home/galaxy_game/app/data/images/catalog") }
    let(:rh400_concept_image) { "crafts/ground/rh400_concept.png" }

    before do
      # Create a temporary test image file if it doesn't exist
      unless File.exist?(catalog_image_dir.join(rh400_concept_image))
        FileUtils.mkdir_p(catalog_image_dir.join("crafts/ground"))
        FileUtils.touch(catalog_image_dir.join(rh400_concept_image))
      end
    end

    it 'serves a valid catalog image' do
      image_path = "images/catalog/crafts/ground/rh400_concept.png"
      get :catalog_image, params: { path: image_path }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('image')
    end

    it 'rejects path traversal attempts' do
      get :catalog_image, params: { path: '../../etc/passwd' }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for non-existent files' do
      get :catalog_image, params: { path: 'images/catalog/nonexistent.png' }
      expect(response).to have_http_status(:not_found)
    end

    it 'accepts nested paths within catalog directory' do
      image_path = "images/catalog/crafts/ground/rh400_concept.png"
      get :catalog_image, params: { path: image_path }
      # Should not return 404 for valid paths
      expect(response.status).not_to eq(404)
    end
  end
end
