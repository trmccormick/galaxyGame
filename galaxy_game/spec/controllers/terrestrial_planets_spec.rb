require 'rails_helper'

RSpec.describe TerrestrialPlanetsController, type: :controller do
  let(:valid_attributes) { attributes_for(:terrestrial_planet) }
  let(:invalid_attributes) { { name: nil, size: -1.0, gravity: nil, density: nil, orbital_period: nil, mass: nil, surface_temperature: nil, biomes: nil, status: nil } }

  describe "GET #index" do
    it "returns a success response" do
      create(:terrestrial_planet)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      terrestrial_planet = create(:terrestrial_planet)
      get :show, params: { id: terrestrial_planet.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new TerrestrialPlanet" do
        expect {
          post :create, params: { terrestrial_planet: valid_attributes }
        }.to change(TerrestrialPlanet, :count).by(1)
      end

      it "renders a JSON response with the new terrestrial_planet" do
        post :create, params: { terrestrial_planet: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')
        expect(JSON.parse(response.body)['name']).to eq('Earth')
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the new terrestrial_planet" do
        post :create, params: { terrestrial_planet: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Mars", size: 0.532, surface_temperature: 210 } }

      it "updates the requested terrestrial_planet" do
        terrestrial_planet = create(:terrestrial_planet)
        patch :update, params: { id: terrestrial_planet.to_param, terrestrial_planet: new_attributes }
        terrestrial_planet.reload
        expect(terrestrial_planet.name).to eq("Mars")
        expect(terrestrial_planet.size).to eq(0.532)
      end

      it "renders a JSON response with the terrestrial_planet" do
        terrestrial_planet = create(:terrestrial_planet)
        patch :update, params: { id: terrestrial_planet.to_param, terrestrial_planet: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')
        expect(JSON.parse(response.body)['name']).to eq('Mars')
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the terrestrial_planet" do
        terrestrial_planet = create(:terrestrial_planet)
        patch :update, params: { id: terrestrial_planet.to_param, terrestrial_planet: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested terrestrial_planet" do
      terrestrial_planet = create(:terrestrial_planet)
      expect {
        delete :destroy, params: { id: terrestrial_planet.to_param }
      }.to change(TerrestrialPlanet, :count).by(-1)
    end

    it "returns a no content response" do
      terrestrial_planet = create(:terrestrial_planet)
      delete :destroy, params: { id: terrestrial_planet.to_param }
      expect(response).to have_http_status(:no_content)
    end
  end
end

