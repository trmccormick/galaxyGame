require 'rails_helper'

RSpec.describe CelestialBodies::Spheres::Biosphere, type: :model do
  let(:celestial_body) { create(:celestial_body) }

  subject {
    described_class.new(
      celestial_body: celestial_body
    )
  }

  # Association tests
  it { should belong_to(:celestial_body) }

  # Validation tests
  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a celestial_body" do
    subject.celestial_body = nil
    expect(subject).to_not be_valid
  end

  # Example custom method tests (if any custom methods were added)
  # You can add custom tests here based on your logic
end
