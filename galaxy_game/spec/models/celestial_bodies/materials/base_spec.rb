# spec/models/celestial_bodies/materials/base_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Materials::Base, type: :model do
  it "inherits from the original Material class" do
    expect(described_class.superclass).to eq(CelestialBodies::Material)
  end
  
  it "uses the materials table" do
    expect(described_class.table_name).to eq('materials')
  end
end