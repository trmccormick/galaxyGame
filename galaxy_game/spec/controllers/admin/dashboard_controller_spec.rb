require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  describe 'GET #index' do

    # -------------------------------------------------------------------------
    # Basic response
    # -------------------------------------------------------------------------

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    # -------------------------------------------------------------------------
    # @system_stats
    # -------------------------------------------------------------------------

    describe '@system_stats' do
      before { get :index }

      it 'is assigned' do
        expect(assigns(:system_stats)).to be_present
      end

      it 'includes uptime' do
        expect(assigns(:system_stats)).to have_key(:uptime)
      end

      it 'does not include total_bodies or total_systems (those belong to galaxy_stats)' do
        expect(assigns(:system_stats)).not_to have_key(:total_bodies)
        expect(assigns(:system_stats)).not_to have_key(:total_systems)
      end
    end

    # -------------------------------------------------------------------------
    # @galaxy_stats
    # -------------------------------------------------------------------------

    describe '@galaxy_stats' do
      before { get :index }

      it 'is assigned' do
        expect(assigns(:galaxy_stats)).to be_present
      end

      it 'includes all required keys' do
        expect(assigns(:galaxy_stats)).to include(
          :total_systems,
          :total_bodies,
          :habitable_bodies,
          :settlements
        )
      end

      it 'has numeric values' do
        stats = assigns(:galaxy_stats)
        expect(stats[:total_systems]).to be >= 0
        expect(stats[:total_bodies]).to be >= 0
        expect(stats[:habitable_bodies]).to be >= 0
        expect(stats[:settlements]).to be >= 0
      end

      it 'does not include usd_balance' do
        expect(assigns(:galaxy_stats)).not_to have_key(:usd_balance)
      end
    end

    # -------------------------------------------------------------------------
    # @ai_status
    # -------------------------------------------------------------------------

    describe '@ai_status' do
      before { get :index }

      it 'is assigned' do
        expect(assigns(:ai_status)).to be_present
      end

      it 'includes all required keys' do
        expect(assigns(:ai_status)).to include(
          :manager_status,
          :bootstrap_capable,
          :learned_patterns,
          :last_decision,
          :active_simulations
        )
      end

      it 'has a valid manager_status' do
        expect(assigns(:ai_status)[:manager_status]).to be_in(%w[online offline])
      end

      it 'has a boolean bootstrap_capable' do
        expect(assigns(:ai_status)[:bootstrap_capable]).to be_in([true, false])
      end

      it 'has a numeric learned_patterns count' do
        expect(assigns(:ai_status)[:learned_patterns]).to be >= 0
      end

      it 'has a numeric active_simulations count' do
        expect(assigns(:ai_status)[:active_simulations]).to be >= 0
      end

      it 'has a last_decision timestamp' do
        expect(assigns(:ai_status)[:last_decision]).to be_a(ActiveSupport::TimeWithZone)
          .or be_a(Time)
      end

      context 'when Sidekiq is unavailable' do
        before do
          allow(Sidekiq::Queue).to receive(:new).and_raise(StandardError, 'Sidekiq down')
        end

        it 'gracefully falls back to 0 simulations' do
          get :index
          expect(assigns(:ai_status)[:active_simulations]).to eq(0)
        end
      end
    end

    # -------------------------------------------------------------------------
    # @economic_indicators
    # -------------------------------------------------------------------------

    describe '@economic_indicators' do
      before { get :index }

      it 'is assigned' do
        expect(assigns(:economic_indicators)).to be_present
      end

      it 'includes all required keys' do
        expect(assigns(:economic_indicators)).to include(
          :total_gcc,
          :minting_rate,
          :active_trades,
          :daily_volume
        )
      end

      it 'has numeric values' do
        indicators = assigns(:economic_indicators)
        expect(indicators[:total_gcc]).to be >= 0
        expect(indicators[:minting_rate]).to be > 0
        expect(indicators[:active_trades]).to be >= 0
        expect(indicators[:daily_volume]).to be >= 0
      end

      it 'does not include usd_balance (NPC-specific metric, not a game-wide stat)' do
        expect(assigns(:economic_indicators)).not_to have_key(:usd_balance)
      end
    end

    # -------------------------------------------------------------------------
    # @network_stats
    # -------------------------------------------------------------------------

    describe '@network_stats' do
      before { get :index }

      it 'is assigned' do
        expect(assigns(:network_stats)).to be_present
      end

      it 'includes all required keys' do
        expect(assigns(:network_stats)).to include(
          :wormholes,
          :connected_systems,
          :isolated_systems
        )
      end

      it 'has numeric values' do
        stats = assigns(:network_stats)
        expect(stats[:wormholes]).to be >= 0
        expect(stats[:connected_systems]).to be >= 0
        expect(stats[:isolated_systems]).to be >= 0
      end
    end

    # -------------------------------------------------------------------------
    # @recent_activity
    # -------------------------------------------------------------------------

    describe '@recent_activity' do
      before { get :index }

      it 'is assigned as an array' do
        expect(assigns(:recent_activity)).to be_an(Array)
      end

      it 'is not empty' do
        expect(assigns(:recent_activity)).not_to be_empty
      end

      it 'each item has required keys' do
        assigns(:recent_activity).each do |activity|
          expect(activity).to have_key(:type)
          expect(activity).to have_key(:message)
          expect(activity).to have_key(:timestamp)
        end
      end

      it 'timestamps are Time objects' do
        assigns(:recent_activity).each do |activity|
          expect(activity[:timestamp]).to be_a(ActiveSupport::TimeWithZone)
            .or be_a(Time)
        end
      end
    end

    # -------------------------------------------------------------------------
    # @ai_activity_feed
    # -------------------------------------------------------------------------

    describe '@ai_activity_feed' do
      before { get :index }

      it 'is assigned as an array' do
        expect(assigns(:ai_activity_feed)).to be_an(Array)
      end

      it 'has the expected number of entries' do
        expect(assigns(:ai_activity_feed).length).to eq(3)
      end

      it 'each item has required keys' do
        assigns(:ai_activity_feed).each do |activity|
          expect(activity).to have_key(:type)
          expect(activity).to have_key(:message)
          expect(activity).to have_key(:details)
          expect(activity).to have_key(:timestamp)
        end
      end

      it 'first item is an analysis type' do
        expect(assigns(:ai_activity_feed).first[:type]).to eq('analysis')
      end

      it 'all types are valid' do
        valid_types = %w[analysis decision idle error warning]
        assigns(:ai_activity_feed).each do |activity|
          expect(activity[:type]).to be_in(valid_types)
        end
      end

      it 'timestamps are Time objects' do
        assigns(:ai_activity_feed).each do |activity|
          expect(activity[:timestamp]).to be_a(ActiveSupport::TimeWithZone)
            .or be_a(Time)
        end
      end
    end

    # -------------------------------------------------------------------------
    # @celestial_bodies
    # -------------------------------------------------------------------------

    describe '@celestial_bodies' do
      before { get :index }

      it 'is assigned' do
        expect(assigns(:celestial_bodies)).not_to be_nil
      end

      it 'is a collection' do
        expect(assigns(:celestial_bodies)).to respond_to(:each)
      end
    end

    # -------------------------------------------------------------------------
    # Error resilience
    # -------------------------------------------------------------------------

    describe 'error resilience' do
      context 'when database is unavailable for galaxy stats' do
        before do
          allow(SolarSystem).to receive(:count).and_raise(StandardError, 'DB error')
        end

        it 'falls back gracefully and still renders' do
          get :index
          expect(response).to have_http_status(:success)
          expect(assigns(:galaxy_stats)[:total_systems]).to eq(0)
        end
      end

      context 'when Wormhole table is unavailable' do
        before do
          allow(Wormhole).to receive(:count).and_raise(StandardError, 'DB error')
        end

        it 'falls back gracefully for network stats' do
          get :index
          expect(response).to have_http_status(:success)
          expect(assigns(:network_stats)[:wormholes]).to eq(0)
        end
      end
    end

  end
end
