require 'rails_helper'

RSpec.describe Market::Settings, type: :model do
  it "can create a settings record" do
    settings = Market::Settings.create(transportation_cost_per_kg: 1.23)
    expect(settings.transportation_cost_per_kg).to eq(1.23)
  end

  it "defaults transportation_cost_per_kg to nil" do
    settings = Market::Settings.create
    expect(settings.transportation_cost_per_kg).to be_nil
  end
end