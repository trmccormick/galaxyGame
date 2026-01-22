# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SolarSystemsController, type: :controller do
  # Use simpler test data to avoid transaction issues
  let!(:galaxy) { Galaxy.create!(name: 'Test Galaxy', identifier: 'TEST-GLX', galaxy_type: 'spiral') }
  let!(:solar_system) { SolarSystem.create!(name: 'Test System', identifier: 'TEST-SS', galaxy: galaxy) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns @solar_systems' do
      get :index
      expect(assigns(:solar_systems)).to include(solar_system)
    end

    it 'assigns @galaxies' do
      get :index
      expect(assigns(:galaxies)).to include(galaxy)
    end

    it 'assigns @system_stats' do
      get :index
      expect(assigns(:system_stats)).to be_a(Hash)
      expect(assigns(:system_stats)).to have_key(:total_systems)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: solar_system.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @solar_system' do
      get :show, params: { id: solar_system.id }
      expect(assigns(:solar_system)).to eq(solar_system)
    end

    it 'assigns @celestial_bodies' do
      get :show, params: { id: solar_system.id }
      expect(assigns(:celestial_bodies)).to be_an(Array)
    end
  end
end