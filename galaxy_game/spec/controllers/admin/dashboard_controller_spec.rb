require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  describe 'GET #index' do
    it 'assigns AI status' do
      get :index

      expect(assigns(:ai_status)).to be_present
      expect(assigns(:ai_status)[:manager_status]).to eq('online')
      expect(assigns(:ai_status)[:bootstrap_capable]).to be true
    end

    it 'assigns AI activity feed' do
      get :index

      expect(assigns(:ai_activity_feed)).to be_an(Array)
      expect(assigns(:ai_activity_feed).length).to eq(3)
      expect(assigns(:ai_activity_feed).first[:type]).to eq('analysis')
    end

    it 'assigns economic indicators' do
      get :index

      expect(assigns(:economic_indicators)).to be_present
      expect(assigns(:economic_indicators)[:total_gcc]).to eq(0)
      expect(assigns(:economic_indicators)[:usd_balance]).to eq(1000000)
    end

    it 'assigns system statistics' do
      get :index

      expect(assigns(:system_stats)).to be_present
      expect(assigns(:system_stats)[:total_bodies]).to be >= 0
      expect(assigns(:system_stats)[:total_systems]).to be >= 0
    end

    it 'renders the index template' do
      get :index

      expect(response).to render_template(:index)
      expect(response).to have_http_status(:success)
    end
  end
end