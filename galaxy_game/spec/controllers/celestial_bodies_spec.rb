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
end

