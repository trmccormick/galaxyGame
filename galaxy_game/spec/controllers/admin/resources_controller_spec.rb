require 'rails_helper'

RSpec.describe Admin::ResourcesController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns resource management sections" do
      get :index
      expect(assigns(:sections)).to be_an(Array)
      expect(assigns(:sections).length).to eq(3)

      section_names = assigns(:sections).map { |s| s[:name] }
      expect(section_names).to include('Resource Flows')
      expect(section_names).to include('Supply Chains')
      expect(section_names).to include('Market & Economy')
    end

    it "includes section descriptions and paths" do
      get :index
      sections = assigns(:sections)

      sections.each do |section|
        expect(section).to have_key(:name)
        expect(section).to have_key(:path)
        expect(section).to have_key(:description)
        expect(section[:description]).to be_a(String)
        expect(section[:description].length).to be > 0
      end
    end
  end

  describe "GET #flows" do
    it "returns http success" do
      get :flows
      expect(response).to have_http_status(:success)
    end

    it "assigns resource flows data" do
      get :flows
      expect(assigns(:resource_flows)).to be_an(Array)
      expect(assigns(:total_flow_volume)).to be_a(Numeric)
    end
  end

  describe "GET #supply_chains" do
    it "returns http success" do
      get :supply_chains
      expect(response).to have_http_status(:success)
    end

    it "assigns supply chains data" do
      get :supply_chains
      expect(assigns(:supply_chains)).to be_an(Array)
    end
  end

  describe "GET #market" do
    it "returns http success" do
      get :market
      expect(response).to have_http_status(:success)
    end

    it "assigns market data" do
      get :market
      expect(assigns(:market_data)).to be_an(Array)
      expect(assigns(:gcc_exchange_rate)).to be_a(Numeric)
    end
  end
end