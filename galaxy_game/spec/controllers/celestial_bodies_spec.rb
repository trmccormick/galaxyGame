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
    it "returns a success response" do
      planet = CelestialBody.create! valid_attributes
      get :show, params: { id: planet.to_param }
      expect(response).to be_successful
    end

    it "assigns the correct atmospheric composition" do
      planet = CelestialBody.create! valid_attributes
      get :show, params: { id: planet.to_param }
      expected_composition = {
        "Nitrogen" => (780800 / (780800 + 209500).to_f * 100).round(2),
        "Oxygen" => (209500 / (780800 + 209500).to_f * 100).round(2)
      }
      expect(assigns(:atmospheric_composition)).to eq(expected_composition)
    end
  end
end
