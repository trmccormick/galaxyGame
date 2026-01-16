require 'rails_helper'

RSpec.describe Admin::DevelopmentCorporationsController, type: :controller do
  describe "GET #index" do
    let!(:ldc) do
      Organizations::BaseOrganization.create!(
        name: 'Lunar Development Corporation',
        identifier: 'LDC',
        organization_type: :development_corporation,
        operational_data: { 'is_npc' => true }
      )
    end
    
    let!(:astrolift) do
      Organizations::BaseOrganization.create!(
        name: 'AstroLift',
        identifier: 'ASTROLIFT',
        organization_type: :corporation,
        operational_data: { 'is_npc' => true, 'specialization' => 'orbital_logistics' }
      )
    end
    
    let!(:consortium) do
      Organizations::BaseOrganization.create!(
        name: 'Wormhole Transit Consortium',
        identifier: 'WH-CONSORTIUM',
        organization_type: :consortium
      )
    end
    
    let!(:settlement1) { create(:base_settlement, owner: ldc, name: 'Lunar Base Alpha') }
    let!(:settlement2) { create(:base_settlement, owner: astrolift, name: 'LEO Depot One') }
    
    before do
      # Create accounts for organizations (use existing GCC currency)
      gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
        c.name = 'Galactic Credit'
      end
      
      Financial::Account.create!(
        accountable: ldc,
        currency: gcc,
        balance: 1_000_000
      )
      Financial::Account.create!(
        accountable: astrolift,
        currency: gcc,
        balance: 500_000
      )
      Financial::Account.create!(
        accountable: consortium,
        currency: gcc,
        balance: 10_000_000
      )
    end
    
    it "loads NPC organizations" do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:npc_organizations)).to include(ldc, astrolift)
      expect(assigns(:total_npc_count)).to eq(2)
    end
    
    it "loads player organizations" do
      # Create a player corporation
      player_corp = Organizations::BaseOrganization.create!(
        name: 'Player Enterprises',
        identifier: 'PLAYER-ENT',
        organization_type: :corporation,
        operational_data: { 'is_npc' => false }
      )
      
      get :index
      expect(assigns(:player_organizations)).to include(player_corp)
      expect(assigns(:total_player_count)).to eq(1)
    end
    
    it "loads consortiums" do
      get :index
      expect(assigns(:consortiums)).to include(consortium)
      expect(assigns(:total_consortium_count)).to eq(1)
    end
    
    it "groups settlements by organization owner" do
      get :index
      settlements_by_org = assigns(:settlements_by_org)
      expect(settlements_by_org[ldc.id]).to include(settlement1)
      expect(settlements_by_org[astrolift.id]).to include(settlement2)
    end
    
    it "counts active contracts" do
      get :index
      expect(assigns(:active_contracts_count)).to be_a(Integer)
    end
  end
end
