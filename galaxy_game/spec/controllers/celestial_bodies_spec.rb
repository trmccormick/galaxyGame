require 'rails_helper'

RSpec.describe CelestialBodiesController, type: :controller do
  let(:valid_attributes) {
    {
      name: "Earth",
      size: 1.0,
      gravity: 9.8,
      density: 5.5,
      orbital_period: 365,
      total_pressure: 10.0,
      gas_quantities: { "Nitrogen" => 780800, "Oxygen" => 209500 },
      temperature: -60
    }
  }

  let(:luna) {
    CelestialBodies::Satellites::Moon.create!(
      name: "Luna",
      identifier: "LUNA-01",
      size: 0.273,
      gravity: 1.62,
      density: 3.344,
      mass: 7.342e22,
      radius: 1.737e6,
      orbital_period: 27.322
    )
  }

  describe "GET #show" do
    # it "returns a success response" do
    #   planet = CelestialBody.create! valid_attributes
    #   get :show, params: { id: planet.to_param }
    #   expect(response).to be_successful
    # end

    # it "returns the correct atmospheric composition in JSON" do
    #   planet = CelestialBody.create! valid_attributes
    #   get :show, params: { id: planet.to_param }
      
    #   # Parsing JSON response
    #   json_response = JSON.parse(response.body)

    #   # Calculate expected atmospheric composition
    #   total_gas = valid_attributes[:gas_quantities].values.sum
    #   expected_composition = valid_attributes[:gas_quantities].transform_values do |quantity|
    #     (quantity / total_gas.to_f * 100).round(2)
    #   end

    #   # Verify that the JSON response matches the expected composition
    #   expect(json_response['gas_quantities']).to eq(expected_composition)
    # end
  end

  describe "GET #map" do
    it "renders the map view for a celestial body" do
      get :map, params: { id: luna.to_param }
      expect(response).to be_successful
      expect(response).to render_template(:map)
    end
  end

  describe "GET #geological_features" do
    it "returns geological features as JSON" do
      get :geological_features, params: { id: luna.to_param }, format: :json
      expect(response).to be_successful
      expect(response.content_type).to include('application/json')
      
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('celestial_body')
      expect(json_response).to have_key('lava_tubes')
      expect(json_response).to have_key('craters')
      expect(json_response).to have_key('strategic_sites')
    end

    it "returns celestial body information" do
      get :geological_features, params: { id: luna.to_param }, format: :json
      json_response = JSON.parse(response.body)
      
      expect(json_response['celestial_body']['name']).to eq('Luna')
      expect(json_response['celestial_body']['id']).to eq(luna.id)
    end
  end
end

