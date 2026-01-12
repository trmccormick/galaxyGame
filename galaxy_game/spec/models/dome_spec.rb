# spec/models/dome_spec.rb
require 'rails_helper'

RSpec.describe Settlement::Dome, type: :model do
  it "calculates used capacity (current occupancy) correctly" do
    dome = Dome.create(name: "Research Dome", capacity: 100, current_occupancy: 50)
    expect(dome.used_capacity).to eq(50)
  end

  it "calculates remaining capacity correctly" do
    dome = Dome.create(name: "Living Dome", capacity: 200, current_occupancy: 50)
    expect(dome.remaining_capacity).to eq(150)
  end

  it "ensures current occupancy does not exceed total capacity" do
    dome = Dome.new(name: "Living Dome", capacity: 100, current_occupancy: 150)
    expect(dome).not_to be_valid
    expect(dome.errors[:current_occupancy]).to include("can't be greater than capacity")
  end
end