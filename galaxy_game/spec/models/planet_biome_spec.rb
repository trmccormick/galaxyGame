require 'rails_helper'

RSpec.describe PlanetBiome, type: :model do
  let(:biome) { create(:biome) }
  let(:celestial_body) { create(:celestial_body) }

  subject {
    described_class.new(
      biome: biome,
      celestial_body: celestial_body
    )
  }

  # Association tests
  it { should belong_to(:biome) }
  it { should belong_to(:celestial_body) }

  # Validation tests
  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a biome" do
    subject.biome = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a celestial_body" do
    subject.celestial_body = nil
    expect(subject).to_not be_valid
  end
end
