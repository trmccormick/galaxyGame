require 'rails_helper'

RSpec.describe StarsController, type: :controller do
  let(:valid_attributes) { attributes_for(:star) }
  let(:invalid_attributes) { { name: nil, type_of_star: nil, identifier: nil, properties: nil } }

  describe "GET #index" do
    it "returns a success response" do
      FactoryBot.create(:star)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      star = FactoryBot.create(:star)
      get :show, params: { id: star.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Star" do
        expect {
          post :create, params: { star: valid_attributes }
        }.to change(CelestialBodies::Star, :count).by(1)
      end

      it "renders a JSON response with the new star" do
        post :create, params: { star: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to be_present
        expect(json_response['type_of_star']).to be_present
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the new star" do
        post :create, params: { star: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          name: "Betelgeuse",
          type_of_star: "supergiant",
          age: 8.0,
          mass: 2.0e30,
          radius: 1.5e8,
          temperature: 3500,
          life: 12.0,
          r_ecosphere: 1.0
        }
      }

      it "updates the requested star" do
        star = FactoryBot.create(:star)
        patch :update, params: { id: star.to_param, star: new_attributes }
        star.reload
        puts star.inspect  # Print updated star for debugging
        expect(star.name).to eq("Betelgeuse")
        expect(star.type_of_star).to eq("supergiant")
        expect(star.age).to eq(8.0)
        expect(star.mass).to eq(2.0e30)
        expect(star.radius).to eq(1.5e8)
        expect(star.temperature).to eq(3500)
        expect(star.life).to eq(12.0)
        expect(star.r_ecosphere).to eq(1.0)
      end

      it "renders a JSON response with the star" do
        star = FactoryBot.create(:star)
        patch :update, params: { id: star.to_param, star: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Betelgeuse')
        expect(json_response['type_of_star']).to eq('supergiant')
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the star" do
        star = FactoryBot.create(:star)
        patch :update, params: { id: star.to_param, star: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested star" do
      star = FactoryBot.create(:star)
      expect {
        delete :destroy, params: { id: star.to_param }
      }.to change(CelestialBodies::Star, :count).by(-1)
    end
  end
end
