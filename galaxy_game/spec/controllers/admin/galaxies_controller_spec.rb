# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::GalaxiesController, type: :controller do
  let!(:galaxy) { create(:galaxy) }
  let!(:solar_system) { create(:solar_system, galaxy: galaxy) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns @galaxies' do
      get :index
      expect(assigns(:galaxies)).to include(galaxy)
    end

    it 'assigns @galaxy_stats' do
      get :index
      expect(assigns(:galaxy_stats)).to be_a(Hash)
      expect(assigns(:galaxy_stats)).to have_key(:total_galaxies)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: galaxy.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @galaxy' do
      get :show, params: { id: galaxy.id }
      expect(assigns(:galaxy)).to eq(galaxy)
    end

    it 'assigns @solar_systems' do
      get :show, params: { id: galaxy.id }
      expect(assigns(:solar_systems)).to include(solar_system)
    end
  end
end