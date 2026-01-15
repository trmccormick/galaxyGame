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
    
    let!(:mdc) do
      Organizations::BaseOrganization.create!(
        name: 'Mars Development Corporation',
        identifier: 'MDC',
        organization_type: :development_corporation,
        operational_data: { 'is_npc' => true }
      )
    end
    
    let!(:settlement1) { create(:base_settlement, owner: ldc, name: 'Lunar Base Alpha') }
    let!(:settlement2) { create(:base_settlement, owner: mdc, name: 'Mars Outpost One') }
    
    before do
      # Create accounts for DCs (use existing GCC currency)
      gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
        c.name = 'Galactic Credit'
      end
      
      Financial::Account.create!(
        accountable: ldc,
        currency: gcc,
        balance: 1_000_000
      )
      Financial::Account.create!(
        accountable: mdc,
        currency: gcc,
        balance: 2_000_000
      )
    end
    
    it "loads all development corporations" do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:development_corporations)).to include(ldc, mdc)
      expect(assigns(:total_dc_count)).to eq(2)
    end
    
    it "groups settlements by DC owner" do
      get :index
      dc_settlements = assigns(:dc_settlements)
      expect(dc_settlements[ldc.id]).to include(settlement1)
      expect(dc_settlements[mdc.id]).to include(settlement2)
    end
    
    it "counts active contracts" do
      get :index
      expect(assigns(:active_contracts_count)).to be_a(Integer)
    end
  end
end
