require 'rails_helper'

RSpec.describe StarsController, type: :controller do
  let(:valid_attributes) {
    {
      name: "Sol",
      type_of_star: "sun",
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      temperature: 5778,
      life: 10.0,
      r_ecosphere: 0.8
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,
      type_of_star: nil,
      age: nil,
      mass: nil,
      radius: nil,
      temperature: nil,
      life: nil,
      r_ecosphere: nil
    }
  }

  describe "GET #index" do
    it "returns a success response" do
      Star.create!(valid_attributes)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      star = Star.create!(valid_attributes)
      get :show, params: { id: star.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Star" do
        expect {
          post :create, params: { star: valid_attributes }
        }.to change(Star, :count).by(1)
      end

      it "renders a JSON response with the new star" do
        post :create, params: { star: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Sol')
        expect(json_response['type_of_star']).to eq('sun')
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
        star = Star.create!(valid_attributes)
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
        star = Star.create!(valid_attributes)
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
        star = Star.create!(valid_attributes)
        patch :update, params: { id: star.to_param, star: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested star" do
      star = Star.create!(valid_attributes)
      expect {
        delete :destroy, params: { id: star.to_param }
      }.to change(Star, :count).by(-1)
    end
  end
end
