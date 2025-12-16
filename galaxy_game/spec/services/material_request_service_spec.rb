require 'rails_helper'

RSpec.describe MaterialRequestService, type: :service do
  let(:blueprint) { create(:blueprint, name: "Small Fuel Tank", player: create(:player)) } # Name must match a JSON blueprint and must have a player
  let(:construction_job) { create(:construction_job, blueprint: blueprint) }

  describe ".create_material_requests" do
    it "creates requests for all required materials" do
      MaterialRequestService.create_material_requests(construction_job)
      expect(construction_job.material_requests.count).to eq(4)
    end
  end
end