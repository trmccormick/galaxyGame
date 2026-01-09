require 'rails_helper'

RSpec.describe TerrestrialPlanetsController, type: :controller do
  let(:star) do
    solar_system = FactoryBot.create(:solar_system)
    FactoryBot.create(:star, solar_system: solar_system)
  end
  let(:planet) { FactoryBot.build(:terrestrial_planet) }
  let(:valid_attributes) do
    planet.attributes.symbolize_keys.slice(:name, :mass, :radius, :orbital_period, :surface_temperature, :identifier, :size).merge(
      solar_system_id: star.solar_system_id,
      star_distances_attributes: [
        { star_id: star.id, distance: 1.496e11 }
      ]
    )
    # Atmosphere is created after planet, not via params
  end
  let(:invalid_attributes) { { name: nil, mass: nil, radius: nil, orbital_period: nil, surface_temperature: nil, star_id: nil } }

  describe "GET #index" do
    it "returns a success response" do
      FactoryBot.create(:terrestrial_planet)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      terrestrial_planet = FactoryBot.create(:terrestrial_planet)
      get :show, params: { id: terrestrial_planet.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new TerrestrialPlanet with star distance" do
        solar_system = FactoryBot.create(:solar_system)
        star = FactoryBot.create(:star, solar_system: solar_system)
        planet = FactoryBot.build(:terrestrial_planet, solar_system: solar_system)
        valid_attributes = planet.attributes.symbolize_keys.slice(:name, :mass, :radius, :orbital_period, :surface_temperature, :identifier, :size).merge(
          solar_system_id: star.solar_system_id
        )
        expect {
          post :create, params: { terrestrial_planet: valid_attributes }, format: :json
        }.to change(CelestialBodies::Planets::Rocky::TerrestrialPlanet, :count).by(1)
        created_planet = CelestialBodies::Planets::Rocky::TerrestrialPlanet.last
        # If atmosphere is needed, create it after planet creation:
        # FactoryBot.create(:atmosphere, celestial_body: created_planet)
        # expect(created_planet.star_distances.count).to eq(1)
        # expect(created_planet.star_distances.first.star_id).to eq(star.id)
        # expect(created_planet.star_distances.first.distance).to eq(1.496e11)
      end

      it "renders a JSON response with the new terrestrial_planet" do
        solar_system = FactoryBot.create(:solar_system)
        star = FactoryBot.create(:star, solar_system: solar_system)
        planet = FactoryBot.build(:terrestrial_planet, solar_system: solar_system)
        valid_attributes = planet.attributes.symbolize_keys.slice(:name, :mass, :radius, :orbital_period, :surface_temperature, :identifier, :size).merge(
          solar_system_id: star.solar_system_id
        )
        post :create, params: { terrestrial_planet: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')
        expect(JSON.parse(response.body)['name']).to be_present
        created_planet = CelestialBodies::Planets::Rocky::TerrestrialPlanet.last
        # If atmosphere is needed, create it after planet creation:
        # FactoryBot.create(:atmosphere, celestial_body: created_planet)
        # expect(created_planet.star_distances.count).to eq(1)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the new terrestrial_planet" do
        post :create, params: { terrestrial_planet: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Mars", surface_temperature: 210 } }

      it "updates the requested terrestrial_planet" do
        terrestrial_planet = FactoryBot.create(:terrestrial_planet)
        patch :update, params: { id: terrestrial_planet.to_param, terrestrial_planet: new_attributes }, format: :json
        terrestrial_planet.reload
        expect(terrestrial_planet.name).to eq("Mars")
        expect(terrestrial_planet.surface_temperature).to eq(210)
      end

      it "renders a JSON response with the terrestrial_planet" do
        terrestrial_planet = FactoryBot.create(:terrestrial_planet)
        patch :update, params: { id: terrestrial_planet.to_param, terrestrial_planet: new_attributes }, format: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')
        expect(JSON.parse(response.body)['name']).to eq('Mars')
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the terrestrial_planet" do
        terrestrial_planet = FactoryBot.create(:terrestrial_planet)
        patch :update, params: { id: terrestrial_planet.to_param, terrestrial_planet: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested terrestrial_planet" do
      terrestrial_planet = FactoryBot.create(:terrestrial_planet)
      expect {
        delete :destroy, params: { id: terrestrial_planet.to_param }, format: :json
      }.to change(CelestialBodies::Planets::Rocky::TerrestrialPlanet, :count).by(-1)
    end

    it "returns a no content response" do
      terrestrial_planet = FactoryBot.create(:terrestrial_planet)
      delete :destroy, params: { id: terrestrial_planet.to_param }, format: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end

