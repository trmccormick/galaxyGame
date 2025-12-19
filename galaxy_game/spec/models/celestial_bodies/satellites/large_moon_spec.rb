require 'rails_helper'


RSpec.describe CelestialBodies::Satellites::LargeMoon, type: :model do
  let(:large_moon) { build(:large_moon) }

  it 'is valid with valid attributes' do
    expect(large_moon).to be_valid
  end

  it 'is classified as a large moon' do
    expect(large_moon.radius).to be > 1000000
  end
end
